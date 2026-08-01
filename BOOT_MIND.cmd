@echo off
REM LIVE connected organism via WSL
cd /d "%~dp0"
title FSOT Live Mind - Idris
echo.
echo ============================================================
echo   FSOT LIVE MIND  (Idris twin / WSL)
echo   ONE brain stays online
echo ============================================================
echo.

where wsl >nul 2>&1
if errorlevel 1 (
  echo ERROR: WSL required for Idris twin
  pause
  exit /b 1
)

set "WSL_DIR=/mnt/c/Users/damia/Desktop/FSOT NEURON idris"
echo Starting LIVE mind (type quit to stop)...
echo.
wsl -e bash -lc "export PATH=$HOME/.local/bin:$PATH; cd '%WSL_DIR%' || exit 1; if [ ! -x build/exec/fsot-mind ]; then idris2 --build fsot-neuron-idris.ipkg || exit 1; fi; ./build/exec/fsot-mind mind"
echo.
pause
