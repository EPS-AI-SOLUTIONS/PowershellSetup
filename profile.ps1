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
