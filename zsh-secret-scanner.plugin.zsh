#!/bin/zsh
#
# zsh-secret-scanner — Block interactive commands that look like they contain secrets.
#
# Scans the command line when you press Enter (accept-line). Uses classic heuristics
# only; no network or AI. Not a security boundary — oops prevention for interactive shells.
#
# Configuration (set in .zshrc before loading):
#
#   ZSH_SECRET_SCANNER_ENABLED=0          Disable scanning
#   ZSH_SECRET_SCANNER_ALLOWLIST          Space-separated regexes; matching lines are ignored
#   ZSH_SECRET_SCANNER_EXTRA_PATTERNS     Extra rules as "label|regex" entries
#

: ${ZSH_SECRET_SCANNER_ENABLED:=1}

local _zss_plugin_dir="${0:A:h}"
source "${_zss_plugin_dir}/lib/scanner.zsh"
_zsh_secret_scanner_load_patterns "$_zss_plugin_dir"
unset _zss_plugin_dir

# ---------------------------------------------------------------------------
# ZLE: wrap accept-line
# ---------------------------------------------------------------------------
_zsh_secret_scanner_accept_line() {
    local label

    if label=$(_zsh_secret_scanner_match "$BUFFER"); then
        zle -M "secret-scanner: blocked ($label) — edit line or export ZSH_SECRET_SCANNER_ENABLED=0"
        return 1
    fi

    zle _zsh_secret_scanner_orig_accept_line
}

if [[ -n "$ZSH_SECRET_SCANNER_ENABLED" && "$ZSH_SECRET_SCANNER_ENABLED" != 0 ]]; then
    zle -A accept-line _zsh_secret_scanner_orig_accept_line
    zle -N accept-line _zsh_secret_scanner_accept_line
fi
