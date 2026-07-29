#!/bin/bash
#
# Phase 90: Finalization and Verification
# Runs health checks and generates bootstrap completion report
#

set -uo pipefail

# Color output
RED=$(tput setaf 1 2>/dev/null || echo "")
GREEN=$(tput setaf 2 2>/dev/null || echo "")
YELLOW=$(tput setaf 3 2>/dev/null || echo "")
CYAN=$(tput setaf 6 2>/dev/null || echo "")
BLUE=$(tput setaf 4 2>/dev/null || echo "")
BOLD=$(tput bold 2>/dev/null || echo "")
RESET=$(tput sgr0 2>/dev/null || echo "")

info() { echo "${GREEN}[INFO]${RESET} $*"; }
warn() { echo "${YELLOW}[WARN]${RESET} $*"; }
error() { echo "${RED}[ERROR]${RESET} $*"; }
success() { echo "${GREEN}[✓]${RESET} $*"; }

# Configuration
REPORT_FILE="$HOME/.bootstrap-report-$(date +%Y%m%d-%H%M%S).txt"

run_health_checks() {
    info "Running system health checks..."
    echo ""

    local checks_passed=0
    local checks_failed=0
    local checks_total=0

    # Health check function. Not every CLI supports a plain `--version`
    # (kubectl and helm dropped it, ssh never had it, aerospace's --version
    # also probes for a running server and prints a network error first) --
    # pass an explicit version_cmd to override the default for those.
    check_command() {
        local cmd="$1"
        local name="${2:-$1}"
        local version_cmd="${3:-$cmd --version}"
        checks_total=$((checks_total + 1))

        if command -v "$cmd" &>/dev/null; then
            local version=$(bash -c "$version_cmd" 2>&1 | head -1 | cut -c1-60)
            success "$name: $version"
            checks_passed=$((checks_passed + 1))
            return 0
        else
            warn "$name: NOT FOUND"
            checks_failed=$((checks_failed + 1))
            return 1
        fi
    }

    # Core tools
    info "Core Tools:"
    check_command git "Git"
    check_command brew "Homebrew"
    check_command yadm "YADM"
    echo ""

    # Security tools
    info "Security Tools:"
    check_command gpg "GPG"
    check_command pass "Password Store"
    check_command ssh "SSH" "ssh -V"
    echo ""

    # Development tools
    info "Development Tools:"
    check_command kubectl "Kubectl" "kubectl version --client"
    check_command helm "Helm" "helm version"
    check_command docker "Docker"
    echo ""

    # Other tools
    info "Other Tools:"
    check_command claude "Claude CLI" || warn "Claude Code may not be installed"
    # `aerospace --version` also probes for a running AeroSpace.app server and
    # prints a network error first when it isn't running; grep the actual
    # client version line instead of taking the raw first line of output.
    check_command aerospace "AeroSpace" "aerospace --version 2>&1 | grep 'CLI client version'" || warn "AeroSpace window manager not installed"
    echo ""

    # Summary
    info "Health Check Summary:"
    echo "  Total checks: $checks_total"
    echo "  ${GREEN}Passed: $checks_passed${RESET}"
    echo "  ${YELLOW}Failed: $checks_failed${RESET}"
    echo ""

    return 0
}

