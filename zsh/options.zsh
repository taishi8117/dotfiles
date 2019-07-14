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

####### MISC ########
## TODO: REVISE

# added by setup_fb4a.sh
export ANDROID_SDK=/opt/android_sdk
export ANDROID_NDK_REPOSITORY=/opt/android_ndk
export ANDROID_HOME=${ANDROID_SDK}
export PATH=${PATH}:${ANDROID_SDK}/tools:${ANDROID_SDK}/platform-tools

# load profile
if [ -d /etc/profile.d ]; then
  for i in /etc/profile.d/*.sh; do
    if [ -r $i ]; then
      . $i
    fi
  done
  unset i
fi

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/taishinojima/tools/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/taishinojima/tools/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/taishinojima/tools/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/taishinojima/tools/google-cloud-sdk/completion.zsh.inc'; fi
export PATH="/usr/local/sbin:$HOME/tools:$PATH"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# For Arch fzf settings
if [ -f '/usr/share/fzf/completion.zsh' ]; then . '/usr/share/fzf/completion.zsh'; fi
if [ -f '/usr/share/fzf/key-bindings.zsh' ]; then . '/usr/share/fzf/key-bindings.zsh'; fi

export PYTHONPATH=$PYTHONPATH:/home/ubuntu/turbinia
