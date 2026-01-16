# === ClaudeCLI: Escape & Ctrl+C Handlers ===
if (Get-Module -Name PSReadLine -ErrorAction SilentlyContinue) {
    $script:lastEscapeTime = [DateTime]::MinValue
    Set-PSReadLineKeyHandler -Key Escape -ScriptBlock {
        $now = [DateTime]::Now
        if (($now - $script:lastEscapeTime).TotalMilliseconds -lt 400) {
            [Microsoft.PowerShell.PSConsoleReadLine]::CancelLine()
            [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
        } else {
            [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
        }
        $script:lastEscapeTime = $now
    }
    Set-PSReadLineKeyHandler -Key Ctrl+c -ScriptBlock {
        $line = $null; $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
        if ($line.Length -gt 0) {
            [Microsoft.PowerShell.PSConsoleReadLine]::CancelLine()
        } else {
            Write-Host "`n[Ctrl+C trapped] Use 'exit' to quit" -ForegroundColor Yellow
            [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
        }
    }
}

# === Oh My Posh: Matrix Setup ===
$binDir = "$env:USERPROFILE\bin"
$env:PATH = "$env:PATH;$binDir"
$exePath = "$binDir\oh-my-posh.exe"
$configPath = "$binDir\matrix.omp.json"

if (Test-Path $exePath) {
    # Uruchamiamy tylko, jeśli plik exe istnieje
    & $exePath init pwsh --config $configPath | Invoke-Expression
}

# === AI AGENT HUB ===
# 1. Ładowanie kluczy z pliku .env (Cicho i bezpiecznie)
$envFile = "$env:USERPROFILE\.ai.env"
if (Test-Path $envFile) {
    Get-Content $envFile | Where-Object { $_ -match '=' -and $_ -notmatch '^#' } | ForEach-Object {
        $key, $value = $_ -split '=', 2
        [System.Environment]::SetEnvironmentVariable($key.Trim(), $value.Trim(), 'Process')
    }
}

# 2. Claude CLI (Wrapper)
function claude {
    if (!$env:ANTHROPIC_API_KEY) { Write-Warning "Brak ANTHROPIC_API_KEY w .ai.env!" }
    # Zakładamy, że binarka nazywa się 'claude' lub uruchamiamy przez npx/python
    # Tutaj przykład dla typowej instalacji npm:
    & npx @anthropic-ai/claude-cli @args
}

# 3. Gemini CLI (Inteligentny wybór)
function gemini {
    if (!$env:GOOGLE_API_KEY) { Write-Warning "Brak GOOGLE_API_KEY w .ai.env!" }
    
    # Logika wyboru modelu (Flash vs Pro) zależnie od potrzeby, 
    # tutaj domyślnie spinamy to z hipotetycznym CLI
    Write-Host "♊ Gemini uplink..." -ForegroundColor DarkGray
    & gemini-cli $args 
}

# 4. Grok CLI
function grok {
    if (!$env:XAI_API_KEY) { Write-Warning "Brak XAI_API_KEY w .ai.env!" }
    Write-Host "🧠 Grokking..." -ForegroundColor DarkGray
    & grok-cli $args
}

# 5. Codex (OpenAI Wrapper)
function codex {
    if (!$env:OPENAI_API_KEY) { Write-Warning "Brak OPENAI_API_KEY w .ai.env!" }
    & openai $args
}

# 6. Jules CLI
function jules {
    if (!$env:JULES_API_KEY) { Write-Warning "Brak JULES_API_KEY w .ai.env!" }
    & jules-cli $args
}
