#!/bin/bash

DOTFILES_ROOT=$(git rev-parse --show-toplevel)

XRESOURCES_REGOLIS_SRC=$DOTFILES_ROOT/regolith/Xresources-regolith
XRESOURCES_REGOLIS_DST=$HOME/.Xresources-regolith

XRESOURCES_D_SRC=$DOTFILES_ROOT/regolith/Xresources.d
XRESOURCES_D_DST=$HOME/.Xresources.d

CONFIG_I3_SRC=$DOTFILES_ROOT/regolith/config_regolith/i3
CONFIG_I3_DST=$HOME/.config/regolith/i3
CONFIG_I3XROCKS_SRC=$DOTFILES_ROOT/regolith/config_regolith/i3xrocks
CONFIG_I3XROCKS_DST=$HOME/.config/regolith/i3xrocks

ln -sfn $XRESOURCES_REGOLIS_SRC $XRESOURCES_REGOLIS_DST
ln -sfn $XRESOURCES_D_SRC $XRESOURCES_D_DST
ln -sfn $CONFIG_I3_SRC $CONFIG_I3_DST
ln -sfn $CONFIG_I3XROCKS_SRC $CONFIG_I3XROCKS_DST
