# Script para probar el login via API
# Útil para demostrar que el backend funciona correctamente

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   PROBANDO LOGIN - SISTEMA SALON DE BELLEZA" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Datos del login
$correo = "admin@salon.com"
$password = "admin123"

Write-Host "[1/3] Probando login con:" -ForegroundColor Yellow
Write-Host "  Correo: $correo"
Write-Host "  Contraseña: $password"
Write-Host ""

# Preparar el body JSON
$body = @{
    correo = $correo
    password = $password
} | ConvertTo-Json

Write-Host "[2/3] Enviando petición POST a http://localhost:3000/api/auth/login..." -ForegroundColor Yellow
Write-Host ""

try {
    $response = Invoke-RestMethod -Uri "http://localhost:3000/api/auth/login" `
                                  -Method POST `
                                  -ContentType "application/json" `
                                  -Body $body

    Write-Host "[3/3] LOGIN EXITOSO!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Datos del administrador:" -ForegroundColor Cyan
    Write-Host "  ID: $($response.admin.id_admin)"
    Write-Host "  Nombre: $($response.admin.nombre)"
    Write-Host "  Correo: $($response.admin.correo)"
    Write-Host "  Activo: $($response.admin.activo)"
    Write-Host "  Fecha Creación: $($response.admin.fecha_creacion)"
    Write-Host "  Último Acceso: $($response.admin.ultimo_acceso)"
    Write-Host ""
    Write-Host "Token JWT generado:" -ForegroundColor Cyan
    Write-Host "  $($response.token.Substring(0, 50))..." -ForegroundColor Gray
    Write-Host ""
    Write-Host "El token expira en: 8 horas" -ForegroundColor Yellow

} catch {
    Write-Host "[3/3] ERROR EN LOGIN!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Detalles del error:" -ForegroundColor Red
    Write-Host $_.Exception.Message
    Write-Host ""
    Write-Host "Verifica que:" -ForegroundColor Yellow
    Write-Host "  1. El backend esté corriendo (cd salon-beauty-app\backend && npm start)"
    Write-Host "  2. Oracle esté corriendo (cd salon-beauty-app\database && docker-compose ps)"
    Write-Host "  3. El correo y contraseña sean correctos"
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
