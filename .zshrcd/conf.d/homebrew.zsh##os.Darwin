# Check if Homebrew is installed
if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew not found. Installing Homebrew."

  # Install Homebrew
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  echo "Homebrew installation complete."
fi
export HOMEBREW_BUNDLE_FILE_GLOBAL="${ZCONFDIR}/Brewfile"

# Homebrew completions (HOMEBREW_PREFIX set in .zprofile.local)
if [[ -n "$HOMEBREW_PREFIX" ]]; then
  fpath+="$HOMEBREW_PREFIX/share/zsh/site-functions"
fi

