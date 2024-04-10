#!/bin/bash

sudo apt-get update && sudo apt-get install software-properties-common -y
sudo apt-get update
sudo apt-get install git sudo zsh tmux python3 python3-dev python3-pip wget gawk curl ripgrep fd-find -y

sudo wget https://github.com/neovim/neovim/releases/download/v0.8.3/nvim-linux64.deb -O /tmp/nvim0.8.3.deb
sudo apt-get install /tmp/nvim0.8.3.deb


mkdir -p ~/garakuta
wget https://github.com/neovim/neovim/releases/download/v0.9.5/nvim-linux64.tar.gz -O ~/garakuta/nvim0.9.5.tar.gz
tar -xzvf ~/garakuta/nvim0.9.5.tar.gz -C ~/garakuta
sudo ln -s ~/garakuta/nvim-linux64/bin/nvim /usr/bin/nvim
