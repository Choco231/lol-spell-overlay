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
  if errorlevel 1 (
    echo.
    echo Repair failed. Press any key to close.
    pause >nul
    exit /b 1
  )
)

call "%~dp0node_modules\.bin\electron.cmd" . > "%~dp0overlay-runtime.log" 2>&1
