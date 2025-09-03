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
    
    # Create prompt for AI
    local prompt="Analyze the following git diff and generate a concise, conventional commit message. 

Use conventional commit format: type(scope): description
Types: feat, fix, docs, style, refactor, test, chore
Keep description under 72 characters.

Staged changes:
$staged_status

Git diff:
$staged_diff

Generate only the commit message, no explanation:"
    
    ai_chat "$prompt" "$provider"
}