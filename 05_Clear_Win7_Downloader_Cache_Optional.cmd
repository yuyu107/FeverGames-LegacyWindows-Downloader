@echo off
setlocal
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Clear_Win7_Downloader_Cache_v1.2.ps1"
echo.
pause
