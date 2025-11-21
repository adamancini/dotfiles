#!/bin/bash
#
# Phase 30: SSH Keys Setup
# Interactive setup for SSH keys (generate new or import existing)
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
SSH_KEY_FILE="$HOME/.ssh/id_moira"
SSH_KEY_EMAIL="adab3ta@gmail.com"

setup_ssh_directory() {
    if [[ ! -d ~/.ssh ]]; then
        info "Creating ~/.ssh directory..."
        mkdir -p ~/.ssh
        chmod 700 ~/.ssh
        success "~/.ssh directory created"
    else
        success "~/.ssh directory exists"
    fi
}

check_existing_keys() {
    if [[ -f "$SSH_KEY_FILE" ]]; then
        success "SSH key already exists: $SSH_KEY_FILE"
        return 0
    fi
    return 1
}

generate_new_key() {
    info "Generating new SSH key..."
    info "Key location: $SSH_KEY_FILE"
    info "Email: $SSH_KEY_EMAIL"
    echo ""

    if ssh-keygen -t rsa -b 4096 -f "$SSH_KEY_FILE" -C "$SSH_KEY_EMAIL"; then
        success "SSH key generated successfully"

        # Set proper permissions
        chmod 600 "$SSH_KEY_FILE"
        chmod 644 "$SSH_KEY_FILE.pub"

        return 0
    else
        error "Failed to generate SSH key"
        return 1
    fi
}

import_existing_key() {
    echo ""
    info "Import existing SSH key"
    echo ""
    read -p "Enter path to private key file: " -r key_path

    if [[ ! -f "$key_path" ]]; then
        error "File not found: $key_path"
        return 1
    fi

    info "Copying key from $key_path to $SSH_KEY_FILE..."
    if cp "$key_path" "$SSH_KEY_FILE"; then
        chmod 600 "$SSH_KEY_FILE"
        success "Private key imported"

        # Check for public key
        if [[ -f "${key_path}.pub" ]]; then
            cp "${key_path}.pub" "$SSH_KEY_FILE.pub"
            chmod 644 "$SSH_KEY_FILE.pub"
            success "Public key imported"
        else
            warn "Public key not found, generating from private key..."
            if ssh-keygen -y -f "$SSH_KEY_FILE" > "$SSH_KEY_FILE.pub"; then
                chmod 644 "$SSH_KEY_FILE.pub"
                success "Public key generated from private key"
            else
                error "Failed to generate public key"
            fi
        fi

        return 0
    else
        error "Failed to copy key"
        return 1
    fi
}

create_key_symlinks() {
    info "Creating SSH key symlinks..."

    # id_rsa -> id_moira
    if [[ ! -L ~/.ssh/id_rsa ]]; then
        ln -sf id_moira ~/.ssh/id_rsa
        success "Created symlink: id_rsa -> id_moira"
    else
        success "Symlink already exists: id_rsa"
    fi

    # id_rsa.pub -> id_moira.pub
    if [[ ! -L ~/.ssh/id_rsa.pub ]]; then
        ln -sf id_moira.pub ~/.ssh/id_rsa.pub
        success "Created symlink: id_rsa.pub -> id_moira.pub"
    else
        success "Symlink already exists: id_rsa.pub"
    fi
}

add_to_ssh_agent() {
    info "Adding key to ssh-agent..."

    # Start ssh-agent if not running
    if [[ -z "${SSH_AUTH_SOCK:-}" ]]; then
        eval "$(ssh-agent -s)"
    fi

    if ssh-add "$SSH_KEY_FILE" 2>/dev/null; then
        success "Key added to ssh-agent"
        return 0
    else
        warn "Failed to add key to ssh-agent (may require passphrase)"
        info "You can add it manually later with: ssh-add $SSH_KEY_FILE"
        return 0  # Don't fail the phase
    fi
}

test_github_connection() {
    info "Testing GitHub SSH connection..."

    if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
        success "GitHub SSH connection successful"
        return 0
    else
        warn "GitHub SSH connection failed"
        info ""
        info "To add this key to GitHub:"
        info "  1. Copy your public key:"
        info "     cat $SSH_KEY_FILE.pub"
        info "  2. Go to: https://github.com/settings/keys"
        info "  3. Click 'New SSH key'"
        info "  4. Paste the key and save"
        info ""
        return 0  # Don't fail the phase
    fi
}

display_public_key() {
    echo ""
    echo "${CYAN}════════════════════════════════════════════════${RESET}"
    echo "${CYAN}Public Key (add this to GitHub/GitLab/etc):${RESET}"
    echo "${CYAN}════════════════════════════════════════════════${RESET}"
    cat "$SSH_KEY_FILE.pub"
    echo "${CYAN}════════════════════════════════════════════════${RESET}"
    echo ""
}

main() {
    info "SSH keys setup..."
    echo ""

    # Step 1: Setup SSH directory
    setup_ssh_directory
    echo ""

    # Step 2: Check for existing keys
    if check_existing_keys; then
        info "SSH key already configured"
    else
        # Step 3: Interactive prompt
        if [[ -t 0 ]]; then
            echo "SSH key not found. What would you like to do?"
            echo ""
            echo "  (g) Generate new SSH key"
            echo "  (i) Import existing SSH key"
            echo "  (s) Skip SSH setup"
            echo ""
            read -p "Choice [g/i/s]: " -n 1 -r choice
            echo ""
            echo ""

            case "$choice" in
                g|G)
                    if ! generate_new_key; then
                        return 1
                    fi
                    ;;
                i|I)
                    if ! import_existing_key; then
                        return 1
                    fi
                    ;;
                s|S)
                    info "Skipping SSH key setup"
                    return 0
                    ;;
                *)
                    error "Invalid choice: $choice"
                    return 1
                    ;;
            esac
        else
            warn "Non-interactive mode detected"
            info "Skipping SSH key generation"
            info "Run manually: ssh-keygen -t rsa -b 4096 -f $SSH_KEY_FILE"
            return 0
        fi
    fi

    echo ""

    # Step 4: Create symlinks
    create_key_symlinks
    echo ""

    # Step 5: Add to ssh-agent
    add_to_ssh_agent
    echo ""

    # Step 6: Display public key
    display_public_key

    # Step 7: Test GitHub connection
    test_github_connection
    echo ""

    success "SSH keys setup completed"
    return 0
}

main "$@"
