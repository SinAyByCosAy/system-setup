brew-add() {
    local tool="$1"
    shift

    brew install "$tool" || return 1

    [ "$#" -gt 0 ] && add-tool.sh "$tool" "$@"
}