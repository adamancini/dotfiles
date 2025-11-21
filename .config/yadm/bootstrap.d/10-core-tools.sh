#!/bin/bash
#
# Phase 10: Core Tools Installation
# Installs Homebrew and essential command-line tools
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

# Essential tools to install
ESSENTIAL_TOOLS=(
    "git"
    "curl"
    "gnupg"
    "yadm"
    "pass"
)

install_xcode_cli_tools() {
    info "Checking for Xcode Command Line Tools..."

    if xcode-select -p &>/dev/null; then
        success "Xcode Command Line Tools already installed"
        return 0
    fi

    info "Installing Xcode Command Line Tools..."
    info "This may prompt for confirmation..."

    # Trigger installation
    xcode-select --install 2>/dev/null || true

    # Wait for installation
    info "Waiting for Xcode Command Line Tools installation..."
    info "(This may take several minutes)"

    local timeout=300  # 5 minutes
    local elapsed=0
    while ! xcode-select -p &>/dev/null; do
        sleep 5
        elapsed=$((elapsed + 5))

        if [[ $elapsed -ge $timeout ]]; then
            error "Xcode Command Line Tools installation timed out"
            error "Please install manually: xcode-select --install"
            return 1
        fi

        echo -n "."
    done
    echo ""

    success "Xcode Command Line Tools installed"
    return 0
}

install_homebrew() {
    info "Checking for Homebrew..."

    if command -v brew &>/dev/null; then
        success "Homebrew already installed: $(brew --version | head -1)"
        return 0
    fi

    info "Installing Homebrew..."
    info "This will prompt for your password..."

    # Install Homebrew
    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        success "Homebrew installed successfully"

        # Add Homebrew to PATH for this session
        if [[ "$(uname -m)" == "arm64" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            eval "$(/usr/local/bin/brew shellenv)"
        fi

        info "Homebrew added to current session PATH"
        return 0
    else
        error "Homebrew installation failed"
        return 1
    fi
}

install_essential_tools() {
    info "Installing essential tools..."
    echo ""

    local failed_tools=()

    for tool in "${ESSENTIAL_TOOLS[@]}"; do
        info "Checking $tool..."

        if command -v "$tool" &>/dev/null; then
            success "$tool already installed"
            continue
        fi

        info "Installing $tool via Homebrew..."
        if brew install "$tool"; then
            success "$tool installed successfully"
        else
            error "$tool installation failed"
            failed_tools+=("$tool")
        fi
    done

    echo ""

    if [[ ${#failed_tools[@]} -gt 0 ]]; then
        error "Failed to install: ${failed_tools[*]}"
        warn "Some features may not work without these tools"
        return 1
    fi

    success "All essential tools installed"
    return 0
}

verify_installations() {
    info "Verifying installations..."
    echo ""

    local all_ok=true

    # Verify Homebrew
    if command -v brew &>/dev/null; then
        success "brew: $(brew --version | head -1)"
    else
        error "brew: NOT FOUND"
        all_ok=false
    fi

    # Verify essential tools
    for tool in "${ESSENTIAL_TOOLS[@]}"; do
        if command -v "$tool" &>/dev/null; then
            local version=$("$tool" --version 2>&1 | head -1)
            success "$tool: $version"
        else
            error "$tool: NOT FOUND"
            all_ok=false
        fi
    done

    echo ""

    if [[ "$all_ok" == true ]]; then
        success "All tools verified successfully"
        return 0
    else
        error "Some tools are missing"
        return 1
    fi
}

main() {
    local os=$(uname)

    if [[ "$os" == "Darwin" ]]; then
        info "Installing core tools for macOS..."
        echo ""

        # Step 1: Xcode CLI Tools
        if ! install_xcode_cli_tools; then
            error "Failed to install Xcode Command Line Tools"
            return 1
        fi
        echo ""

        # Step 2: Homebrew
        if ! install_homebrew; then
            error "Failed to install Homebrew"
            return 1
        fi
        echo ""

        # Step 3: Essential tools
        if ! install_essential_tools; then
            warn "Some essential tools failed to install"
            # Don't fail the phase, continue
        fi
        echo ""

        # Step 4: Verify
        verify_installations

    elif [[ "$os" == "Linux" ]]; then
        warn "Linux support is experimental"
        info "Please ensure git, curl, and gnupg are installed via your package manager"
        info "Then install Homebrew manually: https://brew.sh"
        return 0

    else
        error "Unsupported operating system: $os"
        return 1
    fi
}

main "$@"
