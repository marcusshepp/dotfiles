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

function strapi {
    Set-Location ~/p/strapi/strapi
    railway run npm run develop
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


function u {
    wsl -d Ubuntu
}

# -----------------------------------------------------------------------------
# Startup
# -----------------------------------------------------------------------------

Set-Location ~/o/s/

# Oh My Posh prompt
oh-my-posh init pwsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/space.omp.json' | Invoke-Expression

# AWS Profile
$env:AWS_PROFILE = 'sir-code-alot'
