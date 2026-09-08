# FeverGames rolling version-folder discovery helper.
# PowerShell 2.0 compatible.
#
# v1.3.1:
# - supports custom FeverGames install roots;
# - checks saved root, registry uninstall entries, shortcuts and common paths;
# - accepts a dragged FeverGames root/version folder/EXE;
# - can persist the selected FeverGames root for later status/restore/diagnostics.

# Resolver file directory captured at script load time.
# PowerShell 2.0 has no $PSScriptRoot.
$script:FeverGamesResolverScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

function ConvertTo-FeverGamesVersion([string]$Name) {
    if ([String]::IsNullOrEmpty($Name)) { return $null }
    if ($Name -notmatch '^\d+(\.\d+){1,3}$') { return $null }

    try { return [version]$Name }
    catch { return $null }
}

function Clean-FeverGamesPathText([string]$Text) {
    if ([String]::IsNullOrEmpty($Text)) { return "" }

    $s = $Text.Trim()

    # Drag-and-drop into console often produces a quoted path.
    if ($s.Length -ge 2 -and $s.Substring(0,1) -eq '"' -and $s.Substring($s.Length-1,1) -eq '"') {
        $s = $s.Substring(1,$s.Length-2)
    }

    # Some registry values contain "path\file.exe",args or command-line arguments.
    if ($s.StartsWith('"')) {
        $end = $s.IndexOf('"',1)
        if ($end -gt 1) {
            $s = $s.Substring(1,$end-1)
        }
    } else {
        $lower = $s.ToLowerInvariant()
        $exePos = $lower.IndexOf(".exe")
        if ($exePos -ge 0) {
            $s = $s.Substring(0,$exePos+4)
        }
    }

    try { $s = [Environment]::ExpandEnvironmentVariables($s) } catch {}
    return $s.Trim()
}

function Add-UniquePath([System.Collections.ArrayList]$List,[string]$Path) {
    $Path = Clean-FeverGamesPathText $Path
    if ([String]::IsNullOrEmpty($Path)) { return }

    try {
        if (Test-Path $Path -PathType Leaf) {
            $Path = Split-Path -Parent $Path
        }

        if (Test-Path $Path) {
            $Path = (Resolve-Path $Path).Path
        }
    } catch {}

    foreach ($existing in $List) {
        if ($existing -ieq $Path) { return }
    }

    [void]$List.Add($Path)
}

function Add-FeverGamesHint([System.Collections.ArrayList]$Roots,[string]$Hint) {
    $p = Clean-FeverGamesPathText $Hint
    if ([String]::IsNullOrEmpty($p)) { return }

    try {
        if (Test-Path $p -PathType Leaf) {
            $p = Split-Path -Parent $p
        }
    } catch {}

    if ([String]::IsNullOrEmpty($p)) { return }

    # Add the hinted directory itself.
    Add-UniquePath $Roots $p

    # If hint is a numeric version directory, add its parent FeverGames root too.
    try {
        $leaf = Split-Path -Leaf $p
        if ((ConvertTo-FeverGamesVersion $leaf) -ne $null) {
            Add-UniquePath $Roots (Split-Path -Parent $p)
        }
    } catch {}

    # Registry/shortcut hints sometimes point to a parent directory.
    # Try a FeverGames child without recursively scanning the disk.
    try {
        Add-UniquePath $Roots (Join-Path $p "FeverGames")
    } catch {}

    # Walk up a few levels and keep a directory actually named FeverGames.
    $cur = $p
    for ($i=0; $i -lt 4; $i++) {
        try {
            if ([String]::IsNullOrEmpty($cur)) { break }
            $leaf = Split-Path -Leaf $cur
            if ($leaf -ieq "FeverGames") {
                Add-UniquePath $Roots $cur
                break
            }

            $parent = Split-Path -Parent $cur
            if ([String]::IsNullOrEmpty($parent) -or $parent -eq $cur) { break }
            $cur = $parent
        } catch { break }
    }
}

function Get-FeverGamesSavedRootFile {
    $scriptDir = $script:FeverGamesResolverScriptDir

    if ([String]::IsNullOrEmpty($scriptDir)) {
        throw "Resolver script directory is unavailable."
    }

    return (Join-Path $scriptDir "FeverGames_Install_Root.txt")
}

