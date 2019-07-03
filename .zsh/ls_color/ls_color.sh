#!/bin/bash
if hash dircolors 2>/dev/null; then
  #eval `dircolors ~/.zsh/ls_color/dircolors.256dark`
  eval `dircolors ~/.zsh/ls_color/dircolors.ansi-dark`
elif hash gdircolors 2>/dev/null; then
  eval `gdircolors ~/.zsh/ls_color/dircolors.ansi-dark`
fi
