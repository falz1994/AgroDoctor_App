Write-Host "===================================" -ForegroundColor Cyan
Write-Host "Flutter Web Build for GitHub Pages" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan

Write-Host "`nStep 1: Cleaning previous build..." -ForegroundColor Yellow
flutter clean

Write-Host "`nStep 2: Getting dependencies..." -ForegroundColor Yellow
flutter pub get

Write-Host "`nStep 3: Building web app..." -ForegroundColor Yellow
flutter build web --base-href /AgroDoctor_App/ --output docs --release

Write-Host "`nStep 4: Backing up generated index.html..." -ForegroundColor Yellow
Copy-Item -Path "docs\index.html" -Destination "docs\index.html.bak" -Force

Write-Host "`nStep 5: Replacing with custom index.html..." -ForegroundColor Yellow
Copy-Item -Path "custom_index.html" -Destination "docs\index.html" -Force

Write-Host "`nBuild completed successfully!" -ForegroundColor Green
Write-Host "`nTo deploy:" -ForegroundColor Cyan
Write-Host "1. Commit and push changes to GitHub" -ForegroundColor Cyan
Write-Host "2. Your site will be available at: https://falz1994.github.io/AgroDoctor_App/" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
