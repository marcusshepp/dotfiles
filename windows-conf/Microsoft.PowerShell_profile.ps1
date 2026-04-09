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
    claude --dangerously-skip-permissions
}

# -----------------------------------------------------------------------------
# Project Shortcuts
# -----------------------------------------------------------------------------

$projects = @{
    sr = "~/p/internal/sync.runner"
    sp = "~/p/internal/sync.portal"
    si = "~/p/internal/sync.infra"
}

function p {
    param([Parameter(Mandatory = $true)][string]$key)
    if ($projects.ContainsKey($key)) {
        Set-Location $projects[$key]
    } else {
        Write-Host "Unknown project: $key. Options: $($projects.Keys -join ', ')"
    }
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
# Startup
# -----------------------------------------------------------------------------

Set-Location ~/o

# Oh My Posh prompt
oh-my-posh init pwsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/space.omp.json' | Invoke-Expression

# AWS Profile
$env:AWS_PROFILE = 'sir-code-alot'

# Pi local runner (plan authoring + analysis + execution)
function lrun {
    Set-Location ~/p/internal/sync.runner
    pi -ne -ns -np --no-themes `
        --provider github-copilot --model claude-opus-4.6 `
        -e packages/pi-local-runner/extensions/index.ts `
        -e packages/pi-runner-analyst/extensions/index.ts `
        --append-system-prompt packages/pi-local-runner/system-prompt.md `
        @args
}

function pi-plan-analyze {
    Set-Location ~/p/internal/sync.runner/;
    pi -ne -ns -np --no-themes -e packages/pi-runner-analyst/extensions/index.ts;
}

# Tavily API key for Pi web search extension
$env:TAVILY_API_KEY = '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'
