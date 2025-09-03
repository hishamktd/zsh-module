#!/usr/bin/env zsh
# Ollama Provider for AI Module

# Ollama API call
ai_call_ollama() {
    local prompt="$1"
    local config_file="$2"
    
    if [[ ! -f "$config_file" ]]; then
        echo "❌ Ollama configuration not found: $config_file" >&2
        return 1
    fi
    
    source "$config_file"
    
    local base_url="${base_url:-http://localhost:11434}"
    local model="${model:-llama2}"
    
    if [[ -z "$model" ]]; then
        echo "❌ Ollama model not configured" >&2
        return 1
    fi
    
    curl -s -X POST "${base_url}/api/generate" \
        -H "Content-Type: application/json" \
        -d "{
            \"model\": \"${model}\",
            \"prompt\": $(printf '%s' "$prompt" | jq -R -s .),
            \"stream\": false,
            \"options\": {
                \"num_predict\": 150,
                \"temperature\": 0.7
            }
        }" | jq -r '.response' 2>/dev/null
}