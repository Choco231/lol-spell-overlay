@echo off
setlocal

cd /d "%~dp0"

if not exist "node_modules\electron\dist\electron.exe" (
  echo Electron is not installed. Run install_run.cmd first.
  pause
  exit /b 1
)

echo.
echo Enter the server URL.
echo Press Enter to use the default VPS server.
echo.
set "DEFAULT_SERVER_URL=http://52.78.57.73:17898"
set /p SERVER_URL=Server URL [%DEFAULT_SERVER_URL%]: 

if "%SERVER_URL%"=="" (
  set "SERVER_URL=%DEFAULT_SERVER_URL%"
)

echo.
echo Enter a room code. People using the same room code share spell timers.
echo Use English letters, numbers, dash, or underscore. Example: team1
echo.
set /p ROOM_CODE=Room code: 

if "%ROOM_CODE%"=="" (
  echo No room code entered.
  pause
  exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -Command "$url = $env:SERVER_URL.Trim().TrimEnd('/'); $room = $env:ROOM_CODE.Trim().ToLower() -replace '[^a-z0-9_-]+','-'; $room = $room.Trim('-'); if (-not $room) { throw 'Invalid room code' }; $cfg = [ordered]@{ enabled = $true; serverUrl = $url; room = $room; canControl = $true }; $cfg | ConvertTo-Json | Set-Content -LiteralPath 'sync-client-config.json' -Encoding UTF8"

if errorlevel 1 (
  echo Failed to save sync config. Use only English letters, numbers, dash, or underscore for room code.
  pause
  exit /b 1
)

echo.
echo Saved server URL and room code.
echo Starting overlay...
echo.

start "" wscript.exe "%~dp0run-overlay.vbs"

echo Overlay launch command was sent.
echo If the overlay does not appear, run install_run.cmd first and try again.
echo.
pause



