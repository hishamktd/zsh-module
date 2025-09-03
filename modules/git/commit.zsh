#!/usr/bin/env zsh
# Commit - Enhanced with AI-generated commit messages

commit() {
    local message="$1"
    local flags=("${@:2}")
    local use_ai=false
    local edit_message=false
    
    # Parse flags
    local -a processed_flags
    for flag in "${flags[@]}"; do
        case "$flag" in
            "--ai"|"-a")
                use_ai=true
                ;;
            "--edit"|"-e")
                edit_message=true
                ;;
            *)
                processed_flags+=("$flag")
                ;;
        esac
    done
    
    # Check if there are staged changes
    local staged_status=$(git diff --cached --name-only)
    if [[ -z "$staged_status" ]]; then
        echo "$(zmod_color yellow 'No staged changes found.')"
        echo "Stage files first with: git add <files>"
        echo "Or stage all changes with: git add ."
        return 1
    fi
    
    # Generate AI message if requested and no message provided
    if [[ "$use_ai" == true ]] && [[ -z "$message" ]]; then
        message=$(ai_commit_message)
        if [[ $? -ne 0 ]] || [[ -z "$message" ]]; then
            echo "$(zmod_color red 'Failed to generate AI commit message')"
            echo -n "Please enter a commit message manually: "
            read message
        else
            echo "$(zmod_color green '✨ Generated commit message:') $message"
        fi
    fi
    
    # If no message is provided, prompt the user to enter one
    if [[ -z "$message" ]]; then
        echo -n "Please enter a commit message: "
        read message
    fi
    
    # Allow editing the message if requested
    if [[ "$edit_message" == true ]]; then
        local temp_file=$(mktemp)
        echo "$message" > "$temp_file"
        
        # Use editor preference: VISUAL, then EDITOR, then nano
        local editor="${VISUAL:-${EDITOR:-nano}}"
        
        echo "Opening editor to modify commit message..."
        if $editor "$temp_file"; then
            message=$(cat "$temp_file")
            rm "$temp_file"
            
            # Remove empty lines and trim
            message=$(echo "$message" | sed '/^[[:space:]]*$/d' | head -1)
            
            if [[ -z "$message" ]]; then
                echo "$(zmod_color red 'Empty commit message. Aborting commit.')"
                return 1
            fi
        else
            rm "$temp_file"
            echo "$(zmod_color red 'Editor failed. Aborting commit.')"
            return 1
        fi
    fi
    
    echo "$(zmod_color blue 'Staged changes:')"
    git diff --cached --name-status
    
    echo ""
    echo "$(zmod_color green 'Commit message:') $message"
    
    # Commit with the message and optional flags
    git commit -m "$message" "${processed_flags[@]}"
    
    # Display commit success message
    if [[ $? -eq 0 ]]; then
        echo "$(zmod_color green 'Commit successful!')"
    fi
}

# Alias for compatibility
alias gc='commit'