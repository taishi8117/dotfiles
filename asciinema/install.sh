#!/bin/bash
DOTFILES_ROOT=$(git rev-parse --show-toplevel)
ASCIINEMA_CONFIG_DIR=$HOME/.config/asciinema

mkdir -p "$ASCIINEMA_CONFIG_DIR"
ln -sfn "$DOTFILES_ROOT/asciinema/config" "$ASCIINEMA_CONFIG_DIR/config"
