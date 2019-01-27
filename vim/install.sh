#!/bin/bash

DOTFILES_ROOT=$(git rev-parse --show-toplevel)

VIM_HOME=$HOME/.vim
mkdir -p $VIM_HOME
ln -sfh $DOTFILES_ROOT/vim/vimrc $HOME/.vimrc
ln -sfh $DOTFILES_ROOT/vim/rc/ $VIM_HOME/rc
ln -sfh $DOTFILES_ROOT/vim/after/ $VIM_HOME/after

NVIM_CONF=$HOME/.config/nvim
NVIM_HOME=$HOME/.nvim
mkdir -p $NVIM_HOME $NVIM_CONF
ln -sfh $DOTFILES_ROOT/vim/vimrc $NVIM_CONF/init.vim
ln -sfh $DOTFILES_ROOT/vim/after/ $NVIM_CONF/after
ln -sfh $DOTFILES_ROOT/vim/rc/ $NVIM_HOME/rc

echo '[*] Set up configuration files successfully. Launch vim to complete installation'
