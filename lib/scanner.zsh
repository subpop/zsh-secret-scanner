# Match command lines against heuristic secret patterns.

: ${ZSH_SECRET_SCANNER_ENABLED:=1}

_zsh_secret_scanner_load_patterns() {
    local plugin_dir="$1"
    [[ -n "${_ZSH_SECRET_SCANNER_PATTERNS[(I)*]}" ]] && return 0
    source "${plugin_dir}/lib/patterns.zsh"
    if [[ -n "${ZSH_SECRET_SCANNER_EXTRA_PATTERNS[(I)*]}" ]]; then
        _ZSH_SECRET_SCANNER_PATTERNS+=("${ZSH_SECRET_SCANNER_EXTRA_PATTERNS[@]}")
    fi
}

# Returns 0 if the line is allowlisted (skip scanning).
_zsh_secret_scanner_allowlisted() {
    local line="$1"
    local pattern

    for pattern in ${=ZSH_SECRET_SCANNER_ALLOWLIST}; do
        [[ -n "$pattern" ]] || continue
        if [[ "$line" =~ $pattern ]]; then
            return 0
        fi
    done
    return 1
}

# On match, prints "label" to stdout and returns 0. Otherwise returns 1.
_zsh_secret_scanner_match() {
    local line="$1"
    local entry label regex

    [[ -n "$ZSH_SECRET_SCANNER_ENABLED" && "$ZSH_SECRET_SCANNER_ENABLED" != 0 ]] || return 1
    [[ -n "$line" ]] || return 1

    if _zsh_secret_scanner_allowlisted "$line"; then
        return 1
    fi

    for entry in "${_ZSH_SECRET_SCANNER_PATTERNS[@]}"; do
        label="${entry%%|*}"
        regex="${entry#*|}"
        if [[ "$line" =~ $regex ]]; then
            print -r -- "$label"
            return 0
        fi
    done

    return 1
}
