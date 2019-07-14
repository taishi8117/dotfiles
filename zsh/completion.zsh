############################ Completion options ################################
autoload -Uz compinit
compinit

bindkey "\e[Z" reverse-menu-complete # Use Shift+Tab to reverse

### 補完方法毎にグループ化する。
zstyle ':completion:*' format '%B%F{blue}%d%f%b'
zstyle ':completion:*' group-name ''

# 補完後、メニュー選択モードになり左右キーで移動が出来る
# select=2: 補完候補を一覧から選択する。補完候補が2つ以上なければすぐに補完する
zstyle ':completion:*:default' menu select=2

# 補完候補のカラー表示
zstyle ':completion:*' list-colors "${LS_COLORS}" 

# 補完で大文字にもマッチ
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' keep-prefix
zstyle ':completion:*' recent-dirs-insert both

## sudo の時にコマンドを探すパス
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin

#kill の候補にも色付き表示
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([%0-9]#)*=0=01;31'

# 補完候補のメニュー選択で、矢印キーの代わりにhjklで移動出来るようにする。
zmodload zsh/complist
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char

