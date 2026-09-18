@echo off
chcp 65001 > nul
cd /d "%~dp0"

echo ============================================
echo  LINEスタンプ  メイン画像・タブ画像の作成
echo ============================================
echo.
echo   メイン画像  240x240  -^>  main.png
echo   タブ画像     96x74   -^>  tab.png
echo.

if not exist "%~dp0resize-line-stamps.ps1" (
    echo [エラー] resize-line-stamps.ps1 が見つかりません。
    echo このファイルと同じフォルダに置いてください。
    echo.
    pause
    exit /b 1
)

set "NUM="
set /p "NUM=どの絵を使いますか? 番号を入力してEnter (そのままEnterなら 1): "
if not defined NUM set "NUM=1"

echo %NUM%|findstr /r "^[0-9][0-9]*$" > nul
if errorlevel 1 (
    echo.
    echo [エラー] 半角数字で入力してください。入力内容: %NUM%
    echo.
    pause
    exit /b 1
)

echo.
echo --- メイン画像 240x240 ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0resize-line-stamps.ps1" -Width 240 -Height 240 -From %NUM% -To %NUM% -OutputName main

echo.
echo --- タブ画像 96x74 ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0resize-line-stamps.ps1" -Width 96 -Height 74 -From %NUM% -To %NUM% -OutputName tab

echo.
echo ============================================
echo  resized フォルダに main.png と tab.png を
echo  作成しました。
echo  このウィンドウは何かキーを押すと閉じます。
echo ============================================
pause > nul
