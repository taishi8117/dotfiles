#!/usr/bin/env bash
# nvim/install.sh - Legacy installer (calls main nvim installer)

set -euo pipefail

# Get dotfiles directory
DOTFILES_ROOT="${DOTFILES_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
export DOTFILES_DIR="$DOTFILES_ROOT"

# Call the main nvim installer
echo "[nvim/install.sh] Calling main nvim installer..."
exec "$DOTFILES_ROOT/lib/installers/nvim.sh" "$@"

