#!/bin/bash
#
# Phase 55: Vim Plugin Managers
# Installs pathogen and Vundle for vim plugin management
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

install_pathogen() {
    info "Installing pathogen..."

    mkdir -p "$HOME/.vim/autoload" "$HOME/.vim/bundle"

    if [[ -f "$HOME/.vim/autoload/pathogen.vim" ]]; then
        success "pathogen already installed"
        return 0
    fi

    if curl -LSso "$HOME/.vim/autoload/pathogen.vim" https://tpo.pe/pathogen.vim; then
        success "pathogen installed"
        return 0
    else
        error "pathogen installation failed"
        return 1
    fi
}

install_vundle() {
    info "Installing Vundle..."

    local vundle_dir="$HOME/.vim/bundle/Vundle.vim"

    if [[ -d "$vundle_dir" ]]; then
        success "Vundle already installed"
        return 0
    fi

    if git clone https://github.com/VundleVim/Vundle.vim.git "$vundle_dir"; then
        success "Vundle installed"
        return 0
    else
        error "Vundle installation failed"
        return 1
    fi
}

main() {
    info "Vim plugin manager setup..."
    echo ""

    local failed=0

    install_pathogen || failed=1
    echo ""

    install_vundle || failed=1
    echo ""

    if [[ "$failed" -eq 0 ]]; then
        success "Vim plugin managers ready"
    else
        warn "One or more vim plugin managers failed to install"
    fi

    return 0  # Don't fail the phase over optional vim tooling
}

main "$@"
