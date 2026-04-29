#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TOOL="$1"
shift || true

# Flags
IS_COMMON=false
IS_GUI=false
IS_NPM=false
IS_LOCAL=false
LINUX_NAME=""

usage(){
    echo "Usage:"
    echo "./add-tool.sh <tool> [--common] [--local] [--gui] [--npm] [--linux-name <name>]"
    exit 1
}

# Run usage, is no tool present
[ -z "$TOOL" ] && usage

# Parse flags
while [[ $# -gt 0 ]]; do
  case "$1" in
    --npm) IS_NPM=true ;;
    --common) IS_COMMON=true ;;
    --gui) IS_GUI=true ;;
    --local) IS_LOCAL=true ;;
    --linux-name)
      shift
      LINUX_NAME="$1"
      ;;
    *) echo "[Error] Unknown flag: $1"; exit 1 ;;
  esac
  shift
done

# No flags -> do nothing (user doesn't want to write to any file)
if ! $IS_COMMON && ! $IS_LOCAL && ! $IS_NPM && [ -z "$LINUX_NAME" ]; then
    exit 0
fi

# Validation
if $IS_NPM && ($IS_COMMON || $IS_LOCAL || $IS_GUI || [ -n "$LINUX_NAME" ]); then
    echo "[ERROR] --npm cannot be combined with other flags"
    exit 1
fi

if $IS_COMMON && $IS_LOCAL; then
    echo "[ERROR] --common and --local cannot be combined"
    exit 1
fi

if $IS_COMMON && [ -n "$LINUX_NAME" ]; then
    echo "[ERROR] --common cannot be combined with --linux-name"
    exit 1
fi

# Helper
add_unique() {
    local FILE="$1"
    local VALUE="$2"
    
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
if $IS_NPM; then
    add_unique "$SCRIPT_DIR/npm-global.txt" "$TOOL"
fi
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

    if $IS_NPM; then
        COMMIT_MSG="Add npm tool: $TOOL"
    else
        COMMIT_MSG="Add tool: $TOOL"
    fi

    # commit only if there are changes
    if ! git diff --cached --quiet; then
        git commit -m "$COMMIT_MSG"
        
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