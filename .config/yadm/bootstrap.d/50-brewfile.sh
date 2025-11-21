#!/bin/bash
#
# Phase 50: Brewfile Installation
# Installs packages, casks, and apps from Brewfile
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
BREWFILE="$HOME/.zshrcd/conf.d/Brewfile"

verify_homebrew() {
    if ! command -v brew &>/dev/null; then
        error "Homebrew not found"
        error "Homebrew should have been installed in core tools phase"
        return 1
    fi

    success "Homebrew found: $(brew --version | head -1)"
    return 0
}

verify_brewfile() {
    if [[ ! -f "$BREWFILE" ]]; then
        error "Brewfile not found: $BREWFILE"
        return 1
    fi

    success "Brewfile found: $BREWFILE"

    # Show stats
    local taps=$(grep -c "^tap " "$BREWFILE" || echo "0")
    local brews=$(grep -c "^brew " "$BREWFILE" || echo "0")
    local casks=$(grep -c "^cask " "$BREWFILE" || echo "0")
    local mas=$(grep -c "^mas " "$BREWFILE" || echo "0")

    info "Brewfile contents:"
    echo "  Taps:  $taps"
    echo "  Brews: $brews"
    echo "  Casks: $casks"
    echo "  MAS:   $mas"

    return 0
}

install_from_brewfile() {
    info "Installing from Brewfile..."
    info "This may take a while (10-30 minutes)..."
    echo ""

    # Run brew bundle
    if brew bundle --file="$BREWFILE" --no-lock; then
        success "Brewfile installation completed"
        return 0
    else
        warn "Brewfile installation completed with errors"
        warn "Some packages may have failed to install"
        return 0  # Don't fail the phase, some errors are expected
    fi
}

cleanup_homebrew() {
    info "Cleaning up Homebrew..."

    if brew cleanup; then
        success "Homebrew cleanup completed"
    else
        warn "Homebrew cleanup had issues (non-critical)"
    fi
}

verify_critical_packages() {
    info "Verifying critical packages..."
    echo ""

    local critical_packages=(
        "git"
        "gnupg"
        "yadm"
        "pass"
        "kubectl"
        "helm"
        "aerospace"
    )

    local missing_packages=()

    for pkg in "${critical_packages[@]}"; do
        if command -v "$pkg" &>/dev/null; then
            success "$pkg installed"
        elif brew list "$pkg" &>/dev/null; then
            success "$pkg installed (via Homebrew)"
        else
            warn "$pkg not found"
            missing_packages+=("$pkg")
        fi
    done

    echo ""

    if [[ ${#missing_packages[@]} -gt 0 ]]; then
        warn "Missing packages: ${missing_packages[*]}"
        info "These can be installed manually later"
    else
        success "All critical packages verified"
    fi
}

display_brewfile_errors() {
    info "Checking for Brewfile errors..."

    # Check for common error patterns in Brewfile
    if grep -q "wireshark-app" "$BREWFILE"; then
        warn "Known issue: wireshark-app cask may fail"
        info "This is a known issue and can be ignored"
    fi
}

main() {
    info "Brewfile installation phase..."
    echo ""

    # Step 1: Verify Homebrew
    if ! verify_homebrew; then
        return 1
    fi
    echo ""

    # Step 2: Verify Brewfile exists
    if ! verify_brewfile; then
        return 1
    fi
    echo ""

    # Step 3: Check for known issues
    display_brewfile_errors
    echo ""

    # Step 4: Install from Brewfile
    if ! install_from_brewfile; then
        warn "Installation had issues, but continuing..."
    fi
    echo ""

    # Step 5: Cleanup
    cleanup_homebrew
    echo ""

    # Step 6: Verify critical packages
    verify_critical_packages
    echo ""

    # Information
    echo "${CYAN}════════════════════════════════════════════════${RESET}"
    info "Brewfile installation completed"
    info ""
    info "Notes:"
    info "  - Some packages may have failed (this is normal)"
    info "  - Check brew list to see installed packages"
    info "  - Use 'brew outdated' to check for updates"
    info "  - Use 'brew bundle cleanup' to remove packages not in Brewfile"
    echo "${CYAN}════════════════════════════════════════════════${RESET}"
    echo ""

    success "Brewfile phase completed"
    return 0
}

main "$@"
