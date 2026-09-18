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
echo  それぞれ別の絵を選べます。
echo.

if not exist "%~dp0resize-line-stamps.ps1" (
    echo [エラー] resize-line-stamps.ps1 が見つかりません。
    echo このファイルと同じフォルダに置いてください。
    echo.
    pause
    exit /b 1
)

rem ---- メイン画像に使う番号 ----
set "MAINNUM="
set /p "MAINNUM=[1/2] メイン画像に使う番号は? (そのままEnterなら 1): "
if not defined MAINNUM set "MAINNUM=1"
echo %MAINNUM%|findstr /r "^[0-9][0-9]*$" > nul
if errorlevel 1 (
    echo.
    echo [エラー] 半角数字で入力してください。入力内容: %MAINNUM%
    echo.
    pause
    exit /b 1
)

rem ---- タブ画像に使う番号 ----
set "TABNUM="
set /p "TABNUM=[2/2] タブ画像に使う番号は? (そのままEnterなら %MAINNUM% と同じ): "
if not defined TABNUM set "TABNUM=%MAINNUM%"
echo %TABNUM%|findstr /r "^[0-9][0-9]*$" > nul
if errorlevel 1 (
    echo.
    echo [エラー] 半角数字で入力してください。入力内容: %TABNUM%
    echo.
    pause
    exit /b 1
)

echo.
echo --- メイン画像 240x240  (No.%MAINNUM% を使用) ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0resize-line-stamps.ps1" -Width 240 -Height 240 -From %MAINNUM% -To %MAINNUM% -OutputName main

echo.
echo --- タブ画像 96x74  (No.%TABNUM% を使用) ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0resize-line-stamps.ps1" -Width 96 -Height 74 -From %TABNUM% -To %TABNUM% -OutputName tab

echo.
echo ============================================
echo  resized フォルダに作成しました。
echo    main.png  ... No.%MAINNUM%
echo    tab.png   ... No.%TABNUM%
echo.
echo  このウィンドウは何かキーを押すと閉じます。
echo ============================================
pause > nul
