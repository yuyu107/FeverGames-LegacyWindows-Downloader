param([string]$InstallDir = "")

$ErrorActionPreference = "Stop"
$SupportedBuild = "1.18.42.12"

function Info($s){ Write-Host "[INFO] $s" }
function Ok($s){ Write-Host "[OK]   $s" }
function Warn($s){ Write-Host "[WARN] $s" }
function Err($s){ Write-Host "[ERR]  $s" }

function Find-InstallDir([string]$Requested) {
    if (-not [String]::IsNullOrEmpty($Requested)) {
        if (Test-Path $Requested -PathType Leaf) {
            $Requested = Split-Path -Parent $Requested
        }

        if ((Test-Path (Join-Path $Requested "FeverGamesInstaller.exe")) -and
            (Test-Path (Join-Path $Requested "downloadIPC.exe"))) {
            return (Resolve-Path $Requested).Path
        }
    }

    foreach ($d in @(
        "D:\Program Files\FeverGames\1.18.42.12",
        "C:\Program Files\FeverGames\1.18.42.12",
        "C:\Program Files (x86)\FeverGames\1.18.42.12"
    )) {
        if ((Test-Path (Join-Path $d "FeverGamesInstaller.exe")) -and
            (Test-Path (Join-Path $d "downloadIPC.exe"))) {
            return (Resolve-Path $d).Path
        }
    }

    foreach ($r in @(
        "D:\Program Files\FeverGames",
        "C:\Program Files\FeverGames",
        "C:\Program Files (x86)\FeverGames"
    )) {
        if (-not (Test-Path $r)) { continue }

        foreach ($d in (Get-ChildItem $r | Where-Object { $_.PSIsContainer } | Sort-Object Name -Descending)) {
            if ((Test-Path (Join-Path $d.FullName "FeverGamesInstaller.exe")) -and
                (Test-Path (Join-Path $d.FullName "downloadIPC.exe"))) {
                return $d.FullName
            }
        }
    }

    return $null
}

function Read-Bytes([string]$Path,[Int64]$Offset,[int]$Count) {
    $fs = New-Object System.IO.FileStream($Path,[System.IO.FileMode]::Open,[System.IO.FileAccess]::Read,[System.IO.FileShare]::ReadWrite)

    try {
        [void]$fs.Seek($Offset,[System.IO.SeekOrigin]::Begin)
        [byte[]]$b = New-Object byte[] $Count
        [void]$fs.Read($b,0,$Count)
        return ,$b
    }
    finally {
        $fs.Dispose()
    }
}

function Eq([byte[]]$A,[byte[]]$B) {
    if ($A.Length -ne $B.Length) { return $false }

    for ($i=0; $i -lt $A.Length; $i++) {
        if ($A[$i] -ne $B[$i]) { return $false }
    }

    return $true
}

function Is-ManagedExe([string]$Path) {
    try {
        [void][Reflection.AssemblyName]::GetAssemblyName($Path)
        return $true
    }
    catch {
        return $false
    }
}

[byte[]]$GateAPatched = @(0xB8,0x01,0x00,0x00,0x00,0xC3)
[byte[]]$GateBPatched = @(0x90,0xE9,0xB3,0x00,0x00,0x00)
[byte[]]$NetLabelPatched = @(0x48,0x8D,0x15,0x05,0x7A,0x4B,0x00)
[byte[]]$NetMinorPatched = @(0x6A,0x03,0x5A)
[byte[]]$Getter81 = @(
    0xC7,0x01,0x38,0x2E,0x31,0x00,
    0x48,0xC7,0x41,0x10,0x03,0x00,0x00,0x00,
    0x48,0xC7,0x41,0x18,0x0F,0x00,0x00,0x00,
    0x48,0x8B,0xC1,
    0xC3,
    0x90,0x90,0x90
)

try {
    Write-Host "============================================================"
    Write-Host " FeverGames Win7 Bedrock Fix v1.2 - Status"
    Write-Host "============================================================"

    $InstallDir = Find-InstallDir $InstallDir

    if ([String]::IsNullOrEmpty($InstallDir)) {
        throw "FeverGames installation directory not found."
    }

    $installer = Join-Path $InstallDir "FeverGamesInstaller.exe"
    $downloader = Join-Path $InstallDir "downloadIPC.exe"
    $backupDir = Join-Path $InstallDir "Win7_Bedrock_Fix_Backup_v1.2"
    $marker = Join-Path $InstallDir "Win7_Bedrock_Fix_v1.2.installed.txt"

    Info ("InstallDir: " + $InstallDir)
    Info ("Folder build: " + (Split-Path -Leaf $InstallDir))

    $okCount = 0

    $checks = @(
        @{Name="Gate A"; Offset=0xA64460; Bytes=$GateAPatched},
        @{Name="Gate B"; Offset=0x6EE624; Bytes=$GateBPatched},
        @{Name="download_check os-ver label"; Offset=0xA07B5C; Bytes=$NetLabelPatched},
        @{Name="download_check minor"; Offset=0xA07BD2; Bytes=$NetMinorPatched},
        @{Name="sysVer getter -> 8.1"; Offset=0xA09220; Bytes=$Getter81}
    )

    foreach ($c in $checks) {
        [byte[]]$now = Read-Bytes $installer $c.Offset $c.Bytes.Length

        if (Eq $now $c.Bytes) {
            Ok ($c.Name + " = PATCHED")
            $okCount++
        } else {
            Warn ($c.Name + " = NOT v1.2 PATCH")
        }
    }

    if (Is-ManagedExe $downloader) {
        Ok "downloadIPC.exe = managed Win7 replacement"
        $downloaderOk = $true
    } else {
        Warn "downloadIPC.exe = native/original downloader"
        $downloaderOk = $false
    }

    if (Test-Path $marker) {
        Ok "v1.2 install marker present"
    } else {
        Warn "v1.2 install marker missing"
    }

    if ((Test-Path (Join-Path $backupDir "FeverGamesInstaller.exe.original")) -and
        (Test-Path (Join-Path $backupDir "downloadIPC.exe.original"))) {
        Ok "rollback backup = COMPLETE"
    } else {
        Warn "rollback backup = INCOMPLETE / MISSING"
    }

    $decoderOk = $false

    foreach ($p in @(
        (Join-Path $InstallDir "zstd.exe"),
        (Join-Path $InstallDir "7z.exe"),
        "$env:ProgramFiles\7-Zip\7z.exe",
        "${env:ProgramFiles(x86)}\7-Zip\7z.exe"
    )) {
        if (-not [String]::IsNullOrEmpty($p) -and (Test-Path $p)) {
            Ok ("decoder = " + $p)
            $decoderOk = $true
            break
        }
    }

    if (-not $decoderOk) {
        Warn "No zstd.exe / 7z.exe detected."
    }

    Write-Host ""
    Info ("Frontend patch count: " + $okCount + "/5")

    if (($okCount -eq 5) -and $downloaderOk -and $decoderOk) {
        Write-Host ""
        Ok "RESULT=READY_FOR_WIN7_BEDROCK_DOWNLOAD"
        exit 0
    }

    Write-Host ""
    Warn "RESULT=PATCH_INCOMPLETE_OR_CHANGED"
    Warn "If FeverGames updated itself, rerun 01_Zero_Start_One_Click_Install.cmd."
    exit 2
}
catch {
    Err $_.Exception.Message
    exit 1
}
