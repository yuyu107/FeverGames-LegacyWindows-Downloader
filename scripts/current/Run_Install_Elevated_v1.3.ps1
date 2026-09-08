$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$installerScript = Join-Path $scriptDir "Install_Latest_FeverGames_v1.3.ps1"

function Is-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p = New-Object Security.Principal.WindowsPrincipal($id)
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

try {
    if (-not (Test-Path $installerScript)) {
        throw "Install_Latest_FeverGames_v1.3.ps1 is missing."
    }

    if (Is-Admin) {
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $installerScript
        exit $LASTEXITCODE
    }

    Write-Host "[INFO] Requesting administrator privileges..."
    Write-Host "[INFO] Please accept the UAC prompt. This window will wait for installation to finish."

    $arg = "-NoProfile -ExecutionPolicy Bypass -File `"$installerScript`""
    $proc = Start-Process powershell.exe -Verb RunAs -ArgumentList $arg -Wait -PassThru
    exit $proc.ExitCode
}
catch {
    Write-Host ("[ERR] " + $_.Exception.Message)
    exit 1
}
