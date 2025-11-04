from flask import Flask, request, send_from_directory, jsonify
from datetime import datetime
import os
import json

app = Flask(__name__)

LOG_DIR = 'logs'
HTTP_LOG_FILE = os.path.join(LOG_DIR, 'http_events.jsonl')


def ensure_dirs():
    os.makedirs(LOG_DIR, exist_ok=True)


def log_json_line(path: str, payload: dict) -> None:
    with open(path, 'a', encoding='utf-8') as f:
        json.dump(payload, f, ensure_ascii=False)
        f.write('\n')


@app.route('/', methods=['GET', 'POST'])
def fake_login():
    ensure_dirs()
    if request.method == 'POST':
        username = request.form.get('username', '')
        password = request.form.get('password', '')
        event = {
            'timestamp': datetime.utcnow().isoformat() + 'Z',
            'ip': request.remote_addr,
            'path': request.path,
            'username': username,
            'password': password,
            'type': 'http_login_attempt'
        }
        log_json_line(HTTP_LOG_FILE, event)
        os.system(f"python3 email_alert.py --type http --ip {request.remote_addr} &")
        return 'OK', 200

    return (
        '<!DOCTYPE html><html><head><title>Login</title></head><body>'
        '<h1>Servicio Corporativo</h1>'
        '<form method="post">'
        'Usuario: <input name="username" /><br />'
        'Clave: <input type="password" name="password" /><br />'
        '<button type="submit">Entrar</button>'
        '</form>'
        '</body></html>'
    )


@app.route('/dashboard.html')
def dashboard():
    return send_from_directory('.', 'dashboard.html')


@app.route('/logs/<name>')
def read_logs(name: str):
    ensure_dirs()
    # name safety: only expose known files
    allowed = {
        'http': HTTP_LOG_FILE,
        'ssh': os.path.join(LOG_DIR, 'ssh_attacks.jsonl'),
        'emails': os.path.join(LOG_DIR, 'emails_sent.log'),
        'network': os.path.join(LOG_DIR, 'network_events.jsonl'),
        'blocked': os.path.join(LOG_DIR, 'blocked_ips.txt'),
    }
    path = allowed.get(name)
    if not path or not os.path.exists(path):
        return jsonify({'ok': True, 'lines': []})
    with open(path, 'r', encoding='utf-8', errors='ignore') as f:
        lines = f.read().splitlines()[-200:]
    return jsonify({'ok': True, 'lines': lines})


if __name__ == '__main__':
    ensure_dirs()
    port = int(os.getenv('PORT', '80'))
    app.run(host='0.0.0.0', port=port)


