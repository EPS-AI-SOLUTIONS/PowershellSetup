$ErrorActionPreference = "SilentlyContinue"
$repoRoot = $PSScriptRoot
$assetsDir = Join-Path $repoRoot "assets"
Write-Host "📸 Aktualizacja Repo..." -ForegroundColor Cyan

# A. PS Modules Export (NOWOŚĆ)
Write-Host "🔌 Eksport modułów PS..." -NoNewline
Get-InstalledModule | Select-Object Name, Version | Export-Csv -Path "$assetsDir\modules.csv" -NoTypeInformation
Write-Host " OK." -ForegroundColor Green

# B. Winget Export
Write-Host "📦 Eksport Winget..." -NoNewline
winget export -o "$assetsDir\packages.json" --include-versions
Write-Host " OK." -ForegroundColor Green

# C. Git Push
Set-Location $repoRoot
if (!(Test-Path ".git")) { git init }
git add .
$date = Get-Date -Format "yyyy-MM-dd HH:mm"
git commit -m "Update: $date"
git push origin master
Write-Host "✅ Wysłano do repozytorium." -ForegroundColor Magenta
