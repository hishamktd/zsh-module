#!/usr/bin/env zsh
# Remote repository utilities for Git module

# Get remote repository URL
get_remote_url() {
    local remote="${1:-origin}"
    local url=$(git config --get "remote.$remote.url")
    
    if [[ -z "$url" ]]; then
        return 1
    fi
    
    # Convert SSH URL to HTTPS for web browsing
    if [[ "$url" =~ ^git@ ]]; then
        # Convert git@github.com:user/repo.git to https://github.com/user/repo
        url=$(echo "$url" | sed 's/git@\([^:]*\):/https:\/\/\1\//' | sed 's/\.git$//')
    elif [[ "$url" =~ \.git$ ]]; then
        # Remove .git suffix from HTTPS URLs
        url=$(echo "$url" | sed 's/\.git$//')
    fi
    
    echo "$url"
}

# Get current branch's remote name
get_current_remote() {
    local current_branch=$(zmod_git_branch)
    if [[ -z "$current_branch" ]]; then
        echo "origin" # fallback to origin
        return 1
    fi
    
    local remote=$(git config --get "branch.$current_branch.remote")
    echo "${remote:-origin}"
}

# Check if current branch has upstream set
has_upstream() {
    local current_branch=$(zmod_git_branch)
    [[ -n "$current_branch" ]] && git config --get "branch.$current_branch.remote" >/dev/null
}