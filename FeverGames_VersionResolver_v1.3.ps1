# Shared FeverGames version-folder discovery helpers for the next release.
# PowerShell 2.0 compatible: avoid -Directory, [pscustomobject], and newer syntax.

function ConvertTo-FeverGamesVersion([string]$Name) {
    if ([String]::IsNullOrEmpty($Name)) { return $null }
    if ($Name -notmatch '^\d+(\.\d+){1,3}$') { return $null }

    try {
        return [version]$Name
    }
    catch {
        return $null
    }
}

function Add-UniquePath([System.Collections.ArrayList]$List,[string]$Path) {
    if ([String]::IsNullOrEmpty($Path)) { return }

    try {
        if (Test-Path $Path) {
            $Path = (Resolve-Path $Path).Path
        }
    }
    catch {}

    foreach ($existing in $List) {
        if ($existing -ieq $Path) { return }
    }

    [void]$List.Add($Path)
}

function Get-FeverGamesSearchRoots([string]$Requested) {
    $roots = New-Object System.Collections.ArrayList

    if (-not [String]::IsNullOrEmpty($Requested)) {
        $p = $Requested

        if (Test-Path $p -PathType Leaf) {
            $p = Split-Path -Parent $p
        }

        if (Test-Path $p) {
            $leaf = Split-Path -Leaf $p
            $v = ConvertTo-FeverGamesVersion $leaf

            if ($v -ne $null) {
                Add-UniquePath $roots (Split-Path -Parent $p)
            } else {
                Add-UniquePath $roots $p
            }
        }
    }

    foreach ($drive in (Get-PSDrive -PSProvider FileSystem -ErrorAction SilentlyContinue)) {
        if ([String]::IsNullOrEmpty($drive.Root)) { continue }

        Add-UniquePath $roots (Join-Path $drive.Root 'Program Files\FeverGames')
        Add-UniquePath $roots (Join-Path $drive.Root 'Program Files (x86)\FeverGames')
    }

    return $roots
}

function Get-FeverGamesVersionFolders([string]$Requested) {
    # If an explicit complete version directory was supplied, honor it directly.
    if (-not [String]::IsNullOrEmpty($Requested)) {
        $p = $Requested

        if (Test-Path $p -PathType Leaf) {
            $p = Split-Path -Parent $p
        }

        if (Test-Path $p) {
            $leaf = Split-Path -Leaf $p
            $ver = ConvertTo-FeverGamesVersion $leaf

            if ($ver -ne $null) {
                $installer = Join-Path $p 'FeverGamesInstaller.exe'
                $downloader = Join-Path $p 'downloadIPC.exe'
                $obj = New-Object PSObject -Property @{
                    Path = (Resolve-Path $p).Path
                    Name = $leaf
                    Version = $ver
                    HasInstaller = (Test-Path $installer)
                    HasDownloader = (Test-Path $downloader)
                    Complete = ((Test-Path $installer) -and (Test-Path $downloader))
                }
                return ,$obj
            }
        }
    }

    $seen = New-Object System.Collections.ArrayList
    $items = New-Object System.Collections.ArrayList

    foreach ($root in (Get-FeverGamesSearchRoots $Requested)) {
        if (-not (Test-Path $root)) { continue }

        foreach ($d in (Get-ChildItem $root -ErrorAction SilentlyContinue | Where-Object { $_.PSIsContainer })) {
            $ver = ConvertTo-FeverGamesVersion $d.Name
            if ($ver -eq $null) { continue }

            $full = $d.FullName
            $already = $false
            foreach ($s in $seen) {
                if ($s -ieq $full) { $already = $true; break }
            }
            if ($already) { continue }
            [void]$seen.Add($full)

            $installer = Join-Path $full 'FeverGamesInstaller.exe'
            $downloader = Join-Path $full 'downloadIPC.exe'

            $obj = New-Object PSObject -Property @{
                Path = $full
                Name = $d.Name
                Version = $ver
                HasInstaller = (Test-Path $installer)
                HasDownloader = (Test-Path $downloader)
                Complete = ((Test-Path $installer) -and (Test-Path $downloader))
            }
            [void]$items.Add($obj)
        }
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
        Write-Host '[INFO] No numeric FeverGames version folders detected.'
        return
    }

    Write-Host '[INFO] Detected FeverGames version folders (newest first):'
    $n = 0
    foreach ($item in $Items) {
        if ($n -ge $MaxCount) { break }
        $state = 'incomplete'
        if ($item.Complete) { $state = 'complete' }
        Write-Host ('       ' + $item.Name + '  [' + $state + ']  ' + $item.Path)
        $n++
    }
}
