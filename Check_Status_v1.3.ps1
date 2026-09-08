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
    }
    finally { $fs.Close() }
}

function Eq([byte[]]$A,[byte[]]$B) {
    if ($A -eq $null -or $B -eq $null) { return $false }
    if ($A.Length -ne $B.Length) { return $false }
    for ($i=0; $i -lt $A.Length; $i++) {
        if ($A[$i] -ne $B[$i]) { return $false }
    }
    return $true
}

function Is-ManagedExe([string]$Path) {
    if (-not (Test-Path $Path -PathType Leaf)) { return $false }
    $fs = $null
    $br = $null
    try {
        $fs = New-Object System.IO.FileStream(
            $Path,
            [System.IO.FileMode]::Open,
            [System.IO.FileAccess]::Read,
            [System.IO.FileShare]::ReadWrite
        )
        $br = New-Object System.IO.BinaryReader -ArgumentList $fs
        if ($fs.Length -lt 256) { return $false }
        if ($br.ReadUInt16() -ne 0x5A4D) { return $false }
        [void]$fs.Seek(0x3C,[System.IO.SeekOrigin]::Begin)
        $peOffset = $br.ReadInt32()
        if ($peOffset -lt 0 -or ([Int64]$peOffset + 24) -gt $fs.Length) { return $false }
        [void]$fs.Seek($peOffset,[System.IO.SeekOrigin]::Begin)
        if ($br.ReadUInt32() -ne 0x00004550) { return $false }
        [void]$fs.Seek(([Int64]$peOffset + 20),[System.IO.SeekOrigin]::Begin)
        $optionalSize = $br.ReadUInt16()
        $optionalStart = [Int64]$peOffset + 24
        if ($optionalSize -lt 2 -or ($optionalStart + $optionalSize) -gt $fs.Length) { return $false }
        [void]$fs.Seek($optionalStart,[System.IO.SeekOrigin]::Begin)
        $magic = $br.ReadUInt16()
        if ($magic -eq 0x10B) { $dataDirectoryStart = $optionalStart + 96 }
        elseif ($magic -eq 0x20B) { $dataDirectoryStart = $optionalStart + 112 }
        else { return $false }
        $clrEntry = $dataDirectoryStart + (14 * 8)
        if (($clrEntry + 8) -gt ($optionalStart + $optionalSize)) { return $false }
        [void]$fs.Seek($clrEntry,[System.IO.SeekOrigin]::Begin)
        $clrRva = $br.ReadUInt32()
        $clrSize = $br.ReadUInt32()
        return (($clrRva -ne 0) -and ($clrSize -ne 0))
    }
    catch { return $false }
    finally {
        if ($br -ne $null) { $br.Close() }
        elseif ($fs -ne $null) { $fs.Close() }
    }
}

function Profile-Matches([string]$Path,$Profile) {
    foreach ($entry in $Profile.Entries) {
        try {
            [byte[]]$now = Read-Bytes $Path $entry.Offset $entry.Original.Length
            if (Eq $now $entry.Original) { continue }
            if (Eq $now $entry.Patched) { continue }
            if (($entry["AlternateBefore"] -ne $null) -and (Eq $now $entry.AlternateBefore)) { continue }
            return $false
        }
        catch { return $false }
    }
    return $true
}

function Add-DecoderCandidate([System.Collections.ArrayList]$List,[string]$Path) {
    if ([String]::IsNullOrEmpty($Path)) { return }
    try {
        if (Test-Path $Path) {
            $full = (Resolve-Path $Path).Path
            if (-not $List.Contains($full)) { [void]$List.Add($full) }
        }
    } catch {}
}

function Find-CommandPath([string]$Name) {
    try {
        $cmd = Get-Command $Name -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($cmd -ne $null) {
            if (-not [String]::IsNullOrEmpty($cmd.Path)) { return $cmd.Path }
            if (-not [String]::IsNullOrEmpty($cmd.Definition) -and (Test-Path $cmd.Definition)) {
                return $cmd.Definition
            }
        }
    } catch {}
    return ""
}

