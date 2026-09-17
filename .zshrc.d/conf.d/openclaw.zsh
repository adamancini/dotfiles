# openclaw completion is ~3s to generate; cache it and regenerate only when the binary changes.
# Only generate here — sourcing happens after compinit in .zshrc (compdef requires compinit).
_openclaw_bin=${commands[openclaw]}
if [[ -n $_openclaw_bin ]]; then
  _openclaw_comp=$ZDOTDIR/cache/openclaw-completion.zsh
  if [[ ! -s $_openclaw_comp || $_openclaw_bin -nt $_openclaw_comp ]]; then
    mkdir -p ${_openclaw_comp:h}
    openclaw completion --shell zsh > $_openclaw_comp
  fi
fi
unset _openclaw_bin _openclaw_comp
