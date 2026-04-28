brew-add() {
    local tool="$1"
    shift

    brew install "$tool" || return 1

    # pass flags, if provided
    if [ "$#" -gt 0 ]; then
        add-tool.sh "$tool" "$@"
    fi
}