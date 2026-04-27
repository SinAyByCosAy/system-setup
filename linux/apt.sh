#!/usr/bin/env bash
set -e

sudo apt update

# Install common CLI tools
while read -r tool; do
    sudo apt install -y "$tool" ;;
done < common/common-tools.txt

# Install packages specifically for linux environment
if [ -f linux/linux-packages.txt ]; then
    xargs -a linux/linux-packages.txt sudo apt install -y
fi