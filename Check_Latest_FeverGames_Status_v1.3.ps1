param([string]$InstallDir = "")

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
. (Join-Path $scriptDir "FeverGames_VersionResolver_v1.3.ps1")

try {
    $items = @(Get-FeverGamesVersionFolders $InstallDir)
    Show-FeverGamesVersionFolders $items 5

    $target = Get-NewestCompleteFeverGamesFolder $InstallDir
    if ($target -eq $null) { throw "No complete FeverGames version folder found." }

    Write-Host ""
    Write-Host ("[INFO] Checking newest complete version: " + $target.Name)

    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $scriptDir "Check_Status_v1.3.ps1") -InstallDir $target.Path
    exit $LASTEXITCODE
}
catch {
    Write-Host ("[ERR] " + $_.Exception.Message)
    exit 1
}
