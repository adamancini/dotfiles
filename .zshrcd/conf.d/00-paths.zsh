# Consolidated PATH additions for tools installed outside of system package managers.
# Loaded first (00- prefix) so paths are available to later conf.d files.
# Note: typeset -U in .zshrc deduplicates, so repeated entries are harmless.

# Bun JavaScript runtime
export BUN_INSTALL="$HOME/.bun"
path+="$BUN_INSTALL/bin"

# Krew (kubectl plugin manager)
path+="$HOME/.krew/bin"

# Claude Code (native installer drops binary at ~/.local/bin/claude)
path+="$HOME/.local/bin"
