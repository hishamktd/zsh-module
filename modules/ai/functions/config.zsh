#!/usr/bin/env zsh
# AI Configuration Management Functions

# Initialize AI config directory
ai_init() {
    mkdir -p "$ZSH_MODULE_AI_CONFIG_DIR"
    
    # Create default config if it doesn't exist
    local config_file="$ZSH_MODULE_AI_CONFIG_DIR/config.conf"
    if [[ ! -f "$config_file" ]]; then
        cat > "$config_file" << 'EOF'
# AI Module Configuration
# Default provider
ZSH_MODULE_AI_PROVIDER=openai

# Provider configurations will be stored in separate files
EOF
    fi
}

# Save main configuration
ai_save_config() {
    local config_file="$ZSH_MODULE_AI_CONFIG_DIR/config.conf"
    
    cat > "$config_file" << EOF
# AI Module Configuration
# Generated: $(date)

# Default provider
ZSH_MODULE_AI_PROVIDER=$ZSH_MODULE_AI_PROVIDER

# Global commit message prompt template
# ZSH_MODULE_AI_COMMIT_PROMPT="Custom global commit prompt template..."
EOF
}

# Load configuration
ai_load_config() {
    local config_file="$ZSH_MODULE_AI_CONFIG_DIR/config.conf"
    
    if [[ -f "$config_file" ]]; then
        source "$config_file"
    fi
}

# Get provider configuration
ai_get_config() {
    local provider="${1:-$ZSH_MODULE_AI_PROVIDER}"
    local key="$2"
    local config_file="$ZSH_MODULE_AI_CONFIG_DIR/$provider.conf"
    
    if [[ ! -f "$config_file" ]]; then
        echo "❌ Provider $provider is not configured" >&2
        return 1
    fi
    
    if [[ -n "$key" ]]; then
        grep "^${key}=" "$config_file" 2>/dev/null | cut -d'=' -f2- | tr -d '"'
    else
        cat "$config_file"
    fi
}

# Get commit message prompt (project-level takes precedence over global)
ai_get_commit_prompt() {
    local default_prompt="Analyze the following git diff and generate a concise, conventional commit message. 

Use conventional commit format: type(scope): description
Types: feat, fix, docs, style, refactor, test, chore
Keep description under 72 characters.

Staged changes:
{STAGED_STATUS}

Git diff:
{STAGED_DIFF}

Generate only the commit message, no explanation:"
    
    # Check for project-level prompt in git config directory first
    if zmod_is_git_repo; then
        local project_name=$(basename "$(git rev-parse --show-toplevel)")
        local config_directory="$HOME/.zsh-modules/git-config"
        local config_file="$config_directory/$project_name.conf"
        local prompt_file="$config_directory/$project_name-commit-prompt.txt"
        
        # Check for prompt in the config file first
        if [[ -f "$config_file" ]]; then
            local project_prompt=$(grep "^ai_commit_prompt=" "$config_file" 2>/dev/null | cut -d= -f2-)
            if [[ -n "$project_prompt" ]]; then
                # Convert escaped newlines back to actual newlines
                echo "$project_prompt" | sed 's/\\n/\n/g'
                return 0
            fi
        fi
        
        # Check for separate prompt file
        if [[ -f "$prompt_file" ]]; then
            # Read entire file, removing comment lines
            grep -v '^[[:space:]]*#' "$prompt_file" | sed '/^[[:space:]]*$/d'
            return 0
        fi
    fi
    
    # Check for global prompt in configuration
    local global_prompt="${ZSH_MODULE_AI_COMMIT_PROMPT:-}"
    if [[ -n "$global_prompt" ]]; then
        # Convert escaped newlines back to actual newlines
        echo "$global_prompt" | sed 's/\\n/\n/g'
        return 0
    fi
    
    # Return default prompt
    echo "$default_prompt"
}

