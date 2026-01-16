# Skrypt przywracaj¹cy œrodowisko (uruchom na nowym kompie)
$userBin = "$env:USERPROFILE\bin"
Copy-Item -Path ".\bin" -Destination "$env:USERPROFILE" -Recurse -Force
Copy-Item -Path ".\profile.ps1" -Destination $PROFILE -Force
Write-Host "? Œrodowisko przywrócone! Zrestartuj PowerShell." -ForegroundColor Green
