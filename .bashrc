# Env vars
  export VISUAL=vim
  export EDITOR="$VISUAL"
  export GIT_PS1_SHOWDIRTYSTATE=true
  export GIT_PS1_SHOWUNTRACKEDFILES=true
  export PS1='\[\e[00;33m\][\w]\[\e[0m\]\[\033[00;35m\]$(__git_ps1 " (%s)")\n\[\033[00;36m\][\h.\u]\[\033[36m\]\[\033[0m\] > '

# Aliases
  alias tmux='TERM=screen-256color-bce tmux'
