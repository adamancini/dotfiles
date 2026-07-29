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
DEVOPS_TOOLKIT_MARKETPLACE_SOURCE="adamancini/devops-toolkit"
DEVOPS_TOOLKIT_MARKETPLACE_NAME="devops-toolkit"

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

install_claude_cli() {
    info "Installing Claude Code via the official installer..."

    if curl -fsSL https://claude.ai/install.sh | bash; then
        success "Claude Code installer completed"
        return 0
    else
        error "Claude Code installer failed"
        return 1
    fi
}

register_marketplaces() {
    info "Registering plugin marketplaces..."

    # `marketplace update` only refreshes marketplaces already registered --
    # on a fresh machine none are, so plugin installs below would otherwise
    # fail with "not found in any configured marketplace". Add each one
    # explicitly first; `marketplace add` is idempotent if already present.
    local marketplaces=(
        "anthropics/claude-plugins-official"
        "obra/superpowers-marketplace"
        "wshobson/agents"
        "yaml/yamlscript"
        "$DEVOPS_TOOLKIT_MARKETPLACE_SOURCE"
    )

    local failed=0
    for mp in "${marketplaces[@]}"; do
        if claude plugin marketplace add "$mp" 2>&1; then
            success "$mp registered"
        else
            warn "Failed to register marketplace: $mp"
            failed=1
        fi
    done

    return $failed
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

        if claude plugin install "$plugin" --scope user 2>&1; then
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
    else
        warn "Failed to clone devops-toolkit"
        warn "You can clone it manually later:"
        info "  cd ~/.claude/plugins/repos"
        info "  git clone $DEVOPS_TOOLKIT_REPO"
        return 1
    fi

    # Install via the marketplace (registered in register_marketplaces), not
    # the local cloned path -- `claude plugin install <local-path>` doesn't
    # resolve against a configured marketplace and fails.
    info "Installing devops-toolkit plugin at user scope..."
    if claude plugin install "$DEVOPS_TOOLKIT_MARKETPLACE_NAME@$DEVOPS_TOOLKIT_MARKETPLACE_NAME" --scope user 2>&1; then
        success "devops-toolkit plugin installed (user scope)"
    else
        warn "devops-toolkit plugin install failed"
        info "  Try manually: claude plugin install $DEVOPS_TOOLKIT_MARKETPLACE_NAME@$DEVOPS_TOOLKIT_MARKETPLACE_NAME --scope user"
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

    # Step 1: Check if Claude Code is installed, via the desktop app or the
    # standalone CLI (native installer / npm) -- either is sufficient.
    check_claude_installed || true
    echo ""

    if ! check_claude_cli; then
        if ! install_claude_cli || ! check_claude_cli; then
            warn "Claude Code CLI still not available"
            warn "Skipping plugin installation"
            info ""
            info "To install manually:"
            info "  curl -fsSL https://claude.ai/install.sh | bash"
            info "Then re-run: ~/.config/yadm/bootstrap.d/60-claude-plugins.sh"
            return 0  # Don't fail the phase
        fi
    fi
    echo ""

    # Step 3: Register and update marketplaces
    if ! register_marketplaces; then
        warn "One or more marketplaces failed to register, continuing anyway..."
    fi
    echo ""

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
    info "  - Agents & skills: ~/.claude/plugins/repos/devops-toolkit/"
    info "  - Hookify rules: ~/.claude/hookify.*.local.md"
    info "  - Settings (policy): ~/.claude/settings.json"
    info "  - Settings (local): ~/.claude/settings.local.json"
    info ""
    info "Plugin management:"
    info "  claude plugin list                              # List installed plugins"
    info "  claude plugin marketplace update                # Update marketplaces"
    info "  claude plugin install <name> --scope user       # Install a plugin"
    info ""
    warn "NEVER install plugins without --scope user (local scope breaks project dirs)"
    warn "NEVER create project-level .claude/settings.local.json (shadows user enabledPlugins)"
    echo "${CYAN}════════════════════════════════════════════════${RESET}"
    echo ""

    success "Claude Code plugins phase completed"
    return 0
}

main "$@"
