#!/usr/bin/env bash

set -e

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

# Run my scripts to install the tools

# source - persist changes
source ./common/nvm.sh

# Normal execution - npm installs are using -g flag already
./common/npm.sh