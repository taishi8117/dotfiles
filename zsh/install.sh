#!/bin/bash

DOTFILES_ROOT=$(git rev-parse --show-toplevel)

ZSHRC=$HOME/.zshrc
ZSHENV=$HOME/.zshenv

ln -sfn $DOTFILES_ROOT/zsh/zshrc $ZSHRC
ln -sfn $DOTFILES_ROOT/zsh/zshenv $ZSHENV
echo '[*] Set up ZSH configuration files successfully.'
