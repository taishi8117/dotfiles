#                   .__                   
#    ________  _____|  |_________   ____  
#    \___   / /  ___/  |  \_  __ \_/ ___\ 
#     /    /  \___ \|   Y  \  | \/\  \___ 
# /\ /_____ \/____  >___|  /__|    \___  >
# \/       \/     \/     \/            \/ 
#

source ~/.zsh/git.zsh
source ~/.zsh/ls_color/ls_color.sh

# 色を使用
autoload -Uz colors
colors

############################## History setting #################################
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# Ctrl+rでヒストリーのインクリメンタルサーチ、Ctrl+sで逆順
bindkey '^r' history-incremental-pattern-search-backward
bindkey '^s' history-incremental-pattern-search-forward

# コマンドを途中まで入力後、historyから絞り込み
# 例 ls まで打ってCtrl+pでlsコマンドをさかのぼる、Ctrl+nで逆順
autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^p" history-beginning-search-backward-end
bindkey "^n" history-beginning-search-forward-end

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

################################ Set options ###################################
setopt share_history # 他のターミナルとヒストリーを共有
setopt histignorealldups # ヒストリーに重複を表示しない
setopt append_history  # 複数の zsh を同時に使う時など history ファイルに上書きせず追加

setopt no_nomatch # git show HEAD^とかrake foo[bar]とか使いたい
setopt auto_cd # cdコマンドを省略して、ディレクトリ名のみの入力で移動
setopt auto_pushd # 自動でpushdを実行
setopt pushd_ignore_dups # pushdから重複を削除
setopt correct # コマンドミスを修正
setopt no_flow_control # Ctrl+sのロック, Ctrl+qのロック解除を無効にする
cdpath=(~) # どこからでも参照できるディレクトリパス
setopt no_beep

setopt auto_list  # 補完候補が複数ある時に、一覧表示
setopt auto_menu  # 補完候補が複数あるときに自動的に一覧表示する
setopt complete_in_word  # カーソル位置で補完する。
setopt magic_equal_subst  # コマンドライン引数の --prefix=/usr とか=以降でも補完

# backspace,deleteキーを使えるように
#stty erase ^H
#bindkey "^[[3~" delete-char

# 区切り文字の設定
autoload -Uz select-word-style
select-word-style default
zstyle ':zle:*' word-chars "_-./;@"
zstyle ':zle:*' word-style unspecified

# 実行したプロセスの消費時間が3秒以上かかったら
# 自動的に消費時間の統計情報を表示する。
REPORTTIME=3

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

################################### Misc #######################################
# cdrコマンドを有効 ログアウトしても有効なディレクトリ履歴
# cdr タブでリストを表示
autoload -Uz add-zsh-hook
autoload -Uz chpwd_recent_dirs cdr
add-zsh-hook chpwd chpwd_recent_dirs
# cdrコマンドで履歴にないディレクトリにも移動可能に
zstyle ":chpwd:*" recent-dirs-default true

# 複数ファイルのmv 例　zmv *.txt *.txt.bk
autoload -Uz zmv
alias zmv='noglob zmv -W'

# mkdirとcdを同時実行
function mkcd() {
  if [[ -d $1 ]]; then
    echo "$1 already exists!"
    cd $1
  else
    mkdir -p $1 && cd $1
  fi
}

# =========================================================================== #
# Virtual env

function activate { export VIRTUAL_ENV_DISABLE_PROMPT='1' source ./$1/bin/activate }
function virtualenv_info {
    [ $VIRTUAL_ENV ] && echo '('`basename $VIRTUAL_ENV`') '
}

# =========================================================================== #
# pygmalion PROMPT theme
# =========================================================================== #
prompt_setup_pygmalion(){
  ZSH_THEME_GIT_PROMPT_PREFIX="%{$reset_color%}%{$fg[green]%}"
  ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
  ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[yellow]%}⚡%{$reset_color%}"
  ZSH_THEME_GIT_PROMPT_CLEAN=""

  base_prompt="%{$fg[magenta]%}%n%{$reset_color%}%{$fg[cyan]%}@%{$reset_color%}%{$fg[yellow]%}%m%{$reset_color%}%{$fg[red]%}:%{$reset_color%}%{$fg[cyan]%}%0~%{$reset_color%}%{$fg[red]%}|%{$reset_color%}"
  post_prompt="%{$fg[cyan]%}⇒%{$reset_color%}  "

  base_prompt_nocolor=$(echo "$base_prompt" | perl -pe "s/%\{[^}]+\}//g")
  post_prompt_nocolor=$(echo "$post_prompt" | perl -pe "s/%\{[^}]+\}//g")

  precmd_functions+=(prompt_pygmalion_precmd)
}

prompt_pygmalion_precmd(){
  local gitinfo=$(git_prompt_info)
  local gitinfo_nocolor=$(echo "$gitinfo" | perl -pe "s/%\{[^}]+\}//g")
  local exp_nocolor="$(print -P \"$base_prompt_nocolor$gitinfo_nocolor$post_prompt_nocolor\")"
  local prompt_length=${#exp_nocolor}

  local nl=""

  if [[ $prompt_length -gt 40 ]]; then
    nl=$'\n%{\r%}';
  fi
  PROMPT="$base_prompt$gitinfo$nl$post_prompt"
  RPROMPT="%{$fg[green]%}$(virtualenv_info)%{$reset_color%}"
}

prompt_setup_pygmalion
export FBANDROID_DIR=/Users/taishinojima/fbsource/fbandroid
alias quicklog_update=/Users/taishinojima/fbsource/fbandroid/scripts/quicklog/quicklog_update.sh
alias qlu=quicklog_update

# added by setup_fb4a.sh
export ANDROID_SDK=/opt/android_sdk
export ANDROID_NDK_REPOSITORY=/opt/android_ndk
export ANDROID_HOME=${ANDROID_SDK}
export PATH=${PATH}:${ANDROID_SDK}/tools:${ANDROID_SDK}/platform-tools

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/taishinojima/tools/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/taishinojima/tools/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/taishinojima/tools/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/taishinojima/tools/google-cloud-sdk/completion.zsh.inc'; fi
export PATH="/usr/local/sbin:$HOME/tools:$PATH"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
