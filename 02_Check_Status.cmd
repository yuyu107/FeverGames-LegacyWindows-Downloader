@echo off
setlocal
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Check_Latest_FeverGames_Status_v1.3.ps1"
echo.
pause
