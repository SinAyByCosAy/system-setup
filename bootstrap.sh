#!/usr/bin/env bash
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

OS = "$(uname)"
echo "Detected OS: $OS"

if [[ "$OS" == "Darwin" ]]; then
    ./mac/brew.sh
elif [[ "$OS" == "Linux" ]]; then
    ./linux/apt.sh
else
    echo "Unsupported OS"
    exit 1
fi

# Node / npm
source "$REPO_DIR/common/nvm.sh"
./common/npm.sh

# Make script executable
chmod +x "$REPO_DIR/common/add-tool.sh"

# Add repo to PATH (so add-tool.sh is global)
SHELL_RC="$HOME/.zshrc"
[[ "$SHELL" == *"bash"* ]] && SHELL_RC="$HOME/.bashrc"

PATH_LINE='export PATH="$HOME/system-setup/common:$PATH"'

grep -qxF "$PATH_LINE" "$SHELL_RC" || echo "$PATH_LINE" >> "$SHELL_RC"

# Source shell functions
BLOCK_START="# >>> setup-tools >>>"
BLOCK_END="# <<< setup-tools <<<"

if ! grep -q "$BLOCK_START" "$SHELL_RC"; then
    {
        echo ""
        echo "$BLOCK_START"
        echo "source \"$REPO_DIR/common/shell-functions.sh\""
        echo "$BLOCK_END"
    } >> "$SHELL_RC"
fi

# Reload shell config
source "$SHELL_RC"

echo "[INFO] Setup complete. Restart terminal or run: source $SHELL_RC"