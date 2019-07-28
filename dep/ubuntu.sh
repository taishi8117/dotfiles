#!/bin/bash

apt-get update && apt-get install software-properties-common -y
add-apt-repository ppa:neovim-ppa/stable
apt-get update
apt-get install git sudo zsh tmux neovim python3 python3-dev python3-pip wget gawk curl -y
