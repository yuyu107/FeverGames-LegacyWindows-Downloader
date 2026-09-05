param([string]$InstallDir = "")

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
. (Join-Path $scriptDir "FeverGames_PatchProfiles_v1.3.ps1")

function Info($s){ Write-Host "[INFO] $s" }
function Ok($s){ Write-Host "[OK]   $s" }
function Warn($s){ Write-Host "[WARN] $s" }
function Err($s){ Write-Host "[ERR]  $s" }

function Read-Bytes([string]$Path,[Int64]$Offset,[int]$Count) {
    $fs = New-Object System.IO.FileStream($Path,[System.IO.FileMode]::Open,[System.IO.FileAccess]::Read,[System.IO.FileShare]::ReadWrite)
    try {
        [void]$fs.Seek($Offset,[System.IO.SeekOrigin]::Begin)
        [byte[]]$b = New-Object byte[] $Count
        $n = $fs.Read($b,0,$Count)
        if ($n -ne $Count) { throw "Short read." }
        return ,$b
    } finally { $fs.Dispose() }
}

function Eq([byte[]]$A,[byte[]]$B) {
    if ($A -eq $null -or $B -eq $null -or $A.Length -ne $B.Length) { return $false }
    for ($i=0; $i -lt $A.Length; $i++) { if ($A[$i] -ne $B[$i]) { return $false } }
    return $true
}

function Is-ManagedExe([string]$Path) {
    try { [void][Reflection.AssemblyName]::GetAssemblyName($Path); return $true } catch { return $false }
}

function Profile-Matches([string]$Path,$Profile) {
    foreach ($entry in $Profile.Entries) {
        try {
            [byte[]]$now = Read-Bytes $Path $entry.Offset $entry.Original.Length
            if (Eq $now $entry.Original) { continue }
            if (Eq $now $entry.Patched) { continue }
            if (($entry["AlternateBefore"] -ne $null) -and (Eq $now $entry.AlternateBefore)) { continue }
            return $false
        } catch { return $false }
    }
    return $true
}

try {
    Write-Host "============================================================"
    Write-Host " FeverGames Legacy Windows Downloader v1.3 - Status"
    Write-Host "============================================================"
    if ([String]::IsNullOrEmpty($InstallDir)) { throw "InstallDir is required." }

    $InstallDir = (Resolve-Path $InstallDir).Path
    $installer = Join-Path $InstallDir "FeverGamesInstaller.exe"
    $downloader = Join-Path $InstallDir "downloadIPC.exe"
    $folderBuild = Split-Path -Leaf $InstallDir
    Info ("InstallDir: " + $InstallDir)
    Info ("Folder build: " + $folderBuild)

    $profile = $null
    if ($FeverGamesPatchProfiles.ContainsKey($folderBuild)) {
        $profile = $FeverGamesPatchProfiles[$folderBuild]
    } else {
        $matches = @()
        foreach ($key in $FeverGamesPatchProfiles.Keys) {
            $candidate = $FeverGamesPatchProfiles[$key]
            if (Profile-Matches $installer $candidate) { $matches += $candidate }
        }
        if ($matches.Count -eq 1) {
            $profile = $matches[0]
            Warn ("Unknown folder build matches known layout " + $profile.Build + ".")
        }
    }

    if ($profile -eq $null) {
        Warn "No known frontend patch profile matches this version."
        Write-Host ""
        Warn "RESULT=UNSUPPORTED_OR_CHANGED_FRONTEND"
        exit 3
    }

    Ok ("Patch profile: " + $profile.Build)
    $okCount = 0
    foreach ($entry in $profile.Entries) {
        [byte[]]$now = Read-Bytes $installer $entry.Offset $entry.Patched.Length
        if (Eq $now $entry.Patched) { Ok ($entry.Name + " = PATCHED"); $okCount++ }
        elseif (Eq $now $entry.Original) { Warn ($entry.Name + " = ORIGINAL / NOT PATCHED") }
        else { Warn ($entry.Name + " = UNKNOWN") }
    }

    $downloaderOk = $false
    if (Is-ManagedExe $downloader) { Ok "downloadIPC.exe = managed Win7 replacement"; $downloaderOk = $true }
    else { Warn "downloadIPC.exe = native/original downloader" }

    $backupOk = $false
    foreach ($backupName in @("Win7_Downloader_Fix_Backup_v1.3","Win7_Bedrock_Fix_Backup_v1.2")) {
        $bd = Join-Path $InstallDir $backupName
        if ((Test-Path (Join-Path $bd "FeverGamesInstaller.exe.original")) -and (Test-Path (Join-Path $bd "downloadIPC.exe.original"))) {
            Ok ("rollback backup = COMPLETE (" + $backupName + ")")
            $backupOk = $true
            break
        }
    }
    if (-not $backupOk) { Warn "rollback backup = INCOMPLETE / MISSING" }

    $decoderOk = $false
    foreach ($p in @((Join-Path $InstallDir "zstd.exe"),(Join-Path $InstallDir "7z.exe"),"$env:ProgramFiles\7-Zip\7z.exe","${env:ProgramFiles(x86)}\7-Zip\7z.exe")) {
        if (-not [String]::IsNullOrEmpty($p) -and (Test-Path $p)) { Ok ("decoder = " + $p); $decoderOk = $true; break }
    }
    if (-not $decoderOk) { Warn "No zstd.exe / 7z.exe detected." }

    Write-Host ""
    Info ("Frontend patch count: " + $okCount + "/5")
    if (($okCount -eq 5) -and $downloaderOk -and $decoderOk) {
        Write-Host ""
        Ok "RESULT=READY_FOR_WIN7_FEVERGAMES_DOWNLOAD"
        exit 0
    }

    Write-Host ""
    Warn "RESULT=PATCH_INCOMPLETE_OR_CHANGED"
    exit 2
}
catch { Err $_.Exception.Message; exit 1 }
