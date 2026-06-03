#!/bin/zsh
#
# Run: zsh test/test-scanner.zsh
# Exits 1 on any failure.

emulate -L zsh
setopt localoptions

ROOT="${0:a:h:h}"
source "${ROOT}/lib/scanner.zsh"
_zsh_secret_scanner_load_patterns "$ROOT"

typeset -i failures=0

_assert_blocked() {
    local desc="$1" line="$2" expect_label="$3"
    local label

    if ! label=$(_zsh_secret_scanner_match "$line"); then
        print -u2 "FAIL: $desc — expected block, got none"
        (( failures++ ))
        return
    fi
    if [[ -n "$expect_label" && "$label" != "$expect_label" ]]; then
        print -u2 "FAIL: $desc — expected label '$expect_label', got '$label'"
        (( failures++ ))
        return
    fi
    print "ok: $desc"
}

_assert_allowed() {
    local desc="$1" line="$2"

    if label=$(_zsh_secret_scanner_match "$line"); then
        print -u2 "FAIL: $desc — expected allow, got '$label'"
        (( failures++ ))
        return
    fi
    print "ok: $desc"
}

_assert_blocked "GitHub PAT" \
    'curl -H "Authorization: token ghp_abcdefghijklmnopqrstuvwxyz1234567890"' \
    'GitHub token'

_assert_blocked "AWS key" \
    'export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE' \
    'AWS access key ID'

_assert_blocked "private key header" \
    'cat <<EOF
-----BEGIN RSA PRIVATE KEY-----
EOF' \
    'private key'

_assert_blocked "password assignment" \
    'mysql -u root -ppassword=notarealpassword123' \
    'credential assignment'

_assert_blocked "API key env assignment" \
    'GEMINI_API_KEY=AIzaSyD123456789012345678901234567890 myscript' \
    'API key env var'

_assert_blocked "API key env assignment (short value)" \
    'GEMINI_API_KEY=test myscript' \
    'API key env var'

_assert_blocked "API key shell reference" \
    'curl -H "Authorization: Bearer $GEMINI_API_KEY"' \
    'API key reference'

_assert_allowed "benign ls" 'ls -la'
_assert_allowed "short hash-like" 'echo deadbeef'

ZSH_SECRET_SCANNER_ALLOWLIST='^curl https://example.com'
_assert_allowed "allowlist regex" 'curl https://example.com/docs#Bearer'

if (( failures > 0 )); then
    print -u2 "$failures test(s) failed"
    exit 1
fi

print "All tests passed."
exit 0
