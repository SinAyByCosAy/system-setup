#!/usr/bin/env bash
set -e

# resolve script dir (symlink safe)
SOURCE="${BASH_SOURCE[0]}"
while [ -L "$SOURCE" ]; do
    DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

TOOL="$1"
shift || true

[ -z "$TOOL" ] && {
    echo "Usage: tool-rm <tool> [--npm | --gui | --local | --common]"
    exit 1
}

# Flags
IS_NPM=false
IS_GUI=false
IS_COMMON=false
IS_LOCAL=false
NO_PUSH=false
REMOVED=false
OS="$(uname)"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --npm) IS_NPM=true ;;
    --gui) IS_GUI=true ;;
    --common) IS_COMMON=true ;;
    --local) IS_LOCAL=true ;;
    --no-push) NO_PUSH=true ;;
    *) echo "[ERROR] Unknown flag: $1"; exit 1 ;;
  esac
  shift
done

# incompatible combos
if $IS_NPM && ($IS_GUI || $IS_COMMON || $IS_LOCAL); then
  echo "[ERROR] --npm cannot be combined with other flags"
  exit 1
fi

if $IS_COMMON && $IS_LOCAL; then
  echo "[ERROR] Cannot combine --common and --local"
  exit 1
fi

# If no flags -> remove everywhere
if ! $IS_NPM && ! $IS_GUI && ! $IS_COMMON && ! $IS_LOCAL; then
    IS_NPM=true
    IS_GUI=true
    IS_COMMON=true
    IS_LOCAL=true
fi

remove_from_file() {
    FILE="$1"
    [ -f "$FILE" ] || return
    
    if grep -qxF "$TOOL" "$FILE"; then
        grep -vxF "$TOOL" "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
        echo "[INFO] Removed '$TOOL' from $FILE"
        REMOVED=true
    else
        echo "[INFO] '$TOOL' not found in $FILE"
    fi
}

# Select the file to remove from
$IS_NPM && remove_from_file "$REPO_DIR/npm-global.txt"

# Common
if $IS_COMMON; then
    if $IS_GUI; then
        remove_from_file "$REPO_DIR/common/common-gui.txt"
    else
        remove_from_file "$REPO_DIR/common/common-cli.txt"
    fi
fi

# Local
if $IS_LOCAL; then
    if [[ "$OS" == "Darwin" ]]; then
        if $IS_GUI; then
            remove_from_file "$REPO_DIR/mac/mac-applications.txt"
        else
            remove_from_file "$REPO_DIR/mac/mac-formulas.txt"
        fi
    else
        remove_from_file "$REPO_DIR/linux/linux-packages.txt"
    fi
fi

# Uninstall
if $IS_NPM; then
    npm uninstall -g "$TOOL" || true
fi

if [[ "$OS" == "Darwin" ]]; then
    if $IS_GUI; then
        brew uninstall --cask "$TOOL" || true
    else
        brew uninstall "$TOOL" || true
    fi
else
    sudo apt remove -y "$TOOL" || true
fi