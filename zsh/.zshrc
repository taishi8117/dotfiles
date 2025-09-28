#!/usr/bin/env zsh
# vim:fdm=marker:
#
#  Sirius Lab ZSH Configuration
#    _____ _      _            __         __
#   / ___/(______(___  _______/ /  ____ _/ /_
#   \__ \/ / ___/ / / / / ___/ /  / __ `/ __ \
#  ___/ / / /  / / /_/ (__  / /__/ /_/ / /_/ /
# /____/_/_/  /_/\__,_/____/_____\__,_/_.___/
#
#zmodload zsh/zprof

#===============================================================================
# 1: ZINIT CONFIGURATION
#===============================================================================

# Set zinit home directory
export ZINIT_HOME="${HOME}/.local/share/zinit/zinit.git"

# Load zinit
if [[ -f "$ZINIT_HOME/zinit.zsh" ]]; then
    source "$ZINIT_HOME/zinit.zsh"
else
    echo "Warning: zinit not found at $ZINIT_HOME"
    echo "Run the dotfiles installer to set up zinit"
fi

# Load zinit completion
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Essential plugins loaded immediately
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light djui/alias-tips

# Oh-My-Zsh libraries (essential)
zinit snippet OMZ::lib/completion.zsh
if (( $+commands[git] )); then
    zinit snippet OMZ::lib/git.zsh
fi

# Oh-My-Zsh plugins (with lazy loading for better performance)
zinit snippet OMZ::plugins/colorize/colorize.plugin.zsh
zinit snippet OMZ::plugins/colored-man-pages/colored-man-pages.plugin.zsh

if (( $+commands[git] )); then
    zinit ice wait"0a" lucid
    zinit snippet OMZ::plugins/git/git.plugin.zsh
fi

zinit ice wait"0b" lucid
zinit snippet OMZ::plugins/virtualenv/virtualenv.plugin.zsh

if (( $+commands[docker] )); then
    zinit ice wait"0c" lucid
    zinit snippet OMZ::plugins/docker/docker.plugin.zsh
fi

if (( $+commands[nmap] )); then
    zinit ice wait"0d" lucid
    zinit snippet OMZ::plugins/nmap/nmap.plugin.zsh
fi

if (( $+commands[hg] )); then
    zinit ice wait"0e" lucid
    zinit snippet OMZ::plugins/mercurial/mercurial.plugin.zsh
fi

# Load theme
zinit ice pick"sirius-pygmalion.zsh"
zinit load "${DOTFILES_ZSH_BASE}/themes" 2>/dev/null || {
    # Fallback to a simple prompt if theme loading fails
    autoload -U colors && colors
    PROMPT="%{$fg[cyan]%}%n@%m%{$reset_color%}:%{$fg[blue]%}%~%{$reset_color%}$ "
}

#===============================================================================
# 2: BASIC OPTIONS
#===============================================================================

# Color settings
autoload -Uz colors; colors

# Use emacs key bindings
set -o emacs

setopt no_nomatch           # Allow patterns like git show HEAD^ and rake foo[bar]
setopt auto_cd              # Change directory without typing cd
setopt auto_pushd           # Automatically push directories to stack
setopt pushd_ignore_dups    # Remove duplicates from directory stack
setopt correct              # Command correction
setopt no_flow_control      # Disable Ctrl+S lock and Ctrl+Q unlock
cdpath=(~)                  # Directory paths accessible from anywhere
setopt no_beep              # Disable beeping

# Key bindings
#stty erase ^H
#bindkey "^[[3~" delete-char

# Word character settings
autoload -Uz select-word-style
select-word-style default
zstyle ':zle:*' word-chars "_-./;@"
zstyle ':zle:*' word-style unspecified

# Edit command line with external editor
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

#===============================================================================
# 3: HISTORY OPTIONS
#===============================================================================

setopt share_history        # Share history between terminals
setopt histignorealldups    # Remove duplicate entries from history
setopt append_history       # Append to history file instead of overwriting

# History search bindings
bindkey '^r' history-incremental-pattern-search-backward
bindkey '^s' history-incremental-pattern-search-forward

# Search history based on partial command input
autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^p" history-beginning-search-backward-end
bindkey "^n" history-beginning-search-forward-end

#===============================================================================
# 4: COMPLETION OPTIONS
#===============================================================================

# Initialize completion system
autoload -Uz compinit
if [[ $# -gt 0 ]]; then
    compinit
else
    compinit -C
fi

setopt auto_list            # Show completion candidates automatically
setopt auto_menu            # Use menu selection for multiple matches
setopt complete_in_word     # Complete at cursor position
setopt magic_equal_subst    # Enable completion after = in arguments like --prefix=/usr

bindkey "\e[Z" reverse-menu-complete # Use Shift+Tab for reverse completion

# Group completion results by category
zstyle ':completion:*' format '%B%F{blue}%d%f%b'
zstyle ':completion:*' group-name ''

# Menu selection for completions
zstyle ':completion:*:default' menu select=2

# Colorize completion candidates
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' keep-prefix
zstyle ':completion:*' recent-dirs-insert both

# Search path for sudo commands
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin

# Colorize kill command candidates
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([%0-9]#)*=0=01;31'

# Vi-style navigation in completion menu
zmodload zsh/complist
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char

#===============================================================================
# 5: MISC OPTIONS
#===============================================================================

# Load aliases
if [[ -d "$DOTFILES_ZSH_BASE/aliases" ]]; then
    for alias_file in "$DOTFILES_ZSH_BASE/aliases"/*.zsh; do
        [[ -r "$alias_file" ]] && source "$alias_file"
    done
fi

# Load custom override file if it exists
[[ -r ~/zshrc.override ]] && source ~/zshrc.override

# Environment variables
export DOTFILES_ZSH_BASE="${DOTFILES_ZSH_BASE:-$(dirname "${(%):-%x}")}"
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=50000
export SAVEHIST=50000

# Make sure ~/.local/bin is in PATH
[[ ":$PATH:" != *":$HOME/.local/bin:"* ]] && export PATH="$HOME/.local/bin:$PATH"

# Enable command correction
setopt correct

# Zinit configuration
zstyle ':zinit:*' use-xdg-dir false

#===============================================================================
# 6: PERFORMANCE PROFILING (uncomment to debug startup time)
#===============================================================================

# Uncomment the line at the top (#zmodload zsh/zprof) and this section to profile
# zprof