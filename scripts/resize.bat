@echo off
chcp 65001 > nul
cd /d "%~dp0"

echo ============================================
echo  LINEスタンプ用リサイズ (370x320)
echo ============================================
echo.

if not exist "%~dp0resize-line-stamps.ps1" (
    echo [エラー] resize-line-stamps.ps1 が見つかりません。
    echo resize.bat と同じフォルダに置いてください。
    echo.
    pause
    exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0resize-line-stamps.ps1"

echo.
echo ============================================
echo  このウィンドウは何かキーを押すと閉じます。
echo ============================================
pause > nul
