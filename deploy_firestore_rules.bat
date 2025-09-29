@echo off
echo Desplegando reglas de Firestore actualizadas...
echo.

REM Verificar si Firebase CLI está instalado
firebase --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Firebase CLI no está instalado.
    echo Por favor instala Firebase CLI ejecutando: npm install -g firebase-tools
    pause
    exit /b 1
)

echo Firebase CLI encontrado.
echo.

REM Verificar si el usuario está autenticado
firebase projects:list >nul 2>&1
if %errorlevel% neq 0 (
    echo Iniciando sesión en Firebase...
    firebase login
    if %errorlevel% neq 0 (
        echo ERROR: No se pudo iniciar sesión en Firebase.
        pause
        exit /b 1
    )
)

echo Usuario autenticado en Firebase.
echo.

REM Desplegar solo las reglas de Firestore
echo Desplegando reglas de Firestore...
firebase deploy --only firestore:rules

if %errorlevel% equ 0 (
    echo.
    echo ¡ÉXITO! Las reglas de Firestore se han desplegado correctamente.
    echo.
    echo Las nuevas reglas incluyen:
    echo - Acceso a la colección 'users' para usuarios autenticados
    echo - Permisos para el panel de administración
    echo - Reglas de seguridad mejoradas
) else (
    echo.
    echo ERROR: No se pudieron desplegar las reglas de Firestore.
    echo Verifica tu conexión a internet y los permisos del proyecto.
)

echo.
pause
