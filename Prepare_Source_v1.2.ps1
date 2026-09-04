$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
if ([String]::IsNullOrEmpty($scriptDir)) { $scriptDir = (Get-Location).Path }

$packed = Join-Path $scriptDir "src\downloadIPC_Win7_v1.2.cs.gz.b64"
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
    $b64 = (Get-Content $packed -Raw).Trim()
    [byte[]]$gz = [Convert]::FromBase64String($b64)

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
