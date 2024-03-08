# Check if the operating system is macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
  # Check if Homebrew is installed
  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew not found. Installing Homebrew."

    # Install Homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    echo "Homebrew installation complete."
  fi
  export  HOMEBREW_BUNDLE_FILE_GLOBAL="${ZCONFDIR}/Brewfile"
fi

