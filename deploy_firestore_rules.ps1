# Script de PowerShell para desplegar reglas de Firestore
Write-Host "Desplegando reglas de Firestore actualizadas..." -ForegroundColor Green
Write-Host ""

# Verificar si Firebase CLI está instalado
try {
    $firebaseVersion = firebase --version 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Firebase CLI no encontrado"
    }
    Write-Host "Firebase CLI encontrado: $firebaseVersion" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Firebase CLI no está instalado." -ForegroundColor Red
    Write-Host "Por favor instala Firebase CLI ejecutando: npm install -g firebase-tools" -ForegroundColor Yellow
    Read-Host "Presiona Enter para continuar"
    exit 1
}

Write-Host ""

# Verificar si el usuario está autenticado
try {
    firebase projects:list 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "No autenticado"
    }
    Write-Host "Usuario autenticado en Firebase." -ForegroundColor Green
} catch {
    Write-Host "Iniciando sesión en Firebase..." -ForegroundColor Yellow
    firebase login
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: No se pudo iniciar sesión en Firebase." -ForegroundColor Red
        Read-Host "Presiona Enter para continuar"
        exit 1
    }
}

Write-Host ""

# Desplegar solo las reglas de Firestore
Write-Host "Desplegando reglas de Firestore..." -ForegroundColor Yellow
firebase deploy --only firestore:rules

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "¡ÉXITO! Las reglas de Firestore se han desplegado correctamente." -ForegroundColor Green
    Write-Host ""
    Write-Host "Las nuevas reglas incluyen:" -ForegroundColor Cyan
    Write-Host "- Acceso a la colección 'users' para usuarios autenticados" -ForegroundColor White
    Write-Host "- Permisos para el panel de administración" -ForegroundColor White
    Write-Host "- Reglas de seguridad mejoradas" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "ERROR: No se pudieron desplegar las reglas de Firestore." -ForegroundColor Red
    Write-Host "Verifica tu conexión a internet y los permisos del proyecto." -ForegroundColor Yellow
}

Write-Host ""
Read-Host "Presiona Enter para continuar"
