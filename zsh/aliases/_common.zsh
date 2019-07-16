############################## Alias Settings ##################################
alias sirius-ssh='ssh sirius@71.145.208.119 -p 2222'
alias dev='ssh devvm1209.prn3.facebook.com'

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
    alias lst='ls -ltr -G'
    alias l='ls -ltr -G'
    alias ls='ls -G'
    alias la='ls -la -G'
    alias ll='ls -l -G'
    chpwd() { ls -ltr -G } # cdの後にlsを実行
elif [ "$(expr substr $(uname -s) 1 5)" = 'Linux' ];  then
    # Do something under GNU/Linux platform
    # echo "Using Linux"
    alias lst='ls -ltr --color=auto'
    alias l='ls -ltr --color=auto'
    alias ls='ls --color=auto'
    alias la='ls -la --color=auto'
    alias ll='ls -l --color=auto'
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

