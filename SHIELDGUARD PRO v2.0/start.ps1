Write-Host "Levantando servicios SHIELDGUARD PRO..." -ForegroundColor Cyan

# Verificar si Docker está disponible
$dockerAvailable = $false
$ErrorActionPreferenceBackup = $ErrorActionPreference
$ErrorActionPreference = 'SilentlyContinue'

try {
    $null = docker ps 2>&1
    if ($LASTEXITCODE -eq 0) {
        $dockerAvailable = $true
    }
} catch {
    $dockerAvailable = $false
}

$ErrorActionPreference = $ErrorActionPreferenceBackup

if (-not $dockerAvailable) {
    Write-Host "`nDocker Desktop no está disponible o no está funcionando." -ForegroundColor Yellow
    Write-Host "Usando modo local (sin Docker)..." -ForegroundColor Cyan
    Write-Host ""
    
    # Ejecutar start-local.ps1
    & ".\start-local.ps1"
    exit
}

# Si Docker está disponible, usar docker compose
try {
    docker compose up -d
    Write-Host "Servicios iniciados con Docker. Dashboard en http://localhost/dashboard.html" -ForegroundColor Green
} catch {
    try {
        docker-compose up -d
        Write-Host "Servicios iniciados con Docker. Dashboard en http://localhost/dashboard.html" -ForegroundColor Green
    } catch {
        Write-Host "Error al iniciar servicios con Docker. Intentando modo local..." -ForegroundColor Yellow
        & ".\start-local.ps1"
    }
}


