#!/usr/bin/env bash
set -e

# Install homebrew if not present
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

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