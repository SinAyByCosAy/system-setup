#!/usr/bin/env bash
set -e

sudo apt update

# Install common CLI tools
if [ -f common/common-cli.txt ]; then
    xargs -a common/common-cli.txt sudo apt install -y
fi

# Install common GUI apps
if [ -f common/common-gui.txt ]; then
    xargs -a common/common-gui.txt sudo apt install -y
fi

# Install packages specifically for linux environment
if [ -f linux/linux-packages.txt ]; then
    xargs -a linux/linux-packages.txt sudo apt install -y
fi