if [ -n "$BASH_SOURCE" ]; then
  SCRIPT_PATH="${BASH_SOURCE[0]}"
elif [ -n "$ZSH_VERSION" ]; then
  SCRIPT_PATH="${(%):-%x}"
else
  SCRIPT_PATH="$0"
fi

SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
source "$SCRIPT_DIR/validations.sh"

omni-add() {
    local tool="$1"
    shift

    # Validate the flags using your existing validation script
    validate_flags "$@" || return 1

    local os_name
    os_name="$(uname -s)"

    # --- EXECUTION PHASE ---
    if [ "$os_name" = "Darwin" ]; then
        # macOS: Check for --gui to use cask
        if [[ " $* " == *" --gui "* ]]; then
            echo "[INFO] Installing GUI app '$tool' via Homebrew Cask..."
            brew install --cask "$tool" || return 1
        else
            echo "[INFO] Installing CLI tool '$tool' via Homebrew..."
            brew install "$tool" || return 1
        fi

    elif [ "$os_name" = "Linux" ]; then
        # Linux: Check if a custom linux name was provided via --linux-name
        local install_name="$tool"
        local args=("$@")
        
        for i in "${!args[@]}"; do
            if [[ "${args[$i]}" == "--linux-name" ]]; then
                install_name="${args[$((i+1))]}"
                break
            fi
        done

        echo "[INFO] Installing '$install_name' via apt..."
        sudo apt update && sudo apt install -y "$install_name" || return 1
        
    else
        echo "[ERROR] Unsupported OS: $os_name"
        return 1
    fi

    # Hand off to add-tool to manage the text files and Git commits
    add-tool "$tool" "$@"
}
npm-add() {
    local tool="$1"
    shift

    validate_flags "$@" || return 1

    npm list -g "$tool" &>/dev/null || npm install -g "$tool"
    add-tool "$tool" "$@"
}
tool-rm() {
    remove-tool "$@"
}
setup-config() {
    cat "$HOME/.setup-config"
}
setup-push-on() {
    sed -i '' '/^AUTO_PUSH=/d' "$HOME/.setup-config" 2>/dev/null
    echo "AUTO_PUSH=true" >> "$HOME/.setup-config"
    echo "[INFO] Auto push enabled"
}
setup-push-off() {
    sed -i '' '/^AUTO_PUSH=/d' "$HOME/.setup-config" 2>/dev/null
    echo "AUTO_PUSH=false" >> "$HOME/.setup-config"
    echo "[INFO] Auto push disabled"
}