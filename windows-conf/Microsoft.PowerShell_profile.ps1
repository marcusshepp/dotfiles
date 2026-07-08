# =============================================================================
# PowerShell Profile - marcu
# =============================================================================

# -----------------------------------------------------------------------------
# Navigation
# -----------------------------------------------------------------------------

function notes {
    Set-Location ~/p/notes
    nvim .
}

function dotfiles {
    Set-Location ~/p/dotfiles
    git st
}

function useful {
    Set-Location ~/p/useful
}

# -----------------------------------------------------------------------------
# Config Editing
# -----------------------------------------------------------------------------

function pro {
    nvim $PROFILE
}

function nc {
    nvim ~/p/dotfiles/nvim/
}

function wt {
    nvim ~/.wezterm.lua
}

function glzr {
    Set-Location ~/.glzr
    nvim .
}

# -----------------------------------------------------------------------------
# Git Helpers
# -----------------------------------------------------------------------------

function done {
    git a .
    git ci
    git push origin HEAD
}

function donee {
    param(
        [Parameter(Mandatory = $true)]
        [string]$c
    )
    git a .
    git ci -m "$c"
    git ps
}

function gitbranches {
    git for-each-ref --sort=committerdate refs/heads/ --format='%(committerdate:iso8601) %(refname:short)'
}

# -----------------------------------------------------------------------------
# Docker
# -----------------------------------------------------------------------------

function dd {
    & 'C:\Program Files\Docker\Docker\Docker Desktop.exe'
}


# -----------------------------------------------------------------------------
# Unix-like Utilities
# -----------------------------------------------------------------------------

function c {
    Clear-Host
}

function ll {
    param ([string]$Path = ".")
    Get-ChildItem -Path $Path | ForEach-Object { $_.Name }
}

function touch {
    param(
        [Parameter(Mandatory = $true)]
        [string]$filename
    )

    if (-not (Test-Path $filename)) {
        New-Item -ItemType File -Path $filename
    } else {
        Write-Host "File already exists"
    }
}

# -----------------------------------------------------------------------------
# Claude
# -----------------------------------------------------------------------------

function cl {
    claude --dangerously-skip-permissions @args
}

if (Test-Path Alias:cls) { Remove-Item Alias:cls -Force }
function cls {
    claude --dangerously-skip-permissions --model sonnet @args
}

function clo {
    claude --dangerously-skip-permissions --model opus @args
}

# -----------------------------------------------------------------------------
# Project Shortcuts
# -----------------------------------------------------------------------------

# Everything now lives in the platform monorepo (~/p/i/p). The old split repos
# (sync.portal, sync.infra) are retired; sr stays only for the pi-local-runner
# tooling that never migrated out of the read-only sync.runner repo.
$projects = @{
    web = "~/p/i/p/apps/portal"   # was sp / sync.portal
    api = "~/p/i/p/api"
    inf = "~/p/i/p/infra"          # was si / sync.infra
    lam = "~/p/i/p/lambdas"
    pkg = "~/p/i/p/packages"
    sr  = "~/p/i/sync.runner"      # legacy read-only repo (pi-local-runner only)
}

function p {
    Set-Location ~/p/i/p
    git checkout develop
    git pull origin develop
}

function pc {
    p
    cl @args
}

function n {
    param([Parameter(Mandatory = $true)][string]$key)
    if ($projects.ContainsKey($key)) {
        Set-Location $projects[$key]
        nvim .
    } else {
        Write-Host "Unknown project: $key. Options: $($projects.Keys -join ', ')"
    }
}


function u {
    wsl -d Ubuntu
}

# -----------------------------------------------------------------------------
# Bitwarden CLI Profiles
# -----------------------------------------------------------------------------

function bw-personal {
    $env:BITWARDENCLI_APPDATA_DIR = "$HOME\.config\bw-personal"
    $sessionFile = "$HOME\.config\bw-personal\session"
    if (Test-Path $sessionFile) { $env:BW_SESSION = Get-Content $sessionFile -Raw }
    bw @args
}

function bw-sync {
    $env:BITWARDENCLI_APPDATA_DIR = "$HOME\.config\bw-sync"
    $sessionFile = "$HOME\.config\bw-sync\session"
    if (Test-Path $sessionFile) { $env:BW_SESSION = Get-Content $sessionFile -Raw }
    bw @args
}

function bw-sync-unlock {
    $env:BITWARDENCLI_APPDATA_DIR = "$HOME\.config\bw-sync"
    $session = bw unlock --raw
    if ($session) {
        $session | Set-Content "$HOME\.config\bw-sync\session" -NoNewline
        $env:BW_SESSION = $session
        Write-Host "bw-sync unlocked. Session saved."
    }
}

function bw-personal-unlock {
    $env:BITWARDENCLI_APPDATA_DIR = "$HOME\.config\bw-personal"
    $session = bw unlock --raw
    if ($session) {
        $session | Set-Content "$HOME\.config\bw-personal\session" -NoNewline
        $env:BW_SESSION = $session
        Write-Host "bw-personal unlocked. Session saved."
    }
}

