#!/usr/bin/env zsh
# Git pull commands

# Git pull with rebase
git_pull_rebase() {
    git pull --rebase
}

git_pull() {
    git pull
}

# Simple pull alias
pull() {
    git_pull_rebase "$@"
}

# Aliases
alias gpr='git_pull_rebase'
alias gpull='git_pull_rebase'