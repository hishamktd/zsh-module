#!/usr/bin/env zsh
# Git push commands

# Load utility functions
local GIT_MODULE_DIR="${0:A:h}"
source "$GIT_MODULE_DIR/functions/clipboard.zsh"
source "$GIT_MODULE_DIR/functions/remote.zsh"

# Git push with upstream
git_push_upstream() {
    local current_branch=$(zmod_git_branch)
    if [[ -z "$current_branch" ]]; then
        echo "❌ Not on any branch"
        return 1
    fi
    
    local push_success=false
    
    # Check if upstream is set
    if ! has_upstream; then
        echo "🚀 Setting upstream and pushing..."
        if git push --set-upstream origin "$current_branch"; then
            push_success=true
        fi
    else
        if git push "$@"; then
            push_success=true
        fi
    fi
    
    # If push was successful, copy remote URL to clipboard
    if [[ "$push_success" == true ]]; then
        local remote_url=$(get_remote_url)
        if [[ -n "$remote_url" ]]; then
            copy_with_feedback "$remote_url" "Remote URL"
        fi
    fi
}

# Force push with safety checks
git_push_force() {
    local current_branch=$(zmod_git_branch)
    if [[ -z "$current_branch" ]]; then
        echo "❌ Not on any branch"
        return 1
    fi
    
    # Safety check for protected branches
    if [[ "$current_branch" =~ ^(main|master|develop|dev)$ ]]; then
        echo "⚠️  Force pushing to '$current_branch' branch!"
        echo -n "Are you sure? (y/N): "
        read confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo "❌ Force push cancelled"
            return 1
        fi
    fi
    
    echo "💪 Force pushing..."
    if git push --force-with-lease "$@"; then
        local remote_url=$(get_remote_url)
        if [[ -n "$remote_url" ]]; then
            copy_with_feedback "$remote_url" "Remote URL"
        fi
    fi
}

# Main push commands
push() {
    git_push_upstream "$@"
}

push_force() {
    git_push_force "$@"
}

# Push all branches
push_all() {
    echo "🚀 Pushing all branches..."
    if git push --all; then
        local remote_url=$(get_remote_url)
        if [[ -n "$remote_url" ]]; then
            copy_with_feedback "$remote_url" "Remote URL"
        fi
    fi
}

# Push tags
push_tags() {
    echo "🏷️  Pushing tags..."
    if git push --tags; then
        local remote_url=$(get_remote_url)
        if [[ -n "$remote_url" ]]; then
            copy_with_feedback "$remote_url" "Remote URL"
        fi
    fi
}

# Push current branch and tags
push_with_tags() {
    echo "🚀 Pushing branch and tags..."
    if git_push_upstream && git push --tags; then
        local remote_url=$(get_remote_url)
        if [[ -n "$remote_url" ]]; then
            copy_with_feedback "$remote_url" "Remote URL"
        fi
    fi
}

# Aliases
alias gpu='git_push_upstream'
alias gp='git_push_upstream'
alias gpf='push_force'
alias gpa='push_all'
alias gpt='push_tags'
alias gpwt='push_with_tags'