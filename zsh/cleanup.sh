#!/usr/bin/env bash
# zsh/cleanup.sh - Safe cleanup of zsh configuration

set -euo pipefail

# Get dotfiles directory
DOTFILES_ROOT="${DOTFILES_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"

# Source backup functions
# shellcheck source=../lib/backup.sh
source "$DOTFILES_ROOT/lib/backup.sh"

echo "=== Cleaning up zsh configuration ==="

# Backup important files before cleanup
backup_zsh_files

# Remove zsh configuration files
echo "Removing zsh configuration files..."
rm -f ~/.zshrc ~/.zshenv

# Remove old zplug installation
if [[ -d ~/.zplug ]]; then
    echo "Removing old zplug installation..."
    rm -rf ~/.zplug
fi

# Remove zinit installation
if [[ -d ~/.local/share/zinit ]]; then
    echo "Removing zinit installation..."
    rm -rf ~/.local/share/zinit
fi

# Remove zsh sessions
rm -rf ~/.zsh_sessions

echo "✅ Zsh cleanup completed (important files backed up)"

