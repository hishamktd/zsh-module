#!/usr/bin/env zsh
# Commit - matches commit.ps1

commit() {
    local message="$1"
    local flags="$2"
    
    # If no message is provided, prompt the user to enter one
    if [[ -z "$message" ]]; then
        echo -n "Please enter a commit message: "
        read message
    fi
    
    # Stage all changes
    git add .
    
    # Ensure git add was successful
    if [[ $? -eq 0 ]]; then
        echo "$(zmod_color green 'Files staged successfully')"
        
        # Check if there are any changes to commit
        local status=$(git status --porcelain)
        if [[ -n "$status" ]]; then
            # Commit with the message and optional flags
            git commit -m "$message" $flags
            
            # Display commit success message
            if [[ $? -eq 0 ]]; then
                echo "$(zmod_color green 'Commit successful!')"
            fi
        else
            echo "$(zmod_color yellow 'No changes to commit. Working tree is clean.')"
        fi
    else
        echo "$(zmod_color red 'Failed to stage files for commit')"
    fi
}

# Alias for compatibility
alias gc='commit'