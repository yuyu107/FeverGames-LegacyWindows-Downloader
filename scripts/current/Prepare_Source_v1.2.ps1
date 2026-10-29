$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
if ([String]::IsNullOrEmpty($scriptDir)) { $scriptDir = (Get-Location).Path }

# Source checkouts keep runtime scripts under scripts\current and the packed
# downloader source under the repository-level src directory.
$repoRoot = Split-Path -Parent (Split-Path -Parent $scriptDir)
$packed = Join-Path $repoRoot "src\downloadIPC_Win7_v1.2.cs.gz.b64"
$out = Join-Path $scriptDir "downloadIPC_Win7_v1.2.cs"

if (Test-Path $out) {
    Write-Host "[INFO] downloadIPC_Win7_v1.2.cs already exists."
    exit 0
}

if (-not (Test-Path $packed)) {
    Write-Host "[ERR] Missing packed source:"
    Write-Host ("      " + $packed)
    exit 1
}

try {
    # Read all source lines without requiring PowerShell 3's -Raw parameter.
    $b64 = [String]::Join("", [string[]](Get-Content -LiteralPath $packed))
    $b64 = [System.Text.RegularExpressions.Regex]::Replace($b64, "\\s", "")
    if (($b64.Length % 4) -ne 0 -or -not $b64.StartsWith("H4sI")) {
        throw "Compressed source is corrupt (invalid Base64 length or GZip header). Re-download the repository or use the stable Release ZIP."
    }
    [byte[]]$gz = [Convert]::FromBase64String($b64)
    if ($gz.Length -lt 18 -or $gz[0] -ne 0x1F -or $gz[1] -ne 0x8B -or $gz[2] -ne 0x08) {
        throw "Compressed source is not a valid GZip stream."
    }

    $input = New-Object IO.MemoryStream(,$gz)
    $gzip = New-Object IO.Compression.GZipStream($input,[IO.Compression.CompressionMode]::Decompress)
    $output = New-Object IO.MemoryStream

    try {
        [byte[]]$buf = New-Object byte[] 65536
        while (($n = $gzip.Read($buf,0,$buf.Length)) -gt 0) {
            $output.Write($buf,0,$n)
        }
        [IO.File]::WriteAllBytes($out,$output.ToArray())
    }
    finally {
        $output.Dispose()
        $gzip.Dispose()
        $input.Dispose()
    }

    Write-Host "[OK] Reconstructed downloadIPC_Win7_v1.2.cs"
}
catch {
    Write-Host ("[ERR] Source reconstruction failed: " + $_.Exception.Message)
    exit 1
}
