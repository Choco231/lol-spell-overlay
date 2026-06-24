@echo off
setlocal

cd /d "%~dp0"

where node >nul 2>nul
if errorlevel 1 (
  echo Node.js is not installed.
  echo Run setup-and-run.cmd first, or install Node.js LTS.
  pause
  exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -Command "$cfg = [ordered]@{ enabled = $true; serverUrl = 'http://127.0.0.1:17898'; canControl = $true }; $cfg | ConvertTo-Json | Set-Content -LiteralPath 'sync-client-config.json' -Encoding UTF8"

set "TAILSCALE_EXE=C:\Program Files\Tailscale\tailscale.exe"

echo.
echo Starting LoL spell sync server...
echo.
if exist "%TAILSCALE_EXE%" (
  echo Your Tailscale IP:
  "%TAILSCALE_EXE%" ip -4
  echo.
  echo Share this server URL with clients:
  for /f "usebackq delims=" %%I in (`"%TAILSCALE_EXE%" ip -4`) do echo   http://%%I:17898
  echo.
) else (
  echo Tailscale CLI was not found at:
  echo %TAILSCALE_EXE%
  echo.
)

echo Keep this window open while using synced overlays.
echo.
node sync-server.js
