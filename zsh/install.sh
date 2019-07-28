#!/bin/bash

DOTFILES_ROOT=$(git rev-parse --show-toplevel)

ZSHRC=$HOME/.zshrc
ZSHENV=$HOME/.zshenv

# Install zplug
git clone https://github.com/taishi8117/zplug $ZPLUG_HOME

ln -sfn $DOTFILES_ROOT/zsh/zshrc $ZSHRC
ln -sfn $DOTFILES_ROOT/zsh/zshenv $ZSHENV

# Here, ~/.zshenv and ~/.zshrc are loaded
zsh -ic "echo 'hello dotfiles: zsh'"
