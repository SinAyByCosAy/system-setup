if [ -n "$BASH_SOURCE" ]; then
  SCRIPT_PATH="${BASH_SOURCE[0]}"
elif [ -n "$ZSH_VERSION" ]; then
  SCRIPT_PATH="${(%):-%x}"
else
  SCRIPT_PATH="$0"
fi

SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
source "$SCRIPT_DIR/validations.sh"

brew-add() {
    local tool="$1"
    shift

    validate_flags "$@" || return 1

    local IS_GUI=false

    for arg in "$@"; do
        [[ "$arg" == "--gui" ]] && IS_GUI=true
    done

    if $IS_GUI; then
        brew install --cask "$tool" || return 1
    else
        brew install "$tool" || return 1
    fi

    add-tool "$tool" "$@"
}
apt-add() {
    local tool="$1"
    shift

    validate_flags "$@" || return 1

    sudo apt install -y "$tool" || return 1
    add-tool "$tool" "$@"
}
npm-add() {
    echo "$SCRIPT_DIR/validations.sh"
    local tool="$1"
    shift

    validate_flags "$@" || return 1

    npm install -g "$tool" || return 1
    add-tool "$tool" --npm
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