# Env vars
  export VISUAL=vim
  export EDITOR="$VISUAL"
  export GIT_PS1_SHOWDIRTYSTATE=true
  export GIT_PS1_SHOWUNTRACKEDFILES=true
  export PS1='\[\e[00;33m\][\w]\[\e[0m\]\[\033[00;35m\]$(parse_git_branch)\n\[\033[00;36m\][\h.\u]\[\033[36m\]\[\033[0m\] > '
  export HISTFILESIZE=2000

# Aliases
  alias tmux="TERM=screen-256color-bce tmux"
  alias mkfiledate="date +%m-%d-%y"
  alias grep='grep --color=auto'

parse_git_branch() {
  ref=$(git symbolic-ref HEAD 2> /dev/null | cut -d'/' -f3)
  if [ -n "$ref" ]; then echo "[$ref]"; fi
}
