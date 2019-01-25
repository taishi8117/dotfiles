#!/bin/bash

DOTFILES_ROOT=$(git rev-parse --show-toplevel)

VIM_HOME=$HOME/.vim
mkdir -p $VIM_HOME
ln -sf $DOTFILES_ROOT/vim/vimrc $HOME/.vimrc
ln -sf $DOTFILES_ROOT/vim/rc/ $VIM_HOME/rc
ln -sf $DOTFILES_ROOT/vim/after/ $VIM_HOME/after

NVIM_HOME=$HOME/.nvim
NVIM_CONF=$HOME/.config/nvim
mkdir -p $NVIM_HOME $NVIM_CONF
ln -sf $DOTFILES_ROOT/vim/vimrc $NVIM_CONF/init.vim
ln -sf $DOTFILES_ROOT/vim/rc/ $NVIM_HOME/rc
ln -sf $DOTFILES_ROOT/vim/after/ $NVIM_HOME/after
