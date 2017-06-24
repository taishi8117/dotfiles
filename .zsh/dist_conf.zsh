#!/bin/zsh

if [ "$(uname)" = 'Darwin' ]; then
    # Do something under Mac OS X platform        
    echo "Using Darwin"
    alias lst='ls -ltr -G'
    alias l='ls -ltr -G'
    alias ls='ls -G'
    alias la='ls -la -G'
    alias ll='ls -l -G'
    chpwd() { ls -ltr -G } # cdの後にlsを実行
elif [ "$(expr substr $(uname -s) 1 5)" = 'Linux' ];  then
    # Do something under GNU/Linux platform
    echo "Using Linux"
    alias lst='ls -ltr --color=auto'
    alias l='ls -ltr --color=auto'
    alias ls='ls --color=auto'
    alias la='ls -la --color=auto'
    alias ll='ls -l --color=auto'
    chpwd() { ls -ltr --color=auto } # cdの後にlsを実行
fi

