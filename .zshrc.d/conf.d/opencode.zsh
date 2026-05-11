# opencode CLI -- add to PATH only when installed
[[ -x "$HOME/.opencode/bin/opencode" ]] && path+="$HOME/.opencode/bin"

alias oc='opencode'

# Paivot-ai OpenCode plugin root (for opencode-pvg seed and agent resolution)
export CLAUDE_PLUGIN_ROOT="$HOME/src/github.com/paivot-ai/opencode-paivot"
export PVG_PATH="opencode-pvg"
