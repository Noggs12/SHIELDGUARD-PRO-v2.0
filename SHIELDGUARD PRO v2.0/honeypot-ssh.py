import os
import json
import socket
import threading
from datetime import datetime

import paramiko


LOG_DIR = 'logs'
BLOCKED_IPS_FILE = os.path.join(LOG_DIR, 'blocked_ips.txt')
SSH_LOG_FILE = os.path.join(LOG_DIR, 'ssh_attacks.jsonl')
HOST = '0.0.0.0'
PORT = 2222  # bind non-privileged in container, published as 2222 by compose
HOST_KEY_PATH = 'ssh_host_rsa.key'


def ensure_dirs():
    os.makedirs(LOG_DIR, exist_ok=True)


def persist_host_key():
    if not os.path.exists(HOST_KEY_PATH):
        key = paramiko.RSAKey.generate(2048)
        key.write_private_key_file(HOST_KEY_PATH)
    return paramiko.RSAKey(filename=HOST_KEY_PATH)


def log_json_line(path: str, payload: dict) -> None:
    with open(path, 'a', encoding='utf-8') as f:
        json.dump(payload, f, ensure_ascii=False)
        f.write('\n')


class SSHHoneypot(paramiko.ServerInterface):
    def __init__(self, transport: paramiko.Transport):
        super().__init__()
        self.transport = transport
        self.event = threading.Event()

    def check_channel_request(self, kind, chanid):
        if kind == 'session':
            return paramiko.OPEN_SUCCEEDED
        return paramiko.OPEN_FAILED_ADMINISTRATIVELY_PROHIBITED

    def check_auth_password(self, username, password):
        try:
            peer = self.transport.getpeername()
            ip = peer[0] if isinstance(peer, tuple) else str(peer)
        except Exception:
            ip = 'unknown'

        log = {
            'timestamp': datetime.utcnow().isoformat() + 'Z',
            'username': username,
            'password': password,
            'ip': ip,
            'type': 'ssh_bruteforce'
        }

        log_json_line(SSH_LOG_FILE, log)

        # Attempt to block offending IP inside container (requires NET_ADMIN)
        try:
            os.system(f"iptables -A INPUT -s {ip} -p tcp --dport {PORT} -j DROP")
            with open(BLOCKED_IPS_FILE, 'a', encoding='utf-8') as b:
                b.write(f"{ip}\n")
        except Exception:
            pass

        # Fire and forget email alert
        try:
            os.system(f"python3 email_alert.py --type ssh --ip {ip} &")
        except Exception:
            pass

        return paramiko.AUTH_FAILED


def handle_client(client_socket: socket.socket):
    transport = paramiko.Transport(client_socket)
    transport.add_server_key(persist_host_key())
    server = SSHHoneypot(transport)
    try:
        transport.start_server(server=server)
        chan = transport.accept(20)
        if chan is not None:
            server.event.wait(5)
            try:
                chan.close()
            except Exception:
                pass
    except Exception:
        pass
    finally:
        try:
            transport.close()
        except Exception:
            pass


def main():
    ensure_dirs()
    srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    srv.bind((HOST, PORT))
    srv.listen(100)
    print(f"SSH Honeypot activo en puerto {PORT}...")
    while True:
        client, _ = srv.accept()
        t = threading.Thread(target=handle_client, args=(client,))
        t.daemon = True
        t.start()


if __name__ == '__main__':
    main()


