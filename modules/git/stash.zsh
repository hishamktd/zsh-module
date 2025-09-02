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

# Basic apply command - accepts stash ID or defaults to latest
apply() {
    if ! zmod_is_git_repo; then
        echo "❌ Not a git repository"
        return 1
    fi
    
    local stash_id="$1"
    if [[ -z "$stash_id" ]]; then
        # Default to most recent stash
        stash_id="stash@{0}"
    elif [[ "$stash_id" =~ ^[0-9]+$ ]]; then
        # If just a number, convert to stash@{N} format
        stash_id="stash@{$stash_id}"
    fi
    
    git stash apply "$stash_id"
}

# Interactive stash manager
stash-list() {
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
        local selected=$(echo "$stashes" | fzf \
            --prompt="Select stash (ESC to cancel): " \
            --preview="git stash show -p --color=always \$(echo {} | cut -d: -f1)" \
            --preview-window="right:60%:wrap" \
            --bind="ctrl-c:abort,esc:abort" \
            --ansi)
        
        if [[ -n "$selected" ]]; then
            local stash_id=$(echo "$selected" | cut -d: -f1)
            echo "Selected: $selected"
            echo -n "Action [a]pply [p]op [d]rop [s]how [c]ancel: "
            read -k 1 action
            echo  # Add newline after single character input
            
            case "$action" in
                a|A) 
                    echo "Applying stash $stash_id..."
                    git stash apply "$stash_id" 
                    ;;
                p|P) 
                    echo "Popping stash $stash_id..."
                    git stash pop "$stash_id" 
                    ;;
                d|D) 
                    echo "Dropping stash $stash_id..."
                    git stash drop "$stash_id" 
                    ;;
                s|S) 
                    git stash show -p "$stash_id" 
                    ;;
                c|C) 
                    echo "Cancelled"
                    return 0
                    ;;
                *) 
                    echo "❌ Invalid action. Cancelled."
                    return 1
                    ;;
            esac
        else
            echo "No stash selected. Cancelled."
            return 0
        fi
    else
        echo "$stashes"
    fi
}