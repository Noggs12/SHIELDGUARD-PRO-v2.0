Write-Host "Iniciando servidor Flask para dashboard (sin Docker)..." -ForegroundColor Cyan

# Verificar que Python está instalado
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "Python no está instalado o no está en PATH." -ForegroundColor Red
    exit 1
}

# Crear directorio de logs si no existe
if (-not (Test-Path "logs")) {
    New-Item -ItemType Directory -Path "logs" | Out-Null
}

# Verificar e instalar dependencias si es necesario
Write-Host "Verificando dependencias..." -ForegroundColor Yellow
$ErrorActionPreferenceBackup = $ErrorActionPreference
$ErrorActionPreference = 'SilentlyContinue'
$null = python -c "import flask" 2>&1
$flaskInstalled = ($LASTEXITCODE -eq 0)
$ErrorActionPreference = $ErrorActionPreferenceBackup

if (-not $flaskInstalled) {
    Write-Host "Instalando Flask..." -ForegroundColor Yellow
    python -m pip install flask --quiet
}

# Cambiar al directorio del script
Set-Location $PSScriptRoot

Write-Host "Servidor iniciando en http://localhost:5000/dashboard.html" -ForegroundColor Green
Write-Host "Presiona Ctrl+C para detener" -ForegroundColor Yellow

# Ejecutar Flask en puerto 5000 (no requiere permisos de administrador)
$env:PORT = "5000"
python honeypot-http.py
