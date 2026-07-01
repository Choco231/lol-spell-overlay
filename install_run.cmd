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

node -e "process.exit(Number(process.versions.node.split('.')[0]) >= 22 ? 0 : 1)" >nul 2>nul
if errorlevel 1 (
  echo Node.js 22 or newer is required.
  echo Upgrading Node.js LTS...
  winget upgrade --id OpenJS.NodeJS.LTS -e --source winget --accept-package-agreements --accept-source-agreements
  set "PATH=%ProgramFiles%\nodejs;%PATH%"
  node -e "process.exit(Number(process.versions.node.split('.')[0]) >= 22 ? 0 : 1)" >nul 2>nul
  if errorlevel 1 (
    echo Node.js is still too old. Close this window, open it again, and run this file again.
    pause
    exit /b 1
  )
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
  call npm.cmd install --no-audit --no-fund
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
  call npm.cmd install --no-audit --no-fund
  call node "node_modules\electron\install.js"
)

if not exist "node_modules\electron\dist\electron.exe" (
  echo Clean reinstalling dependencies...
  if exist "node_modules" (
    rmdir /s /q "node_modules"
  )
  call npm.cmd install --no-audit --no-fund
  if errorlevel 1 (
    echo npm clean install failed.
    pause
    exit /b 1
  )
  call node "node_modules\electron\install.js"
)

if not exist "node_modules\electron\dist\electron.exe" (
  echo Trying direct Electron zip repair...
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0repair-electron.ps1"
)

if not exist "node_modules\electron\dist\electron.exe" (
  echo Electron install is incomplete.
  echo Close this window and run install_run.cmd again.
  pause
  exit /b 1
)

echo.
echo Setup complete.
echo.
echo Starting client setup...
echo.

call "%~dp0client_run.cmd"

echo.
echo Setup script finished.
echo.

