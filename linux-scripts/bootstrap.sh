#!/usr/bin/env bash
# Reproduce Marcus's dev environment on a fresh Ubuntu/Debian box (bare metal, WSL, or a dev EC2).
# Idempotent: every tool is guarded by `command -v`; config linking backs up whatever it replaces.
# Contains NO secrets — SSH keys, AWS SSO, Bitwarden and Tailscale auth are manual post-steps.
#
#   git clone https://github.com/marcusshepp/dotfiles ~/p/dotfiles
#   bash ~/p/dotfiles/linux-scripts/bootstrap.sh                # everything
#   bash ~/p/dotfiles/linux-scripts/bootstrap.sh --skip-packages   # just link configs
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKIP_PACKAGES=0; SKIP_CONFIGS=0
for a in "$@"; do case "$a" in
  --skip-packages) SKIP_PACKAGES=1 ;; --skip-configs) SKIP_CONFIGS=1 ;;
  *) echo "unknown arg: $a"; exit 2 ;;
esac; done

info(){ printf '\033[36m==> %s\033[0m\n' "$*"; }
have(){ command -v "$1" >/dev/null 2>&1; }
mkbin(){ mkdir -p "$HOME/.local/bin"; case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="$HOME/.local/bin:$PATH";; esac; }

link(){ # link <target> <source>
  local target="$1" source="$2"
  [ -e "$source" ] || { echo "!! missing in repo, skipping: $source"; return; }
  mkdir -p "$(dirname "$target")"
  if [ -L "$target" ] && [ "$(readlink -f "$target")" = "$(readlink -f "$source")" ]; then return; fi
  [ -e "$target" ] && mv "$target" "$target.backup.$(date +%s 2>/dev/null || echo bak)"
  ln -sfn "$source" "$target"; info "linked $target -> $source"
}

if [ "$SKIP_PACKAGES" -eq 0 ]; then
  info 'apt base packages'
  sudo apt-get update -y
  sudo apt-get install -y --no-install-recommends \
    git curl wget unzip build-essential ca-certificates gnupg fontconfig \
    ripgrep jq tmux fzf pandoc ffmpeg imagemagick nmap \
    python3 python3-pip python3-venv zsh

  have bun      || { info 'bun';      curl -fsSL https://bun.sh/install | bash; }
  have rustup   || { info 'rustup';   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y; }
  have uv       || { info 'uv';       curl -LsSf https://astral.sh/uv/install.sh | sh; }
  have oh-my-posh || { info 'oh-my-posh'; curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$HOME/.local/bin"; }
  have tailscale  || { info 'tailscale';  curl -fsSL https://tailscale.com/install.sh | sh; }

  if ! have just; then info 'just'; mkbin; curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to "$HOME/.local/bin"; fi

  if ! have go; then
    info 'go (official tarball)'
    GO_VER=1.26.0
    curl -fsSL "https://go.dev/dl/go${GO_VER}.linux-amd64.tar.gz" -o /tmp/go.tgz
    sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf /tmp/go.tgz && rm /tmp/go.tgz
    echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/go.sh >/dev/null
  fi

  if ! have nvim; then
    info 'neovim (official tarball -> /opt/nvim)'
    curl -fsSL https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz -o /tmp/nvim.tgz
    sudo rm -rf /opt/nvim && sudo tar -C /opt -xzf /tmp/nvim.tgz && rm /tmp/nvim.tgz
    sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
  fi

  if ! have node; then
    info 'node (nvm -> latest LTS)'
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
    export NVM_DIR="$HOME/.nvm"; . "$NVM_DIR/nvm.sh"; nvm install --lts
  fi

  if ! have gh; then
    info 'github cli (apt repo)'
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
    sudo apt-get update -y && sudo apt-get install -y gh
  fi

  if ! have terraform; then
    info 'terraform (hashicorp apt repo)'
    wget -qO- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(. /etc/os-release && echo "$VERSION_CODENAME") main" | sudo tee /etc/apt/sources.list.d/hashicorp.list >/dev/null
    sudo apt-get update -y && sudo apt-get install -y terraform
  fi

  if ! have aws; then
    info 'aws cli v2'
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
    (cd /tmp && unzip -q -o awscliv2.zip && sudo ./aws/install --update && rm -rf aws awscliv2.zip)
  fi

  # Cascadia Code (primary dev font)
  if ! fc-list 2>/dev/null | grep -qi 'Cascadia Code'; then
    info 'font: Cascadia Code'
    mkdir -p "$HOME/.local/share/fonts"
    curl -fsSL https://github.com/microsoft/cascadia-code/releases/latest/download/CascadiaCode-2404.23.zip -o /tmp/cc.zip || true
    (cd /tmp && unzip -q -o cc.zip -d cc 2>/dev/null && cp cc/ttf/*.ttf "$HOME/.local/share/fonts/" 2>/dev/null; rm -rf cc cc.zip) || true
    fc-cache -f >/dev/null 2>&1 || true
  fi

  if have npm; then
    info 'npm globals'
    grep -v '^\s*#' "$REPO/bootstrap/npm-globals.txt" | sed '/^\s*$/d' | xargs -r -n1 npm install -g || true
  fi
  if have code; then
    info 'vscode extensions'
    grep -v '^\s*#' "$REPO/bootstrap/vscode-extensions.txt" | sed '/^\s*$/d' | xargs -r -n1 code --install-extension || true
  fi
fi

if [ "$SKIP_CONFIGS" -eq 0 ]; then
  info 'linking configs from repo'
  link "$HOME/.bashrc"              "$REPO/linux-conf/.bashrc"
  link "$HOME/.zshrc"               "$REPO/linux-conf/.zshrc"
  link "$HOME/.tmux.conf"           "$REPO/linux-conf/.tmux.conf"
  link "$HOME/.config/i3/config"    "$REPO/linux-conf/i3/config"
  link "$HOME/.config/kitty/kitty.conf" "$REPO/linux-conf/kitty.conf"
  link "$HOME/.wezterm.lua"         "$REPO/linux-conf/wezterm/wezterm.lua"
  link "$HOME/.config/nvim"         "$REPO/nvim"
  link "$HOME/.gitconfig"           "$REPO/shared/.gitconfig"
  link "$HOME/.ssh/config"          "$REPO/shared/ssh-config"
fi

cat <<'EOF'

==> Toolchain + configs done. MANUAL post-steps (need secrets — not in this repo):
   1. SSH:        ssh-keygen -t ed25519 -C "marcusshepdotcom@gmail.com"   (add .pub to GitHub)
   2. AWS:        aws configure sso     (profile sir-code-alot, us-east-1)
   3. Bitwarden:  npm i -g @bitwarden/cli && bw login
   4. Tailscale:  sudo tailscale up
   5. GitHub CLI: gh auth login
   6. Restart the shell (or: source ~/.bashrc) so PATH + prompt reload.
EOF
