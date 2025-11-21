#!/bin/bash
#
# Phase 40: GPG and Password-Store Setup
# Configures GPG agent and sets up password-store
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
GPG_KEY_EMAIL="adab3ta@gmail.com"
PASSSTORE_REPO="git@github.com:adamancini/password-store.git"
PASSSTORE_REPO_HTTPS="https://github.com/adamancini/password-store.git"

verify_gpg_key() {
    info "Verifying GPG key..."

    if ! command -v gpg &>/dev/null; then
        error "GPG not installed"
        return 1
    fi

    if gpg --list-secret-keys "$GPG_KEY_EMAIL" &>/dev/null; then
        success "GPG key found: $GPG_KEY_EMAIL"

        # Show key info
        info "Key details:"
        gpg --list-secret-keys --keyid-format LONG "$GPG_KEY_EMAIL" | grep -A1 "^sec" | sed 's/^/  /'

        return 0
    else
        error "GPG key not found: $GPG_KEY_EMAIL"
        error "This should have been caught in prerequisites phase"
        return 1
    fi
}

configure_gpg_agent() {
    info "Configuring GPG agent..."

    # Create gnupg directory if needed
    mkdir -p ~/.gnupg
    chmod 700 ~/.gnupg

    # Write gpg-agent.conf
    local gpg_agent_conf="$HOME/.gnupg/gpg-agent.conf"

    info "Writing $gpg_agent_conf..."
    cat > "$gpg_agent_conf" <<EOF
# GPG Agent Configuration
# Cache settings
default-cache-ttl 600
max-cache-ttl 7200

# Pinentry program
pinentry-program /opt/homebrew/bin/pinentry

# Enable SSH support
enable-ssh-support
EOF

    chmod 600 "$gpg_agent_conf"
    success "gpg-agent.conf configured"

    # Write common.conf
    local gpg_common_conf="$HOME/.gnupg/common.conf"
    if [[ ! -f "$gpg_common_conf" ]]; then
        info "Writing $gpg_common_conf..."
        echo "use-keyboxd" > "$gpg_common_conf"
        chmod 600 "$gpg_common_conf"
        success "common.conf configured"
    else
        success "common.conf already exists"
    fi

    # Restart GPG agent
    info "Restarting GPG agent..."
    gpgconf --kill gpg-agent 2>/dev/null || true
    sleep 1
    gpg-agent --daemon 2>/dev/null || true
    success "GPG agent restarted"
}

test_gpg_signing() {
    info "Testing GPG signing..."

    if echo "test" | gpg --clearsign -u "$GPG_KEY_EMAIL" &>/dev/null; then
        success "GPG signing test passed"
        return 0
    else
        warn "GPG signing test failed"
        warn "This may require entering your GPG passphrase"
        return 0  # Don't fail the phase
    fi
}

setup_password_store() {
    info "Setting up password-store..."

    # Check if password-store already exists
    if [[ -d ~/.password-store/.git ]]; then
        success "Password-store repository already exists"
        return 0
    fi

    # Initialize pass if not already done
    if [[ ! -f ~/.password-store/.gpg-id ]]; then
        info "Initializing pass with GPG key..."
        if pass init "$GPG_KEY_EMAIL"; then
            success "Pass initialized"
        else
            error "Failed to initialize pass"
            return 1
        fi
    fi

    # Try to clone password-store via SSH first
    info "Cloning password-store repository..."
    info "Trying SSH: $PASSSTORE_REPO"

    if pass git clone "$PASSSTORE_REPO" ~/.password-store 2>/dev/null; then
        success "Password-store cloned via SSH"
        return 0
    fi

    warn "SSH clone failed, trying HTTPS..."
    info "HTTPS: $PASSSTORE_REPO_HTTPS"

    if git clone "$PASSSTORE_REPO_HTTPS" ~/.password-store; then
        success "Password-store cloned via HTTPS"
        warn "Don't forget to update remote to SSH later:"
        info "  cd ~/.password-store && git remote set-url origin $PASSSTORE_REPO"
        return 0
    fi

    error "Failed to clone password-store"
    return 1
}

verify_pass_functionality() {
    info "Verifying pass functionality..."

    if ! command -v pass &>/dev/null; then
        error "Pass command not found"
        return 1
    fi

    # List passwords (should not fail even if empty)
    if pass ls &>/dev/null; then
        success "Pass is working"

        # Show count
        local count=$(find ~/.password-store -name "*.gpg" 2>/dev/null | wc -l | tr -d ' ')
        info "Password entries: $count"

        return 0
    else
        warn "Pass list command failed"
        warn "This may be normal if password-store is empty or needs GPG unlock"
        return 0  # Don't fail the phase
    fi
}

main() {
    info "Setting up GPG and password-store..."
    echo ""

    # Step 1: Verify GPG key
    if ! verify_gpg_key; then
        return 1
    fi
    echo ""

    # Step 2: Configure GPG agent
    configure_gpg_agent
    echo ""

    # Step 3: Test GPG signing
    test_gpg_signing
    echo ""

    # Step 4: Setup password-store
    if ! setup_password_store; then
        warn "Password-store setup incomplete"
        warn "You can set it up manually later with:"
        info "  pass init $GPG_KEY_EMAIL"
        info "  pass git clone $PASSSTORE_REPO ~/.password-store"
    fi
    echo ""

    # Step 5: Verify pass
    verify_pass_functionality
    echo ""

    # Instructions
    echo "${CYAN}════════════════════════════════════════════════${RESET}"
    info "GPG and password-store setup completed"
    info ""
    info "Usage:"
    info "  pass               # List all passwords"
    info "  pass show <name>   # Show password"
    info "  pass -c <name>     # Copy password to clipboard"
    info "  pass insert <name> # Add new password"
    echo "${CYAN}════════════════════════════════════════════════${RESET}"
    echo ""

    success "GPG and password-store phase completed"
    return 0
}

main "$@"
