# Secret-detection rules: each entry is "label|extended_regex".
# Loaded by lib/scanner.zsh. Add custom rules via ZSH_SECRET_SCANNER_EXTRA_PATTERNS.

typeset -ga _ZSH_SECRET_SCANNER_PATTERNS
_ZSH_SECRET_SCANNER_PATTERNS=(
    'private key|-----BEGIN[[:space:]]+.*PRIVATE[[:space:]]+KEY-----'
    'GitHub token|(ghp_|gho_|ghu_|ghs_|github_pat_)[A-Za-z0-9_]{20,}'
    'AWS access key ID|AKIA[0-9A-Z]{16}'
    'Slack token|xox[baprs]-[0-9A-Za-z-]{10,}'
    'Stripe secret key|sk_(live|test)_[0-9A-Za-z]{16,}'
    'Bearer token|([Bb]earer|[Aa]uthorization:)[[:space:]]+[A-Za-z0-9._~+/=-]{20,}'
    'HTTP Basic credentials|[Bb]asic[[:space:]]+[A-Za-z0-9+/]{20,}=*'
    'JWT|eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}'
    'credential assignment|(password|api[_-]?key|client[_-]?secret|access[_-]?token)[[:space:]]*[=:][[:space:]]*[^[:space:]]{8,}'
    'API key env var|[A-Za-z0-9_]+_API_KEY[[:space:]]*=[[:space:]]*[^[:space:]]+'
    'API key reference|\$[A-Za-z0-9_]+_API_KEY'
)
