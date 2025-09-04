#!/usr/bin/env zsh
# AI Module - Configurable AI Provider Management

# Configuration variables
export ZSH_MODULE_AI_PROVIDER=${ZSH_MODULE_AI_PROVIDER:-"openai"}
export ZSH_MODULE_DIR=${ZSH_MODULE_DIR:-"${0:A:h:h:h}"}
export ZSH_MODULE_AI_CONFIG_DIR="$ZSH_MODULE_DIR/config/ai"

# Supported AI providers
typeset -gA AI_PROVIDERS
AI_PROVIDERS=(
    "openai" "OpenAI GPT"
    "claude" "Anthropic Claude"
    "gemini" "Google Gemini"
    "ollama" "Ollama (Local)"
    "azure" "Azure OpenAI"
    "huggingface" "Hugging Face"
    "cohere" "Cohere"
    "grok" "xAI Grok"
    "deepseek" "DeepSeek AI"
)

# Provider configuration requirements
typeset -gA AI_CONFIG_KEYS
AI_CONFIG_KEYS=(
    "openai" "api_key,model,base_url"
    "claude" "api_key,model"
    "gemini" "api_key,model"
    "ollama" "base_url,model"
    "azure" "api_key,endpoint,deployment,api_version"
    "huggingface" "api_key,model"
    "cohere" "api_key,model"
    "grok" "api_key,model,base_url"
    "deepseek" "api_key,model,base_url"
)

# Load function modules
source "$ZSH_MODULE_DIR/modules/ai/functions/config.zsh"
source "$ZSH_MODULE_DIR/modules/ai/functions/management.zsh"
source "$ZSH_MODULE_DIR/modules/ai/functions/chat.zsh"
source "$ZSH_MODULE_DIR/modules/ai/functions/commit.zsh"

# Main AI command dispatcher
ai() {
    local command="${1:-status}"
    shift
    
    # Initialize on first run
    ai_init
    ai_load_config
    
    case "$command" in
        "list"|"ls")
            ai_list "$@"
            ;;
        "select"|"choose")
            ai_select "$@"
            ;;
        "config"|"configure")
            ai_config "$@"
            ;;
        "status"|"info")
            ai_status "$@"
            ;;
        "remove"|"rm")
            ai_remove "$@"
            ;;
        "get")
            ai_get_config "$@"
            ;;
        "chat")
            ai_chat "$@"
            ;;
        "commit-message")
            ai_commit_message "$@"
            ;;
        "commit-prompt")
            ai_commit_prompt_dispatcher "$@"
            ;;
        "help"|"-h"|"--help")
            cat << 'EOF'
🤖 AI Module Commands:

  ai list                    List all available AI providers
  ai select                  Interactive provider selection
  ai config [provider]       Configure AI provider (current if not specified)
  ai status                  Show current AI configuration
  ai remove [provider]       Remove provider configuration
  ai get [provider] [key]    Get configuration value
  ai chat "prompt"           Send a prompt to the configured AI provider
  ai commit-message          Generate commit message for staged changes
  ai commit-prompt show      Show current commit message prompt
  ai commit-prompt set-global "prompt"    Set global commit message prompt
  ai commit-prompt set-project "prompt"   Set project-level commit message prompt
  ai commit-prompt reset [global|project] Reset commit message prompt

Examples:
  ai list                    # Show all providers
  ai select                 # Interactive selection menu
  ai config openai          # Configure OpenAI
  ai config                 # Configure current provider
  ai get openai api_key     # Get OpenAI API key
  ai remove claude          # Remove Claude configuration
  ai chat "Explain git"     # Send prompt to AI
  ai commit-message         # Generate commit message

Documentation:
  Full docs: $ZSH_MODULE_DIR/modules/ai/README.md
  Quick ref: $ZSH_MODULE_DIR/modules/ai/QUICKSTART.md
EOF
            ;;
        *)
            # Treat unknown parameters as chat prompts
            ai_chat "$command $*"
            ;;
    esac
}

# Commit prompt command dispatcher
ai_commit_prompt_dispatcher() {
    local subcommand="${1:-show}"
    shift
    
    case "$subcommand" in
        "show"|"view")
            ai_show_commit_prompt
            ;;
        "set-global"|"global")
            if [[ $# -eq 0 ]]; then
                # No arguments - open editor by default
                ai_edit_global_commit_prompt
            else
                # Arguments provided - set directly
                ai_set_global_commit_prompt "$*"
            fi
            ;;
        "set-project"|"project")
            if [[ $# -eq 0 ]]; then
                # No arguments - open editor by default
                ai_edit_project_commit_prompt
            else
                # Arguments provided - set directly
                ai_set_project_commit_prompt "$*"
            fi
            ;;
        "text-global")
            if [[ $# -eq 0 ]]; then
                echo "❌ Please provide a commit message prompt" >&2
                echo "Usage: ai commit-prompt text-global \"Your custom prompt with {STAGED_STATUS} and {STAGED_DIFF} placeholders\"" >&2
                return 1
            fi
            ai_set_global_commit_prompt "$*"
            ;;
        "text-project")
            if [[ $# -eq 0 ]]; then
                echo "❌ Please provide a commit message prompt" >&2
                echo "Usage: ai commit-prompt text-project \"Your custom prompt with {STAGED_STATUS} and {STAGED_DIFF} placeholders\"" >&2
                return 1
            fi
            ai_set_project_commit_prompt "$*"
            ;;
        "edit-global"|"edit-g")
            ai_edit_global_commit_prompt
            ;;
        "edit-project"|"edit-p")
            ai_edit_project_commit_prompt
            ;;
        "reset"|"clear")
            ai_reset_commit_prompt "$@"
            ;;
        "help"|"-h"|"--help")
            cat << 'EOF'
🤖 AI Commit Prompt Management Commands:

  ai commit-prompt show                   Show current commit message prompt
  ai commit-prompt set-global [prompt]    Set global prompt (opens editor if no prompt given)
  ai commit-prompt set-project [prompt]   Set project prompt (opens editor if no prompt given)
  ai commit-prompt text-global "prompt"   Set global prompt directly from command line
  ai commit-prompt text-project "prompt"  Set project prompt directly from command line
  ai commit-prompt edit-global            Edit global commit message prompt in editor
  ai commit-prompt edit-project           Edit project-level commit message prompt in editor
  ai commit-prompt reset [global|project] Reset commit message prompt to default

Placeholders in custom prompts:
  {STAGED_STATUS} - Replaced with git diff --cached --name-status output
  {STAGED_DIFF}   - Replaced with git diff --cached output

Examples:
  ai commit-prompt show
  ai commit-prompt set-global           # Opens editor (default behavior)
  ai commit-prompt set-project          # Opens editor (default behavior)  
  ai commit-prompt set-global "Custom prompt: {STAGED_STATUS}"    # Direct text input
  ai commit-prompt text-global "Another way to set directly"      # Explicit text input
  ai commit-prompt edit-global          # Explicitly open editor
  ai commit-prompt reset global
  ai commit-prompt reset project
  ai commit-prompt reset both

Priority (highest to lowest):
  1. Project-level (.ai-commit-prompt file)
  2. Global configuration
  3. Built-in default prompt
EOF
            ;;
        *)
            echo "❌ Unknown subcommand: $subcommand" >&2
            echo "Run 'ai commit-prompt help' for usage information" >&2
            return 1
            ;;
    esac
}

# Initialize module
ai_init
ai_load_config