# -----------------------------------------------------------------------------
# Hermes Engine (EC2 i-0ef2548b845d06c07)
# -----------------------------------------------------------------------------
# he          → drop straight into hermes
# he shell    → plain ubuntu login shell (for hermes update, etc.)

function he {
    param([string]$Mode = "")

    $target = "i-0ef2548b845d06c07"

    $cmd = switch ($Mode) {
        "shell" { "sudo -iu ubuntu bash -l" }
        default { "sudo -iu ubuntu bash -lc hermes" }
    }

    aws ssm start-session `
        --target $target `
        --document-name AWS-StartInteractiveCommand `
        --parameters "{`"command`":[`"$cmd`"]}"
}

# -----------------------------------------------------------------------------
# Iron Tower  (Tailscale: iron-tower / 100.101.121.61)
# -----------------------------------------------------------------------------
# it          → attach tmux "main" (auto-reclaims a swept socket; starts Claude Code if new)
# it shell    → attach tmux "main" as a plain shell
# it list     → list sessions + live tmux server processes
# it reclaim  → force the orphaned server to recreate its socket, then attach

function it {
    param([string]$Mode = "")

    # If /tmp's tmux socket was swept but a server is still alive, `tmux ls` fails
    # and a bare new-session would spawn a SECOND, orphaned server. Detect the
    # missing socket and SIGUSR1 the daemonized server (PPID 1, cmdline starting
    # "tmux") so it recreates the socket and -A can reattach. Matches nothing =
    # harmless no-op. Prevents the 2026-07-02 orphaned-server split.
    $reclaim = "tmux ls >/dev/null 2>&1 || { pkill -USR1 -o -P 1 -f '^tmux'; sleep 1; }; "

    switch ($Mode) {
        "shell"   { ssh -t marcusshep@iron-tower "$reclaim tmux new-session -A -s main" }
        "list"    { ssh marcusshep@iron-tower "tmux ls 2>/dev/null || echo 'No tmux sessions (socket may be swept)'; echo '--- tmux servers ---'; pgrep -a -P 1 -f '^tmux' || echo none" }
        "reclaim" { ssh marcusshep@iron-tower "pkill -USR1 -o -P 1 -f '^tmux' && sleep 1 && tmux ls" }
        default   { ssh -t marcusshep@iron-tower "$reclaim tmux new-session -A -s main '~/.local/bin/claude --dangerously-skip-permissions'" }
    }
}

# -----------------------------------------------------------------------------
# Startup
# -----------------------------------------------------------------------------

Set-Location ~/o

# Oh My Posh prompt — use a LOCAL theme so shell startup never depends on
# GitHub being reachable (the remote --config URL was what printed "CONFIG URL FETCH FAILED").
# To refresh the theme: iwr 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/space.omp.json' -OutFile "$HOME\.config\oh-my-posh\space.omp.json"
$poshTheme = "$HOME\.config\oh-my-posh\space.omp.json"
if (Test-Path $poshTheme) {
    oh-my-posh init pwsh --config $poshTheme | Invoke-Expression
} else {
    oh-my-posh init pwsh | Invoke-Expression
}

# AWS Profile
$env:AWS_PROFILE = 'sir-code-alot'

# Pi local runner (plan authoring + analysis + execution)
function lrun {
    Set-Location ~/p/i/sync.runner
    pi -ne -ns -np --no-themes `
        --provider github-copilot --model claude-opus-4.6 `
        -e packages/pi-local-runner/extensions/index.ts `
        -e packages/pi-runner-analyst/extensions/index.ts `
        --append-system-prompt packages/pi-local-runner/system-prompt.md `
        @args
}

function pi-plan-analyze {
    Set-Location ~/p/i/sync.runner/;
    pi -ne -ns -np --no-themes -e packages/pi-runner-analyst/extensions/index.ts;
}

# Tavily API key for Pi web search extension — loaded from a gitignored local
# file so the secret never lands in this (public) dotfiles repo. To rotate:
# regenerate in the Tavily dashboard, then update ~/.config/secrets/tavily.key.
$tavilyKeyFile = "$HOME\.config\secrets\tavily.key"
if (Test-Path $tavilyKeyFile) { $env:TAVILY_API_KEY = (Get-Content $tavilyKeyFile -Raw).Trim() }

# just (command runner)
Set-Alias -Name j -Value just

# Add Git's usr/bin to PATH so `just` can find sh.exe and cygpath.exe
# (recipes with #!/usr/bin/env bash shebangs need cygpath; plain recipes need sh)
$gitUsrBin = 'C:\Program Files\Git\usr\bin'
if ((Test-Path $gitUsrBin) -and ($env:Path -notlike "*$gitUsrBin*")) {
    $env:Path += ";$gitUsrBin"
}

# Ctrl+U clears the current command line (moved here from a WezTerm SendKey{Escape}
# remap that was hijacking Ctrl+U inside nvim)
Set-PSReadLineKeyHandler -Key Ctrl+u -Function RevertLine
