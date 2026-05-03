#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Load nvm 
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Activate default mode
if ! command -v node &>/dev/null; then
  nvm install --lts
  nvm use --lts
else
  nvm use --silent || true
fi

# Ensure file exists
[ -f "$REPO_DIR/npm-global.txt" ] || {
    echo "[INFO] No npm-global.txt found"
    exit 0
}

while IFS= read -r pkg || [ -n "$pkg" ]; do
  pkg="$(echo "$pkg" | xargs)"
  [ -z "$pkg" ] && continue

  echo "[INFO] Processing: $pkg"

  if ! npm list -g "$pkg" &>/dev/null; then
    npm install -g "$pkg"
  fi
done < "$REPO_DIR/npm-global.txt"