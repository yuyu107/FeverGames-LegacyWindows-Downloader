param([string]$InstallDir = "")

$ErrorActionPreference = "Stop"
$ThisScript = $MyInvocation.MyCommand.Definition

function Info($s){ Write-Host "[INFO] $s" }
function Ok($s){ Write-Host "[OK]   $s" }
function Warn($s){ Write-Host "[WARN] $s" }
function Err($s){ Write-Host "[ERR]  $s" }

function Ensure-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($id)

    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Info "Requesting administrator privileges..."

        $arg = "-NoProfile -ExecutionPolicy Bypass -File `"$ThisScript`""

        if (-not [String]::IsNullOrEmpty($InstallDir)) {
            $arg += " -InstallDir `"$InstallDir`""
        }

        Start-Process powershell.exe -Verb RunAs -ArgumentList $arg
        exit 0
    }
}

function Find-InstallDir([string]$Requested) {
    if (-not [String]::IsNullOrEmpty($Requested)) {
        if (Test-Path $Requested -PathType Leaf) {
            $Requested = Split-Path -Parent $Requested
        }

        if (Test-Path (Join-Path $Requested "Win7_Bedrock_Fix_Backup_v1.2")) {
            return (Resolve-Path $Requested).Path
        }
    }

    foreach ($d in @(
        "D:\Program Files\FeverGames\1.18.42.12",
        "C:\Program Files\FeverGames\1.18.42.12",
        "C:\Program Files (x86)\FeverGames\1.18.42.12"
    )) {
        if (Test-Path (Join-Path $d "Win7_Bedrock_Fix_Backup_v1.2")) {
            return (Resolve-Path $d).Path
        }
    }

    return $null
}

function Assert-PlatformClosed {
    foreach ($n in @("FeverGamesInstaller","FeverGamesLauncher","downloadIPC","FeverGamesService")) {
        if (Get-Process -Name $n -ErrorAction SilentlyContinue) {
            throw ("Please fully exit FeverGames first. Running process: " + $n)
        }
    }
}

function Get-Sha256([string]$Path) {
    $sha = [Security.Cryptography.SHA256]::Create()
    $fs = [IO.File]::OpenRead($Path)

    try {
        $hash = $sha.ComputeHash($fs)
        return (($hash | ForEach-Object { $_.ToString("x2") }) -join "")
    }
    finally {
        $fs.Dispose()
        $sha.Dispose()
    }
}

Ensure-Admin

try {
    Write-Host "============================================================"
    Write-Host " FeverGames Win7 Bedrock Fix v1.2 - Restore Official Files"
    Write-Host "============================================================"

    Assert-PlatformClosed

    $InstallDir = Find-InstallDir $InstallDir

    if ([String]::IsNullOrEmpty($InstallDir)) {
        throw "v1.2 backup folder was not found."
    }

    $backupDir = Join-Path $InstallDir "Win7_Bedrock_Fix_Backup_v1.2"
    $backupInstaller = Join-Path $backupDir "FeverGamesInstaller.exe.original"
    $backupDownloader = Join-Path $backupDir "downloadIPC.exe.original"

    if (-not (Test-Path $backupInstaller)) {
        throw "Original FeverGamesInstaller backup is missing."
    }

    if (-not (Test-Path $backupDownloader)) {
        throw "Original downloadIPC backup is missing."
    }

    Copy-Item $backupInstaller (Join-Path $InstallDir "FeverGamesInstaller.exe") -Force
    Copy-Item $backupDownloader (Join-Path $InstallDir "downloadIPC.exe") -Force

    Ok "Official/original FeverGamesInstaller.exe restored."
    Ok "Official/original downloadIPC.exe restored."

    $copiedZstdHashFile = Join-Path $backupDir "copied_zstd.sha256"
    $liveZstd = Join-Path $InstallDir "zstd.exe"

    if ((Test-Path $copiedZstdHashFile) -and (Test-Path $liveZstd)) {
        $expected = (Get-Content $copiedZstdHashFile | Select-Object -First 1).Trim()
        $actual = Get-Sha256 $liveZstd

        if ($actual -eq $expected) {
            Remove-Item $liveZstd -Force
            Ok "Patch-supplied zstd.exe removed."
        } else {
            Warn "zstd.exe was changed after installation; it was kept."
        }
    }

    $marker = Join-Path $InstallDir "Win7_Bedrock_Fix_v1.2.installed.txt"

    if (Test-Path $marker) {
        Remove-Item $marker -Force
    }

    Write-Host ""
    Ok "RESULT=RESTORE_COMPLETE"
    Info "Game files under FeverApps\MCBedrock were NOT deleted."
    Info "The backup folder is intentionally kept."
}
catch {
    Err $_.Exception.Message
    exit 1
}
