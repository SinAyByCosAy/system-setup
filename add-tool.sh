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
