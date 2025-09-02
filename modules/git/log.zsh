#!/usr/bin/env zsh
# Enhanced git log

git_log() {
    local count="${1:-10}"
    git log --oneline --graph --decorate --color=always -n "$count"
}

# Alias for git_log
alias glog='git_log'
alias gl='git_log'