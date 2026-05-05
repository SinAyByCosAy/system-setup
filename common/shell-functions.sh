SCRIPT_DIR="${0:A:h}"
source "$SCRIPT_DIR/validations.sh"

brew-add() {
    local tool="$1"
    shift

    validate_flags "$@" || return 1

    brew install "$tool" || return 1
    add-tool "$tool" "$@"
}
cask-add() {
    local tool="$1"
    shift

    validate_flags "$@" || return 1

    brew install --cask "$tool" || return 1
    add-tool "$tool" --gui "$@"
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