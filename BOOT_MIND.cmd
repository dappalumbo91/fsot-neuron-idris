@echo off
REM Double-click: FSOT Idris mind via WSL (local, no server).
cd /d "%~dp0"
title FSOT Neuron Idris
echo.
echo ============================================================
echo   FSOT NEURON IDRIS  -  local host twin (WSL)
echo ============================================================
echo.

where wsl >nul 2>&1
if errorlevel 1 (
  echo ERROR: WSL not found. Idris twin runs under WSL2 Ubuntu.
  pause
  exit /b 1
)

echo   1 phase-a   2 phase-b   3 phase-c   4 phase-d
echo   5 glia-ca   6 self-talk 7 genetic   8 selftest
echo   a all-product   q quit
echo.
set /p CHOICE=Select mode: 
if /i "%CHOICE%"=="q" exit /b 0
if "%CHOICE%"=="1" set MODE=phase-a
if "%CHOICE%"=="2" set MODE=phase-b
if "%CHOICE%"=="3" set MODE=phase-c
if "%CHOICE%"=="4" set MODE=phase-d
if /i "%CHOICE%"=="5" set MODE=glia-ca
if /i "%CHOICE%"=="6" set MODE=self-talk
if "%CHOICE%"=="7" set MODE=genetic
if "%CHOICE%"=="8" set MODE=selftest
if /i "%CHOICE%"=="a" set MODE=all
if not defined MODE set MODE=%CHOICE%

set "WSL_DIR=/mnt/c/Users/damia/Desktop/FSOT NEURON idris"

if /i "%MODE%"=="all" (
  wsl -e bash -lc "export PATH=$HOME/.local/bin:$PATH; cd '%WSL_DIR%' || exit 1; test -x build/exec/fsot-mind || idris2 --build fsot-neuron-idris.ipkg; for m in phase-a phase-b phase-c phase-d glia-ca self-talk; do echo; echo ----- $m -----; ./build/exec/fsot-mind $m || exit 1; done"
) else (
  wsl -e bash -lc "export PATH=$HOME/.local/bin:$PATH; cd '%WSL_DIR%' || exit 1; if [ ! -x build/exec/fsot-mind ]; then idris2 --build fsot-neuron-idris.ipkg || exit 1; fi; ./build/exec/fsot-mind %MODE%"
)
set ERR=%ERRORLEVEL%
echo.
if %ERR%==0 (echo FSOT_OK) else (echo FAILED exit=%ERR%)
pause
exit /b %ERR%
