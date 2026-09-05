param([string]$InstallDir = "")

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
. (Join-Path $scriptDir "FeverGames_VersionResolver_v1.3.ps1")

try {
    Write-Host "============================================================"
    Write-Host " FeverGames Legacy Windows Downloader v1.3.0"
    Write-Host " Rolling version-folder selector"
    Write-Host "============================================================"
    Write-Host ""

    $items = @(Get-FeverGamesVersionFolders $InstallDir)
    Show-FeverGamesVersionFolders $items 5

    $target = Get-NewestCompleteFeverGamesFolder $InstallDir
    if ($target -eq $null) {
        throw "No complete FeverGames version folder containing both FeverGamesInstaller.exe and downloadIPC.exe was found."
    }

    Write-Host ""
    Write-Host ("[OK] Targeting newest complete version: " + $target.Name)
    Write-Host ("[OK] Path: " + $target.Path)
    Write-Host "[INFO] Known frontend profiles: 1.18.42.12, 1.18.42.14."
    Write-Host "[INFO] Unknown future folder versions may reuse a known layout only when all exact target bytes match."
    Write-Host ""

    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $scriptDir "Install_From_Zero_v1.3.ps1") -InstallDir $target.Path
    exit $LASTEXITCODE
}
catch {
    Write-Host ("[ERR] " + $_.Exception.Message)
    exit 1
}
