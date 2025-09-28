#!/usr/bin/env bash
# zsh/install.sh - Legacy installer (calls main zsh installer)

set -euo pipefail

# Get dotfiles directory
DOTFILES_ROOT="${DOTFILES_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
export DOTFILES_DIR="$DOTFILES_ROOT"

# Call the main zsh installer
echo "[zsh/install.sh] Calling main zsh installer..."
exec "$DOTFILES_ROOT/lib/installers/zsh.sh" "$@"
