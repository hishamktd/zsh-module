#!/usr/bin/env zsh
# Git blame with better formatting

gblame() {
    if [[ -z "$1" ]]; then
        echo "❌ File path required"
        echo "Usage: gblame file.txt"
        return 1
    fi
    
    git blame --color-lines --color-by-age "$1"
}