#!/usr/bin/env zsh
# Code linting and formatting commands

# Lint and format
lint() {
    local fixed=false
    
    if [[ -f "package.json" ]]; then
        if zmod_has_command eslint; then
            eslint . --fix && fixed=true
        fi
        if zmod_has_command prettier; then
            prettier . --write && fixed=true
        fi
    elif [[ -f "Cargo.toml" ]]; then
        if zmod_has_command cargo-fmt; then
            cargo fmt && fixed=true
        fi
        if zmod_has_command clippy; then
            cargo clippy --fix --allow-dirty && fixed=true
        fi
    elif [[ -f "pyproject.toml" ]] || [[ -f "setup.py" ]]; then
        if zmod_has_command black; then
            black . && fixed=true
        fi
        if zmod_has_command isort; then
            isort . && fixed=true
        fi
        if zmod_has_command flake8; then
            flake8 .
        fi
    elif [[ -f "go.mod" ]]; then
        if zmod_has_command gofmt; then
            gofmt -w . && fixed=true
        fi
    fi
    
    if [[ "$fixed" == "false" ]]; then
        echo "❌ No linting tools found"
        return 1
    else
        echo "✅ Code formatted and linted"
    fi
}

# Alias
alias l='lint'