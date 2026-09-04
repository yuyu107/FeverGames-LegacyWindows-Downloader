@echo off
setlocal
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Prepare_Source_v1.2.ps1"
if errorlevel 1 goto :end
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install_Latest_FeverGames_v1.3.ps1"
:end
echo.
pause
