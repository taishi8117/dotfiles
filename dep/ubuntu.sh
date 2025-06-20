#!/bin/bash

sudo apt-get update && sudo apt-get install software-properties-common -y
sudo apt-get update
sudo apt-get install git sudo zsh tmux python3 python3-dev python3-pip wget gawk curl ripgrep fd-find -y


mkdir -p ~/garakuta
wget https://github.com/neovim/neovim/releases/download/v0.10.4/nvim-linux-x86_64.tar.gz -O ~/garakuta/nvim0.10.4.tar.gz
tar -xzvf ~/garakuta/nvim0.10.4.tar.gz -C ~/garakuta
sudo ln -s ~/garakuta/nvim-linux-x86_64/bin/nvim /usr/bin/nvim
