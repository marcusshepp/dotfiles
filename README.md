# 🚀 Dotfiles

A meticulously curated collection of development environment configurations, designed for seamless cross-platform development on both Windows and Linux systems.

## 📋 Overview

This repository contains my personal development environment configurations, carefully organized to support a consistent experience across multiple machines and operating systems. It includes configurations for terminal emulators, window managers, and development tools, with automated setup scripts for easy deployment.

> **No secrets live here.** This repo is public. SSH keys, AWS/SSO creds, Bitwarden, and API keys are never committed — configs load them from SSM / `~/.aws` / Bitwarden / gitignored files at runtime. See `.gitignore`.

## 🔁 Reproduce this environment

One command per OS provisions the toolchain and links every config into place. Both scripts are idempotent (safe to re-run) and finish by printing the manual, secret-bearing steps (SSH keygen, AWS SSO, Bitwarden, Tailscale) that can't be automated from a public repo.

**Windows** (elevated PowerShell 7):

```powershell
git clone https://github.com/marcusshepp/dotfiles ~/p/dotfiles
~/p/dotfiles/windows-scripts/bootstrap.ps1
```

**Ubuntu / Debian / WSL:**

```bash
git clone https://github.com/marcusshepp/dotfiles ~/p/dotfiles
bash ~/p/dotfiles/linux-scripts/bootstrap.sh
```

What the bootstrap installs is version-controlled in [`bootstrap/`](bootstrap/):

| File | Purpose |
|------|---------|
| `bootstrap/winget-packages.json` | Windows package manifest (`winget import`). Regenerate the raw superset with `winget export`. |
| `bootstrap/npm-globals.txt` | Global npm CLIs + language servers (both OSes). |
| `bootstrap/vscode-extensions.txt` | VS Code / Cursor extensions (both OSes). |

To refresh the **backup** after changing configs on Windows, run `windows-scripts/backup-configs.ps1`, then commit and push.

## 🛠️ Technology Stack

### Windows Environment

- **[Neovim](https://neovim.io/)** - Modern, extensible text editor
- **[GlazeWM](https://github.com/glazewm/glazewm)** - Tiling window manager for Windows
- **[Zebar](https://github.com/zebar/zebar)** - Minimalist status bar
- **[WezTerm](https://wezfurlong.org/wezterm/)** - GPU-accelerated terminal emulator

### Linux Environment

- **[i3](https://i3wm.org/)** - Dynamic tiling window manager
- **[Kitty](https://sw.kovidgoyal.net/kitty/)** - Fast, feature-rich terminal emulator

## 🔗 Symlink Management

### Current Implementation

Currently, symlinks are manually created to map configuration files from this repository to their respective locations in the system. This ensures that any changes made to the configurations are tracked in version control.

## 🛠️ Planned Improvements

- [x] Automated symlink creation scripts (`bootstrap.ps1` / `bootstrap.sh`)
- [x] Cross-platform configuration synchronization (Windows + Ubuntu bootstrap)
- [x] Backup and restore functionality (`backup-configs.ps1` capture + bootstrap restore)
- [ ] Version tracking and update notifications
- [ ] Configuration validation tests
- [ ] Plugin version management
- [ ] Documentation for each tool's configuration

## 🙏 Acknowledgments

Special thanks to the developers and communities behind all the tools used in this configuration. Their work makes this development environment possible.
Specifically the neovim community, the inspiration I draw from this community is endless.
