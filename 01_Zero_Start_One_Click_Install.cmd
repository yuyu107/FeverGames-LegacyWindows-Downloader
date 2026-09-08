@echo off
setlocal
cd /d "%~dp0"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Prepare_Source_v1.2.ps1"
if errorlevel 1 goto :end

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Run_Install_Elevated_v1.3.ps1"
set "RC=%ERRORLEVEL%"

echo.
if not "%RC%"=="0" (
    echo [ERR] Installation did not complete successfully. Exit code: %RC%
    goto :end
)
echo [OK] Installer returned success.
echo [INFO] Running status verification...
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Check_Latest_FeverGames_Status_v1.3.ps1"
:end
echo.
pause
