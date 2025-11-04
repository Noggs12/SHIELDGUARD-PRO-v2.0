# Requires: Docker Desktop with WSL 2 engine
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "Instalando SHIELDGUARD PRO para Windows..." -ForegroundColor Cyan

# Verificar Docker
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "Docker no está instalado o no está en PATH. Instala Docker Desktop y vuelve a intentar." -ForegroundColor Red
    exit 1
}

# Verificar docker compose (plugin integrado)
$composeOk = $false
try {
    docker compose version *> $null
    $composeOk = $true
} catch {
    # Intentar docker-compose clásico
    if (Get-Command docker-compose -ErrorAction SilentlyContinue) {
        $composeOk = $true
    }
}

if (-not $composeOk) {
    Write-Host "No se detectó 'docker compose' ni 'docker-compose'. Actualiza Docker Desktop." -ForegroundColor Red
    exit 1
}

Write-Host "Construyendo imágenes..." -ForegroundColor Yellow
try {
    docker compose build
} catch {
    docker-compose build
}

Write-Host "¡Listo! Ejecuta: .\\start.ps1 para levantar los servicios." -ForegroundColor Green


