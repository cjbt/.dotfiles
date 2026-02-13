#!/usr/bin/env bash
set -euo pipefail

# Install dotfiles via GNU Stow
# Usage: ./install.sh

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DOTFILES_DIR"

packages=(zsh git starship ghostty mise hammerspoon ssh)

echo "Stowing packages from $DOTFILES_DIR ..."
for pkg in "${packages[@]}"; do
  echo "  -> $pkg"
  stow --restow "$pkg"
done

echo "Done. All symlinks created."
