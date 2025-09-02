#!/usr/bin/env zsh
# Git undo operations

# Undo last commit (keep changes)
gundo() {
    if zmod_confirm "Undo last commit but keep changes?"; then
        git reset --soft HEAD~1
        echo "✅ Last commit undone, changes kept"
    fi
}