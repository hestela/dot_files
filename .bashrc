# Env vars
  export VISUAL=vim
  export EDITOR="$VISUAL"
  export GIT_PS1_SHOWDIRTYSTATE=true
  export GIT_PS1_SHOWUNTRACKEDFILES=true
  export PS1='\[\e[00;33m\][\w]\[\e[0m\]\[\033[00;35m\]$(parse_git_branch)\n\[\033[00;36m\][\h.\u]\[\033[36m\]\[\033[0m\] > '

# Aliases
if [[ -n $(infocmp screen-256color-bce 2>/dev/null) ]]; then
  alias tmux="TERM=screen-256color-bce tmux"
elif [[ -n $(infocmp screen-256color) ]]; then
  alias tmux="TERM=screen-256color tmux"
else
  >&2 echo "ERROR: screen-256color and screen-256color-bce TERM not valid for this system"
fi

parse_git_branch() {
ref=$(git symbolic-ref HEAD 2> /dev/null | cut -d'/' -f3)

if [ -n "$ref" ]; then echo "[$ref]"; fi
}
