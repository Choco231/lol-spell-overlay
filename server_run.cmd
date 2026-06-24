@echo off
setlocal

cd /d "%~dp0"

where node >nul 2>nul
if errorlevel 1 (
  echo Node.js is not installed. Run install_run.cmd first.
  pause
  exit /b 1
)

if not exist "node_modules\electron\dist\electron.exe" (
  echo Electron is not installed. Run install_run.cmd first.
  pause
  exit /b 1
)

set "TAILSCALE_EXE=C:\Program Files\Tailscale\tailscale.exe"
if not exist "%TAILSCALE_EXE%" (
  echo Tailscale is not installed. Run install_run.cmd first.
  pause
  exit /b 1
)

for /f "usebackq delims=" %%I in (`"%TAILSCALE_EXE%" ip -4`) do set "TAILSCALE_IP=%%I"
if "%TAILSCALE_IP%"=="" (
  echo Tailscale is not logged in. Run install_run.cmd first.
  pause
  exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -Command "$cfg = [ordered]@{ enabled = $true; serverUrl = 'http://127.0.0.1:17898'; canControl = $true }; $cfg | ConvertTo-Json | Set-Content -LiteralPath 'sync-client-config.json' -Encoding UTF8"

echo.
echo LoL spell sync server will start.
echo.
echo Share this URL with clients:
echo   http://%TAILSCALE_IP%:17898
echo.
echo Starting host overlay...
start "" wscript.exe "%~dp0run-overlay.vbs"
echo.
echo Keep this server window open.
echo.

node sync-server.js


