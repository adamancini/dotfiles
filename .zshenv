[[ $TMUX != "" ]] && export TERM='screen-256color'

# xdg
export XDG_CONFIG_HOME="$HOME/.config"

# zsh
export ZDOTDIR=$HOME/.zshrcd
export ZCONFDIR=$ZDOTDIR/conf.d
export HISTFILE="$ZDOTDIR/.zhistory"    # History filepath
export HISTSIZE=100000                   # Maximum events for internal history
export SAVEHIST=100000                   # Maximum events in history file


# Ensure that a non-login, non-interactive shell has a defined environment.
if [[ ( "$SHLVL" -eq 1 && ! -o LOGIN ) && -s ${ZDOTDIR:-~}/.zprofile ]]; then
  source ${ZDOTDIR:-~}/.zprofile
fi

# golang
export GOPATH=$HOME/go
export GOBIN=$HOME/go/bin
# export GOCACHE=$XDG_CACHE_HOME/go-build


# path
typeset -aU path
path+=$HOME/bin
path+=$GOPATH/bin
if [[ "$(uname -s)" = "Darwin" ]]; then
  path+=/opt/homebrew/bin
fi
