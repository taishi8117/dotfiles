#!/bin/bash
set -e
DOTFILE_ROOT=$(git rev-parse --show-toplevel)
source $DOTFILE_ROOT/scripts/lib.sh

ok_log "Installing Dein"


curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > /tmp/installer.sh
/bin/bash /tmp/installer.sh ~/.vim/dein


