#!/usr/bin/env zsh
# Additional git aliases for compatibility

alias ga='git add'
alias gd='git diff'
alias gdc='git diff --cached'
alias gblame='blame'

# Git differ function (matches PowerShell script)
function differ() {
    local branch="${1:-main}"
    git diff "$branch"
}