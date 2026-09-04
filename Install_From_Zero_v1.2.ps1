param([string]$InstallDir = "")

$ErrorActionPreference = "Stop"
$ThisScript = $MyInvocation.MyCommand.Definition
$SupportedBuild = "1.18.42.12"

function Info($s){ Write-Host "[INFO] $s" }
function Ok($s){ Write-Host "[OK]   $s" }
function Warn($s){ Write-Host "[WARN] $s" }
function Err($s){ Write-Host "[ERR]  $s" }

function Ensure-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($id)
    $admin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if (-not $admin) {
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
            if ([IO.Path]::GetFileName($Requested) -ieq "FeverGamesInstaller.exe") {
                $Requested = Split-Path -Parent $Requested
            }
        }

        if (Test-Path (Join-Path $Requested "FeverGamesInstaller.exe")) {
            if (Test-Path (Join-Path $Requested "downloadIPC.exe")) {
                return (Resolve-Path $Requested).Path
            }
        }
    }

    $exact = @(
        "D:\Program Files\FeverGames\1.18.42.12",
        "C:\Program Files\FeverGames\1.18.42.12",
        "C:\Program Files (x86)\FeverGames\1.18.42.12"
    )

    foreach ($d in $exact) {
        if ((Test-Path (Join-Path $d "FeverGamesInstaller.exe")) -and
            (Test-Path (Join-Path $d "downloadIPC.exe"))) {
            return (Resolve-Path $d).Path
        }
    }

    $roots = @(
        "D:\Program Files\FeverGames",
        "C:\Program Files\FeverGames",
        "C:\Program Files (x86)\FeverGames"
    )

    foreach ($r in $roots) {
        if (-not (Test-Path $r)) { continue }

        $dirs = Get-ChildItem $r | Where-Object { $_.PSIsContainer } | Sort-Object Name -Descending

        foreach ($d in $dirs) {
            if ((Test-Path (Join-Path $d.FullName "FeverGamesInstaller.exe")) -and
                (Test-Path (Join-Path $d.FullName "downloadIPC.exe"))) {
                return $d.FullName
            }
        }
    }

    return $null
}

function Assert-PlatformClosed {
    $names = @(
        "FeverGamesInstaller",
        "FeverGamesLauncher",
        "downloadIPC",
        "FeverGamesService"
    )

    $busy = @()

    foreach ($n in $names) {
        $p = Get-Process -Name $n -ErrorAction SilentlyContinue

        if ($p) {
            $busy += $n
        }
    }

    if ($busy.Count -gt 0) {
        throw ("Please fully exit FeverGames first. Running process(es): " + ($busy -join ", "))
    }
}

function Read-Bytes([string]$Path,[Int64]$Offset,[int]$Count) {
    $fs = New-Object System.IO.FileStream(
        $Path,
        [System.IO.FileMode]::Open,
        [System.IO.FileAccess]::Read,
        [System.IO.FileShare]::ReadWrite
    )

    try {
        [void]$fs.Seek($Offset,[System.IO.SeekOrigin]::Begin)
        [byte[]]$b = New-Object byte[] $Count
        $n = $fs.Read($b,0,$Count)

        if ($n -ne $Count) {
            throw ("Short read at 0x" + ("{0:X}" -f $Offset))
        }

        return ,$b
    }
    finally {
        $fs.Dispose()
    }
}

