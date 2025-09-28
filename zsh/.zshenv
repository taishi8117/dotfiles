# vim:fdm=marker:
#
#  Sirius Lab ZSH Environment Configuration
#    _____ _      _            __         __
#   / ___/(______(___  _______/ /  ____ _/ /_
#   \__ \/ / ___/ / / / / ___/ /  / __ `/ __ \
#  ___/ / / /  / / /_/ (__  / /__/ /_/ / /_/ /
# /____/_/_/  /_/\__,_/____/_____\__,_/_.___/
#

#===============================================================================
# 0: SHARED
#===============================================================================

export DOTFILES_BASE="${HOME}/dotfiles"
export EDITOR=nvim

# Load system profile scripts
if [ -d /etc/profile.d ]; then
  for i in /etc/profile.d/*.sh; do
    if [ -r $i ]; then
      . $i
    fi
  done
  unset i
fi

#===============================================================================
# 1: GENERAL
#===============================================================================

export DOTFILES_ZSH_BASE="${DOTFILES_BASE}/zsh"

# Show execution time for commands taking longer than 3 seconds
export REPORTTIME=3

#===============================================================================
# 2: HISTORY
#===============================================================================

HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000

#===============================================================================
# 3: PATH
#===============================================================================

# Add user's private bin to PATH if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# Add dotfiles bin directory
PATH="$PATH:$HOME/dotfiles/bin"

#===============================================================================
# 4: MISC
#===============================================================================

# Colorize style for oh-my-zsh colorize plugin
# Refer to http://pygments.org/docs/styles/
# To get all available styles from python:
#
#  >>> from pygments.styles import STYLE_MAP
#  >>> STYLE_MAP.keys()
#
export ZSH_COLORIZE_STYLE="monokai"

# Load Cargo environment if it exists
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Add Foundry to PATH if it exists
[ -d "$HOME/.foundry/bin" ] && export PATH="$PATH:$HOME/.foundry/bin"