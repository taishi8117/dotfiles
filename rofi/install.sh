#!/bin/bash

DOTFILES_ROOT=$(git rev-parse --show-toplevel)
ROFI_CONFIG_DIR=$HOME/.config/rofi
ROFI_CONFIG_FILE=$ROFI_CONFIG_DIR/config

if [[ -f "$ROFI_CONFIG_FILE" ]]; then
    echo "$ROFI_CONFIG_FILE" exists, renaming to "$ROFI_CONFIG_FILE".bak
    mv "$ROFI_CONFIG_FILE" "$ROFI_CONFIG_FILE".bak
fi

ln -sfn "$DOTFILES_ROOT/rofi/config" "$ROFI_CONFIG_FILE"
ln -sfn "$DOTFILES_ROOT/rofi/scripts" $ROFI_CONFIG_DIR/scripts
