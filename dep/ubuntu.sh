#!/bin/bash

sudo apt-get update && sudo apt-get install software-properties-common -y
sudo apt-get update
sudo apt-get install git sudo zsh tmux python3 python3-dev python3-pip wget gawk curl ripgrep fd-find -y

sudo wget https://github.com/neovim/neovim/releases/download/v0.7.2/nvim-linux64.deb -O /tmp/nvim0.7.2.deb
sudo apt-get install /tmp/nvim0.7.2.deb
