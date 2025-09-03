#!/usr/bin/env zsh
# AI Chat Function

# General AI chat function
ai_chat() {
    local prompt="$1"
    local provider="${2:-$ZSH_MODULE_AI_PROVIDER}"
    local config_file="$ZSH_MODULE_AI_CONFIG_DIR/$provider.conf"
    
    if [[ ! -f "$config_file" ]]; then
        echo "❌ AI provider $provider not configured. Run 'ai config' to set up." >&2
        return 1
    fi
    
    if [[ -z "$prompt" ]]; then
        echo "❌ No prompt provided." >&2
        return 1
    fi
    
    # Load the appropriate provider
    case "$provider" in
        "openai")
            source "$ZSH_MODULE_DIR/modules/ai/providers/openai.zsh"
            ai_call_openai "$prompt" "$config_file"
            ;;
        "claude")
            source "$ZSH_MODULE_DIR/modules/ai/providers/claude.zsh"
            ai_call_claude "$prompt" "$config_file"
            ;;
        "gemini")
            source "$ZSH_MODULE_DIR/modules/ai/providers/gemini.zsh"
            ai_call_gemini "$prompt" "$config_file"
            ;;
        "ollama")
            source "$ZSH_MODULE_DIR/modules/ai/providers/ollama.zsh"
            ai_call_ollama "$prompt" "$config_file"
            ;;
        "grok")
            source "$ZSH_MODULE_DIR/modules/ai/providers/grok.zsh"
            ai_call_grok "$prompt" "$config_file"
            ;;
        "deepseek")
            source "$ZSH_MODULE_DIR/modules/ai/providers/deepseek.zsh"
            ai_call_deepseek "$prompt" "$config_file"
            ;;
        *)
            echo "❌ Provider $provider not implemented" >&2
            return 1
            ;;
    esac
}