# Set global commit message prompt
ai_set_global_commit_prompt() {
    local prompt="$*"
    
    if [[ -z "$prompt" ]]; then
        echo "❌ Please provide a commit message prompt" >&2
        return 1
    fi
    
    # Update the global variable (for single-line, escape newlines for config)
    local config_prompt=$(echo "$prompt" | tr '\n' '\\n')
    export ZSH_MODULE_AI_COMMIT_PROMPT="$config_prompt"
    
    # Update config file
    local config_file="$ZSH_MODULE_AI_CONFIG_DIR/config.conf"
    local temp_file="$config_file.tmp"
    
    # Remove existing prompt line and add new one
    grep -v "^ZSH_MODULE_AI_COMMIT_PROMPT=" "$config_file" > "$temp_file" 2>/dev/null || true
    echo "ZSH_MODULE_AI_COMMIT_PROMPT=\"$config_prompt\"" >> "$temp_file"
    mv "$temp_file" "$config_file"
    
    echo "✅ Global commit message prompt updated"
}

# Set project-level commit message prompt
ai_set_project_commit_prompt() {
    local prompt="$*"
    
    if [[ -z "$prompt" ]]; then
        echo "❌ Please provide a commit message prompt" >&2
        return 1
    fi
    
    if ! zmod_is_git_repo; then
        echo "❌ Not inside a git repository."
        return 1
    fi
    
    # Get the project name from the Git repository's root directory
    local project_name=$(basename "$(git rev-parse --show-toplevel)")
    local config_directory="$HOME/.zsh-modules/git-config"
    local config_file="$config_directory/$project_name.conf"
    local prompt_file="$config_directory/$project_name-commit-prompt.txt"
    
    # Ensure the config directory exists
    if [[ ! -d "$config_directory" ]]; then
        mkdir -p "$config_directory"
    fi
    
    # Write prompt to separate file with header comment
    cat > "$prompt_file" << EOF
# AI Commit Message Prompt for $project_name
# This file supports multi-line prompts
# Available placeholders: {STAGED_STATUS}, {STAGED_DIFF}
# Generated on $(date)

$prompt
EOF
    
    echo "✅ Project commit message prompt saved to $prompt_file"
    echo "📁 Project: $project_name"
}

# Show current commit message prompt
ai_show_commit_prompt() {
    echo "🤖 Current Commit Message Prompt Configuration:"
    echo
    
    # Check project-level configuration
    if zmod_is_git_repo; then
        local project_name=$(basename "$(git rev-parse --show-toplevel)")
        local config_directory="$HOME/.zsh-modules/git-config"
        local config_file="$config_directory/$project_name.conf"
        local prompt_file="$config_directory/$project_name-commit-prompt.txt"
        
        # Check for prompt in config file
        if [[ -f "$config_file" ]] && grep -q "^ai_commit_prompt=" "$config_file" 2>/dev/null; then
            echo "📁 Using project-level prompt from config: $config_file"
            echo "─────────────────────────────────────────────────"
            local project_prompt=$(grep "^ai_commit_prompt=" "$config_file" | cut -d= -f2-)
            echo "$project_prompt" | sed 's/\\n/\n/g'
            echo
            echo "─────────────────────────────────────────────────"
        # Check for separate prompt file
        elif [[ -f "$prompt_file" ]]; then
            echo "📁 Using project-level prompt from: $prompt_file"
            echo "─────────────────────────────────────────────────"
            grep -v '^[[:space:]]*#' "$prompt_file" | sed '/^[[:space:]]*$/d'
            echo
            echo "─────────────────────────────────────────────────"
        # Check for legacy .ai-commit-prompt file
        elif [[ -f ".ai-commit-prompt" ]]; then
            echo "📁 Using legacy project-level prompt from: .ai-commit-prompt"
            echo "💡 Consider migrating to the new location with: ai commit-prompt set-project"
            echo "─────────────────────────────────────────────────"
            cat ".ai-commit-prompt"
            echo
            echo "─────────────────────────────────────────────────"
        elif [[ -n "${ZSH_MODULE_AI_COMMIT_PROMPT:-}" ]]; then
            echo "🌍 Using global prompt from configuration"
            echo "─────────────────────────────────────────────────"
            echo "$ZSH_MODULE_AI_COMMIT_PROMPT" | sed 's/\\n/\n/g'
            echo
            echo "─────────────────────────────────────────────────"
        else
            echo "⚙️ Using default built-in prompt"
            echo "─────────────────────────────────────────────────"
            ai_get_commit_prompt
            echo
            echo "─────────────────────────────────────────────────"
        fi
    elif [[ -n "${ZSH_MODULE_AI_COMMIT_PROMPT:-}" ]]; then
        echo "🌍 Using global prompt from configuration"
        echo "─────────────────────────────────────────────────"
        echo "$ZSH_MODULE_AI_COMMIT_PROMPT" | sed 's/\\n/\n/g'
        echo
        echo "─────────────────────────────────────────────────"
    else
        echo "⚙️ Using default built-in prompt"
        echo "─────────────────────────────────────────────────"
        ai_get_commit_prompt
        echo
        echo "─────────────────────────────────────────────────"
    fi
    
    echo
    echo "💡 Configuration options:"
    echo "  • Set global prompt: ai commit-prompt set-global \"<prompt>\""
    echo "  • Set project prompt: ai commit-prompt set-project \"<prompt>\""
    echo "  • View current prompt: ai commit-prompt show"
    echo "  • Reset to default: ai commit-prompt reset [global|project]"
    
    if zmod_is_git_repo; then
        local project_name=$(basename "$(git rev-parse --show-toplevel)")
        echo "  • Config location: $HOME/.zsh-modules/git-config/$project_name-commit-prompt.txt"
    fi
}

