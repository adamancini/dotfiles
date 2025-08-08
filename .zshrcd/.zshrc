

DISABLE_AUTO_UPDATE="true"
ENABLE_CORRECTION="false"
COMPLETION_WAITING_DOTS="true"

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=10'
ZSH_TMUX_CONFIG=$HOME/.tmux.d/tmux.conf

# import completions files
fpath+=($ZDOTDIR/completions $fpath)

# load completions for homebrew
if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
  path+="/opt/homebrew/sbin"
fi

# turn on completions
autoload -Uz compinit
compinit -u
_comp_options+=(globdots) # With hidden files

setopt prompt_subst
setopt complete_aliases

export HISTTIMEFORMAT="[%F %T] "
setopt append_history
setopt autocd
setopt extendedglob
setopt nomatch
setopt notify
setopt inc_append_history
setopt share_history
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_save_no_dups
setopt extended_history
setopt hist_find_no_dups


if [[ -d $ZDOTDIR/conf.d ]]; then
  for file in $ZDOTDIR/conf.d/*.zsh; do
    source $file
  done
fi

# load antigen
if [ -f $ZDOTDIR/conf.d/antigen.zsh ]; then
  typeset -a ANTIGEN_CHECK_FILES=(${ZDOTDIR:-~}/.zshrc ${ZDOTDIR:-~}/antigen.zsh)
  ADOTDIR=$HOME/.antigen
  ANTIGEN_LOG=$ADOTDIR/logs
  POWERLEVEL9K_DISABLE_RPROMPT=true
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(status host dir vcs)
  antigen init $ZDOTDIR/antigenrc
fi

# disable Ctrl+S 'freeze terminal' keybind
stty -ixon

# enable emacs keybindings (disable vi mode)
bindkey -e

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

if type direnv &> /dev/null; then
  eval "$(direnv hook zsh)"
fi

alias claude="/Users/ada/.claude/local/claude"