function Write-Bytes([string]$Path,[Int64]$Offset,[byte[]]$Bytes) {
    $fs = New-Object System.IO.FileStream(
        $Path,
        [System.IO.FileMode]::Open,
        [System.IO.FileAccess]::ReadWrite,
        [System.IO.FileShare]::Read
    )

    try {
        [void]$fs.Seek($Offset,[System.IO.SeekOrigin]::Begin)
        $fs.Write($Bytes,0,$Bytes.Length)
        $fs.Flush()
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

function Hex([byte[]]$B) {
    return (($B | ForEach-Object { $_.ToString("X2") }) -join " ")
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

function Is-ManagedExe([string]$Path) {
    if (-not (Test-Path $Path)) { return $false }

    try {
        [void][Reflection.AssemblyName]::GetAssemblyName($Path)
        return $true
    }
    catch {
        return $false
    }
}

function Find-Compiler {
    $candidates = @(
        "$env:WINDIR\Microsoft.NET\Framework64\v4.0.30319\csc.exe",
        "$env:WINDIR\Microsoft.NET\Framework\v4.0.30319\csc.exe",
        "$env:WINDIR\Microsoft.NET\Framework64\v3.5\csc.exe",
        "$env:WINDIR\Microsoft.NET\Framework\v3.5\csc.exe",
        "$env:WINDIR\Microsoft.NET\Framework64\v2.0.50727\csc.exe",
        "$env:WINDIR\Microsoft.NET\Framework\v2.0.50727\csc.exe"
    )

    foreach ($c in $candidates) {
        if (Test-Path $c) { return $c }
    }

    return $null
}

function Find-Decoder([string]$Dir,[string]$ScriptDir) {
    $zstdCandidates = @(
        (Join-Path $Dir "zstd.exe"),
        (Join-Path $ScriptDir "zstd.exe"),
        (Join-Path $ScriptDir "tools\zstd.exe")
    )

    foreach ($p in $zstdCandidates) {
        if (Test-Path $p) {
            return @{
                Type="zstd";
                Path=(Resolve-Path $p).Path;
                NeedCopy=($p -ne (Join-Path $Dir "zstd.exe"))
            }
        }
    }

    $sevenCandidates = @(
        (Join-Path $Dir "7z.exe"),
        "$env:ProgramFiles\7-Zip\7z.exe",
        "${env:ProgramFiles(x86)}\7-Zip\7z.exe"
    )

    foreach ($p in $sevenCandidates) {
        if (-not [String]::IsNullOrEmpty($p) -and (Test-Path $p)) {
            return @{
                Type="7zip";
                Path=(Resolve-Path $p).Path;
                NeedCopy=$false
            }
        }
    }

    return $null
}

# Exact 1.18.42.12 patch data.
[byte[]]$GateAOrig = @(0x40,0x53,0x48,0x81,0xEC,0x50)
[byte[]]$GateAPatched = @(0xB8,0x01,0x00,0x00,0x00,0xC3)

[byte[]]$GateBOrig = @(0x0F,0x85,0xB3,0x00,0x00,0x00)
[byte[]]$GateBPatched = @(0x90,0xE9,0xB3,0x00,0x00,0x00)

[byte[]]$NetLabelOrig = @(0x48,0x8D,0x15,0xE5,0x79,0x4B,0x00)
[byte[]]$NetLabelPatched = @(0x48,0x8D,0x15,0x05,0x7A,0x4B,0x00)

[byte[]]$NetMinorOrig = @(0x8B,0x55,0xA7)
[byte[]]$NetMinorPatched = @(0x6A,0x03,0x5A)

[byte[]]$GetterOrig = @(
    0x48,0x89,0x4C,0x24,0x08,
    0x53,
    0x48,0x83,0xEC,0x20,
    0x48,0x8B,0xD9,
    0x8B,0x15,0x65,0x2B,0x23,0x04,
    0x65,0x48,0x8B,0x04,0x25,0x58,0x00,0x00,0x00,
    0xB9
)

[byte[]]$Getter81 = @(
    0xC7,0x01,0x38,0x2E,0x31,0x00,
    0x48,0xC7,0x41,0x10,0x03,0x00,0x00,0x00,
    0x48,0xC7,0x41,0x18,0x0F,0x00,0x00,0x00,
    0x48,0x8B,0xC1,
    0xC3,
    0x90,0x90,0x90
)

[byte[]]$Getter10 = @(
    0x66,0xC7,0x01,0x31,0x30,
    0xC6,0x41,0x02,0x00,
    0x48,0xC7,0x41,0x10,0x02,0x00,0x00,0x00,
    0x48,0xC7,0x41,0x18,0x0F,0x00,0x00,0x00,
    0x48,0x8B,0xC1,
    0xC3
)

function Patch-Normal([string]$Path,[string]$Name,[Int64]$Offset,[byte[]]$Original,[byte[]]$Patched) {
    [byte[]]$now = Read-Bytes $Path $Offset $Original.Length
    Info ($Name + ": " + (Hex $now))

    if (Eq $now $Patched) {
        Ok ($Name + " already patched.")
        return
    }

    if (-not (Eq $now $Original)) {
        throw ($Name + " has unexpected bytes; refusing to modify this build.")
    }

    Write-Bytes $Path $Offset $Patched

    [byte[]]$verify = Read-Bytes $Path $Offset $Patched.Length

    if (-not (Eq $verify $Patched)) {
        throw ($Name + " verification failed.")
    }

    Ok ($Name + " patched.")
}

function Patch-Getter([string]$Path) {
    [byte[]]$now = Read-Bytes $Path 0xA09220 $GetterOrig.Length
    Info ("downloadIPC sysVer getter: " + (Hex $now))

    if (Eq $now $Getter81) {
        Ok "downloadIPC sysVer getter already returns 8.1."
        return
    }

    if ((Eq $now $GetterOrig) -or (Eq $now $Getter10)) {
        Write-Bytes $Path 0xA09220 $Getter81
        [byte[]]$verify = Read-Bytes $Path 0xA09220 $Getter81.Length

        if (-not (Eq $verify $Getter81)) {
            throw "sysVer getter verification failed."
        }

        Ok "downloadIPC sysVer getter patched to 8.1."
        return
    }

    throw "sysVer getter has unexpected bytes; refusing to modify this build."
}

function Normalize-InstallerBackup([string]$Path) {
    $pairs = @(
        @{Name="Gate A"; Offset=0xA64460; Orig=$GateAOrig; Patched=$GateAPatched},
        @{Name="Gate B"; Offset=0x6EE624; Orig=$GateBOrig; Patched=$GateBPatched},
        @{Name="Network label"; Offset=0xA07B5C; Orig=$NetLabelOrig; Patched=$NetLabelPatched},
        @{Name="Network minor"; Offset=0xA07BD2; Orig=$NetMinorOrig; Patched=$NetMinorPatched}
    )

    foreach ($p in $pairs) {
        [byte[]]$now = Read-Bytes $Path $p.Offset $p.Orig.Length

        if (Eq $now $p.Orig) {
            continue
        }

        if (Eq $now $p.Patched) {
            Write-Bytes $Path $p.Offset $p.Orig
            continue
        }

        throw ("Cannot construct clean backup: " + $p.Name + " bytes are unknown.")
    }

    [byte[]]$g = Read-Bytes $Path 0xA09220 $GetterOrig.Length

    if (Eq $g $GetterOrig) {
        return
    }

    if ((Eq $g $Getter81) -or (Eq $g $Getter10)) {
        Write-Bytes $Path 0xA09220 $GetterOrig
        return
    }

    throw "Cannot construct clean backup: sysVer getter bytes are unknown."
}

function Find-NativeOriginalDownloader([string]$Live,[string]$Dir) {
    if ((Test-Path $Live) -and (-not (Is-ManagedExe $Live))) {
        return $Live
    }

    $candidates = @(
        (Join-Path $Dir "downloadIPC.before_win7_integrated_v1.1.exe"),
        (Join-Path $Dir "downloadIPC.before_zmq_emulator_v1.0.exe"),
        (Join-Path $Dir "downloadIPC.real.exe"),
        (Join-Path $Dir "downloadIPC.before_legacy_probe.exe"),
        (Join-Path $Dir "downloadIPC.original.exe")
    )

    foreach ($p in $candidates) {
        if ((Test-Path $p) -and (-not (Is-ManagedExe $p))) {
            return $p
        }
    }

    return $null
}

Ensure-Admin

$scriptDir = Split-Path -Parent $ThisScript
$work = $null
$modified = $false
$copiedZstd = $false

try {
    Write-Host "============================================================"
    Write-Host " FeverGames Win7 Bedrock Zero-Start Fix v1.2"
    Write-Host " Stock 1.18.42.12 -> frontend unlock + Win7 downloader"
    Write-Host "============================================================"
    Write-Host ""

    Assert-PlatformClosed

    $InstallDir = Find-InstallDir $InstallDir

    if ([String]::IsNullOrEmpty($InstallDir)) {
        throw "FeverGames installation directory was not found."
    }

    $installer = Join-Path $InstallDir "FeverGamesInstaller.exe"
    $downloader = Join-Path $InstallDir "downloadIPC.exe"

    Info ("InstallDir: " + $InstallDir)

    $folderBuild = Split-Path -Leaf $InstallDir

    if ($folderBuild -ne $SupportedBuild) {
        Warn ("Folder version is " + $folderBuild + ", expected " + $SupportedBuild + ".")
        Warn "This patch still performs exact byte checks and will refuse unknown builds."
    } else {
        Ok ("Supported FeverGames build folder: " + $SupportedBuild)
    }

    $compiler = Find-Compiler

    if ([String]::IsNullOrEmpty($compiler)) {
        throw "No compatible .NET C# compiler was found (2.0/3.5/4.x)."
    }

    Ok ("C# compiler: " + $compiler)

    $decoder = Find-Decoder $InstallDir $scriptDir

    if ($decoder -eq $null) {
        throw "No Zstd decoder found. Install 7-Zip, or put standalone zstd.exe in this package's tools folder."
    }

    Ok ("Decoder: " + $decoder.Type + " -> " + $decoder.Path)

    $source = Join-Path $scriptDir "downloadIPC_Win7_v1.2.cs"

    if (-not (Test-Path $source)) {
        throw "downloadIPC_Win7_v1.2.cs is missing from the patch package."
    }

    $backupDir = Join-Path $InstallDir "Win7_Bedrock_Fix_Backup_v1.2"
    $backupInstaller = Join-Path $backupDir "FeverGamesInstaller.exe.original"
    $backupDownloader = Join-Path $backupDir "downloadIPC.exe.original"
    $backupInfo = Join-Path $backupDir "backup_info.txt"

    if (-not (Test-Path $backupDir)) {
        New-Item -ItemType Directory -Path $backupDir | Out-Null
    }

    $work = Join-Path $env:TEMP ("FeverGames_ZeroStart_v1.2_" + $PID)

    if (Test-Path $work) {
        Remove-Item $work -Recurse -Force
    }

    New-Item -ItemType Directory -Path $work | Out-Null

    $patchedInstaller = Join-Path $work "FeverGamesInstaller.patched.exe"
    $compiledDownloader = Join-Path $work "downloadIPC.v1.2.exe"

    Copy-Item $installer $patchedInstaller -Force

    Patch-Normal $patchedInstaller "Gate A - central Win10 helper" 0xA64460 $GateAOrig $GateAPatched
    Patch-Normal $patchedInstaller "Gate B - checkSystemVersion caller" 0x6EE624 $GateBOrig $GateBPatched
    Patch-Normal $patchedInstaller "download_check os-ver label Win7 -> Win8.1" 0xA07B5C $NetLabelOrig $NetLabelPatched
    Patch-Normal $patchedInstaller "download_check minor 1 -> 3" 0xA07BD2 $NetMinorOrig $NetMinorPatched
    Patch-Getter $patchedInstaller

    Info "Compiling Win7 integrated downloadIPC v1.2..."

    & $compiler /nologo /target:exe /optimize+ ("/out:" + $compiledDownloader) $source

    if (($LASTEXITCODE -ne 0) -or (-not (Test-Path $compiledDownloader))) {
        throw ("C# compile failed, csc exit=" + $LASTEXITCODE)
    }

    if (-not (Is-ManagedExe $compiledDownloader)) {
        throw "Compiled downloader did not validate as a managed .NET executable."
    }

    Ok "Win7 downloader compiled successfully."

    if (-not (Test-Path $backupInstaller)) {
        Copy-Item $installer $backupInstaller -Force
        Normalize-InstallerBackup $backupInstaller
        Ok "Clean original FeverGamesInstaller backup created."
    } else {
        Info "Installer backup already exists; not overwritten."
    }

    if (-not (Test-Path $backupDownloader)) {
        $nativeOriginal = Find-NativeOriginalDownloader $downloader $InstallDir

        if ([String]::IsNullOrEmpty($nativeOriginal)) {
            throw "Could not find a native/original downloadIPC.exe for rollback backup."
        }

        Copy-Item $nativeOriginal $backupDownloader -Force
        Ok ("Original native downloadIPC backup created from: " + $nativeOriginal)
    } else {
        Info "Downloader backup already exists; not overwritten."
    }

    $infoLines = @()
    $infoLines += "FeverGames Win7 Bedrock Zero-Start Fix v1.2"
    $infoLines += ("Created: " + (Get-Date).ToString("yyyy-MM-dd HH:mm:ss"))
    $infoLines += ("InstallDir: " + $InstallDir)
    $infoLines += ("Expected build: " + $SupportedBuild)
    $infoLines += ("Installer original SHA256: " + (Get-Sha256 $backupInstaller))
    $infoLines += ("downloadIPC original SHA256: " + (Get-Sha256 $backupDownloader))
    $infoLines | Out-File -FilePath $backupInfo -Encoding UTF8

    if ($decoder.Type -eq "zstd" -and $decoder.NeedCopy) {
        $destZstd = Join-Path $InstallDir "zstd.exe"
        Copy-Item $decoder.Path $destZstd -Force
        $zstdHash = Get-Sha256 $destZstd
        $zstdHash | Out-File (Join-Path $backupDir "copied_zstd.sha256") -Encoding ASCII
        $copiedZstd = $true
        Ok "Standalone zstd.exe copied beside downloadIPC.exe."
    }

    Copy-Item $patchedInstaller $installer -Force
    Copy-Item $compiledDownloader $downloader -Force
    $modified = $true

    [byte[]]$verifyA = Read-Bytes $installer 0xA64460 $GateAPatched.Length
    [byte[]]$verifyB = Read-Bytes $installer 0x6EE624 $GateBPatched.Length
    [byte[]]$verifyC = Read-Bytes $installer 0xA07B5C $NetLabelPatched.Length
    [byte[]]$verifyD = Read-Bytes $installer 0xA07BD2 $NetMinorPatched.Length
    [byte[]]$verifyG = Read-Bytes $installer 0xA09220 $Getter81.Length

    if ((-not (Eq $verifyA $GateAPatched)) -or
        (-not (Eq $verifyB $GateBPatched)) -or
        (-not (Eq $verifyC $NetLabelPatched)) -or
        (-not (Eq $verifyD $NetMinorPatched)) -or
        (-not (Eq $verifyG $Getter81))) {
        throw "Post-install FeverGamesInstaller patch verification failed."
    }

    if (-not (Is-ManagedExe $downloader)) {
        throw "Post-install downloadIPC verification failed."
    }

    $marker = Join-Path $InstallDir "Win7_Bedrock_Fix_v1.2.installed.txt"

    @(
        "FeverGames Win7 Bedrock Zero-Start Fix v1.2",
        ("Installed: " + (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")),
        ("Build: " + $folderBuild),
        "Frontend unlock: OK",
        "download_check Win8.1 compatibility spoof: OK",
        "downloadIPC: managed Win7 replacement v1.2",
        ("Backup: " + $backupDir)
    ) | Out-File -FilePath $marker -Encoding UTF8

    Write-Host ""
    Ok "ALL-IN-ONE INSTALL SUCCESS."
    Write-Host ""
    Info "No old v2.0 / v1.0 / v1.1 patch needs to be applied first."
    Info "Now open FeverGames normally and click the Bedrock download button."
    Info "If FeverGames updates/replaces its own files later, rerun this installer."
    Info "Use 02_Check_Status.cmd at any time to verify the patch."
}
catch {
    Write-Host ""
    Err $_.Exception.Message

    if ($modified) {
        Warn "Install failed after live files were changed. Rolling back..."

        try {
            if (Test-Path $backupInstaller) {
                Copy-Item $backupInstaller $installer -Force
            }

            if (Test-Path $backupDownloader) {
                Copy-Item $backupDownloader $downloader -Force
            }

            Ok "Automatic rollback completed."
        }
        catch {
            Err ("Automatic rollback also failed: " + $_.Exception.Message)
            Err ("Use the backup folder manually: " + $backupDir)
        }
    }

    exit 1
}
finally {
    if (-not [String]::IsNullOrEmpty($work)) {
        try {
            if (Test-Path $work) {
                Remove-Item $work -Recurse -Force
            }
        }
        catch {}
    }
}