verify_configurations() {
    info "Verifying configurations..."
    echo ""

    # Shell configuration
    info "Shell Configuration:"
    [[ -d ~/.zshrc.d ]] && success "Zsh config directory exists" || warn "Zsh config directory missing"
    [[ -f ~/.zshrc ]] && success ".zshrc exists" || warn ".zshrc missing"
    [[ -f ~/.zshenv ]] && success ".zshenv exists" || warn ".zshenv missing"
    echo ""

    # Git configuration
    info "Git Configuration:"
    [[ -f ~/.gitconfig ]] && success ".gitconfig exists" || warn ".gitconfig missing"
    [[ -f ~/.gitconfig.local ]] && success ".gitconfig.local exists" || warn ".gitconfig.local missing"
    echo ""

    # SSH configuration
    info "SSH Configuration:"
    [[ -d ~/.ssh ]] && success "~/.ssh directory exists" || warn "~/.ssh missing"
    [[ -f ~/.ssh/id_moira ]] && success "SSH key exists" || warn "SSH key missing"
    echo ""

    # GPG configuration
    info "GPG Configuration:"
    [[ -d ~/.gnupg ]] && success "~/.gnupg directory exists" || warn "~/.gnupg missing"
    if gpg --list-secret-keys adab3ta@gmail.com &>/dev/null; then
        success "GPG key found"
    else
        warn "GPG key not found"
    fi
    echo ""

    # Password store
    info "Password Store:"
    [[ -d ~/.password-store ]] && success "Password store exists" || warn "Password store missing"
    [[ -d ~/.password-store/.git ]] && success "Password store is git repo" || warn "Password store not initialized"
    echo ""

    # Claude Code
    info "Claude Code Configuration:"
    [[ -d ~/.claude ]] && success "Claude config directory exists" || warn "Claude config missing"
    [[ -f ~/.claude/settings.json ]] && success "Claude settings exist" || warn "Claude settings missing"
    # Custom agents/skills are no longer stored directly under
    # .claude/agents or .claude/skills -- they ship via the devops-toolkit
    # plugin repo instead.
    [[ -d ~/.claude/plugins/repos/devops-toolkit ]] && success "devops-toolkit plugin repo exists" || warn "devops-toolkit plugin repo missing"
    echo ""
}

