from datetime import datetime
import os
import json
import sys

LOG_DIR = 'logs'
NET_LOG_FILE = os.path.join(LOG_DIR, 'network_events.jsonl')


def ensure_dirs():
    os.makedirs(LOG_DIR, exist_ok=True)


def log_json_line(path: str, payload: dict) -> None:
    with open(path, 'a', encoding='utf-8') as f:
        json.dump(payload, f, ensure_ascii=False)
        f.write('\n')


def main():
    ensure_dirs()
    # Lazy import to avoid needing scapy in environments where monitor is not used
    try:
        from scapy.all import sniff, TCP, IP, ICMP
    except Exception as e:
        print(f"Scapy import error: {e}")
        sys.exit(1)

    def handler(pkt):
        try:
            src = pkt[IP].src if IP in pkt else 'unknown'
            dst = pkt[IP].dst if IP in pkt else 'unknown'

            event_type = None
            details = {}

            if TCP in pkt:
                flags = pkt[TCP].flags
                dport = int(pkt[TCP].dport)
                if flags & 0x02:  # SYN
                    event_type = 'tcp_syn'
                    details = {'dport': dport}
                    # Trigger alert on interesting ports
                    if dport in (22, 80, 443, 2222):
                        os.system(f"python3 email_alert.py --type suspicious --ip {src} &")
            elif ICMP in pkt:
                event_type = 'icmp'

            if event_type:
                log_json_line(NET_LOG_FILE, {
                    'timestamp': datetime.utcnow().isoformat() + 'Z',
                    'src': src,
                    'dst': dst,
                    'type': event_type,
                    'details': details,
                })
        except Exception:
            pass

    # Use a broad filter; requires CAP_NET_RAW
    sniff(filter="ip", prn=handler, store=False)


if __name__ == '__main__':
    main()


