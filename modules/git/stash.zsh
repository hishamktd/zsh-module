#!/usr/bin/env zsh
# Git stash commands

# Basic stash command
stash() {
    if ! zmod_is_git_repo; then
        echo "❌ Not a git repository"
        return 1
    fi
    
    local message="${1:-WIP: $(date)}"
    if [[ -n "$1" ]]; then
        git stash push -m "$message"
    else
        git stash push -m "$message"
    fi
}

# Basic apply command
apply() {
    if ! zmod_is_git_repo; then
        echo "❌ Not a git repository"
        return 1
    fi
    
    local stash_ref="${1:-stash@{0}}"
    git stash apply "$stash_ref"
}

# Git stash with message
gstash() {
    local message="${1:-WIP: $(date)}"
    git stash push -m "$message"
}

# Interactive stash manager
gstash-list() {
    if ! zmod_is_git_repo; then
        echo "❌ Not a git repository"
        return 1
    fi
    
    local stashes=$(git stash list)
    if [[ -z "$stashes" ]]; then
        echo "📦 No stashes found"
        return 0
    fi
    
    if zmod_has_command fzf; then
        local selected=$(echo "$stashes" | fzf --prompt="Select stash: " --preview="git stash show -p {1}")
        if [[ -n "$selected" ]]; then
            local stash_id=$(echo "$selected" | cut -d: -f1)
            echo "Selected: $selected"
            echo -n "Action [a]pply [p]op [d]rop [s]how: "
            read action
            case "$action" in
                a) git stash apply "$stash_id" ;;
                p) git stash pop "$stash_id" ;;
                d) git stash drop "$stash_id" ;;
                s) git stash show -p "$stash_id" ;;
                *) echo "❌ Invalid action" ;;
            esac
        fi
    else
        echo "$stashes"
    fi
}