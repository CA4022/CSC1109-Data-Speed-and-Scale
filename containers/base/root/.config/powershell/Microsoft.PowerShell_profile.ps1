$env:USER = (whoami).Trim()
$env:HOME = [System.IO.Path]::GetFullPath($HOME)
$env:LANG = "en_US.UTF-8"
$env:TERM = "xterm-256color"
$env:COLORTERM = "truecolor"
$env:MANPAGER = "bat -l man -p"
$env:STARSHIP_CONFIG = "$HOME/.config/starship/powershell.toml"

Set-Alias -Name cat -Value bat -Option AllScope
Set-Alias -Name ls -Value lsd -Option AllScope
Set-Alias -Name grep -Value rg -Option AllScope
Set-Alias -Name find -Value fd -Option AllScope

function edit {
    if (-not $env:EDITOR) {
        Write-Error "'EDITOR' environment variable is not set."
        return
    }
    & $env:EDITOR @args
}

if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}
