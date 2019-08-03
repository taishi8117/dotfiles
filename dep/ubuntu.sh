#!/bin/bash

sudo apt-get update && apt-get install software-properties-common -y
sudo add-apt-repository ppa:neovim-ppa/stable
sudo apt-get update
sudo apt-get install git sudo zsh tmux neovim python3 python3-dev python3-pip wget gawk curl -y
