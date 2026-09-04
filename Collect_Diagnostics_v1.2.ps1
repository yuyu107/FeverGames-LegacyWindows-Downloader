param([string]$InstallDir = "")

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
if ([String]::IsNullOrEmpty($scriptDir)) { $scriptDir = (Get-Location).Path }

$result = Join-Path $scriptDir "ZeroStart_v1.2_Diagnostic_Result"

if (Test-Path $result) {
    Remove-Item $result -Recurse -Force
}

New-Item -ItemType Directory -Path $result | Out-Null

$statusScript = Join-Path $scriptDir "Check_Status_v1.2.ps1"
$statusOut = Join-Path $result "status.txt"

try {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $statusScript -InstallDir $InstallDir 2>&1 |
        Out-File -FilePath $statusOut -Encoding UTF8
}
catch {
    $_ | Out-File -FilePath $statusOut -Encoding UTF8
}

$logDir = Join-Path $env:TEMP "FeverGames_Win7_DownloadIPC_v1.2"
$log = Join-Path $logDir "downloadIPC_v1.2.log"

if (Test-Path $log) {
    Copy-Item $log (Join-Path $result "downloadIPC_v1.2.log")
    Write-Host "[OK] Copied downloader log."
} else {
    Write-Host "[WARN] No v1.2 downloader log found yet."
}

$roots = @(
    "D:\Program Files\FeverGames\1.18.42.12",
    "C:\Program Files\FeverGames\1.18.42.12",
    "C:\Program Files (x86)\FeverGames\1.18.42.12"
)

if (-not [String]::IsNullOrEmpty($InstallDir)) {
    $roots = @($InstallDir) + $roots
}

foreach ($d in $roots) {
    $info = Join-Path $d "Win7_Bedrock_Fix_Backup_v1.2\backup_info.txt"
    $marker = Join-Path $d "Win7_Bedrock_Fix_v1.2.installed.txt"

    if (Test-Path $info) {
        Copy-Item $info (Join-Path $result "backup_info.txt")
    }

    if (Test-Path $marker) {
        Copy-Item $marker (Join-Path $result "install_marker.txt")
    }

    if ((Test-Path $info) -or (Test-Path $marker)) {
        break
    }
}

Write-Host ""
Write-Host ("[OK] Diagnostic result: " + $result)
Write-Host "[INFO] No PRIVATE manifest response, AES key, deviceId, uid, sig or secKey is collected."
