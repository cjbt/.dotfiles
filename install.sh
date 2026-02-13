#!/usr/bin/env bash
set -euo pipefail

# Bootstrap dotfiles on a fresh Mac
# Usage: git clone <repo> ~/.dotfiles && ~/.dotfiles/install.sh

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DOTFILES_DIR"

# 1. Homebrew
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# 2. Stow
if ! command -v stow &>/dev/null; then
  echo "Installing stow..."
  brew install stow
fi

# 3. Symlink all packages
packages=(zsh git starship ghostty mise hammerspoon ssh)

echo "Stowing packages from $DOTFILES_DIR ..."
for pkg in "${packages[@]}"; do
  echo "  -> $pkg"
  stow --restow "$pkg"
done

echo "Done. All symlinks created."
