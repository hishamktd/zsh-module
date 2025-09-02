#!/usr/bin/env zsh
# Git blame with better formatting

blame() {
    if [[ -z "$1" ]]; then
        echo "❌ File path required"
        echo "Usage: blame file.txt"
        return 1
    fi
    
    git blame --color-lines --color-by-age "$1"
}