#!/bin/bash
#
# Phase 20: Shell Configuration
# Sets up shell environment and YADM alt templates
#

set -uo pipefail

# Color output
RED=$(tput setaf 1 2>/dev/null || echo "")
GREEN=$(tput setaf 2 2>/dev/null || echo "")
YELLOW=$(tput setaf 3 2>/dev/null || echo "")
RESET=$(tput sgr0 2>/dev/null || echo "")

info() { echo "${GREEN}[INFO]${RESET} $*"; }
warn() { echo "${YELLOW}[WARN]${RESET} $*"; }
error() { echo "${RED}[ERROR]${RESET} $*"; }
success() { echo "${GREEN}[✓]${RESET} $*"; }

main() {
    info "Configuring shell environment..."
    echo ""

    # Step 1: Run YADM alt to create template symlinks
    info "Creating YADM template symlinks..."
    if command -v yadm &>/dev/null; then
        if yadm alt; then
            success "YADM templates processed"

            # Show some examples of created symlinks
            info "Created template symlinks:"
            if [[ -L ~/.gitconfig.local ]]; then
                echo "  $(ls -l ~/.gitconfig.local | awk '{print $9, $10, $11}')"
            fi
            if [[ -L ~/.zshenv.local ]]; then
                echo "  $(ls -l ~/.zshenv.local | awk '{print $9, $10, $11}')"
            fi
            if [[ -L ~/.tmux.local.conf ]]; then
                echo "  $(ls -l ~/.tmux.local.conf | awk '{print $9, $10, $11}')"
            fi
        else
            warn "YADM alt command failed or no templates to process"
        fi
    else
        error "YADM not found - cannot process templates"
        return 1
    fi
    echo ""

    # Step 2: Verify shell configuration structure
    info "Verifying shell configuration..."

    local config_dirs=(
        "$HOME/.zshrcd"
        "$HOME/.zshrcd/conf.d"
        "$HOME/.config"
    )

    for dir in "${config_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            success "$dir exists"
        else
            warn "$dir not found"
        fi
    done
    echo ""

    # Step 3: Check PATH configuration
    info "Checking PATH configuration..."

    local expected_paths=(
        "/opt/homebrew/bin"
        "$HOME/bin"
        "$HOME/go/bin"
    )

    for path in "${expected_paths[@]}"; do
        if [[ ":$PATH:" == *":$path:"* ]]; then
            success "$path in PATH"
        else
            warn "$path not in PATH (will be after shell reload)"
        fi
    done
    echo ""

    # Step 4: Check ZDOTDIR
    info "Checking ZDOTDIR..."
    if [[ "${ZDOTDIR:-}" == "$HOME/.zshrcd" ]]; then
        success "ZDOTDIR set correctly: $ZDOTDIR"
    else
        warn "ZDOTDIR not set yet (will be set after shell reload)"
        info "Expected: $HOME/.zshrcd"
    fi
    echo ""

    # Step 5: Verify key config files exist
    info "Verifying configuration files..."

    local key_files=(
        "$HOME/.zshrc"
        "$HOME/.zshenv"
        "$HOME/.zshrcd/.zshrc"
        "$HOME/.gitconfig"
        "$HOME/.tmux.conf"
    )

    for file in "${key_files[@]}"; do
        if [[ -f "$file" ]]; then
            success "$(basename "$file") exists"
        else
            warn "$(basename "$file") not found: $file"
        fi
    done
    echo ""

    # Step 6: Note about shell reload
    echo "${YELLOW}═══════════════════════════════════════════════════${RESET}"
    info "Shell configuration updated"
    info ""
    info "Changes will take effect after opening a new terminal"
    info "Or run: exec zsh"
    echo "${YELLOW}═══════════════════════════════════════════════════${RESET}"
    echo ""

    success "Shell configuration phase completed"
    return 0
}

main "$@"
