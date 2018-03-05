# 環境変数
export LANG=ja_JP.UTF-8

# https://github.com/sindresorhus/pure#getting-started
autoload -U promptinit; promptinit
prompt pure

# 補完機能有効化
autoload -Uz compinit
compinit

# 色使用有効化
autoload -Uz colors
colors

# cd後、自動的にpushdする
setopt auto_pushd

# 重複したディレクトリを追加しない
setopt pushd_ignore_dups

HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

# 日本語ファイル名を表示可能にする
setopt print_eight_bit

# beepを無効
setopt no_beep

# Ctrl+Dでzshを終了しない
setopt ignore_eof

# '#'以降をコメントとして扱う
setopt interactive_comments

# プロンプト
#PROMPT="%{${fg[green]}%}[%n@%m]%{${reset_color}%} %~
#%# "

# anyenv
export PATH="$HOME/.anyenv/bin:$PATH"
eval "$(anyenv init -)"

#gitの補完
#source /usr/local/etc/bash_completion.d/git-prompt.sh
#source /usr/local/etc/bash_completion.d/git-completion.bash

# alias
alias p="cd ~/Project"
alias d="cd ~/Desktop"
alias ls='ls -G'
alias gs='git status'
alias gb='git branch'
alias grep='grep --color=auto'

#同時に起動したzshの間でヒストリを共有する
setopt share_history

# 同じコマンドをヒストリに残さない
setopt hist_ignore_all_dups

# スペースから始まるコマンド行はヒストリに残さない
setopt hist_ignore_space

# ヒストリに保存するときに余分なスペースを削除する
setopt hist_reduce_blanks

# ディレクトリ名の補完で末尾の / を自動的に付加し、次の補完に備える
setopt auto_param_slash
# ファイル名の展開でディレクトリにマッチした場合 末尾に / を付加
setopt mark_dirs
# 補完候補一覧でファイルの種別を識別マーク表示 (訳注:ls -F の記号)
setopt list_types
# 補完キー連打で順に補完候補を自動で補完
setopt auto_menu
# カッコの対応などを自動的に補完
setopt auto_param_keys
# 語の途中でもカーソル位置で補完
setopt complete_in_word

zstyle ':completion:*' use-cache true
zstyle ':completion:*:default' menu select=2
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

