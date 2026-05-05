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

while [[ $# -gt 0 ]]; do
  case "$1" in
    --npm) IS_NPM=true ;;
    --gui) IS_GUI=true ;;
    --common) IS_COMMON=true ;;
    --local) IS_LOCAL=true ;;
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
if ! $IS_NPM && ! $IS_GUI && ! $IS_COMMON && ! IS_LOCAL; then
    IS_NPM=true
    IS_GUI=true
    IS_COMMON=true
    IS_LOCAL=true
fi

