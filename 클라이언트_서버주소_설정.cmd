@echo off
setlocal

cd /d "%~dp0"

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

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$url = '%SERVER_URL%'.Trim().TrimEnd('/'); $cfg = [ordered]@{ enabled = $true; serverUrl = $url; canControl = $true }; $cfg | ConvertTo-Json | Set-Content -LiteralPath 'sync-client-config.json' -Encoding UTF8"

echo.
echo Saved sync-client-config.json
echo Now run 롤_스펠_오버레이_실행.vbs
echo.
pause
