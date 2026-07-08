<#
.SYNOPSIS
    Capture the live Windows configs on THIS machine back into the repo, so a
    `git commit && git push` keeps the backup current. Reverse of bootstrap.ps1.
    Run it, review `git status`/`git diff`, then commit. No secrets are copied.
#>
$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$docs = [Environment]::GetFolderPath('MyDocuments')

function Capture($src, $dst) {
    if (-not (Test-Path $src)) { Write-Host "skip (no source): $src" -ForegroundColor Yellow; return }
    $dir = Split-Path -Parent $dst
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    if ((Get-Item $src).PSIsContainer) {
        if (Test-Path $dst) { Remove-Item $dst -Recurse -Force }
        Copy-Item $src $dst -Recurse -Force
    } else {
        Copy-Item $src $dst -Force
    }
    Write-Host "captured $dst" -ForegroundColor Cyan
}

Capture "$docs\PowerShell\Microsoft.PowerShell_profile.ps1"  "$repo\windows-conf\Microsoft.PowerShell_profile.ps1"
Capture "$HOME\.gitconfig"                                   "$repo\shared\.gitconfig"
Capture "$env:LOCALAPPDATA\nvim"                             "$repo\nvim"
Capture "$HOME\.glzr\glazewm"                                "$repo\windows-conf\glazewm"
Capture "$HOME\.glzr\zebar\settings.json"                    "$repo\windows-conf\zebar\settings.json"
Capture "$env:APPDATA\Code\User\settings.json"              "$repo\windows-conf\vscode\settings.json"
# .wezterm.lua is symlinked to the repo by setup-wezterm.ps1, so it needs no capture.

Write-Host "`nDone. Review changes, then commit:" -ForegroundColor Green
Write-Host "  git -C $repo status" -ForegroundColor Gray
Write-Host "  git -C $repo add -A && git -C $repo commit -m 'backup: refresh configs' && git -C $repo push" -ForegroundColor Gray
