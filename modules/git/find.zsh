#!/usr/bin/env zsh
# Find files in git history

gfind() {
    if [[ -z "$1" ]]; then
        echo "❌ Filename pattern required"
        echo "Usage: gfind 'pattern'"
        return 1
    fi
    
    git log --all --full-history -- "*$1*"
}