#!/usr/bin/env zsh
# Build and compilation commands

# Build project
build() {
    if [[ -f "package.json" ]]; then
        if zmod_has_command bun; then
            bun run build
        elif zmod_has_command pnpm; then
            pnpm build
        elif zmod_has_command yarn; then
            yarn build
        else
            npm run build
        fi
    elif [[ -f "Cargo.toml" ]]; then
        cargo build --release
    elif [[ -f "Makefile" ]]; then
        make
    elif [[ -f "go.mod" ]]; then
        go build
    else
        echo "❌ No build system detected"
        return 1
    fi
}

# Alias
alias b='build'