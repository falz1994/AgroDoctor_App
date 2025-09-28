Write-Host "===================================" -ForegroundColor Cyan
Write-Host "Creando un repositorio Git limpio" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan

Write-Host "`nPaso 1: Crear un directorio temporal..." -ForegroundColor Yellow
New-Item -Path "temp_repo" -ItemType Directory -Force | Out-Null

Write-Host "`nPaso 2: Copiar archivos necesarios (excluyendo archivos grandes y .git)..." -ForegroundColor Yellow
$excludePatterns = @(
    ".git",
    ".dart_tool",
    "build",
    "android\.gradle",
    "docs\canvaskit\canvaskit.wasm",
    "docs\canvaskit\chromium\canvaskit.wasm",
    "docs\canvaskit\skwasm_heavy.wasm",
    "docs\main.dart.js",
    "docs\canvaskit\skwasm.wasm",
    "docs\assets\NOTICES",
    "docs\canvaskit\skwasm_heavy.js.symbols",
    "docs\canvaskit\skwasm.js.symbols",
    "docs\canvaskit\canvaskit.js.symbols",
    "docs\canvaskit\chromium\canvaskit.js.symbols",
    "ia-model\*.h5"
)

Get-ChildItem -Path "." -Recurse -Force | 
    Where-Object { 
        $item = $_
        $exclude = $false
        foreach ($pattern in $excludePatterns) {
            if ($item.FullName -like "*$pattern*") {
                $exclude = $true
                break
            }
        }
        -not $exclude
    } | 
    ForEach-Object {
        $targetPath = $_.FullName.Replace($PWD.Path, "$PWD\temp_repo")
        if (-not (Test-Path (Split-Path -Parent $targetPath))) {
            New-Item -Path (Split-Path -Parent $targetPath) -ItemType Directory -Force | Out-Null
        }
        if (-not $_.PSIsContainer) {
            Copy-Item -Path $_.FullName -Destination $targetPath -Force
        }
    }

Write-Host "`nPaso 3: Inicializar un nuevo repositorio Git..." -ForegroundColor Yellow
Set-Location -Path "temp_repo"
git init
git add .
git commit -m "Primer commit - Repositorio limpio"

Write-Host "`nPaso 4: Configurar el repositorio remoto..." -ForegroundColor Yellow
git remote add origin https://github.com/falz1994/AgroDoctor_App.git

Write-Host "`nPaso 5: Hacer push forzado al repositorio remoto..." -ForegroundColor Yellow
git push -f origin main

Write-Host "`nRepositorio limpio creado y subido correctamente!" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Cyan
