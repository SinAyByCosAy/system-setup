validate_flags() {
    local has_common=false
    local has_local=false
    local has_gui=false
    local has_npm=false
    local has_linux_name=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
          --common) has_common=true ;;
          --local) has_local=true ;;
          --gui) has_gui=true ;;
          --npm) has_npm=true ;;
          --linux-name)
            has_linux_name=true
            shift
            ;;
          *) echo "[ERROR] Unknown flag: $1"; return 1 ;;
        esac
        shift
    done

    if $has_common && $has_local; then
        echo "[ERROR] --common and --local cannot be combined"
        return 1
    fi

    if $has_npm && ($has_common || $has_local || $has_gui || $has_linux_name); then
        echo "[ERROR] --npm cannot be combined with other flags"
        return 1
    fi
    
    if $has_common && $has_linux_name; then
        echo "[ERROR] --common cannont be combined with --linux-name"
        return 1
    fi

    return 0
}