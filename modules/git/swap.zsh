#!/usr/bin/env zsh
# Git swap/switch commands

# Switch to a branch (alias for git switch)
swap() {
    local branch_name="$1"
    
    if ! zmod_is_git_repo; then
        echo "❌ Not a git repository"
        return 1
    fi
    
    # If no branch name provided, default to configured main branch
    if [[ -z "$branch_name" ]]; then
        # Get the configured default branch for this repository
        local default_branch=$(zmod_get_default_branch)
        
        # Try to find main branch starting with configured default, then fallbacks
        if git show-ref --verify --quiet "refs/heads/$default_branch"; then
            branch_name="$default_branch"
        elif git show-ref --verify --quiet "refs/heads/main"; then
            branch_name="main"
        elif git show-ref --verify --quiet "refs/heads/master"; then
            branch_name="master"
        elif git show-ref --verify --quiet "refs/heads/develop"; then
            branch_name="develop"
        elif git show-ref --verify --quiet "refs/heads/dev"; then
            branch_name="dev"
        else
            # Get the default branch from remote origin
            local remote_default=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | cut -d/ -f4)
            if [[ -n "$remote_default" ]] && git show-ref --verify --quiet "refs/heads/$remote_default"; then
                branch_name="$remote_default"
            else
                echo "❌ No main branch found ($default_branch/main/master/develop/dev)"
                echo "Available branches:"
                git branch --format="  %(refname:short)" | head -5
                echo "Usage: swap [branch-name]"
                echo "Tip: Set default branch with 'default_branch set <branch-name>'"
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
            echo "$(zmod_color yellow "⚠️  Branch '$branch_name' does not exist.")"
            echo -n "$(zmod_color yellow "Do you want to create it? (Y - default/n): ")"
            read confirmation
            if [[ -z "$confirmation" || "$confirmation" =~ ^[Yy]([Ee][Ss])?$ ]]; then
                echo "$(zmod_color green "🌱 Creating and switching to branch '$branch_name'...")"
                git switch -c "$branch_name"
            else
                echo "$(zmod_color red "❌ Operation canceled.")"
                echo "Available branches:"
                git branch --format="  %(refname:short)" | head -5
                return 1
            fi
        fi
    else
        git switch "$branch_name"
    fi
}

# Alias for compatibility
alias gco='git checkout'