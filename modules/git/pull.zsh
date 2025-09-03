#!/usr/bin/env zsh
# Git pull commands - matches pull.ps1

# Main pull function (matches PowerShell pull.ps1)
pull() {
    local branch="${1:-$(zmod_get_default_branch)}"
    
    if ! zmod_is_git_repo; then
        echo "❌ Not a git repository"
        return 1
    fi
    
    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        echo "$(zmod_color yellow "⚠️  You have uncommitted changes")"
        echo "$(zmod_color yellow "Stashing changes before pull...")"
        git stash push -m "Auto-stash before pull $(date)"
        local stashed=true
    fi
    
    echo "$(zmod_color cyan "Pulling from origin/$branch...")"
    
    # Fetch from origin first
    git fetch origin
    
    if [[ $? -eq 0 ]]; then
        # Pull with rebase from specific origin/branch
        git pull origin "$branch" --rebase
        local pull_result=$?
        
        # Restore stashed changes if we stashed them
        if [[ "$stashed" == "true" ]]; then
            echo "$(zmod_color yellow "Restoring stashed changes...")"
            git stash pop
        fi
        
        return $pull_result
    else
        echo "❌ Failed to fetch from origin"
        return 1
    fi
}

# Additional pull variations for compatibility
git_pull_rebase() {
    git pull --rebase
}

git_pull() {
    git pull
}

# Aliases
alias gpr='git_pull_rebase'
alias gpull='git_pull'