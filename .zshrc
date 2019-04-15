# https://github.com/sindresorhus/pure#getting-started
autoload -U promptinit; promptinit
autoload bashcompinit

bashcompinit
prompt pure

# https://qiita.com/kwgch/items/445a230b3ae9ec246fcb
setopt nonomatch

# ブックマーク
fpath=(~/dotfiles/cd-bookmark(N-/) $fpath)
autoload -Uz cd-bookmark

# 補完機能有効化
autoload -Uz compinit
compinit -u

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

# alias
alias p="cd ~/Project"
alias d="cd ~/Desktop"
alias b='cd-bookmark'
alias ls='ls -G'
alias gs='git status'
alias gb='git branch'
alias grep='grep --color=auto'
alias server='python -m SimpleHTTPServer 9999'

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
# コマンドの打ち間違いを指摘してくれる
setopt correct
SPROMPT="correct: $RED%R$DEFAULT -> $GREEN%r$DEFAULT ? [Yes/No/Abort/Edit] => "

zstyle ':completion:*' use-cache true
zstyle ':completion:*:default' menu select=2
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

source ~/.bin/tmuxinator.zsh
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# パスワード生成
# pswgen 5
pswgen() {
  pwgen -sy $1 1 |pbcopy |pbpaste; echo "Has been copied to clipboard"
}

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/ougi/google-cloud-sdk/path.zsh.inc' ]; then source '/Users/ougi/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/ougi/google-cloud-sdk/completion.zsh.inc' ]; then source '/Users/ougi/google-cloud-sdk/completion.zsh.inc'; fi

# wp-cliタブ補完
source ~/.bin/wp-completion.bash
export PATH="/usr/local/opt/openssl/bin:$PATH"

# シェルの再起動
alias relogin='exec $SHELL -l'

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
