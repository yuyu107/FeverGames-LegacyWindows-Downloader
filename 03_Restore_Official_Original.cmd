@echo off
setlocal
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Restore_Latest_FeverGames_v1.3.ps1"
echo.
pause
