# 環境変数
export LANG=ja_JP.UTF-8

# エディタ
export EDITOR='vim'

#export JAVA_HOME=`/usr/libexec/java_home -v 1.8`
# Android Studio
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# anyenv
export PATH="$HOME/.anyenv/bin:$PATH"
eval "$(anyenv init -)"

eval "$(direnv hook zsh)"
export PGDATA='/usr/local/var/postgres'

alias brew="PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin brew"

