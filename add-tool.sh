#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/validations.sh"

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

ORIGINAL_ARGS=("$@")

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

# Flags validation
validate_flags "${ORIGINAL_ARGS[@]}" || exit 1

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

# --- npm ---
if $IS_NPM; then
    add_unique "$SCRIPT_DIR/../npm-global.txt" "$TOOL"
else
    # --- common ---
    if $IS_COMMON; then
        if $IS_GUI; then
            add_unique "$SCRIPT_DIR/../common/common-gui.txt" "$TOOL"
        else
            add_unique "$SCRIPT_DIR/../common/common-cli.txt" "$TOOL"
        fi

    # --- local ---
    elif $IS_LOCAL; then
        OS="$(uname)"
        if [[ "$OS" == "Darwin" ]]; then
            if $IS_GUI; then
                add_unique "$SCRIPT_DIR/../mac/mac-applications.txt" "$TOOL"
            else
                add_unique "$SCRIPT_DIR/../mac/mac-formulas.txt" "$TOOL"
            fi
        else
            add_unique "$SCRIPT_DIR/../linux/linux-packages.txt" "$TOOL"
        fi
    
    # --- cross OS via linux-name ---
    elif [ -n "$LINUX_NAME" ]; then
        # mac side
        if $IS_GUI; then
            add_unique "$SCRIPT_DIR/../mac/mac-applications.txt" "$TOOL"
        else
            add_unique "$SCRIPT_DIR/../mac/mac-formulas.txt" "$TOOL"
        fi

        # linux side
        add_unique "$SCRIPT_DIR/../linux/linux-packages.txt" "$TOOL"
    fi
fi

# Git auto-commit + push
if command -v git &> /dev/null; then
    git add .

    # commit only if there are changes
    if ! git diff --cached --quiet; then
        if $IS_NPM; then
            COMMIT_MSG="Add npm tool: $TOOL"
        else
            COMMIT_MSG="Add tool: $TOOL"
        fi
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