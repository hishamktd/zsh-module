#!/usr/bin/env zsh
# OpenAI Provider for AI Module

# OpenAI API call
ai_call_openai() {
    local prompt="$1"
    local config_file="$2"
    
    if [[ ! -f "$config_file" ]]; then
        echo "❌ OpenAI configuration not found: $config_file" >&2
        return 1
    fi
    
    source "$config_file"
    
    local api_key="${api_key}"
    local model="${model:-gpt-3.5-turbo}"
    local base_url="${base_url:-https://api.openai.com/v1}"
    
    if [[ -z "$api_key" ]]; then
        echo "❌ OpenAI API key not configured" >&2
        return 1
    fi
    
    curl -s -X POST "${base_url}/chat/completions" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${api_key}" \
        -d "{
            \"model\": \"${model}\",
            \"messages\": [{\"role\": \"user\", \"content\": $(printf '%s' "$prompt" | jq -R -s .)}],
            \"max_tokens\": 150,
            \"temperature\": 0.7
        }" | jq -r '.choices[0].message.content' 2>/dev/null
}