# Sourced by all zsh instances (interactive and non-interactive) when ZDOTDIR is set.
# ZDOTDIR is exported from ~/.zshenv, so child shells land here instead of ~/.zshenv.

# Load aliases for both interactive and non-interactive shells
[[ -f $ZCONFDIR/aliases.zsh ]] && source $ZCONFDIR/aliases.zsh

# Load conf.d modules for non-interactive shells
# (interactive shells load them from .zshrc)
if [[ ! -o interactive && -z "$CONFD_ENV_SOURCED" ]]; then
  export CONFD_ENV_SOURCED=1
  for file in $ZCONFDIR/*.zsh(N); do
    [[ -f $file ]] && source "$file"
  done
fi
