#!/usr/bin/env bash
set -e

export NVM_DIR="$HOME/.nvm"

if [ ! -d "NVM_DIR" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi

source "$NVM_DIR/nvm.sh"

nvm install --lts
nvm use --lts