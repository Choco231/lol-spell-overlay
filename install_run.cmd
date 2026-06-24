@echo off
setlocal

cd /d "%~dp0"

echo.
echo [1/4] Checking winget...
where winget >nul 2>nul
if errorlevel 1 (
  echo winget is not available on this PC.
  echo Install Node.js LTS and Tailscale manually, then run this file again.
  pause
  exit /b 1
)

echo.
echo [2/4] Checking Node.js...
where node >nul 2>nul
if errorlevel 1 (
  echo Installing Node.js LTS...
  winget install --id OpenJS.NodeJS.LTS -e --source winget --accept-package-agreements --accept-source-agreements
  if errorlevel 1 (
    echo Node.js install failed.
    pause
    exit /b 1
  )
  set "PATH=%ProgramFiles%\nodejs;%PATH%"
)

where npm.cmd >nul 2>nul
if errorlevel 1 (
  echo npm.cmd was not found. If Node.js was just installed, close this window and run again.
  pause
  exit /b 1
)

echo.
echo [3/4] Installing overlay dependencies...
if not exist "node_modules\.bin\electron.cmd" (
  call npm.cmd install
  if errorlevel 1 (
    echo npm install failed.
    pause
    exit /b 1
  )
)

if not exist "node_modules\electron\dist\electron.exe" (
  echo Repairing Electron...
  call node "node_modules\electron\install.js"
)

if not exist "node_modules\electron\dist\electron.exe" (
  echo Reinstalling Electron...
  call npm.cmd install electron@31.7.7 --save-dev --force
)

if not exist "node_modules\electron\dist\electron.exe" (
  echo Electron install is incomplete. Try deleting node_modules and run this file again.
  pause
  exit /b 1
)

echo.
echo [4/4] Checking Tailscale...
set "TAILSCALE_EXE=C:\Program Files\Tailscale\tailscale.exe"
if not exist "%TAILSCALE_EXE%" (
  echo Installing Tailscale...
  winget install --id Tailscale.Tailscale -e --source winget --accept-package-agreements --accept-source-agreements
  if errorlevel 1 (
    echo Tailscale install failed.
    pause
    exit /b 1
  )
)

if exist "%TAILSCALE_EXE%" (
  "%TAILSCALE_EXE%" status > "%TEMP%\tailscale-status.txt" 2>&1
  findstr /i "Logged out NeedsLogin" "%TEMP%\tailscale-status.txt" >nul 2>nul
  if not errorlevel 1 (
    echo.
    echo Tailscale login is required.
    echo A browser login page may open. Complete login/signup there.
    echo.
    "%TAILSCALE_EXE%" up
  )
) else (
  echo Tailscale was installed, but tailscale.exe was not found yet.
  echo Close this window and run this file again.
  pause
  exit /b 1
)

echo.
echo Setup complete.
echo.
echo Next:
echo   Host:   run server_run.cmd
echo   Client: run client_run.cmd
echo.
pause

