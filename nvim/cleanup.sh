#!/usr/bin/env bash
# nvim/cleanup.sh - Safe cleanup of neovim configuration

set -euo pipefail

# Get dotfiles directory
DOTFILES_ROOT="${DOTFILES_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"

# Source backup functions
# shellcheck source=../lib/backup.sh
source "$DOTFILES_ROOT/lib/backup.sh"

echo "=== Cleaning up neovim configuration ==="

# Backup important files before cleanup
backup_nvim_files

# Remove neovim configuration files
echo "Removing neovim configuration files..."
rm -rf ~/.vim ~/.vimrc ~/.nvim
rm -rf ~/.config/nvim ~/.config/coc
rm -rf ~/.cache/nvim ~/.local/share/nvim
rm -rf ~/.dein_cache

echo "✅ Neovim cleanup completed (important files backed up)"
