# SHIELDGUARD PRO v2.0

Docker + SSH Honeypot + Email Alerts + Logs en JSON

## Servicios
- honeypot-http: señuelo web (Flask) + dashboard
- honeypot-ssh: servidor SSH falso con bloqueo de IP (iptables)
- monitor: análisis de red (Scapy), genera eventos y dispara alertas
- email-sender: contenedor utilitario para mantener SMTP disponible (opcional)

## Requisitos
- Docker y Docker Compose (en Linux: `install.sh`)
- Para Gmail: activar 2FA y generar App Password

## Estructura
```
.
├─ docker-compose.yml
├─ Dockerfile
├─ honeypot-http.py
├─ honeypot-ssh.py
├─ monitor.py
├─ email_alert.py
├─ dashboard.html
├─ install.sh / start.sh / stop.sh
├─ config.json
└─ logs/
```

## Configurar email
Edita `config.json`:
```json
{
  "email": "tuemail@gmail.com",
  "app_password": "tu_app_password_gmail",
  "to_email": "admin@empresa.com"
}
```

## Construir e iniciar
```bash
./install.sh
./start.sh
```
O manualmente:
```bash
docker compose build
docker compose up -d
```

## Windows (PowerShell)
Desde PowerShell en la carpeta del proyecto:
```powershell
./install.ps1
./start.ps1
```
Para detener:
```powershell
./stop.ps1
```

## Acceso
- Dashboard: http://TU_IP/dashboard.html
- SSH Honeypot: puerto 2222 (mapea al contenedor)

Si necesitas usar el puerto 22 del host, ajusta `docker-compose.yml` y `honeypot-ssh.py` bajo tu responsabilidad (puede colisionar con el SSH real del host).

## Logs
- `logs/http_events.jsonl` – intentos de login web
- `logs/ssh_attacks.jsonl` – intentos SSH
- `logs/network_events.jsonl` – eventos de red (SYN/ICMP)
- `logs/emails_sent.log` – auditoría de emails
- `logs/blocked_ips.txt` – IPs bloqueadas por iptables

Todos visibles en el dashboard. Formato JSONL listo para ELK.

## Parar
```bash
./stop.sh
```

## Notas
- Los contenedores `honeypot-ssh` y `monitor` requieren capacidades de red (`NET_ADMIN`, `NET_RAW`).
- En Windows necesitas Docker Desktop; los scripts `.sh` son para Linux. En Windows usa `docker compose` desde PowerShell.



