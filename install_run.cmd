@echo off
setlocal

cd /d "%~dp0"

echo.
echo [1/3] Checking winget...
where winget >nul 2>nul
if errorlevel 1 (
  echo winget is not available on this PC.
  echo Install Node.js LTS manually, then run this file again.
  pause
  exit /b 1
)

echo.
echo [2/3] Checking Node.js...
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
echo [3/3] Installing overlay dependencies...
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
echo Setup complete.
echo.
echo Next:
echo   Run client_run.cmd
echo   or double-click 클라이언트_실행.cmd
echo.
pause

