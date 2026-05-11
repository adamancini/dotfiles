[[ $TMUX != "" ]] && export TERM='screen-256color'

# xdg
export XDG_CONFIG_HOME="$HOME/.config"

# zsh
export ZDOTDIR=$HOME/.zshrcd
export ZCONFDIR=$ZDOTDIR/conf.d
export HISTFILE="$ZDOTDIR/.zhistory"    # History filepath
export HISTSIZE=100000                   # Maximum events for internal history
export SAVEHIST=100000                   # Maximum events in history file


# Ensure that a non-login shell has a defined environment (any SHLVL).
if [[ ! -o LOGIN && -s ${ZDOTDIR:-~}/.zprofile && -z "$ZPROFILE_SOURCED" ]]; then
  export ZPROFILE_SOURCED=1
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


# Load OS-specific environment settings if available
[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local

# Load tool-specific PATH additions needed for non-interactive SSH
[[ -f ${ZDOTDIR:-~}/conf.d/claude.zsh ]] && source ${ZDOTDIR:-~}/conf.d/claude.zsh
