if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi
if [ -f ~/.bash_prompt ]; then
  . ~/.bash_prompt
fi
export LANG=ja_JP.UTF-8
export PATH=~/bin:$PATH
export PATH="$HOME/.anyenv/bin:$PATH"
export RAILS_ENV=development
export EDITOR='code'
eval "$(anyenv init -)"

#bash_completion
if [ -f $(brew --prefix)/etc/bash_completion ]; then
  source $(brew --prefix)/etc/bash_completion
fi

#shortcut
alias p="cd ~/Project"
alias d="cd ~/Desktop"
alias ls='ls -G'
alias gs='git status'
alias gb='git branch'

#bash_completion
if [ -f $(brew --prefix)/etc/bash_completion ]; then
  source $(brew --prefix)/etc/bash_completion
fi

#gitの補完
source /usr/local/etc/bash_completion.d/git-prompt.sh
source /usr/local/etc/bash_completion.d/git-completion.bash

