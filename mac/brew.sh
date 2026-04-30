#!/usr/bin/env bash
set -e

# Install homebrew if not present
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Ensure brew is available in this script
eval "$(/opt/homebrew/bin/brew shellenv)"
# Persist brew for future shells
ZPROFILE="$HOME/.zprofile"

if ! grep -q 'brew shellenv' "$ZPROFILE" 2>/dev/null; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$ZPROFILE"
    echo "[INFO] Added brew shellenv to ~/.zprofile"
fi

brew update

# Install common CLI tools
if [ -f common/common-cli.txt ]; then
    xargs brew install < common/common-cli.txt
fi

# Install common GUI apps
if [ -f common/common-gui.txt ]; then
    xargs brew install --cask < common/common-gui.txt
fi

# Install mac-only CLI tools
if [ -f mac/mac-formulas.txt ]; then
    xargs brew install < mac/mac-formulas.txt
fi

# Install mac-only GUI apps
xargs -P 4 brew install --cask < mac/mac-applications.txt