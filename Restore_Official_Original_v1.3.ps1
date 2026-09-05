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
        $arg = "-NoProfile -ExecutionPolicy Bypass -File `"$ThisScript`""
        if (-not [String]::IsNullOrEmpty($InstallDir)) {
            $arg += " -InstallDir `"$InstallDir`""
        }
        Start-Process powershell.exe -Verb RunAs -ArgumentList $arg
        exit 0
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
        $sha.Clear()
    }
}

Ensure-Admin

try {
    foreach ($n in @("FeverGamesInstaller","FeverGamesLauncher","downloadIPC","FeverGamesService")) {
        if (Get-Process -Name $n -ErrorAction SilentlyContinue) {
            throw ("Please fully exit FeverGames first. Running process: " + $n)
        }
    }

    if ([String]::IsNullOrEmpty($InstallDir)) { throw "InstallDir is required." }
    $InstallDir = (Resolve-Path $InstallDir).Path

    $backupDir = $null

    foreach ($name in @("Win7_Downloader_Fix_Backup_v1.3","Win7_Bedrock_Fix_Backup_v1.2")) {
        $candidate = Join-Path $InstallDir $name

        if ((Test-Path (Join-Path $candidate "FeverGamesInstaller.exe.original")) -and
            (Test-Path (Join-Path $candidate "downloadIPC.exe.original"))) {
            $backupDir = $candidate
            break
        }
    }

    if ([String]::IsNullOrEmpty($backupDir)) {
        throw "No complete rollback backup was found in this version folder."
    }

    Copy-Item (Join-Path $backupDir "FeverGamesInstaller.exe.original") (Join-Path $InstallDir "FeverGamesInstaller.exe") -Force
    Copy-Item (Join-Path $backupDir "downloadIPC.exe.original") (Join-Path $InstallDir "downloadIPC.exe") -Force

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

    foreach ($markerName in @("Win7_Downloader_Fix_v1.3.installed.txt","Win7_Bedrock_Fix_v1.2.installed.txt")) {
        $marker = Join-Path $InstallDir $markerName
        if (Test-Path $marker) { Remove-Item $marker -Force }
    }

    Write-Host ""
    Ok "RESULT=RESTORE_COMPLETE"
    Info "Downloaded game files were NOT deleted."
    Info ("Backup folder kept: " + $backupDir)
}
catch {
    Err $_.Exception.Message
    exit 1
}
