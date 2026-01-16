# === SYSTEM RESTORE ===
$userBin = "$env:USERPROFILE\bin"

# Kopiowanie binarek
if (Test-Path ".\bin") {
    Write-Host "⏳ Przywracanie silnika..." -ForegroundColor Cyan
    Copy-Item -Path ".\bin" -Destination "$env:USERPROFILE" -Recurse -Force
}

# Kopiowanie profilu
Write-Host "⏳ Przywracanie profilu..." -ForegroundColor Cyan
Copy-Item -Path ".\profile.ps1" -Destination $PROFILE -Force

Write-Host "✅ Środowisko przywrócone! Zrestartuj PowerShell." -ForegroundColor Green
