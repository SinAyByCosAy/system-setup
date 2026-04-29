brew-add() {
    local tool="$1"
    shift

    brew install "$tool" || return 1
    add-tool.sh "$tool" "$@"
}