function Save-FeverGamesInstallRoot([string]$VersionFolderPath) {
    try {
        if ([String]::IsNullOrEmpty($VersionFolderPath)) { return }
        $root = Split-Path -Parent $VersionFolderPath
        if ([String]::IsNullOrEmpty($root)) { return }

        $file = Get-FeverGamesSavedRootFile
        $root | Out-File -FilePath $file -Encoding UTF8
        Write-Host ("[INFO] Saved FeverGames install root: " + $root)
    } catch {
        Write-Host ("[WARN] Could not save FeverGames install root: " + $_.Exception.Message)
    }
}

function Add-FeverGamesSavedRoot([System.Collections.ArrayList]$Roots) {
    try {
        $file = Get-FeverGamesSavedRootFile
        if (Test-Path $file) {
            $saved = (Get-Content $file | Select-Object -First 1)
            Add-FeverGamesHint $Roots $saved
        }
    } catch {}
}

function Add-FeverGamesRegistryHints([System.Collections.ArrayList]$Roots) {
    $uninstallRoots = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKCU:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    )

    foreach ($base in $uninstallRoots) {
        try {
            if (-not (Test-Path $base)) { continue }

            foreach ($key in (Get-ChildItem $base -ErrorAction SilentlyContinue)) {
                try {
                    $item = Get-ItemProperty $key.PSPath -ErrorAction SilentlyContinue
                    if ($item -eq $null) { continue }

                    $display = [string]$item.DisplayName
                    $install = [string]$item.InstallLocation
                    $icon = [string]$item.DisplayIcon
                    $uninstall = [string]$item.UninstallString

                    $joined = ($display + " " + $install + " " + $icon + " " + $uninstall)
                    if ($joined -notmatch "(?i)FeverGames|发烧游戏") { continue }

                    Add-FeverGamesHint $Roots $install
                    Add-FeverGamesHint $Roots $icon
                    Add-FeverGamesHint $Roots $uninstall
                } catch {}
            }
        } catch {}
    }

    # A few possible direct application keys. Harmless when absent.
    foreach ($keyPath in @(
        "HKLM:\SOFTWARE\FeverGames",
        "HKLM:\SOFTWARE\Wow6432Node\FeverGames",
        "HKCU:\SOFTWARE\FeverGames",
        "HKCU:\SOFTWARE\Wow6432Node\FeverGames"
    )) {
        try {
            if (-not (Test-Path $keyPath)) { continue }
            $item = Get-ItemProperty $keyPath -ErrorAction SilentlyContinue

            foreach ($name in @("Path","InstallPath","InstallLocation","Dir")) {
                try {
                    $value = [string]$item.$name
                    Add-FeverGamesHint $Roots $value
                } catch {}
            }
        } catch {}
    }
}

function Add-FeverGamesShortcutHints([System.Collections.ArrayList]$Roots) {
    $folders = New-Object System.Collections.ArrayList

    foreach ($p in @(
        (Join-Path $env:USERPROFILE "Desktop"),
        (Join-Path $env:PUBLIC "Desktop"),
        (Join-Path $env:APPDATA "Microsoft\Windows\Start Menu"),
        (Join-Path $env:ProgramData "Microsoft\Windows\Start Menu")
    )) {
        if (-not [String]::IsNullOrEmpty($p) -and (Test-Path $p)) {
            Add-UniquePath $folders $p
        }
    }

    try {
        $ws = New-Object -ComObject WScript.Shell
    } catch {
        return
    }

    foreach ($folder in $folders) {
        try {
            foreach ($lnk in (Get-ChildItem $folder -Filter *.lnk -Recurse -ErrorAction SilentlyContinue)) {
                try {
                    $sc = $ws.CreateShortcut($lnk.FullName)
                    $target = [string]$sc.TargetPath
                    $args = [string]$sc.Arguments

                    if (($target + " " + $args + " " + $lnk.Name) -match "(?i)FeverGames|发烧游戏") {
                        Add-FeverGamesHint $Roots $target
                    }
                } catch {}
            }
        } catch {}
    }
}

