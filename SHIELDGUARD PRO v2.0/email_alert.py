import os
import json
import argparse
import smtplib
from datetime import datetime
from email.mime.text import MIMEText

LOG_DIR = 'logs'
EMAIL_LOG = os.path.join(LOG_DIR, 'emails_sent.log')


def send_email(subject: str, body: str) -> None:
    with open('config.json', 'r', encoding='utf-8') as f:
        config = json.load(f)

    msg = MIMEText(body)
    msg['Subject'] = subject
    msg['From'] = config['email']
    msg['To'] = config['to_email']

    with smtplib.SMTP_SSL('smtp.gmail.com', 465) as server:
        server.login(config['email'], config['app_password'])
        server.send_message(msg)

    os.makedirs(LOG_DIR, exist_ok=True)
    with open(EMAIL_LOG, 'a', encoding='utf-8') as f:
        f.write(f"{datetime.utcnow().isoformat()}Z | {subject} -> {msg['To']}\n")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--type', required=False)
    parser.add_argument('--ip', required=False)
    parser.add_argument('--daemon', action='store_true', help='Idle process to keep container alive if desired')
    args = parser.parse_args()

    if args.daemon:
        # Keep the container up if used as a sidecar; no-op loop
        try:
            while True:
                import time
                time.sleep(3600)
        except KeyboardInterrupt:
            return

    if not args.type or not args.ip:
        print('No email sent: --type and --ip are required unless --daemon is used')
        return

    body = f"ALERTA SHIELDGUARD PRO\nTipo: {args.type}\nIP: {args.ip}\nHora: {datetime.utcnow().isoformat()}Z"
    send_email(f"Ataque Detectado: {args.type}", body)


if __name__ == '__main__':
    main()


