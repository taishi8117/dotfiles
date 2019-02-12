#!/bin/bash

# For neovim
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:neovim-ppa/stable
sudo apt-get update
sudo apt-get install neovim

sudo apt-get install python-dev python-pip python3-dev python3-pip
pip3 install --user pynvim
pip3 install --user --upgrade pynvim