# Reset commit message prompt
ai_reset_commit_prompt() {
    local level="${1:-both}"
    
    case "$level" in
        "global")
            # Remove from config file
            local config_file="$ZSH_MODULE_AI_CONFIG_DIR/config.conf"
            local temp_file="$config_file.tmp"
            grep -v "^ZSH_MODULE_AI_COMMIT_PROMPT=" "$config_file" > "$temp_file" 2>/dev/null || true
            mv "$temp_file" "$config_file"
            unset ZSH_MODULE_AI_COMMIT_PROMPT
            echo "✅ Global commit message prompt reset to default"
            ;;
        "project")
            if zmod_is_git_repo; then
                local project_name=$(basename "$(git rev-parse --show-toplevel)")
                local config_directory="$HOME/.zsh-modules/git-config"
                local config_file="$config_directory/$project_name.conf"
                local prompt_file="$config_directory/$project_name-commit-prompt.txt"
                local legacy_file=".ai-commit-prompt"
                
                local removed_any=false
                
                # Remove from config file if present
                if [[ -f "$config_file" ]] && grep -q "^ai_commit_prompt=" "$config_file" 2>/dev/null; then
                    sed -i "/^ai_commit_prompt=/d" "$config_file"
                    echo "✅ Removed project commit prompt from config file"
                    removed_any=true
                fi
                
                # Remove separate prompt file if present
                if [[ -f "$prompt_file" ]]; then
                    rm "$prompt_file"
                    echo "✅ Removed project commit prompt file: $prompt_file"
                    removed_any=true
                fi
                
                # Remove legacy file if present
                if [[ -f "$legacy_file" ]]; then
                    rm "$legacy_file"
                    echo "✅ Removed legacy commit prompt file: $legacy_file"
                    removed_any=true
                fi
                
                if ! $removed_any; then
                    echo "ℹ️ No project-level prompt configuration found"
                fi
            else
                echo "❌ Not inside a git repository"
            fi
            ;;
        "both"|"")
            ai_reset_commit_prompt "global"
            ai_reset_commit_prompt "project"
            ;;
        *)
            echo "❌ Invalid level. Use: global, project, or both" >&2
            return 1
            ;;
    esac
}