function Find-InstalledDecoder([string]$Dir) {
    foreach ($p in @(
        (Join-Path $Dir "zstd.exe"),
        (Find-CommandPath "zstd.exe")
    )) {
        if (-not [String]::IsNullOrEmpty($p) -and (Test-Path $p)) {
            return (Resolve-Path $p).Path
        }
    }

    $cfg = Join-Path $Dir "Win7_Downloader_Decoder_Path.txt"
    if (Test-Path $cfg) {
        try {
            $configured = (Get-Content $cfg | Select-Object -First 1).Trim()
            if (-not [String]::IsNullOrEmpty($configured) -and (Test-Path $configured)) {
                return (Resolve-Path $configured).Path
            }
        } catch {}
    }

    $cands = New-Object System.Collections.ArrayList
    Add-DecoderCandidate $cands (Join-Path $Dir "7z.exe")

    if (-not [String]::IsNullOrEmpty($env:ProgramFiles)) {
        Add-DecoderCandidate $cands (Join-Path $env:ProgramFiles "7-Zip\7z.exe")
    }
    if (-not [String]::IsNullOrEmpty(${env:ProgramFiles(x86)})) {
        Add-DecoderCandidate $cands (Join-Path ${env:ProgramFiles(x86)} "7-Zip\7z.exe")
    }

    foreach ($key in @(
        "HKLM:\SOFTWARE\7-Zip",
        "HKLM:\SOFTWARE\Wow6432Node\7-Zip",
        "HKCU:\SOFTWARE\7-Zip",
        "HKCU:\SOFTWARE\Wow6432Node\7-Zip"
    )) {
        try {
            if (-not (Test-Path $key)) { continue }
            $item = Get-ItemProperty $key
            foreach ($valueName in @("Path","Path64","Path32")) {
                $base = $item.$valueName
                if (-not [String]::IsNullOrEmpty($base)) {
                    Add-DecoderCandidate $cands (Join-Path $base "7z.exe")
                }
            }
        } catch {}
    }

    Add-DecoderCandidate $cands (Find-CommandPath "7z.exe")

    if ($cands.Count -gt 0) { return $cands[0] }
    return ""
}

try {
    Write-Host "============================================================"
    Write-Host " FeverGames Legacy Windows Downloader v1.3.2 - Status"
    Write-Host "============================================================"

    if ([String]::IsNullOrEmpty($InstallDir)) { throw "InstallDir is required." }

    $InstallDir = (Resolve-Path $InstallDir).Path
    $installer = Join-Path $InstallDir "FeverGamesInstaller.exe"
    $downloader = Join-Path $InstallDir "downloadIPC.exe"
    $folderBuild = Split-Path -Leaf $InstallDir

    Info ("InstallDir: " + $InstallDir)
    Info ("Folder build: " + $folderBuild)

    $profile = $null
    $sameFolder = @()
    $matches = @()

    foreach ($key in $FeverGamesPatchProfiles.Keys) {
        $candidate = $FeverGamesPatchProfiles[$key]
        $candidateFolder = [string]$candidate.Build
        if ($candidate["FolderBuild"] -ne $null) {
            $candidateFolder = [string]$candidate.FolderBuild
        }

        if ($candidateFolder -eq $folderBuild) {
            $sameFolder += $candidate
        }
    }

    foreach ($candidate in $sameFolder) {
        if (Profile-Matches $installer $candidate) {
            $matches += $candidate
        }
    }

    if ($matches.Count -eq 1) {
        $profile = $matches[0]
    } elseif ($matches.Count -gt 1) {
        Warn "Multiple exact layouts match this folder build; refusing ambiguous status result."
    } elseif ($sameFolder.Count -eq 0) {
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

        if (Eq $now $entry.Patched) {
            Ok ($entry.Name + " = PATCHED")
            $okCount++
        } elseif (Eq $now $entry.Original) {
            Warn ($entry.Name + " = ORIGINAL / NOT PATCHED")
        } else {
            Warn ($entry.Name + " = UNKNOWN")
        }
    }

    $downloaderOk = $false

    if (Is-ManagedExe $downloader) {
        Ok "downloadIPC.exe = managed Win7 replacement"
        $downloaderOk = $true
    } else {
        Warn "downloadIPC.exe = native/original downloader"
    }

    $backupOk = $false
    foreach ($backupName in @("Win7_Downloader_Fix_Backup_v1.3","Win7_Bedrock_Fix_Backup_v1.2")) {
        $bd = Join-Path $InstallDir $backupName
        if ((Test-Path (Join-Path $bd "FeverGamesInstaller.exe.original")) -and
            (Test-Path (Join-Path $bd "downloadIPC.exe.original"))) {
            Ok ("rollback backup = COMPLETE (" + $backupName + ")")
            $backupOk = $true
            break
        }
    }

    if (-not $backupOk) { Warn "rollback backup = INCOMPLETE / MISSING" }

    $decoderOk = $false
    $decoderPath = Find-InstalledDecoder $InstallDir

    if (-not [String]::IsNullOrEmpty($decoderPath)) {
        Ok ("decoder = " + $decoderPath)
        $decoderOk = $true
    } else {
        Warn "No zstd.exe / 7z.exe detected (including custom 7-Zip registry path and PATH)."
    }

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
catch {
    Err $_.Exception.Message
    exit 1
}
