@echo off
setlocal

cd /d "%~dp0"

if not exist "node_modules\electron\dist\electron.exe" (
  echo Electron is not installed. Run install_run.cmd first.
  pause
  exit /b 1
)

echo.
echo Enter the server URL shared by the host.
echo Example: http://100.78.213.33:17898
echo.
set /p SERVER_URL=Server URL: 

if "%SERVER_URL%"=="" (
  echo No server URL entered.
  pause
  exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -Command "$url = '%SERVER_URL%'.Trim().TrimEnd('/'); $cfg = [ordered]@{ enabled = $true; serverUrl = $url; canControl = $true }; $cfg | ConvertTo-Json | Set-Content -LiteralPath 'sync-client-config.json' -Encoding UTF8"

echo.
echo Saved server URL.
echo Starting overlay...
echo.

start "" wscript.exe "%~dp0run-overlay.vbs"

echo Overlay launch command was sent.
echo If the overlay does not appear, run install_run.cmd first and try again.
echo.
pause



