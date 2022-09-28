[[ $TMUX != "" ]] && export TERM='screen-256color'

# xdg
export XDG_CONFIG_HOME="$HOME/.config"

# editor
export LANG=en_US.UTF-8
export EDITOR='vim'
export VISUAL='subl -w'

# zsh
export ZDOTDIR=$HOME/.zshrcd
export HISTFILE="$ZDOTDIR/.zhistory"    # History filepath
export HISTSIZE=10000                   # Maximum events for internal history
export SAVEHIST=10000                   # Maximum events in history file


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