function Get-FeverGamesSearchRoots([string]$Requested) {
    $roots = New-Object System.Collections.ArrayList

    if (-not [String]::IsNullOrEmpty($Requested)) {
        Add-FeverGamesHint $roots $Requested
    }

    # Previous successful selection from this package.
    Add-FeverGamesSavedRoot $roots

    # Installed-app metadata and shortcuts are the best way to find arbitrary custom paths.
    Add-FeverGamesRegistryHints $roots
    Add-FeverGamesShortcutHints $roots

    # Common locations on every filesystem drive.
    foreach ($drive in (Get-PSDrive -PSProvider FileSystem -ErrorAction SilentlyContinue)) {
        if ([String]::IsNullOrEmpty($drive.Root)) { continue }

        foreach ($rel in @(
            "FeverGames",
            "Games\FeverGames",
            "Game\FeverGames",
            "Apps\FeverGames",
            "Programs\FeverGames",
            "Software\FeverGames",
            "Program Files\FeverGames",
            "Program Files (x86)\FeverGames"
        )) {
            Add-UniquePath $roots (Join-Path $drive.Root $rel)
        }
    }

    return $roots
}

function New-FeverGamesVersionFolderObject([string]$Path) {
    if ([String]::IsNullOrEmpty($Path) -or -not (Test-Path $Path)) { return $null }

    try {
        $full = (Resolve-Path $Path).Path
        $leaf = Split-Path -Leaf $full
        $ver = ConvertTo-FeverGamesVersion $leaf
        if ($ver -eq $null) { return $null }

        $installer = Join-Path $full "FeverGamesInstaller.exe"
        $downloader = Join-Path $full "downloadIPC.exe"

        return (New-Object PSObject -Property @{
            Path = $full
            Name = $leaf
            Version = $ver
            HasInstaller = (Test-Path $installer)
            HasDownloader = (Test-Path $downloader)
            Complete = ((Test-Path $installer) -and (Test-Path $downloader))
        })
    } catch {
        return $null
    }
}

function Get-FeverGamesVersionFolders([string]$Requested) {
    $seen = New-Object System.Collections.ArrayList
    $items = New-Object System.Collections.ArrayList

    foreach ($root in (Get-FeverGamesSearchRoots $Requested)) {
        if ([String]::IsNullOrEmpty($root) -or -not (Test-Path $root)) { continue }

        # A hint may be the numeric version folder itself.
        $self = New-FeverGamesVersionFolderObject $root
        if ($self -ne $null) {
            $already = $false
            foreach ($s in $seen) {
                if ($s -ieq $self.Path) { $already = $true; break }
            }
            if (-not $already) {
                [void]$seen.Add($self.Path)
                [void]$items.Add($self)
            }
        }

        # Or it may be the FeverGames root containing numeric version folders.
        try {
            foreach ($d in (Get-ChildItem $root -ErrorAction SilentlyContinue | Where-Object { $_.PSIsContainer })) {
                $obj = New-FeverGamesVersionFolderObject $d.FullName
                if ($obj -eq $null) { continue }

                $already = $false
                foreach ($s in $seen) {
                    if ($s -ieq $obj.Path) { $already = $true; break }
                }

                if ($already) { continue }
                [void]$seen.Add($obj.Path)
                [void]$items.Add($obj)
            }
        } catch {}
    }

    return @($items | Sort-Object Version -Descending)
}

function Get-NewestCompleteFeverGamesFolder([string]$Requested) {
    $all = @(Get-FeverGamesVersionFolders $Requested)
    foreach ($item in $all) {
        if ($item.Complete) { return $item }
    }
    return $null
}

function Show-FeverGamesVersionFolders([object[]]$Items,[int]$MaxCount = 5) {
    if ($Items -eq $null -or $Items.Count -eq 0) {
        Write-Host "[INFO] No numeric FeverGames version folders detected."
        return
    }

    Write-Host "[INFO] Detected FeverGames version folders (newest first):"
    $n = 0

    foreach ($item in $Items) {
        if ($n -ge $MaxCount) { break }
        $state = "incomplete"
        if ($item.Complete) { $state = "complete" }

        Write-Host ("       " + $item.Name + "  [" + $state + "]  " + $item.Path)
        $n++
    }
}

function Ask-FeverGamesInstallPath {
    Write-Host ""
    Write-Host "[WARN] FeverGames was not found automatically."
    Write-Host "[INFO] You can drag any of these into this window:"
    Write-Host "       - FeverGames root folder"
    Write-Host "       - numeric version folder (for example 1.18.42.14)"
    Write-Host "       - FeverGamesInstaller.exe"
    Write-Host ""
    $answer = Read-Host "FeverGames path"
    return (Clean-FeverGamesPathText $answer)
}
