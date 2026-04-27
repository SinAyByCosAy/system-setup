#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TOOL=""
COMMON=false
MAC_FORMULA=false
MAC_APP=false
LINUX=false
LINUX_NAME=""

usage(){
    echo "Usage:"
    echo "./add-tool.sh <tool> [--common] [--mac-formula] [--mac-app] [--linux] [--linux-name <name>]"
    exit 1
}

if [ $# -lt 1 ]; then
    usage
fi

TOOL="$1"
shift

while [[ $# -gt 0 ]]; do
  case "$1" in
    --common) COMMON=true ;;
    --mac-formula) MAC_FORMULA=true ;;
    --mac-app) MAC_APP=true ;;
    --linux) LINUX=true ;;
    --linux-name)
      shift
      LINUX_NAME="$1"
      ;;
    *) echo "Unknown flag: $1"; usage ;;
  esac
  shift
done

# Default linux name = same as tool
if [ -z "$LINUX_NAME" ]; then
    LINUX_NAME="$TOOL"
fi

add_unique() {
    FILE="$1"
    VALUE="$2"
    
    mkdir -p "$(dirname "$FILE")"
    touch "$FILE"

    if ! grep -qxF "$VALUE" "$FILE"; then
        echo "$VALUE" >> "$FILE"
        echo "[INFO] Added '$VALUE' to $FILE"
    else
        echo "[INFO] '$VALUE' already exists in $FILE"
    fi
}

# Logic
if $COMMON; then
    add_unique "$SCRIPT_DIR/common/common-tools.txt" "$TOOL"
fi
if $MAC_FORMULA; then
    add_unique "$SCRIPT_DIR/mac/mac-formula.txt" "$TOOL"
fi
if $MAC_APP; then
    add_unique "$SCRIPT_DIR/mac/mac-applications.txt" "$TOOL"
fi
if $LINUX; then
    add_unique "$SCRIPT_DIR/linux/linux-packages.txt" "$LINUX_NAME"
fi

# Git auto-commit + push
if command -v git &> /dev/null; then
    git add .

    # commit only if there are changes
    if ! git diff --cached --quiet; then
        git commit -m "Add tool: $TOOL"
        
        # push (only if branch has upstream)
        CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
        if git rev-parse --abbrev-ref --symbolic-full-name "@{u}" &>/dev/null; then
            git push
        else
            git push -u origin "$CURRENT_BRANCH"
        fi
    else
        echo "[INFO] No changes to commit"
    fi
fi