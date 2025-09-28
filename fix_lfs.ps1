Write-Host "===================================" -ForegroundColor Cyan
Write-Host "Fixing Git LFS issues for GitHub Pages" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan

Write-Host "`nStep 1: Removing main.dart.js from Git LFS tracking..." -ForegroundColor Yellow
git lfs untrack docs/main.dart.js

Write-Host "`nStep 2: Removing the LFS pointer and getting the actual file..." -ForegroundColor Yellow
Remove-Item -Path "docs\main.dart.js" -Force -ErrorAction SilentlyContinue
git checkout -- docs/main.dart.js

Write-Host "`nStep 3: Rebuilding the web app..." -ForegroundColor Yellow
flutter clean
flutter pub get
flutter build web --base-href /AgroDoctor_App/ --output docs --release --web-renderer html

Write-Host "`nStep 4: Replacing with custom index.html..." -ForegroundColor Yellow
Copy-Item -Path "custom_index.html" -Destination "docs\index.html" -Force

Write-Host "`nStep 5: Creating .nojekyll file..." -ForegroundColor Yellow
"" | Set-Content -Path "docs\.nojekyll" -NoNewline

Write-Host "`nFix completed!" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "1. Commit these changes: git add . && git commit -m `"Fix LFS issues with main.dart.js`"" -ForegroundColor Cyan
Write-Host "2. Push to GitHub: git push" -ForegroundColor Cyan
Write-Host "3. Your site should now work correctly at: https://falz1994.github.io/AgroDoctor_App/" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
