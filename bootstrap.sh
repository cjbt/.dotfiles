#!/usr/bin/env bash
set -euo pipefail

# Bare-machine entry point. Curl-able.
# Usage: curl -fsSL https://raw.githubusercontent.com/cjbt/.dotfiles/main/bootstrap.sh | bash -s -- [company]
#   company — 1Password vault name to provision from (default: personal)

COMPANY="${1:-personal}"
DOTFILES_REPO="https://github.com/cjbt/.dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"

GREEN='\033[0;32m'; NC='\033[0m'
info() { echo -e "${GREEN}[bootstrap]${NC} $*"; }

# ── 1. Xcode Command Line Tools ────────────────────────────────────────────────
if ! xcode-select -p &>/dev/null; then
  info "Installing Xcode Command Line Tools..."
  info "A macOS dialog will appear — click Install and wait for it to complete."
  xcode-select --install
  echo ""
  read -r -p "Press Enter once the Xcode CLI tools installation has finished..."
fi

# ── 2. Homebrew ────────────────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ── 3. Clone or update dotfiles ────────────────────────────────────────────────
if [[ -d "$DOTFILES_DIR/.git" ]]; then
  info "Updating existing dotfiles at $DOTFILES_DIR..."
  git -C "$DOTFILES_DIR" pull --ff-only
else
  info "Cloning dotfiles to $DOTFILES_DIR..."
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

# ── 4. Run install.sh ──────────────────────────────────────────────────────────
info "Running install.sh for company: $COMPANY"
bash "$DOTFILES_DIR/install.sh" "$COMPANY"
