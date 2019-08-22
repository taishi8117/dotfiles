#!/bin/zsh

tmux new-session -s 'MITM' \; \
    send-keys 'mitmproxy' C-m \; \
    split-window -v \; \
    select-pane -t 1 \;
