#!/usr/bin/env zsh
# Gemini Provider for AI Module

# Gemini API call
ai_call_gemini() {
    local prompt="$1"
    local config_file="$2"
    
    if [[ ! -f "$config_file" ]]; then
        echo "❌ Gemini configuration not found: $config_file" >&2
        return 1
    fi
    
    source "$config_file"
    
    local api_key="${api_key}"
    local model="${model:-gemini-pro}"
    
    if [[ -z "$api_key" ]]; then
        echo "❌ Gemini API key not configured" >&2
        return 1
    fi
    
    curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${api_key}" \
        -H "Content-Type: application/json" \
        -d "{
            \"contents\": [{
                \"parts\": [{\"text\": $(printf '%s' "$prompt" | jq -R -s .)}]
            }],
            \"generationConfig\": {
                \"maxOutputTokens\": 150,
                \"temperature\": 0.7
            }
        }" | jq -r '.candidates[0].content.parts[0].text' 2>/dev/null
}