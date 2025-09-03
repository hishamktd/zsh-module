#!/usr/bin/env zsh
# Claude Provider for AI Module

# Claude API call
ai_call_claude() {
    local prompt="$1"
    local config_file="$2"
    
    if [[ ! -f "$config_file" ]]; then
        echo "❌ Claude configuration not found: $config_file" >&2
        return 1
    fi
    
    source "$config_file"
    
    local api_key="${api_key}"
    local model="${model:-claude-3-sonnet-20240229}"
    
    if [[ -z "$api_key" ]]; then
        echo "❌ Claude API key not configured" >&2
        return 1
    fi
    
    curl -s -X POST "https://api.anthropic.com/v1/messages" \
        -H "Content-Type: application/json" \
        -H "x-api-key: ${api_key}" \
        -H "anthropic-version: 2023-06-01" \
        -d "{
            \"model\": \"${model}\",
            \"max_tokens\": 150,
            \"messages\": [{\"role\": \"user\", \"content\": $(printf '%s' "$prompt" | jq -R -s .)}]
        }" | jq -r '.content[0].text' 2>/dev/null
}