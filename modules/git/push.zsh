#!/usr/bin/env zsh
# Git push commands

# Helper function to copy text to clipboard
copy_to_clipboard() {
    local text="$1"
    
    # Detect clipboard utility
    if command -v pbcopy >/dev/null; then
        # macOS
        echo -n "$text" | pbcopy
        return 0
    elif command -v xclip >/dev/null; then
        # Linux with xclip
        echo -n "$text" | xclip -selection clipboard
        return 0
    elif command -v xsel >/dev/null; then
        # Linux with xsel
        echo -n "$text" | xsel --clipboard --input
        return 0
    elif command -v wl-copy >/dev/null; then
        # Wayland
        echo -n "$text" | timeout 3s wl-copy 2>/dev/null
        return 0
    else
        # No clipboard utility found
        return 1
    fi
}

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

# Git push with upstream
git_push_upstream() {
    local current_branch=$(zmod_git_branch)
    if [[ -z "$current_branch" ]]; then
        echo "❌ Not on any branch"
        return 1
    fi
    
    local push_success=false
    
    # Check if upstream is set
    if ! git config --get "branch.$current_branch.remote" >/dev/null; then
        echo "🚀 Setting upstream and pushing..."
        if git push --set-upstream origin "$current_branch"; then
            push_success=true
        fi
    else
        if git push; then
            push_success=true
        fi
    fi
    
    # If push was successful, copy remote URL to clipboard
    if [[ "$push_success" == true ]]; then
        local remote_url=$(get_remote_url)
        if [[ -n "$remote_url" ]]; then
            if copy_to_clipboard "$remote_url"; then
                echo "$(zmod_color green '📋 Remote URL copied to clipboard:') $remote_url"
            else
                echo "$(zmod_color yellow '🔗 Remote URL:') $remote_url"
                echo "$(zmod_color dim '(Clipboard utility not available)')"
            fi
        fi
    fi
}

# Simple push alias
push() {
    git_push_upstream "$@"
}

# Aliases
alias gpu='git_push_upstream'
alias gp='git_push_upstream'