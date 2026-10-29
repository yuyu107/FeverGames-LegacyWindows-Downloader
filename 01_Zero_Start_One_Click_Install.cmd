@echo off
setlocal
cd /d "%~dp0"
echo.
echo ============================================================
echo  FeverGames Legacy Windows Downloader - SOURCE CHECKOUT
echo ============================================================
echo.
echo [INFO] This folder is a GitHub SOURCE checkout, not the stable release ZIP.
echo [INFO] Regular users should download the prebuilt v1.4.2 package:
echo.
echo https://github.com/yuyu107/FeverGames-LegacyWindows-Downloader/releases/tag/v1.4.2
echo.
echo [INFO] Release ZIP contains 01, 02, 03, 04, 05, 06 launchers.
echo [INFO] The source bootstrap below is a LEGACY developer workflow.
echo [INFO] It is NOT equivalent to the v1.4.2 release package.
echo.
set "ANSWER="
set /p "ANSWER=Type DEV to run historical source bootstrap, or press Enter to exit: "
if /I not "%ANSWER%"=="DEV" goto :end

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\current\Prepare_Source_v1.2.ps1"
if errorlevel 1 goto :end

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\current\Run_Install_Elevated_v1.3.ps1"
set "RC=%ERRORLEVEL%"

echo.
if not "%RC%"=="0" (
    echo [ERR] Source bootstrap installation failed. Exit code: %RC%
    goto :end
)
echo [OK] Installer returned success.
echo [INFO] Running status verification...
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\current\Check_Latest_FeverGames_Status_v1.3.ps1"
:end
echo.
pause
