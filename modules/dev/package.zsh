#!/usr/bin/env zsh
# Package management commands

# Package manager shortcuts
install() {
    if [[ -f "package.json" ]]; then
        if zmod_has_command bun; then
            echo "⚡ Installing with bun..."
            bun install "$@"
        elif zmod_has_command pnpm; then
            echo "📦 Installing with pnpm..."
            pnpm install "$@"
        elif zmod_has_command yarn; then
            echo "🧶 Installing with yarn..."
            yarn add "$@"
        else
            echo "📦 Installing with npm..."
            npm install "$@"
        fi
    elif [[ -f "Cargo.toml" ]]; then
        echo "🦀 Installing Rust dependencies..."
        cargo add "$@"
    elif [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]]; then
        if zmod_has_command poetry; then
            echo "🎭 Installing with poetry..."
            poetry add "$@"
        elif zmod_has_command pipenv; then
            echo "🐍 Installing with pipenv..."
            pipenv install "$@"
        else
            echo "🐍 Installing with pip..."
            pip install "$@"
        fi
    elif [[ -f "go.mod" ]]; then
        echo "🐹 Installing Go dependencies..."
        go get "$@"
    else
        echo "❌ No package manager detected"
        return 1
    fi
}

# Alias
alias i='install'