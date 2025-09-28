#!/usr/bin/env bash
# tmux/install.sh - Legacy installer (calls main tmux installer)

set -euo pipefail

# Get dotfiles directory
DOTFILES_ROOT="${DOTFILES_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
export DOTFILES_DIR="$DOTFILES_ROOT"

# Call the main tmux installer
echo "[tmux/install.sh] Calling main tmux installer..."
exec "$DOTFILES_ROOT/lib/installers/tmux.sh" "$@"
