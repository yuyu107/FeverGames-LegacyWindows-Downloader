param([string]$InstallDir = "")

$ErrorActionPreference = "Stop"
$ThisScript = $MyInvocation.MyCommand.Definition
$PackageVersion = "1.3.0"

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
        if (-not [String]::IsNullOrEmpty($InstallDir)) { $arg += " -InstallDir `"$InstallDir`"" }
        Start-Process powershell.exe -Verb RunAs -ArgumentList $arg
        exit 0
    }
}

function Assert-PlatformClosed {
    $busy = @()
    foreach ($n in @("FeverGamesInstaller","FeverGamesLauncher","downloadIPC","FeverGamesService")) {
        if (Get-Process -Name $n -ErrorAction SilentlyContinue) { $busy += $n }
    }
    if ($busy.Count -gt 0) { throw ("Please fully exit FeverGames first. Running process(es): " + ($busy -join ", ")) }
}

function Read-Bytes([string]$Path,[Int64]$Offset,[int]$Count) {
    $fs = New-Object System.IO.FileStream($Path,[System.IO.FileMode]::Open,[System.IO.FileAccess]::Read,[System.IO.FileShare]::ReadWrite)
    try {
        [void]$fs.Seek($Offset,[System.IO.SeekOrigin]::Begin)
        [byte[]]$buf = New-Object byte[] $Count
        $n = $fs.Read($buf,0,$Count)
        if ($n -ne $Count) { throw ("Short read at 0x" + ("{0:X}" -f $Offset)) }
        return ,$buf
    } finally { $fs.Dispose() }
}

function Write-Bytes([string]$Path,[Int64]$Offset,[byte[]]$Bytes) {
    $fs = New-Object System.IO.FileStream($Path,[System.IO.FileMode]::Open,[System.IO.FileAccess]::ReadWrite,[System.IO.FileShare]::Read)
    try {
        [void]$fs.Seek($Offset,[System.IO.SeekOrigin]::Begin)
        $fs.Write($Bytes,0,$Bytes.Length)
        $fs.Flush()
    } finally { $fs.Dispose() }
}

function Eq([byte[]]$A,[byte[]]$B) {
    if ($A -eq $null -or $B -eq $null -or $A.Length -ne $B.Length) { return $false }
    for ($i=0; $i -lt $A.Length; $i++) { if ($A[$i] -ne $B[$i]) { return $false } }
    return $true
}

function Hex([byte[]]$B) { return (($B | ForEach-Object { $_.ToString("X2") }) -join " ") }

function Get-Sha256([string]$Path) {
    $sha = [Security.Cryptography.SHA256]::Create()
    $fs = [IO.File]::OpenRead($Path)
    try {
        $hash = $sha.ComputeHash($fs)
        return (($hash | ForEach-Object { $_.ToString("x2") }) -join "")
    } finally {
        $fs.Dispose()
        $sha.Clear()
    }
}

function Is-ManagedExe([string]$Path) {
    if (-not (Test-Path $Path)) { return $false }
    try { [void][Reflection.AssemblyName]::GetAssemblyName($Path); return $true } catch { return $false }
}

function Find-Compiler {
    foreach ($c in @(
        "$env:WINDIR\Microsoft.NET\Framework64\v4.0.30319\csc.exe",
        "$env:WINDIR\Microsoft.NET\Framework\v4.0.30319\csc.exe",
        "$env:WINDIR\Microsoft.NET\Framework64\v3.5\csc.exe",
        "$env:WINDIR\Microsoft.NET\Framework\v3.5\csc.exe",
        "$env:WINDIR\Microsoft.NET\Framework64\v2.0.50727\csc.exe",
        "$env:WINDIR\Microsoft.NET\Framework\v2.0.50727\csc.exe"
    )) { if (Test-Path $c) { return $c } }
    return $null
}

function Find-Decoder([string]$Dir,[string]$ScriptDir) {
    foreach ($p in @((Join-Path $Dir "zstd.exe"),(Join-Path $ScriptDir "zstd.exe"),(Join-Path $ScriptDir "tools\zstd.exe"))) {
        if (Test-Path $p) { return @{ Type="zstd"; Path=(Resolve-Path $p).Path; NeedCopy=($p -ne (Join-Path $Dir "zstd.exe")) } }
    }
    foreach ($p in @((Join-Path $Dir "7z.exe"),"$env:ProgramFiles\7-Zip\7z.exe","${env:ProgramFiles(x86)}\7-Zip\7z.exe")) {
        if (-not [String]::IsNullOrEmpty($p) -and (Test-Path $p)) { return @{ Type="7zip"; Path=(Resolve-Path $p).Path; NeedCopy=$false } }
    }
    return $null
}

function Entry-MatchesKnownState([string]$Path,$Entry) {
    [byte[]]$now = Read-Bytes $Path $Entry.Offset $Entry.Original.Length
    if (Eq $now $Entry.Original) { return $true }
    if (Eq $now $Entry.Patched) { return $true }
    if ($Entry["AlternateBefore"] -ne $null -and (Eq $now $Entry.AlternateBefore)) { return $true }
    return $false
}

function Profile-MatchesKnownLayout([string]$Path,$Profile) {
    foreach ($entry in $Profile.Entries) {
        try { if (-not (Entry-MatchesKnownState $Path $entry)) { return $false } } catch { return $false }
    }
    return $true
}

function Resolve-PatchProfile([string]$Path,[string]$FolderBuild) {
    if ($FeverGamesPatchProfiles.ContainsKey($FolderBuild)) { return $FeverGamesPatchProfiles[$FolderBuild] }
    $matches = @()
    foreach ($key in $FeverGamesPatchProfiles.Keys) {
        $candidate = $FeverGamesPatchProfiles[$key]
        if (Profile-MatchesKnownLayout $Path $candidate) { $matches += $candidate }
    }
    if ($matches.Count -eq 1) {
        Warn ("Unknown folder version " + $FolderBuild + " matches known binary layout " + $matches[0].Build + ".")
        Warn "Proceeding with exact-byte validation for that known layout."
        return $matches[0]
    }
    if ($matches.Count -gt 1) { throw ("Folder version " + $FolderBuild + " matches multiple known layouts; refusing ambiguous patch.") }
    throw ("Unsupported FeverGames frontend build " + $FolderBuild + ". No known exact-byte layout matches.")
}

function Patch-Entry([string]$Path,$Entry) {
    [byte[]]$now = Read-Bytes $Path $Entry.Offset $Entry.Original.Length
    Info ($Entry.Name + " @ 0x" + ("{0:X}" -f $Entry.Offset) + ": " + (Hex $now))
    if (Eq $now $Entry.Patched) { Ok ($Entry.Name + " already patched."); return }
    $acceptable = (Eq $now $Entry.Original)
    if ((-not $acceptable) -and ($Entry["AlternateBefore"] -ne $null)) { $acceptable = (Eq $now $Entry.AlternateBefore) }
    if (-not $acceptable) { throw ($Entry.Name + " has unexpected bytes; refusing to modify this build.") }
    Write-Bytes $Path $Entry.Offset $Entry.Patched
    [byte[]]$verify = Read-Bytes $Path $Entry.Offset $Entry.Patched.Length
    if (-not (Eq $verify $Entry.Patched)) { throw ($Entry.Name + " verification failed.") }
    Ok ($Entry.Name + " patched.")
}

function Normalize-InstallerBackup([string]$Path,$Profile) {
    foreach ($entry in $Profile.Entries) {
        [byte[]]$now = Read-Bytes $Path $entry.Offset $entry.Original.Length
        if (Eq $now $entry.Original) { continue }
        if (Eq $now $entry.Patched) { Write-Bytes $Path $entry.Offset $entry.Original; continue }
        if (($entry["AlternateBefore"] -ne $null) -and (Eq $now $entry.AlternateBefore)) { Write-Bytes $Path $entry.Offset $entry.Original; continue }
        throw ("Cannot construct clean backup: " + $entry.Name + " bytes are unknown.")
    }
}

function Find-NativeOriginalDownloader([string]$Live,[string]$Dir) {
    if ((Test-Path $Live) -and (-not (Is-ManagedExe $Live))) { return $Live }
    foreach ($p in @(
        (Join-Path $Dir "Win7_Bedrock_Fix_Backup_v1.2\downloadIPC.exe.original"),
        (Join-Path $Dir "downloadIPC.before_win7_integrated_v1.1.exe"),
        (Join-Path $Dir "downloadIPC.before_zmq_emulator_v1.0.exe"),
        (Join-Path $Dir "downloadIPC.real.exe"),
        (Join-Path $Dir "downloadIPC.before_legacy_probe.exe"),
        (Join-Path $Dir "downloadIPC.original.exe")
    )) { if ((Test-Path $p) -and (-not (Is-ManagedExe $p))) { return $p } }
    return $null
}

Ensure-Admin
$scriptDir = Split-Path -Parent $ThisScript
. (Join-Path $scriptDir "FeverGames_PatchProfiles_v1.3.ps1")
$work = $null
$modified = $false

try {
    Write-Host "============================================================"
    Write-Host (" FeverGames Legacy Windows Downloader v" + $PackageVersion)
    Write-Host " Multi-build exact-byte frontend patch + Win7 downloader"
    Write-Host "============================================================"
    Write-Host ""
    Assert-PlatformClosed
    if ([String]::IsNullOrEmpty($InstallDir)) { throw "InstallDir was not supplied by the rolling version selector." }

    $InstallDir = (Resolve-Path $InstallDir).Path
    $installer = Join-Path $InstallDir "FeverGamesInstaller.exe"
    $downloader = Join-Path $InstallDir "downloadIPC.exe"
    if (-not (Test-Path $installer)) { throw "FeverGamesInstaller.exe is missing." }
    if (-not (Test-Path $downloader)) { throw "downloadIPC.exe is missing." }
    Info ("InstallDir: " + $InstallDir)

    $folderBuild = Split-Path -Leaf $InstallDir
    $profile = Resolve-PatchProfile $installer $folderBuild
    Ok ("Selected frontend patch profile: " + $profile.Build)

    $compiler = Find-Compiler
    if ([String]::IsNullOrEmpty($compiler)) { throw "No compatible .NET C# compiler was found (2.0/3.5/4.x)." }
    Ok ("C# compiler: " + $compiler)

    $decoder = Find-Decoder $InstallDir $scriptDir
    if ($decoder -eq $null) { throw "No Zstd decoder found. Install 7-Zip, or put standalone zstd.exe in this package's tools folder." }
    Ok ("Decoder: " + $decoder.Type + " -> " + $decoder.Path)

    $source = Join-Path $scriptDir "downloadIPC_Win7_v1.2.cs"
    if (-not (Test-Path $source)) { throw "downloadIPC_Win7_v1.2.cs is missing from the patch package." }

    $backupDir = Join-Path $InstallDir "Win7_Downloader_Fix_Backup_v1.3"
    $backupInstaller = Join-Path $backupDir "FeverGamesInstaller.exe.original"
    $backupDownloader = Join-Path $backupDir "downloadIPC.exe.original"
    $backupInfo = Join-Path $backupDir "backup_info.txt"
    if (-not (Test-Path $backupDir)) { New-Item -ItemType Directory -Path $backupDir | Out-Null }

    $work = Join-Path $env:TEMP ("FeverGames_LegacyWindows_v1.3_" + $PID)
    if (Test-Path $work) { Remove-Item $work -Recurse -Force }
    New-Item -ItemType Directory -Path $work | Out-Null
    $patchedInstaller = Join-Path $work "FeverGamesInstaller.patched.exe"
    $compiledDownloader = Join-Path $work "downloadIPC.v1.2.exe"
    Copy-Item $installer $patchedInstaller -Force

    foreach ($entry in $profile.Entries) { Patch-Entry $patchedInstaller $entry }

    Info "Compiling Win7 integrated downloadIPC core v1.2..."
    & $compiler /nologo /target:exe /optimize+ ("/out:" + $compiledDownloader) $source
    if (($LASTEXITCODE -ne 0) -or (-not (Test-Path $compiledDownloader))) { throw ("C# compile failed, csc exit=" + $LASTEXITCODE) }
    if (-not (Is-ManagedExe $compiledDownloader)) { throw "Compiled downloader did not validate as a managed .NET executable." }
    Ok "Win7 downloader compiled successfully."

    if (-not (Test-Path $backupInstaller)) {
        Copy-Item $installer $backupInstaller -Force
        Normalize-InstallerBackup $backupInstaller $profile
        Ok "Clean original FeverGamesInstaller backup created."
    } else { Info "Installer backup already exists; not overwritten." }

    if (-not (Test-Path $backupDownloader)) {
        $nativeOriginal = Find-NativeOriginalDownloader $downloader $InstallDir
        if ([String]::IsNullOrEmpty($nativeOriginal)) { throw "Could not find a native/original downloadIPC.exe for rollback backup." }
        Copy-Item $nativeOriginal $backupDownloader -Force
        Ok ("Original native downloadIPC backup created from: " + $nativeOriginal)
    } else { Info "Downloader backup already exists; not overwritten." }

    @(
        ("FeverGames Legacy Windows Downloader v" + $PackageVersion),
        ("Created: " + (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")),
        ("InstallDir: " + $InstallDir),
        ("Folder build: " + $folderBuild),
        ("Patch profile: " + $profile.Build),
        ("Installer original SHA256: " + (Get-Sha256 $backupInstaller)),
        ("downloadIPC original SHA256: " + (Get-Sha256 $backupDownloader))
    ) | Out-File -FilePath $backupInfo -Encoding UTF8

    if ($decoder.Type -eq "zstd" -and $decoder.NeedCopy) {
        $destZstd = Join-Path $InstallDir "zstd.exe"
        Copy-Item $decoder.Path $destZstd -Force
        (Get-Sha256 $destZstd) | Out-File (Join-Path $backupDir "copied_zstd.sha256") -Encoding ASCII
        Ok "Standalone zstd.exe copied beside downloadIPC.exe."
    }

    Copy-Item $patchedInstaller $installer -Force
    Copy-Item $compiledDownloader $downloader -Force
    $modified = $true

    foreach ($entry in $profile.Entries) {
        [byte[]]$verify = Read-Bytes $installer $entry.Offset $entry.Patched.Length
        if (-not (Eq $verify $entry.Patched)) { throw ("Post-install verification failed: " + $entry.Name) }
    }
    if (-not (Is-ManagedExe $downloader)) { throw "Post-install downloadIPC verification failed." }

    $marker = Join-Path $InstallDir "Win7_Downloader_Fix_v1.3.installed.txt"
    @(
        ("FeverGames Legacy Windows Downloader v" + $PackageVersion),
        ("Installed: " + (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")),
        ("Folder build: " + $folderBuild),
        ("Patch profile: " + $profile.Build),
        "Frontend unlock: OK",
        "download_check Win8.1 compatibility spoof: OK",
        "downloadIPC: managed Win7 replacement core v1.2",
        ("Backup: " + $backupDir)
    ) | Out-File -FilePath $marker -Encoding UTF8

    Write-Host ""
    Ok "ALL-IN-ONE INSTALL SUCCESS."
    Info "Now open FeverGames normally and test a download."
    Info "Use 02_Check_Status.cmd to verify the newest version folder."
}
catch {
    Write-Host ""
    Err $_.Exception.Message
    if ($modified) {
        Warn "Install failed after live files were changed. Rolling back..."
        try {
            if (Test-Path $backupInstaller) { Copy-Item $backupInstaller $installer -Force }
            if (Test-Path $backupDownloader) { Copy-Item $backupDownloader $downloader -Force }
            Ok "Automatic rollback completed."
        } catch {
            Err ("Automatic rollback also failed: " + $_.Exception.Message)
            Err ("Use the backup folder manually: " + $backupDir)
        }
    }
    exit 1
}
finally {
    if (-not [String]::IsNullOrEmpty($work)) {
        try { if (Test-Path $work) { Remove-Item $work -Recurse -Force } } catch {}
    }
}
