#!/usr/bin/env zsh
# Git swap/switch commands

# Switch to a branch (alias for git switch)
swap() {
    if [[ -z "$1" ]]; then
        echo "❌ Branch name required"
        echo "Usage: swap branch-name"
        return 1
    fi
    
    git switch "$1"
}

# Alias for compatibility
alias gco='git checkout'