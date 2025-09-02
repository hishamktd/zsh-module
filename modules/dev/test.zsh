#!/usr/bin/env zsh
# Testing commands

# Test runner
test() {
    if [[ -f "package.json" ]]; then
        if zmod_has_command bun; then
            bun test "$@"
        elif zmod_has_command pnpm; then
            pnpm test "$@"
        elif zmod_has_command yarn; then
            yarn test "$@"
        else
            npm test "$@"
        fi
    elif [[ -f "Cargo.toml" ]]; then
        cargo test "$@"
    elif [[ -f "pytest.ini" ]] || [[ -f "pyproject.toml" ]]; then
        if zmod_has_command pytest; then
            pytest "$@"
        else
            python -m pytest "$@"
        fi
    elif [[ -f "go.mod" ]]; then
        go test "$@"
    else
        echo "❌ No test runner detected"
        return 1
    fi
}

# Alias
alias t='test'