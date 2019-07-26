############################## Alias Settings ##################################
alias sirius-ssh='ssh sirius@71.145.208.119 -p 2222'

alias rg='rg -p'
alias less='less -RFX'
alias grep='grep --color=auto'
alias -g L='| less'
alias -g H='| head'
alias -g G='| grep'
alias -g GI='| grep -ri'

# エイリアス
if [ "$(uname)" = 'Darwin' ]; then
    # Do something under Mac OS X platform        
    # echo "Using Darwin"
    export CLICOLOR=1
    export LSCOLORS=GxFxCxDxBxegedabagaced
    alias ls='ls -G'
    alias lst='ls -ltr'
    alias l='ls -ltr'
    alias la='ls -la'
    alias ll='ls -l'
    chpwd() { ls -ltr -G } # cdの後にlsを実行
elif [ "$(expr substr $(uname -s) 1 5)" = 'Linux' ];  then
    # Do something under GNU/Linux platform
    # echo "Using Linux"
    alias ls='ls --color=auto'
    alias l='ls -alhtr'
    alias la='ls -la'
    alias ll='ls -l'
    chpwd() { ls -ltr --color=auto } # cdの後にlsを実行
fi

alias so='source'
alias vim='nvim'
alias v='vim'
alias vi='vim'
alias vz='vim ~/.zshrc'
alias c='cdr'
alias h='fc -lt '%F %T' 1' # historyに日付を表示
alias mkdir='mkdir -p'
alias ..='c ../'
alias back='pushd'
alias diff='diff -U1'

# change the current directory to the parent directory that contains the .git folder
alias groot='cd "`git rev-parse --show-toplevel`"'

# tmux
alias t='tmux'
alias ta='t attach -t'


function cl () {
  ccat $1 | less
}


# Docker related
# https://blog.ropnop.com/docker-for-pentesters/

alias dockerzsh="docker run --rm -i -t --entrypoint=/bin/zsh"
alias dockerbash="docker run --rm -i -t --entrypoint=/bin/bash"
alias dockersh="docker run --rm -i -t --entrypoint=/bin/sh"

function dockerzshhere() {
    dirname=${PWD##*/}
    docker run --rm -it --entrypoint=/bin/zsh -v `pwd`:/${dirname} -w /${dirname} "$@"
}
function dockerbashhere() {
    dirname=${PWD##*/}
    docker run --rm -it --entrypoint=/bin/bash -v `pwd`:/${dirname} -w /${dirname} "$@"
}
function dockershhere() {
    dirname=${PWD##*/}
    docker run --rm -it --entrypoint=/bin/sh -v `pwd`:/${dirname} -w /${dirname} "$@"
}
