#!/bin/zsh

if [ "$(uname)" == "Darwin" ]; then
    # Do something under Mac OS X platform        
    # echo "Using Darwin"
    alias lst='ls -ltr -G'
    alias l='ls -ltr -G'
    alias ls='ls -G'
    alias la='ls -la -G'
    alias ll='ls -l -G'
    chpwd() { ls -ltr -G } # cdの後にlsを実行
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    # Do something under GNU/Linux platform
    alias lst='ls -ltr --color=auto'
    alias l='ls -ltr --color=auto'
    alias ls='ls --color=auto'
    alias la='ls -la --color=auto'
    alias ll='ls -l --color=auto'
    chpwd() { ls -ltr --color=auto } # cdの後にlsを実行
    echo "Using Linux"
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
    # Do something under 32 bits Windows NT platform
    echo "Using WIN 32 NT"
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
    # Do something under 64 bits Windows NT platform
    echo "Using WIN 64 NT"
fi

