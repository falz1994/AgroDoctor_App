@echo off
echo ===================================
echo Fixing Git LFS issues for GitHub Pages
echo ===================================

echo.
echo Step 1: Removing main.dart.js from Git LFS tracking...
git lfs untrack docs/main.dart.js

echo.
echo Step 2: Removing the LFS pointer and getting the actual file...
del docs\main.dart.js
git checkout -- docs/main.dart.js

echo.
echo Step 3: Rebuilding the web app...
call flutter clean
call flutter pub get
call flutter build web --base-href /AgroDoctor_App/ --output docs --release --web-renderer html

echo.
echo Step 4: Replacing with custom index.html...
copy custom_index.html docs\index.html

echo.
echo Step 5: Creating .nojekyll file...
echo. > docs\.nojekyll

echo.
echo Fix completed!
echo.
echo Next steps:
echo 1. Commit these changes: git add . && git commit -m "Fix LFS issues with main.dart.js"
echo 2. Push to GitHub: git push
echo 3. Your site should now work correctly at: https://falz1994.github.io/AgroDoctor_App/
echo ===================================
