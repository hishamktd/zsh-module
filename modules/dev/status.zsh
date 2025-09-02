#!/usr/bin/env zsh
# Project status and information commands

# Quick project status
status() {
    echo "📁 Project: $(basename $(pwd))"
    echo "📂 Directory: $(pwd)"
    
    # Git status
    if zmod_is_git_repo; then
        echo "🌿 Branch: $(zmod_git_branch)"
        local dirty_files=$(git status --porcelain | wc -l)
        if [[ $dirty_files -gt 0 ]]; then
            echo "📝 Modified files: $dirty_files"
        else
            echo "✅ Working directory clean"
        fi
    else
        echo "❌ Not a git repository"
    fi
    
    # Package info
    if [[ -f "package.json" ]]; then
        local pkg_name=$(grep '"name"' package.json | cut -d'"' -f4)
        local pkg_version=$(grep '"version"' package.json | cut -d'"' -f4)
        echo "📦 Package: $pkg_name@$pkg_version"
    elif [[ -f "Cargo.toml" ]]; then
        local crate_name=$(grep '^name = ' Cargo.toml | cut -d'"' -f2)
        local crate_version=$(grep '^version = ' Cargo.toml | cut -d'"' -f2)
        echo "🦀 Crate: $crate_name@$crate_version"
    elif [[ -f "pyproject.toml" ]]; then
        local py_name=$(grep '^name = ' pyproject.toml | cut -d'"' -f2)
        echo "🐍 Python project: $py_name"
    fi
}

# Alias
alias st='status'