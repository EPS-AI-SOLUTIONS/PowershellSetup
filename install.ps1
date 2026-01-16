# === SYSTEM RESTORE v5.0 ===
$ErrorActionPreference = "SilentlyContinue"
$repoRoot = $PSScriptRoot
$configDir = Join-Path $repoRoot "config"
$assetsDir = Join-Path $repoRoot "assets"
$timestamp = Get-Date -Format "yyyyMMdd_HHmm"

Write-Host "💀 Inicjalizacja Systemu..." -ForegroundColor Cyan

# --- A. GIT IDENTITY (NOWOŚĆ) ---
# Sprawdzamy czy git jest skonfigurowany, jeśli nie - pytamy usera
try {
    if (!(git config --global user.email)) {
        Write-Host "👤 Konfiguracja tożsamości Git (wymagane do commitowania)..." -ForegroundColor Yellow
        $gitUser = Read-Host "   Podaj User Name (np. Jan Kowalski)"
        $gitEmail = Read-Host "   Podaj Email (np. jan@example.com)"
        if ($gitUser -and $gitEmail) {
            git config --global user.name "$gitUser"
            git config --global user.email "$gitEmail"
            Write-Host "✅ Git skonfigurowany." -ForegroundColor Green
        }
    }
} catch { Write-Warning "⚠️ Nie wykryto Gita." }

# --- B. PS MODULES RESTORE (NOWOŚĆ) ---
$modulesFile = "$assetsDir\modules.csv"
if (Test-Path $modulesFile) {
    Write-Host "🔌 Instalacja modułów PowerShell..." -ForegroundColor Cyan
    $modules = Import-Csv $modulesFile
    foreach ($mod in $modules) {
        # Sprawdzamy czy moduł już jest, żeby nie tracić czasu
        if (!(Get-Module -ListAvailable -Name $mod.Name)) {
            Write-Host "   Instaluję: $($mod.Name)..." -NoNewline
            Install-Module -Name $mod.Name -Scope CurrentUser -Force -SkipPublisherCheck -AllowClobber
            Write-Host " OK." -ForegroundColor Green
        }
    }
}

# --- C. FONT AUTO-INSTALLER ---
$fontDest = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts\JetBrainsMonoNerdFont-Regular.ttf"
if (!(Test-Path $fontDest)) {
    Write-Host "🔤 Instalacja Nerd Font..." -ForegroundColor Yellow
    try {
        $url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip"
        $zipPath = "$env:TEMP\font.zip"
        Invoke-WebRequest -Uri $url -OutFile $zipPath
        Expand-Archive $zipPath -DestinationPath "$env:TEMP\font_extracted" -Force
        Copy-Item "$env:TEMP\font_extracted\JetBrainsMonoNerdFont-Regular.ttf" $fontDest -Force
        New-ItemProperty -Name "JetBrainsMono Nerd Font (TrueType)" -Path "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -PropertyType string -Value $fontDest -Force | Out-Null
        Write-Host "✅ Font zainstalowany." -ForegroundColor Green
    } catch { }
}

# --- D. WINGET FAIL-SAFE LOOP ---
$wingetFile = "$assetsDir\packages.json"
if (Test-Path $wingetFile) {
    Write-Host "📦 Instalacja aplikacji (Winget)..." -ForegroundColor Cyan
    try {
        $json = Get-Content $wingetFile -Raw | ConvertFrom-Json
        foreach ($pkg in $json.Sources[0].Packages) {
            Write-Host "   ⚙️ $($pkg.PackageIdentifier)... " -NoNewline
            winget install --id $pkg.PackageIdentifier --accept-package-agreements --accept-source-agreements --silent 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) { Write-Host "OK" -ForegroundColor Green } else { Write-Host "." -ForegroundColor DarkGray }
        }
    } catch {
        winget import -i $wingetFile --ignore-versions --accept-package-agreements --accept-source-agreements
    }
}

# --- E. SYMLINKS (PROFILE & VSCODE) ---
$targetProfile = $PROFILE
$sourceProfile = "$configDir\Microsoft.PowerShell_profile.ps1"
if (Test-Path $sourceProfile) {
    if (Test-Path $targetProfile) { Move-Item $targetProfile "$targetProfile.$timestamp.bak" -Force }
    if (!(Test-Path (Split-Path $targetProfile))) { New-Item -Type Directory (Split-Path $targetProfile) -Force | Out-Null }
    New-Item -ItemType SymbolicLink -Path $targetProfile -Target $sourceProfile -Force | Out-Null
    Write-Host "🔗 Profil zlinkowany." -ForegroundColor Green
}

$vsCodePath = "$env:APPDATA\Code\User"
if (Test-Path $vsCodePath) {
    foreach ($file in @("settings.json", "keybindings.json")) {
        $repoFile = "$configDir\vscode_$file"; $sysFile = "$vsCodePath\$file"
        if (Test-Path $repoFile) {
            if (Test-Path $sysFile) { Move-Item $sysFile "$sysFile.$timestamp.bak" -Force }
            New-Item -ItemType SymbolicLink -Path $sysFile -Target $repoFile -Force | Out-Null
            Write-Host "🔗 VS Code: $file zlinkowany." -ForegroundColor Green
        }
    }
}

# --- F. SECRETS & SSH ---
$secretsPath = "$env:USERPROFILE\.secrets.ps1"
if (!(Test-Path $secretsPath)) { Set-Content $secretsPath "# API Keys`n`$env:OPENAI_API_KEY='...'" }

$sshPath = "$env:USERPROFILE\.ssh\id_ed25519"
if (!(Test-Path $sshPath)) {
    Write-Host "🔑 Generowanie SSH..." -ForegroundColor Yellow
    if (!(Test-Path "$env:USERPROFILE\.ssh")) { New-Item -Type Directory "$env:USERPROFILE\.ssh" -Force | Out-Null }
    ssh-keygen -t ed25519 -f $sshPath -N "" -q
    Write-Host "👇 DODAJ TEN KLUCZ DO GITHUBA (Settings -> SSH Keys):" -ForegroundColor White
    Get-Content "$sshPath.pub" | Write-Host -ForegroundColor Cyan
}

Write-Host "`n✨ GOTOWE." -ForegroundColor Magenta
