Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "Deteniendo servicios SHIELDGUARD PRO..." -ForegroundColor Cyan

try {
    docker compose down
} catch {
    docker-compose down
}

Write-Host "Servicios detenidos." -ForegroundColor Green


