#!/usr/bin/env zsh
# AI Commit Message Generation Function

# Load chat functionality
source "$ZSH_MODULE_DIR/modules/ai/functions/chat.zsh"

# Generate commit message using AI
ai_commit_message() {
    local provider="${ZSH_MODULE_AI_PROVIDER:-openai}"
    
    # Get staged changes
    local staged_diff=$(git diff --cached)
    local staged_status=$(git diff --cached --name-status)
    
    if [[ -z "$staged_diff" ]]; then
        echo "❌ No staged changes found. Stage files first with 'git add'." >&2
        return 1
    fi
    
    echo "🤖 Generating commit message using $provider..." >&2
    
    # Get configurable prompt template
    local prompt_template=$(ai_get_commit_prompt)
    
    # Replace placeholders in the prompt template
    local prompt="${prompt_template/\{STAGED_STATUS\}/$staged_status}"
    prompt="${prompt/\{STAGED_DIFF\}/$staged_diff}"
    
    local result=$(ai_chat "$prompt" "$provider")
    
    # If AI call failed, generate a simple fallback message
    if [[ $? -ne 0 ]] || [[ -z "$result" ]] || [[ "$result" == "null" ]]; then
        echo "⚠️ AI provider failed, generating fallback message..." >&2
        
        # Count file changes
        local added_files=$(echo "$staged_status" | grep "^A" | wc -l)
        local modified_files=$(echo "$staged_status" | grep "^M" | wc -l) 
        local deleted_files=$(echo "$staged_status" | grep "^D" | wc -l)
        
        # Generate simple commit message based on changes
        local message=""
        if [[ $added_files -gt 0 ]] && [[ $modified_files -gt 0 ]]; then
            local add_text="file"; [[ $added_files -gt 1 ]] && add_text="files"
            local mod_text="file"; [[ $modified_files -gt 1 ]] && mod_text="files"
            message="feat: Add $added_files $add_text and update $modified_files $mod_text"
        elif [[ $added_files -gt 0 ]]; then
            local add_text="file"; [[ $added_files -gt 1 ]] && add_text="files"
            message="feat: Add $added_files new $add_text"
        elif [[ $modified_files -gt 0 ]]; then
            local mod_text="file"; [[ $modified_files -gt 1 ]] && mod_text="files"
            message="fix: Update $modified_files $mod_text"
        elif [[ $deleted_files -gt 0 ]]; then
            local del_text="file"; [[ $deleted_files -gt 1 ]] && del_text="files"
            message="chore: Remove $deleted_files $del_text"
        else
            message="chore: Update project files"
        fi
        
        echo "$message"
    else
        echo "$result"
    fi
}