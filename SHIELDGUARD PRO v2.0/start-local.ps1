Write-Host "Iniciando SHIELDGUARD PRO localmente (sin Docker)..." -ForegroundColor Cyan

# Verificar que Python está instalado
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "Python no está instalado o no está en PATH." -ForegroundColor Red
    exit 1
}

# Verificar Flask
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

# Crear directorio de logs si no existe
if (-not (Test-Path "logs")) {
    New-Item -ItemType Directory -Path "logs" | Out-Null
}

# Verificar si tenemos permisos de administrador para usar puerto 80
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "`nADVERTENCIA: El puerto 80 requiere permisos de administrador." -ForegroundColor Yellow
    Write-Host "Ejecutando en puerto 5000 como alternativa..." -ForegroundColor Yellow
    Write-Host "Accede a: http://localhost:5000/dashboard.html" -ForegroundColor Green
    Write-Host "`nPara usar el puerto 80, ejecuta PowerShell como Administrador y ejecuta:" -ForegroundColor Yellow
    Write-Host "  .\start-local.ps1" -ForegroundColor Cyan
    $env:PORT = "5000"
} else {
    Write-Host "Iniciando servidor en puerto 80..." -ForegroundColor Green
    Write-Host "Accede a: http://localhost/dashboard.html" -ForegroundColor Green
    $env:PORT = "80"
}

Write-Host "`nPresiona Ctrl+C para detener el servidor" -ForegroundColor Yellow
Write-Host ""

# Ejecutar Flask
python honeypot-http.py
