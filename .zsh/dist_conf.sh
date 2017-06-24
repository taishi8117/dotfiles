#!/bin/bash

if [ "$(uname)" == "Darwin" ]; then
    # Do something under Mac OS X platform        
    echo "Using Darwin"
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    # Do something under GNU/Linux platform
    echo "Using Linux"
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
    # Do something under 32 bits Windows NT platform
    echo "Using WIN 32 NT"
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
    # Do something under 64 bits Windows NT platform
    echo "Using WIN 64 NT"
fi

