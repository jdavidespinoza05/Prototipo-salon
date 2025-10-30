# Script para detener el sistema completo del Salón de Belleza
# Ejecutar con: .\stop-system.ps1

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Sistema de Salón de Belleza - Detener Servicios" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Detener procesos de Node.js (Backend y Frontend)
Write-Host "1. Deteniendo procesos de Node.js..." -ForegroundColor Yellow
$nodeProcesses = Get-Process node -ErrorAction SilentlyContinue
if ($nodeProcesses) {
    $nodeProcesses | ForEach-Object {
        Write-Host "   → Deteniendo proceso Node.js (PID: $($_.Id))" -ForegroundColor Cyan
        Stop-Process -Id $_.Id -Force
    }
    Write-Host "   ✓ Procesos Node.js detenidos" -ForegroundColor Green
} else {
    Write-Host "   ℹ No hay procesos Node.js corriendo" -ForegroundColor Gray
}
Write-Host ""

# Detener Oracle Database
Write-Host "2. Deteniendo Oracle Database..." -ForegroundColor Yellow
Set-Location "salon-beauty-app\database"
docker-compose down
if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✓ Oracle detenido correctamente" -ForegroundColor Green
} else {
    Write-Host "   ⚠ No se pudo detener Oracle (puede que no esté corriendo)" -ForegroundColor Yellow
}
Write-Host ""

# Volver a la raíz
Set-Location "..\..\"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  ✓ Sistema detenido correctamente!              " -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Para volver a iniciar el sistema, ejecuta:" -ForegroundColor Cyan
Write-Host "   .\start-system.ps1" -ForegroundColor White
Write-Host ""
