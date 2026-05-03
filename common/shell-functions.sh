SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/validations.sh"

brew-add() {
    local tool="$1"
    shift

    validate_flags "$@" || return 1

    brew install "$tool" || return 1
    add-tool.sh "$tool" "$@"
}
cask-add() {
    local tool="$1"
    shift

    validate_flags "$@" || return 1

    brew install --cask "$tool" || return 1
    add-tool.sh "$tool" --gui "$@"
}
apt-add() {
    local tool="$1"
    shift

    validate_flags "$@" || return 1

    sudo apt install -y "$tool" || return 1
    add-tool.sh "$tool" "$@"
}
npm-add() {
    echo "$SCRIPT_DIR/validations.sh"
    local tool="$1"
    shift

    validate_flags "$@" || return 1

    npm install -g "$tool" || return 1
    add-tool.sh "$tool" --npm
}