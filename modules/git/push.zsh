#!/usr/bin/env zsh
# Git push commands

# Git push with upstream
git_push_upstream() {
    local current_branch=$(zmod_git_branch)
    if [[ -z "$current_branch" ]]; then
        echo "❌ Not on any branch"
        return 1
    fi
    
    # Check if upstream is set
    if ! git config --get "branch.$current_branch.remote" >/dev/null; then
        echo "🚀 Setting upstream and pushing..."
        git push --set-upstream origin "$current_branch"
    else
        git push
    fi
}

# Simple push alias
push() {
    git_push_upstream "$@"
}

# Aliases
alias gpu='git_push_upstream'
alias gp='git_push_upstream'