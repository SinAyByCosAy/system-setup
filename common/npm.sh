#!/usr/bin/env bash
set -e

source "$HOME/.nvm/nvm.sh"

while read -r pkg; do
    if ! npm list -g --depth=0 | grep -q "$pkg@"; then
        npm install -g "$pkg"
    fi
done < npm-global.txt