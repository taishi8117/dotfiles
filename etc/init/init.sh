#!/bin/sh

echo "[+] Installing vim plugins..."
vim +NeoBundleInstall +qall
echo "[+] Vim plugin installed!"

echo "[+] Installing tmux configurations..."
DOTFILES_ROOT=$(git rev-parse --show-toplevel)
TMUX_INSTALL="$DOTFILES_ROOT/tmux-config/install.sh"
$TMUX_INSTALL
echo "[+] tmux configuration installed!"
