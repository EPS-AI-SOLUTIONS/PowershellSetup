# === SYSTEM BACKUPPER (SECURE) ===
$scriptDir = $PSScriptRoot
Write-Host "⏳ Archiwizacja konfiguracji..." -ForegroundColor Cyan

# Kopia profilu
Copy-Item -Path $PROFILE -Destination "$scriptDir\profile.ps1" -Force

# Kopia folderu bin
$systemBin = "$env:USERPROFILE\bin"
if (Test-Path $systemBin) {
    if (Test-Path "$scriptDir\bin") { Remove-Item "$scriptDir\bin" -Recurse -Force }
    Copy-Item -Path $systemBin -Destination "$scriptDir" -Recurse -Force
}

# Kopia SZABLONU kluczy (ale NIE prawdziwego pliku .ai.env)
$envTemplate = "$env:USERPROFILE\.ai.env.example"
if (!(Test-Path $envTemplate)) {
    Set-Content "$envTemplate" "KEY=VALUE_TEMPLATE" # Fallback
}
Copy-Item "$scriptDir\.ai.env.example" -Destination "$scriptDir\.ai.env.example" -Force

Write-Host "✅ Backup gotowy (Bezpieczny - bez kluczy API)." -ForegroundColor Green
