@echo off
echo ===================================
echo Flutter Web Build for GitHub Pages
echo ===================================

echo.
echo Step 1: Cleaning previous build...
call flutter clean

echo.
echo Step 2: Getting dependencies...
call flutter pub get

echo.
echo Step 3: Building web app...
call flutter build web --base-href /AgroDoctor_App/ --output docs --release

echo.
echo Step 4: Backing up generated index.html...
copy docs\index.html docs\index.html.bak

echo.
echo Step 5: Replacing with custom index.html...
copy custom_index.html docs\index.html

echo.
echo Build completed successfully!
echo.
echo To deploy:
echo 1. Commit and push changes to GitHub
echo 2. Your site will be available at: https://falz1994.github.io/AgroDoctor_App/
echo ===================================
