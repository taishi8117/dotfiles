#!/usr/bin/env bash
# tmux/cleanup.sh - Safe cleanup of tmux configuration

set -euo pipefail

# Get dotfiles directory
DOTFILES_ROOT="${DOTFILES_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"

# Source backup functions
# shellcheck source=../lib/backup.sh
source "$DOTFILES_ROOT/lib/backup.sh"

echo "=== Cleaning up tmux configuration ==="

# Backup important files before cleanup
backup_tmux_files

# Remove tmux configuration files
echo "Removing tmux configuration files..."
rm -f ~/.tmux.conf

# Remove tmux directory (but preserve resurrect sessions if they exist)
if [[ -d ~/.tmux ]]; then
    echo "Removing tmux directory..."
    rm -rf ~/.tmux
fi

echo "✅ Tmux cleanup completed (important files backed up)"