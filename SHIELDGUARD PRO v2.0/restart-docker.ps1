Write-Host "Reiniciando Docker Desktop y servicios SHIELDGUARD PRO..." -ForegroundColor Cyan

# Cerrar Docker Desktop si está corriendo
Write-Host "Cerrando Docker Desktop..." -ForegroundColor Yellow
Get-Process "Docker Desktop" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3

# Iniciar Docker Desktop
Write-Host "Iniciando Docker Desktop..." -ForegroundColor Yellow
$dockerPath = "$env:ProgramFiles\Docker\Docker\Docker Desktop.exe"
if (Test-Path $dockerPath) {
    Start-Process $dockerPath
    Write-Host "Esperando a que Docker Desktop inicie (esto puede tardar 30-60 segundos)..." -ForegroundColor Yellow
    
    # Esperar a que Docker esté listo (máximo 2 minutos)
    $timeout = 120
    $elapsed = 0
    $dockerReady = $false
    
    while ($elapsed -lt $timeout -and -not $dockerReady) {
        Start-Sleep -Seconds 5
        $elapsed += 5
        try {
            $null = docker ps 2>&1
            if ($LASTEXITCODE -eq 0) {
                $dockerReady = $true
                Write-Host "Docker Desktop está listo!" -ForegroundColor Green
            }
        } catch {
            Write-Host "." -NoNewline
        }
    }
    
    if (-not $dockerReady) {
        Write-Host "`nDocker Desktop tardó demasiado en iniciar. Por favor, verifica manualmente." -ForegroundColor Yellow
        Write-Host "Cuando Docker Desktop esté listo, ejecuta: .\start.ps1" -ForegroundColor Yellow
        exit 1
    }
} else {
    Write-Host "No se encontró Docker Desktop en la ruta esperada." -ForegroundColor Red
    Write-Host "Por favor, inicia Docker Desktop manualmente." -ForegroundColor Yellow
    exit 1
}

# Iniciar servicios
Write-Host "Iniciando servicios SHIELDGUARD PRO..." -ForegroundColor Cyan
& ".\start.ps1"
