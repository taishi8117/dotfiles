#!/bin/bash
# maybe better to run compaudit | xargs sudo {chmod,chown} -R
sudo chmod -R 755 /usr/local/share/zsh
sudo chown -R root:root /usr/local/share/zsh
sudo chmod -R 755 ${HOME}/.zplug
sudo chown -R root:root ${HOME}/.zplug
