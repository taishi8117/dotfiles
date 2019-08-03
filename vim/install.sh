#!/bin/bash

DOTFILES_ROOT=$(git rev-parse --show-toplevel)
VIM_HOME=$HOME/.vim

pip3 install --user pynvim

mkdir -p $VIM_HOME
ln -sfn $DOTFILES_ROOT/vim/vimrc $HOME/.vimrc
ln -sfn $DOTFILES_ROOT/vim/rc/ $VIM_HOME/rc
ln -sfn $DOTFILES_ROOT/vim/after/ $VIM_HOME/after

NVIM_CONF=$HOME/.config/nvim
NVIM_HOME=$HOME/.nvim
mkdir -p $NVIM_HOME $NVIM_CONF
ln -sfn $DOTFILES_ROOT/vim/vimrc $NVIM_CONF/init.vim
ln -sfn $DOTFILES_ROOT/vim/after/ $NVIM_CONF/after
ln -sfn $DOTFILES_ROOT/vim/rc/ $NVIM_HOME/rc

nvim --headless +UpdateRemotePlugins +qa
echo "hello dotfiles: vim"

