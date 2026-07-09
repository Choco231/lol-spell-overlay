@echo off
setlocal

cd /d "%~dp0"

if not exist "node_modules\electron\dist\electron.exe" (
  echo Electron is not installed. Run install_run.cmd first.
  pause
  exit /b 1
)

set "DEFAULT_SERVER_URL=http://52.78.57.73:17898"
set "SERVER_URL=%DEFAULT_SERVER_URL%"

echo.
echo Select a room. People using the same room share spell timers.
echo 1. team1
echo 2. team2
echo 3. team3
echo.
set /p ROOM_NUMBER=Room number [1-3]: 

if "%ROOM_NUMBER%"=="1" set "ROOM_CODE=team1"
if "%ROOM_NUMBER%"=="2" set "ROOM_CODE=team2"
if "%ROOM_NUMBER%"=="3" set "ROOM_CODE=team3"

if "%ROOM_CODE%"=="" (
  echo Invalid room number. Enter 1, 2, or 3.
  pause
  exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -Command "$url = $env:SERVER_URL.Trim().TrimEnd('/'); $room = $env:ROOM_CODE; $cfg = [ordered]@{ enabled = $true; serverUrl = $url; room = $room; canControl = $true }; $cfg | ConvertTo-Json | Set-Content -LiteralPath 'sync-client-config.json' -Encoding UTF8"

if errorlevel 1 (
  echo Failed to save sync config.
  pause
  exit /b 1
)

echo.
echo Saved room code.
echo Starting overlay...
echo.

start "" wscript.exe "%~dp0run-overlay.vbs"

echo Overlay launch command was sent.
echo If the overlay does not appear, run install_run.cmd first and try again.
echo.
pause



