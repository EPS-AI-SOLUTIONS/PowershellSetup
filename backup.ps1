# === CONFIG UPDATE ===
$scriptDir = $PSScriptRoot
Write-Host "⏳ Pobieranie aktualnej konfiguracji z systemu..." -ForegroundColor Cyan

Copy-Item -Path $PROFILE -Destination "$scriptDir\profile.ps1" -Force
if (Test-Path "$env:USERPROFILE\bin") {
    Copy-Item -Path "$env:USERPROFILE\bin" -Destination "$scriptDir" -Recurse -Force
}

Write-Host "✅ Folder zaktualizowany. Gotowy do Git Push." -ForegroundColor Green
