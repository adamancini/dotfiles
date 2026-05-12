# Enable Powerlevel10k instant prompt. Should stay close to the top of .zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# .zshrc is only for interactive shells
[[ -o interactive ]] || return 0

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

export ZLUA_EXEC="luajit"

# zsh-history-substring-search keybindings (called via post: annotation in .zsh_plugins.txt)
function hss-bindkey() {
  zmodload zsh/terminfo
  local keymap
  for keymap in 'main' 'emacs' 'viins'; do
    bindkey -M "$keymap" "$terminfo[kcuu1]" history-substring-search-up
    bindkey -M "$keymap" "$terminfo[kcud1]" history-substring-search-down
  done
}

# load conf.d modules
if [[ -d $ZDOTDIR/conf.d ]]; then
  for file in $ZDOTDIR/conf.d/*.zsh; do
    source $file
  done
fi

# custom completions directory
fpath+="$ZDOTDIR/completions"

# antidote static loading
zsh_plugins=${ZDOTDIR}/.zsh_plugins
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  source /Users/ada/src/github.com/mattmc3/antidote/antidote.zsh
  antidote bundle <${zsh_plugins}.txt >${zsh_plugins}.zsh
fi
source ${zsh_plugins}.zsh

# compinit
autoload -Uz compinit
_zcompdump=$ZDOTDIR/.zcompdump
if [[ -n $_zcompdump(#qN.mh-20) ]]; then
  compinit -C -d $_zcompdump
else
  compinit -u -d $_zcompdump
fi
unset _zcompdump
_comp_options+=(globdots)

# deferred completions
(( $+functions[_kubecm_setup_completion] )) && _kubecm_setup_completion && unfunction _kubecm_setup_completion

[[ -t 0 ]] && stty -ixon
bindkey -e

function _ctrl_d_handler() {
  if [[ -z "$BUFFER" ]]; then
    zle -M "zsh: use 'exit' to exit."
  else
    zle delete-char
  fi
}
zle -N _ctrl_d_handler
bindkey '^D' _ctrl_d_handler

# p10k theme config
[[ ! -f ${ZDOTDIR}/.p10k.zsh ]] || source ${ZDOTDIR}/.p10k.zsh

# bun completions
[ -s "/Users/ada/.bun/_bun" ] && source "/Users/ada/.bun/_bun"
