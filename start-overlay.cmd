@echo off
setlocal

cd /d "%~dp0"

where node >nul 2>nul
if errorlevel 1 (
  echo Node.js is missing. Run install_run.cmd first.
  pause
  exit /b 1
)

node -e "process.exit(Number(process.versions.node.split('.')[0]) >= 22 ? 0 : 1)" >nul 2>nul
if errorlevel 1 (
  echo Node.js 22 or newer is required. Run install_run.cmd first.
  pause
  exit /b 1
)

where npm.cmd >nul 2>nul
if errorlevel 1 (
  echo npm.cmd is missing. Run install_run.cmd first.
  pause
  exit /b 1
)

if not exist "node_modules\.bin\electron.cmd" (
  echo Electron dependency is missing.
  echo Installing dependencies first...
  call npm.cmd install --no-audit --no-fund
  if errorlevel 1 (
    echo.
    echo Install failed. Press any key to close.
    pause >nul
    exit /b 1
  )
)

if not exist "node_modules\electron\dist\electron.exe" (
  echo Electron executable is missing.
  echo Repairing Electron install...
  call node "node_modules\electron\install.js"
)

if not exist "node_modules\electron\dist\electron.exe" (
  echo Electron repair did not create electron.exe.
  echo Rebuilding Electron...
  call npm.cmd rebuild electron
)

if not exist "node_modules\electron\dist\electron.exe" (
  echo Electron rebuild did not create electron.exe.
  echo Reinstalling Electron...
  if exist "node_modules\electron" (
    rmdir /s /q "node_modules\electron"
  )
  call npm.cmd install --no-audit --no-fund
)

if not exist "node_modules\electron\dist\electron.exe" (
  echo Electron reinstall did not create electron.exe.
  echo Forcing Electron install...
  call npm.cmd install --no-audit --no-fund
  call node "node_modules\electron\install.js"
)

if not exist "node_modules\electron\dist\electron.exe" (
  echo Electron reinstall did not create electron.exe.
  echo Clean reinstalling all dependencies...
  if exist "node_modules" (
    rmdir /s /q "node_modules"
  )
  call npm.cmd install --no-audit --no-fund
  if errorlevel 1 (
    echo Clean install failed. Press any key to close.
    pause >nul
    exit /b 1
  )
  call node "node_modules\electron\install.js"
)

if not exist "node_modules\electron\dist\electron.exe" (
  echo Electron npm install is still incomplete.
  echo Trying direct zip repair...
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0repair-electron.ps1"
)

if not exist "node_modules\electron\dist\electron.exe" (
  echo Electron install is still incomplete.
  echo Close this window and run install_run.cmd again.
  pause
  exit /b 1
)

call "%~dp0node_modules\.bin\electron.cmd" . > "%~dp0overlay-runtime.log" 2>&1
