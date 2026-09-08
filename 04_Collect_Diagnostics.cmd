@echo off
setlocal
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\current\Collect_Diagnostics_v1.3.ps1"
echo.
echo [INFO] Diagnostic result is created next to this CMD file.
echo.
pause
