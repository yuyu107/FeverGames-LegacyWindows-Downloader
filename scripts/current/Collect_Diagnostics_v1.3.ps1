param([string]$InstallDir = "")

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
. (Join-Path $scriptDir "FeverGames_VersionResolver_v1.3.ps1")

# scripts\current -> scripts -> repository root
$packageRoot = Split-Path -Parent (Split-Path -Parent $scriptDir)
$result = Join-Path $packageRoot "FeverGames_v1.3.6_Diagnostic_Result"

if (Test-Path $result) {
    Remove-Item $result -Recurse -Force
}

New-Item -ItemType Directory -Path $result | Out-Null

try {
    $items = @(Get-FeverGamesVersionFolders $InstallDir)
    Show-FeverGamesVersionFolders $items 10

    $target = Get-NewestCompleteFeverGamesFolder $InstallDir

    if ($target -ne $null) {
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $scriptDir "Check_Status_v1.3.ps1") -InstallDir $target.Path 2>&1 |
            Out-File -FilePath (Join-Path $result "status.txt") -Encoding UTF8

        foreach ($backupName in @("Win7_Downloader_Fix_Backup_v1.3","Win7_Bedrock_Fix_Backup_v1.2")) {
            $info = Join-Path $target.Path ($backupName + "\backup_info.txt")
            if (Test-Path $info) {
                Copy-Item $info (Join-Path $result "backup_info.txt") -Force
                break
            }
        }

        foreach ($markerName in @("Win7_Downloader_Fix_v1.3.installed.txt","Win7_Bedrock_Fix_v1.2.installed.txt")) {
            $marker = Join-Path $target.Path $markerName
            if (Test-Path $marker) {
                Copy-Item $marker (Join-Path $result "install_marker.txt") -Force
                break
            }
        }

        $decoderInfo = Join-Path $result "decoder_info.txt"
        $libzstd = Join-Path $target.Path "libzstd.dll"
        if (Test-Path $libzstd -PathType Leaf) {
            try {
                $shaObj = [System.Security.Cryptography.SHA256]::Create()
                try {
                    $bytes = [System.IO.File]::ReadAllBytes($libzstd)
                    $sha = [BitConverter]::ToString($shaObj.ComputeHash($bytes)).Replace("-","").ToLowerInvariant()
                }
                finally { $shaObj.Clear() }

                $vi = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($libzstd)
                @(
                    ("Path: " + $libzstd),
                    ("FileVersion: " + $vi.FileVersion),
                    ("ProductVersion: " + $vi.ProductVersion),
                    ("SHA256: " + $sha)
                ) | Out-File -FilePath $decoderInfo -Encoding UTF8
            }
            catch {
                ("libzstd.dll present, metadata read failed: " + $_.Exception.Message) |
                    Out-File -FilePath $decoderInfo -Encoding UTF8
            }
        }
        else {
            "libzstd.dll missing" | Out-File -FilePath $decoderInfo -Encoding UTF8
        }
    }
}
catch {
    $_ | Out-File -FilePath (Join-Path $result "collector_error.txt") -Encoding UTF8
}

$log = Join-Path $env:TEMP "FeverGames_Win7_DownloadIPC_v1.2\downloadIPC_v1.2.log"
if (Test-Path $log) {
    Copy-Item $log (Join-Path $result "downloadIPC_v1.2.log") -Force
}

Write-Host ""
Write-Host ("[OK] Diagnostic result: " + $result)
Write-Host "[INFO] No PRIVATE manifest response, AES key, deviceId, uid, sig or secKey is collected."