# Edit global commit message prompt in editor
ai_edit_global_commit_prompt() {
    local editor="${EDITOR:-nano}"
    local temp_file=$(mktemp)
    local config_file="$ZSH_MODULE_AI_CONFIG_DIR/config.conf"
    
    # Get current global prompt or default
    local current_prompt="${ZSH_MODULE_AI_COMMIT_PROMPT:-}"
    if [[ -z "$current_prompt" ]]; then
        current_prompt="Generate a short commit message based on these changes: {STAGED_STATUS}. Use conventional commits format."
    fi
    
    # Write current prompt to temp file with helpful comments
    cat > "$temp_file" << EOF
# Global AI Commit Message Prompt
# This prompt will be used for all projects unless overridden by a project-specific prompt
# 
# Available placeholders:
#   {STAGED_STATUS} - Replaced with: git diff --cached --name-status
#   {STAGED_DIFF}   - Replaced with: git diff --cached
#
# Example prompts:
#   "Generate a concise commit message for: {STAGED_STATUS}"
#   "Based on {STAGED_DIFF}, create a conventional commit message"
#   "Analyze the changes and write a commit message: {STAGED_STATUS}"
#
# Edit the prompt below (remove these comments when done):

$current_prompt
EOF
    
    echo "🖊️  Opening global commit prompt in $editor..."
    echo "💡 Available placeholders: {STAGED_STATUS}, {STAGED_DIFF}"
    
    # Open editor
    if $editor "$temp_file"; then
        # Read the edited content, removing comment lines and preserving multi-line
        local new_prompt=$(grep -v '^[[:space:]]*#' "$temp_file" | sed '/^[[:space:]]*$/d')
        
        if [[ -n "$new_prompt" ]]; then
            ai_set_global_commit_prompt "$new_prompt"
        else
            echo "❌ No prompt entered, global prompt unchanged"
        fi
    else
        echo "❌ Editor cancelled, global prompt unchanged"
    fi
    
    rm -f "$temp_file"
}

# Edit project-level commit message prompt in editor
ai_edit_project_commit_prompt() {
    local editor="${EDITOR:-nano}"
    local temp_file=$(mktemp)
    
    if ! zmod_is_git_repo; then
        echo "❌ Not inside a git repository."
        rm -f "$temp_file"
        return 1
    fi
    
    local project_name=$(basename "$(git rev-parse --show-toplevel)")
    local config_directory="$HOME/.zsh-modules/git-config"
    local config_file="$config_directory/$project_name.conf"
    local prompt_file="$config_directory/$project_name-commit-prompt.txt"
    local legacy_file=".ai-commit-prompt"
    
    # Get current project prompt or default
    local current_prompt=""
    
    # Check for prompt in config file
    if [[ -f "$config_file" ]] && grep -q "^ai_commit_prompt=" "$config_file" 2>/dev/null; then
        local project_prompt=$(grep "^ai_commit_prompt=" "$config_file" | cut -d= -f2-)
        current_prompt=$(echo "$project_prompt" | sed 's/\\n/\n/g')
    # Check for separate prompt file
    elif [[ -f "$prompt_file" ]]; then
        current_prompt=$(grep -v '^[[:space:]]*#' "$prompt_file" | sed '/^[[:space:]]*$/d')
    # Check for legacy file
    elif [[ -f "$legacy_file" ]]; then
        current_prompt=$(grep -v '^[[:space:]]*#' "$legacy_file" | sed '/^[[:space:]]*$/d')
        echo "💡 Found legacy prompt file. Will migrate to new location after editing."
    else
        current_prompt="Generate a commit message for this project based on: {STAGED_STATUS}. Include scope if appropriate."
    fi
    
    # Write current prompt to temp file with helpful comments
    cat > "$temp_file" << EOF
# Project-Level AI Commit Message Prompt
# This prompt will be used for this project only and overrides the global prompt
# File: $project_prompt_file
#
# Available placeholders:
#   {STAGED_STATUS} - Replaced with: git diff --cached --name-status
#   {STAGED_DIFF}   - Replaced with: git diff --cached
#
# Project context: $(basename $(pwd))
# 
# Example project-specific prompts:
#   "Create a commit for this React app: {STAGED_STATUS}"
#   "Generate a commit message for this API project: {STAGED_DIFF}"
#   "Write a conventional commit for this CLI tool: {STAGED_STATUS}"
#
# Edit the prompt below (remove these comments when done):

$current_prompt
EOF
    
    echo "🖊️  Opening project commit prompt in $editor..."
    echo "📁 Project: $(basename $(pwd))"
    echo "💡 Available placeholders: {STAGED_STATUS}, {STAGED_DIFF}"
    
    # Open editor
    if $editor "$temp_file"; then
        # Read the edited content, removing comment lines and preserving multi-line
        local new_prompt=$(grep -v '^[[:space:]]*#' "$temp_file" | sed '/^[[:space:]]*$/d')
        
        if [[ -n "$new_prompt" ]]; then
            ai_set_project_commit_prompt "$new_prompt"
        else
            echo "❌ No prompt entered, project prompt unchanged"
        fi
    else
        echo "❌ Editor cancelled, project prompt unchanged"
    fi
    
    rm -f "$temp_file"
}