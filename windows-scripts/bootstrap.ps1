<#
.SYNOPSIS
    Reproduce Marcus's Windows dev environment on a fresh machine from this repo.

.DESCRIPTION
    Idempotent. Safe to re-run — winget/choco skip already-installed packages and
    config restore backs up anything it replaces. Installs the toolchain, then links
    every config from this repo into place. Contains NO secrets: SSH keys, AWS SSO,
    Bitwarden, and Tailscale auth are printed as manual post-steps at the end.

.USAGE
    # From an elevated PowerShell 7 (choco + symlinks want admin):
    git clone https://github.com/marcusshepp/dotfiles ~/p/dotfiles
    ~/p/dotfiles/windows-scripts/bootstrap.ps1
    # Install packages only, skip config restore:
    ~/p/dotfiles/windows-scripts/bootstrap.ps1 -SkipConfigs
#>
[CmdletBinding()]
param(
    [switch]$SkipPackages,
    [switch]$SkipConfigs
)
$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot   # .../dotfiles

function Info($m) { Write-Host "==> $m" -ForegroundColor Cyan }
function Warn($m) { Write-Host "!!  $m" -ForegroundColor Yellow }

function Link-Config($target, $source) {
    if (-not (Test-Path $source)) { Warn "missing in repo, skipping: $source"; return }
    $dir = Split-Path -Parent $target
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    if (Test-Path $target) {
        $existing = Get-Item $target -Force
        if ($existing.LinkType -eq 'SymbolicLink' -and $existing.Target -eq $source) { return }
        Copy-Item $target "$target.backup" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item $target -Recurse -Force
    }
    try {
        New-Item -ItemType SymbolicLink -Path $target -Target $source -Force | Out-Null
        Info "linked $target -> $source"
    } catch {
        Copy-Item $source $target -Recurse -Force   # no admin/dev-mode: fall back to copy
        Info "copied $target (symlink denied — re-run elevated for a live link)"
    }
}

if (-not $SkipPackages) {
    Info 'winget: importing package manifest'
    winget import -i "$repo\bootstrap\winget-packages.json" `
        --accept-package-agreements --accept-source-agreements `
        --ignore-unavailable --ignore-versions

    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Info 'installing Chocolatey'
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = 3072
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    }
    Info 'choco: jq (only tool without a clean winget source here)'
    choco install jq -y

    if (-not (Get-Command bun -ErrorAction SilentlyContinue)) {
        Info 'installing Bun'; irm bun.sh/install.ps1 | iex
    }
    if (Get-Command rustup -ErrorAction SilentlyContinue) { rustup default stable }

    if (Get-Command npm -ErrorAction SilentlyContinue) {
        Info 'npm globals'
        Get-Content "$repo\bootstrap\npm-globals.txt" |
            Where-Object { $_ -and $_ -notmatch '^\s*#' } |
            ForEach-Object { npm install -g $_.Trim() }
    }
    if (Get-Command code -ErrorAction SilentlyContinue) {
        Info 'VS Code extensions'
        Get-Content "$repo\bootstrap\vscode-extensions.txt" |
            Where-Object { $_ -and $_ -notmatch '^\s*#' } |
            ForEach-Object { code --install-extension $_.Trim() --force }
    }
}

if (-not $SkipConfigs) {
    Info 'linking configs from repo'
    $docs = [Environment]::GetFolderPath('MyDocuments')  # OneDrive-redirected on this box
    Link-Config "$HOME\.wezterm.lua"                                   "$repo\.wezterm.lua"
    Link-Config "$docs\PowerShell\Microsoft.PowerShell_profile.ps1"    "$repo\windows-conf\Microsoft.PowerShell_profile.ps1"
    Link-Config "$HOME\.gitconfig"                                     "$repo\shared\.gitconfig"
    Link-Config "$HOME\.ssh\config"                                    "$repo\shared\ssh-config"
    Link-Config "$env:LOCALAPPDATA\nvim"                              "$repo\nvim"
    Link-Config "$HOME\.glzr\glazewm"                                 "$repo\windows-conf\glazewm"
    Link-Config "$HOME\.glzr\zebar"                                   "$repo\windows-conf\zebar"
    Link-Config "$env:APPDATA\Code\User\settings.json"               "$repo\windows-conf\vscode\settings.json"
}

Write-Host ''
Info 'Toolchain + configs done. MANUAL post-steps (these need secrets — not in this repo):'
@(
    '1. SSH:        ssh-keygen -t ed25519 -C "marcusshepdotcom@gmail.com"  (then add the .pub to GitHub)'
    '2. AWS:        aws configure sso     (profile sir-code-alot, region us-east-1)  +  set profile sync-cli-agent'
    '3. Bitwarden:  bw login              (bw-personal / bw-sync helper funcs are in the PowerShell profile)'
    '4. Tailscale:  tailscale up'
    '5. GitHub CLI: gh auth login'
    '6. WSL:        wsl --install -d Ubuntu   (then run linux-scripts/bootstrap.sh inside it)'
    '7. Restart the terminal so PATH + the PowerShell profile reload.'
) | ForEach-Object { Write-Host "   $_" -ForegroundColor Gray }
