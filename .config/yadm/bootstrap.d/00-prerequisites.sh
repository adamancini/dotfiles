#!/bin/bash
#
# Phase 00: Prerequisites Check
# Verifies all prerequisites are met before bootstrap proceeds
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

# Configuration
GPG_KEY_EMAIL="adab3ta@gmail.com"

main() {
    info "Checking prerequisites..."
    echo ""

    local prerequisites_met=true

    # Check 1: Operating System
    info "Checking operating system..."
    if [[ "$(uname)" == "Darwin" ]]; then
        success "Running on macOS: $(sw_vers -productVersion)"
    elif [[ "$(uname)" == "Linux" ]]; then
        success "Running on Linux: $(uname -r)"
        warn "Linux support is experimental"
    else
        error "Unsupported operating system: $(uname)"
        prerequisites_met=false
    fi
    echo ""

    # Check 2: Internet Connectivity
    info "Checking internet connectivity..."
    if ping -c 1 github.com &>/dev/null || ping -c 1 8.8.8.8 &>/dev/null; then
        success "Internet connection available"
    else
        error "No internet connection detected"
        error "Internet access is required for bootstrap"
        prerequisites_met=false
    fi
    echo ""

    # Check 3: Sudo Access
    info "Checking sudo access..."
    if sudo -n true 2>/dev/null || sudo -v; then
        success "Sudo access available"
    else
        warn "Sudo access not available or not configured"
        warn "Some installations may require manual password entry"
    fi
    echo ""

    # Check 4: GPG Key (CRITICAL)
    info "Checking for GPG key..."
    if command -v gpg &>/dev/null; then
        if gpg --list-secret-keys "$GPG_KEY_EMAIL" &>/dev/null; then
            success "GPG key found for $GPG_KEY_EMAIL"

            # Show key details
            local key_info=$(gpg --list-secret-keys --keyid-format LONG "$GPG_KEY_EMAIL" 2>/dev/null | grep -A1 "^sec")
            if [[ -n "$key_info" ]]; then
                info "Key details:"
                echo "$key_info" | sed 's/^/  /'
            fi
        else
            error "GPG key NOT found for $GPG_KEY_EMAIL"
            error ""
            error "CRITICAL: GPG key must be restored before bootstrap!"
            error ""
            error "To restore your GPG key:"
            error "  1. Locate your GPG key backup (private key)"
            error "  2. Import it: gpg --import /path/to/your/private-key.asc"
            error "  3. Trust the key: gpg --edit-key $GPG_KEY_EMAIL"
            error "     - Type 'trust', select '5' (ultimate), 'quit'"
            error "  4. Re-run this bootstrap script"
            error ""
            prerequisites_met=false
        fi
    else
        warn "GPG not installed yet (will be installed in core tools phase)"
        warn "If you have a GPG key to restore, install GPG first:"
        warn "  brew install gnupg"
        warn "Then import your key and re-run bootstrap"
    fi
    echo ""

    # Check 5: Disk Space
    info "Checking available disk space..."
    if [[ "$(uname)" == "Darwin" ]]; then
        local available=$(df -h ~ | awk 'NR==2 {print $4}')
        success "Available disk space: $available"

        # Warn if less than 10GB
        local available_gb=$(df -g ~ | awk 'NR==2 {print $4}')
        if [[ $available_gb -lt 10 ]]; then
            warn "Less than 10GB free space - bootstrap may fail"
        fi
    fi
    echo ""

    # Check 6: Existing YADM Setup
    info "Checking existing YADM setup..."
    if [[ -d ~/.local/share/yadm/repo.git ]]; then
        success "YADM repository detected"

        # Show remote
        local remote=$(yadm remote get-url origin 2>/dev/null)
        if [[ -n "$remote" ]]; then
            info "Remote: $remote"
        fi
    else
        info "No existing YADM repository (expected on fresh install)"
    fi
    echo ""

    # Final verdict
    if [[ "$prerequisites_met" == true ]]; then
        echo "${GREEN}╔═══════════════════════════════════════════════════╗${RESET}"
        echo "${GREEN}║                                                   ║${RESET}"
        echo "${GREEN}║     All prerequisites met! ✓                      ║${RESET}"
        echo "${GREEN}║                                                   ║${RESET}"
        echo "${GREEN}╚═══════════════════════════════════════════════════╝${RESET}"
        echo ""
        return 0
    else
        echo "${RED}╔═══════════════════════════════════════════════════╗${RESET}"
        echo "${RED}║                                                   ║${RESET}"
        echo "${RED}║     Prerequisites check FAILED ✗                  ║${RESET}"
        echo "${RED}║                                                   ║${RESET}"
        echo "${RED}╚═══════════════════════════════════════════════════╝${RESET}"
        echo ""
        error "Bootstrap cannot proceed until all prerequisites are met"
        error "Please address the issues above and re-run bootstrap"
        return 1
    fi
}

main "$@"
