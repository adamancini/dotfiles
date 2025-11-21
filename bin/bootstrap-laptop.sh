#!/bin/bash
#
# Standalone Bootstrap Script
# Wrapper that calls the modular YADM bootstrap system
#
# This script provides a convenient way to run the bootstrap system
# without needing to remember the full path to the YADM bootstrap script.
#
# Usage:
#   ~/bin/bootstrap-laptop.sh                    # Run all phases
#   SKIP_PHASES="30,40" ~/bin/bootstrap-laptop.sh # Skip specific phases
#   ONLY_PHASES="50" ~/bin/bootstrap-laptop.sh    # Run only specific phases
#   DEBUG=1 ~/bin/bootstrap-laptop.sh             # Verbose output
#

set -uo pipefail

# Bootstrap location
BOOTSTRAP_SCRIPT="$HOME/.config/yadm/bootstrap"

# Check if bootstrap script exists
if [[ ! -f "$BOOTSTRAP_SCRIPT" ]]; then
    echo "Error: Bootstrap script not found at $BOOTSTRAP_SCRIPT"
    echo ""
    echo "Have you cloned your dotfiles yet?"
    echo "  yadm clone git@github.com:adamancini/dotfiles.git"
    exit 1
fi

# Pass all environment variables and execute bootstrap
exec "$BOOTSTRAP_SCRIPT" "$@"
