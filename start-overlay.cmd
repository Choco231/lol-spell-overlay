@echo off
setlocal

cd /d "%~dp0"

if not exist "node_modules\.bin\electron.cmd" (
  echo Electron dependency is missing.
  echo Installing dependencies first...
  call npm.cmd install
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
  call npm.cmd install electron@31.7.7 --save-dev --force
)

if not exist "node_modules\electron\dist\electron.exe" (
  echo Electron install is still incomplete.
  echo Try deleting the node_modules folder and run setup-and-run.cmd again.
  pause
  exit /b 1
)

call "%~dp0node_modules\.bin\electron.cmd" . > "%~dp0overlay-runtime.log" 2>&1
