param([string]$InstallDir = "")

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
. (Join-Path $scriptDir "FeverGames_VersionResolver_v1.3.ps1")

try {
    $items = @(Get-FeverGamesVersionFolders $InstallDir)
    Show-FeverGamesVersionFolders $items 5

    $target = $null

    foreach ($item in $items) {
        $backupNew = Join-Path $item.Path "Win7_Downloader_Fix_Backup_v1.3"
        $backupOld = Join-Path $item.Path "Win7_Bedrock_Fix_Backup_v1.2"
        if ((Test-Path $backupNew) -or (Test-Path $backupOld)) {
            $target = $item
            break
        }
    }

    if ($target -eq $null) {
        throw "No FeverGames version folder with a rollback backup was found."
    }

    Write-Host ""
    Write-Host ("[INFO] Restoring newest patched/backed-up version: " + $target.Name)

    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $scriptDir "Restore_Official_Original_v1.3.ps1") -InstallDir $target.Path
    exit $LASTEXITCODE
}
catch {
    Write-Host ("[ERR] " + $_.Exception.Message)
    exit 1
}
