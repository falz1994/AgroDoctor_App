@echo off
echo ===================================
echo Creando un repositorio Git limpio
echo ===================================

echo.
echo Paso 1: Crear un directorio temporal...
mkdir temp_repo

echo.
echo Paso 2: Copiar archivos necesarios (excluyendo archivos grandes y .git)...
xcopy /E /I /Y /EXCLUDE:exclusiones.txt . temp_repo

echo.
echo Paso 3: Inicializar un nuevo repositorio Git...
cd temp_repo
git init
git add .
git commit -m "Primer commit - Repositorio limpio"

echo.
echo Paso 4: Configurar el repositorio remoto...
git remote add origin https://github.com/falz1994/AgroDoctor_App.git

echo.
echo Paso 5: Hacer push forzado al repositorio remoto...
git push -f origin main

echo.
echo Repositorio limpio creado y subido correctamente!
echo ===================================
