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


# Initialize module
ai_init
ai_load_config