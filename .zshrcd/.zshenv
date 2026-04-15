# Sourced by all zsh instances (interactive and non-interactive) when ZDOTDIR is set.
# ZDOTDIR is exported from ~/.zshenv, so child shells land here instead of ~/.zshenv.

# Load aliases for both interactive and non-interactive shells
[[ -f $ZCONFDIR/aliases.zsh ]] && source $ZCONFDIR/aliases.zsh
