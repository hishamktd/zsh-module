#!/usr/bin/env zsh
# Git swap/switch commands

# Switch to a branch (alias for git switch)
swap() {
    local branch_name="$1"
    
    if ! zmod_is_git_repo; then
        echo "❌ Not a git repository"
        return 1
    fi
    
    # If no branch name provided, default to main branch
    if [[ -z "$branch_name" ]]; then
        # Try to find main branch starting with configured default, then fallbacks
        if git show-ref --verify --quiet "refs/heads/$ZSH_MODULE_DEFAULT_BRANCH"; then
            branch_name="$ZSH_MODULE_DEFAULT_BRANCH"
        elif git show-ref --verify --quiet "refs/heads/master"; then
            branch_name="master"
        elif git show-ref --verify --quiet "refs/heads/develop"; then
            branch_name="develop"
        elif git show-ref --verify --quiet "refs/heads/dev"; then
            branch_name="dev"
        else
            # Get the default branch from remote origin
            local default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | cut -d/ -f4)
            if [[ -n "$default_branch" ]] && git show-ref --verify --quiet "refs/heads/$default_branch"; then
                branch_name="$default_branch"
            else
                echo "❌ No main branch found (main/master/develop/dev)"
                echo "Available branches:"
                git branch --format="  %(refname:short)" | head -5
                echo "Usage: swap [branch-name]"
                return 1
            fi
        fi
        
        echo "$(zmod_color green "🏠 Switching to main branch: $branch_name")"
    fi
    
    # Check if branch exists before switching
    if ! git show-ref --verify --quiet "refs/heads/$branch_name"; then
        # Check if it exists as remote branch
        if git show-ref --verify --quiet "refs/remotes/origin/$branch_name"; then
            echo "$(zmod_color yellow "📥 Creating local branch from origin/$branch_name")"
            git switch -c "$branch_name" "origin/$branch_name"
        else
            echo "❌ Branch '$branch_name' not found"
            echo "Available branches:"
            git branch --format="  %(refname:short)" | head -5
            return 1
        fi
    else
        git switch "$branch_name"
    fi
}

# Alias for compatibility
alias gco='git checkout'