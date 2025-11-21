#!/bin/bash
#
# Phase 60: Claude Code Plugins Setup
# Installs and configures Claude Code plugins and marketplaces
#

set -uo pipefail

# Color output
RED=$(tput setaf 1 2>/dev/null || echo "")
GREEN=$(tput setaf 2 2>/dev/null || echo "")
YELLOW=$(tput setaf 3 2>/dev/null || echo "")
CYAN=$(tput setaf 6 2>/dev/null || echo "")
RESET=$(tput sgr0 2>/dev/null || echo "")

info() { echo "${GREEN}[INFO]${RESET} $*"; }
warn() { echo "${YELLOW}[WARN]${RESET} $*"; }
error() { echo "${RED}[ERROR]${RESET} $*"; }
success() { echo "${GREEN}[✓]${RESET} $*"; }

# Configuration
CLAUDE_APP="/Applications/Claude.app"
DEVOPS_TOOLKIT_REPO="https://github.com/adamancini/devops-toolkit.git"

check_claude_installed() {
    if [[ -d "$CLAUDE_APP" ]]; then
        success "Claude Code app found: $CLAUDE_APP"
        return 0
    else
        warn "Claude Code app not found: $CLAUDE_APP"
        return 1
    fi
}

check_claude_cli() {
    if command -v claude &>/dev/null; then
        success "Claude CLI available"
        return 0
    else
        warn "Claude CLI not in PATH"
        return 1
    fi
}

update_marketplaces() {
    info "Updating plugin marketplaces..."

    if claude plugin marketplace update 2>&1; then
        success "Marketplaces updated"
        return 0
    else
        warn "Marketplace update failed (may need manual intervention)"
        return 1
    fi
}

install_superpowers_plugins() {
    info "Installing superpowers marketplace plugins..."
    echo ""

    local plugins=(
        "superpowers@superpowers-marketplace"
        "elements-of-style@superpowers-marketplace"
        "superpowers-developing-for-claude-code@superpowers-marketplace"
    )

    local failed_plugins=()

    for plugin in "${plugins[@]}"; do
        local plugin_name=$(echo "$plugin" | cut -d'@' -f1)
        info "Installing $plugin_name..."

        if claude plugin install "$plugin" 2>&1; then
            success "$plugin_name installed"
        else
            warn "$plugin_name installation failed (may already be installed)"
            failed_plugins+=("$plugin_name")
        fi
    done

    echo ""

    if [[ ${#failed_plugins[@]} -gt 0 ]]; then
        warn "Some plugins failed: ${failed_plugins[*]}"
        info "Check if they're already installed: claude plugin list"
    else
        success "All superpowers plugins installed"
    fi
}

install_devops_toolkit() {
    info "Installing devops-toolkit custom plugin..."

    local toolkit_dir="$HOME/.claude/plugins/repos/devops-toolkit"

    if [[ -d "$toolkit_dir/.git" ]]; then
        success "devops-toolkit already cloned"
        info "Updating to latest version..."
        if (cd "$toolkit_dir" && git pull); then
            success "devops-toolkit updated"
        else
            warn "devops-toolkit update failed"
        fi
        return 0
    fi

    # Clone the repository
    mkdir -p "$HOME/.claude/plugins/repos"

    info "Cloning devops-toolkit from $DEVOPS_TOOLKIT_REPO..."
    if git clone "$DEVOPS_TOOLKIT_REPO" "$toolkit_dir"; then
        success "devops-toolkit cloned"
        return 0
    else
        warn "Failed to clone devops-toolkit"
        warn "You can clone it manually later:"
        info "  cd ~/.claude/plugins/repos"
        info "  git clone $DEVOPS_TOOLKIT_REPO"
        return 1
    fi
}

verify_claude_config() {
    info "Verifying Claude Code configuration..."
    echo ""

    local config_files=(
        "$HOME/.claude/settings.json"
        "$HOME/.claude/plugins/config.json"
        "$HOME/.claude/plugins/installed_plugins.json"
        "$HOME/.claude/plugins/known_marketplaces.json"
    )

    for file in "${config_files[@]}"; do
        if [[ -f "$file" ]]; then
            success "$(basename "$file") exists"
        else
            warn "$(basename "$file") not found"
        fi
    done
}

list_installed_plugins() {
    info "Listing installed plugins..."
    echo ""

    if command -v claude &>/dev/null; then
        if claude plugin list 2>&1; then
            success "Plugin list retrieved"
        else
            warn "Failed to list plugins"
        fi
    else
        warn "Claude CLI not available, cannot list plugins"
    fi
}

main() {
    info "Claude Code plugins setup..."
    echo ""

    # Step 1: Check if Claude Code is installed
    if ! check_claude_installed; then
        warn "Claude Code app not installed"
        warn "Skipping plugin installation"
        info ""
        info "To install Claude Code:"
        info "  1. Visit: https://claude.ai/download"
        info "  2. Download and install Claude Code"
        info "  3. Re-run: ~/.config/yadm/bootstrap.d/60-claude-plugins.sh"
        return 0  # Don't fail the phase
    fi
    echo ""

    # Step 2: Check Claude CLI
    if ! check_claude_cli; then
        warn "Claude CLI not available"
        info "You may need to launch Claude Code first"
        return 0  # Don't fail the phase
    fi
    echo ""

    # Step 3: Update marketplaces
    if ! update_marketplaces; then
        warn "Marketplace update failed, continuing anyway..."
    fi
    echo ""

    # Step 4: Install superpowers plugins
    install_superpowers_plugins
    echo ""

    # Step 5: Install devops-toolkit
    if ! install_devops_toolkit; then
        warn "devops-toolkit installation incomplete"
    fi
    echo ""

    # Step 6: Verify configuration
    verify_claude_config
    echo ""

    # Step 7: List installed plugins
    list_installed_plugins
    echo ""

    # Information
    echo "${CYAN}════════════════════════════════════════════════${RESET}"
    info "Claude Code plugins setup completed"
    info ""
    info "Custom configurations:"
    info "  - Custom agents: ~/.claude/agents/"
    info "  - Custom skills: ~/.claude/skills/"
    info "  - Hookify rules: ~/.claude/hookify.*.local.md"
    info "  - Settings: ~/.claude/settings.json"
    info ""
    info "Plugin management:"
    info "  claude plugin list              # List installed plugins"
    info "  claude plugin marketplace update # Update marketplaces"
    info "  claude plugin install <name>    # Install a plugin"
    echo "${CYAN}════════════════════════════════════════════════${RESET}"
    echo ""

    success "Claude Code plugins phase completed"
    return 0
}

main "$@"