check_manual_steps() {
    info "Checking for manual steps needed..."
    echo ""

    local manual_steps=()

    # SSH key on GitHub
    # `ssh -T git@github.com` always exits 1 by design, even on successful
    # auth, so with `pipefail` a piped `| grep -q` always reports failure
    # regardless of the match. Capture output first and grep separately.
    local github_ssh_output
    github_ssh_output=$(ssh -T git@github.com 2>&1)
    if ! echo "$github_ssh_output" | grep -q "successfully authenticated"; then
        manual_steps+=("Add SSH key to GitHub: https://github.com/settings/keys")
    fi

    # GPG signing
    if ! git config --global user.signingkey &>/dev/null; then
        manual_steps+=("Configure GPG signing key: git config --global user.signingkey <key-id>")
    fi

    # Claude Code -- either the desktop app or the standalone CLI counts
    if [[ ! -d "/Applications/Claude.app" ]] && ! command -v claude &>/dev/null; then
        manual_steps+=("Install Claude Code: https://claude.ai/download")
    fi

    if [[ ${#manual_steps[@]} -gt 0 ]]; then
        warn "Manual steps required:"
        for step in "${manual_steps[@]}"; do
            echo "  • $step"
        done
        echo ""
    else
        success "No manual steps required"
        echo ""
    fi
}

generate_report() {
    info "Generating bootstrap completion report..."

    {
        echo "╔═══════════════════════════════════════════════════════════════╗"
        echo "║                                                               ║"
        echo "║              LAPTOP BOOTSTRAP COMPLETION REPORT               ║"
        echo "║                                                               ║"
        echo "╚═══════════════════════════════════════════════════════════════╝"
        echo ""
        echo "Generated: $(date)"
        echo "Hostname: $(hostname)"
        echo "User: $USER"
        echo "OS: $(uname -s) $(uname -r)"
        echo ""
        echo "─────────────────────────────────────────────────────────────────"
        echo "INSTALLED TOOLS"
        echo "─────────────────────────────────────────────────────────────────"
        echo ""

        command -v git &>/dev/null && echo "Git: $(git --version)"
        command -v brew &>/dev/null && echo "Homebrew: $(brew --version | head -1)"
        command -v yadm &>/dev/null && echo "YADM: $(yadm --version)"
        command -v gpg &>/dev/null && echo "GPG: $(gpg --version | head -1)"
        command -v pass &>/dev/null && echo "Pass: $(pass --version)"
        command -v kubectl &>/dev/null && echo "Kubectl: $(kubectl version --client 2>/dev/null | tr '\n' ' ')"
        command -v helm &>/dev/null && echo "Helm: $(helm version --short 2>/dev/null)"
        command -v claude &>/dev/null && echo "Claude CLI: $(claude --version 2>/dev/null)" || echo "Claude CLI: Not installed"

        echo ""
        echo "─────────────────────────────────────────────────────────────────"
        echo "CONFIGURATION STATUS"
        echo "─────────────────────────────────────────────────────────────────"
        echo ""

        [[ -f ~/.zshrc ]] && echo "✓ Shell configuration" || echo "✗ Shell configuration"
        [[ -f ~/.gitconfig ]] && echo "✓ Git configuration" || echo "✗ Git configuration"
        [[ -f ~/.ssh/id_moira ]] && echo "✓ SSH keys" || echo "✗ SSH keys"
        gpg --list-secret-keys adab3ta@gmail.com &>/dev/null && echo "✓ GPG key" || echo "✗ GPG key"
        [[ -d ~/.password-store/.git ]] && echo "✓ Password store" || echo "✗ Password store"
        [[ -d ~/.claude ]] && echo "✓ Claude Code config" || echo "✗ Claude Code config"

        echo ""
        echo "─────────────────────────────────────────────────────────────────"
        echo "NEXT STEPS"
        echo "─────────────────────────────────────────────────────────────────"
        echo ""
        echo "1. Open a new terminal to load updated shell configuration"
        echo "   Or run: exec zsh"
        echo ""
        echo "2. Verify SSH key is added to GitHub:"
        echo "   • Visit: https://github.com/settings/keys"
        echo "   • Add key from: cat ~/.ssh/id_moira.pub"
        echo ""
        echo "3. Test password store:"
        echo "   • Run: pass ls"
        echo "   • Should list your passwords"
        echo ""
        echo "4. Configure Claude Code (if installed):"
        echo "   • Launch Claude Code app"
        echo "   • Verify plugins: claude plugin list"
        echo ""
        echo "─────────────────────────────────────────────────────────────────"
        echo "USEFUL COMMANDS"
        echo "─────────────────────────────────────────────────────────────────"
        echo ""
        echo "YADM:"
        echo "  yadm status    # Check dotfiles status"
        echo "  yadm pull      # Update dotfiles from remote"
        echo "  yadm push      # Push dotfile changes"
        echo ""
        echo "Password Store:"
        echo "  pass            # List passwords"
        echo "  pass show <name>  # Show password"
        echo "  pass -c <name>    # Copy to clipboard"
        echo ""
        echo "Homebrew:"
        echo "  brew update    # Update Homebrew"
        echo "  brew upgrade   # Upgrade packages"
        echo "  brew outdated  # List outdated packages"
        echo ""
        echo "Claude Code:"
        echo "  claude plugin list              # List plugins"
        echo "  claude plugin marketplace update # Update marketplaces"
        echo ""
        echo "╔═══════════════════════════════════════════════════════════════╗"
        echo "║                                                               ║"
        echo "║                  BOOTSTRAP COMPLETED! ✓                       ║"
        echo "║                                                               ║"
        echo "╚═══════════════════════════════════════════════════════════════╝"

    } > "$REPORT_FILE"

    success "Report saved to: $REPORT_FILE"
    echo ""
    info "Displaying report..."
    echo ""
    cat "$REPORT_FILE"
}

main() {
    echo ""
    echo "${BOLD}${BLUE}╔═══════════════════════════════════════════════════╗${RESET}"
    echo "${BOLD}${BLUE}║                                                   ║${RESET}"
    echo "${BOLD}${BLUE}║           FINALIZATION & VERIFICATION             ║${RESET}"
    echo "${BOLD}${BLUE}║                                                   ║${RESET}"
    echo "${BOLD}${BLUE}╚═══════════════════════════════════════════════════╝${RESET}"
    echo ""

    # Step 1: Health checks
    run_health_checks

    # Step 2: Verify configurations
    verify_configurations

    # Step 3: Check manual steps
    check_manual_steps

    # Step 4: Generate report
    generate_report

    echo ""
    success "Bootstrap finalization completed!"
    return 0
}

main "$@"
