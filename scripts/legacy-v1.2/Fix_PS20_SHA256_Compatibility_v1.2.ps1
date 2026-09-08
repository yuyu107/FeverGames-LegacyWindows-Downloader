$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
if ([String]::IsNullOrEmpty($scriptDir)) { $scriptDir = (Get-Location).Path }

$targets = @(
    (Join-Path $scriptDir "Install_From_Zero_v1.2.ps1"),
    (Join-Path $scriptDir "Restore_Official_Original_v1.2.ps1")
)

$old = '$sha.Dispose()'
$new = '$sha.Clear()'
$utf8 = New-Object System.Text.UTF8Encoding($true)
$changed = 0

foreach ($path in $targets) {
    if (-not (Test-Path $path)) {
        continue
    }

    $text = [System.IO.File]::ReadAllText($path)

    if ($text.IndexOf($old, [StringComparison]::Ordinal) -ge 0) {
        $text = $text.Replace($old, $new)
        [System.IO.File]::WriteAllText($path, $text, $utf8)
        Write-Host ("[OK] PowerShell 2.0/.NET 3.5 SHA256 compatibility fixed: " + (Split-Path -Leaf $path))
        $changed++
    } elseif ($text.IndexOf($new, [StringComparison]::Ordinal) -ge 0) {
        Write-Host ("[OK] SHA256 compatibility already fixed: " + (Split-Path -Leaf $path))
    }
}

if ($changed -eq 0) {
    Write-Host "[INFO] No SHA256 Dispose compatibility change was required."
}

exit 0
