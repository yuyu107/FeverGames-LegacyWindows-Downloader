param(
    [string]$GameDir = "D:\FeverApps\MCBedrock"
)

$ErrorActionPreference = "Stop"

Write-Host "============================================================"
Write-Host " Clear Win7 downloader v1.2 cache ONLY"
Write-Host "============================================================"
Write-Host ""
Write-Host ("GameDir: " + $GameDir)
Write-Host "This does NOT delete normal game files."
Write-Host ""

$cache = Join-Path $GameDir ".dlstorage\legacy_win7_v1.2"
$log = Join-Path $env:TEMP "FeverGames_Win7_DownloadIPC_v1.2"

if (Test-Path $cache) {
    Remove-Item $cache -Recurse -Force
    Write-Host "[OK] v1.2 download cache removed."
} else {
    Write-Host "[INFO] No v1.2 download cache exists."
}

if (Test-Path $log) {
    Remove-Item $log -Recurse -Force
    Write-Host "[OK] v1.2 diagnostic log removed."
} else {
    Write-Host "[INFO] No v1.2 diagnostic log exists."
}
