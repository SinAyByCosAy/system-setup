source "$HOME/system-setup/common/validations.sh"

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
    local tool="$1"
    shift

    validate_flags "$@" || return 1

    npm install -g "$tool" || return 1
    add-tool.sh "$tool" --npm
}