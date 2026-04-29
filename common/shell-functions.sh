brew-add() {
    local tool="$1"
    shift

    brew install "$tool" || return 1
    add-tool.sh "$tool" "$@"
}
cask-add() {
    local tool="$1"
    shift

    brew install --cask "$tool" || return 1
    add-tool.sh "$tool" --gui "$@"
}
apt-add() {
    local tool="$1"
    shift

    sudo apt install -y "$tool" || return 1
    add-tool.sh "$tool" "$@"
}
npm-add() {
    local tool="$1"
    shift

    npm install -g "$tool" || return 1
    add-tool.sh "$tool" --npm
}