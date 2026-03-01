
# Deduplicate path arrays (prevents bloat on re-source)
typeset -U fpath path

DISABLE_AUTO_UPDATE="true"
ENABLE_CORRECTION="false"
COMPLETION_WAITING_DOTS="true"

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=10'
ZSH_TMUX_CONFIG=$HOME/.tmux.d/tmux.conf

setopt prompt_subst
setopt complete_aliases
setopt ignore_eof

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

# load conf.d modules (paths, aliases, tool configs)
if [[ -d $ZDOTDIR/conf.d ]]; then
  for file in $ZDOTDIR/conf.d/*.zsh; do
    source $file
  done
fi

# turn on completions (after conf.d so fpath additions are picked up)
autoload -Uz compinit
compinit -u
_comp_options+=(globdots) # With hidden files

# load antigen (only once per session)
if [ -f $ZDOTDIR/conf.d/antigen.zsh ] && [[ -z "$_ANTIGEN_LOADED" ]]; then
  typeset -a ANTIGEN_CHECK_FILES=(${ZDOTDIR:-~}/.zshrc ${ZDOTDIR:-~}/conf.d/antigen.zsh)
  ADOTDIR=$HOME/.antigen
  ANTIGEN_LOG=$ADOTDIR/logs
  POWERLEVEL9K_DISABLE_RPROMPT=true
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(status host dir vcs)
  antigen init $ZDOTDIR/antigenrc
  _ANTIGEN_LOADED=1
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh  # re-source after oh-my-zsh to preserve fzf bindings
fi

# disable Ctrl+S 'freeze terminal' keybind
stty -ixon

# enable emacs keybindings (disable vi mode)
bindkey -e

# Ctrl+D: delete char mid-line, warn on empty line (no completion trigger)
function _ctrl_d_handler() {
  if [[ -z "$BUFFER" ]]; then
    zle -M "zsh: use 'exit' to exit."
  else
    zle delete-char
  fi
}
zle -N _ctrl_d_handler
bindkey '^D' _ctrl_d_handler
