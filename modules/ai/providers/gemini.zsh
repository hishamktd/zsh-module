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
    
    local response=$(curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${api_key}" \
        -H "Content-Type: application/json" \
        -d "{
            \"contents\": [{
                \"parts\": [{\"text\": $(printf '%s' "$prompt" | jq -R -s .)}]
            }],
            \"generationConfig\": {
                \"maxOutputTokens\": 150,
                \"temperature\": 0.7
            }
        }")
    
    # Check for errors
    local error_message=$(echo "$response" | jq -r '.error.message' 2>/dev/null)
    if [[ "$error_message" != "null" ]] && [[ -n "$error_message" ]]; then
        echo "❌ Gemini API error: $error_message" >&2
        return 1
    fi
    
    # Extract the text response
    local result=$(echo "$response" | jq -r '.candidates[0].content.parts[0].text' 2>/dev/null)
    
    # Check if result is null or empty
    if [[ "$result" == "null" ]] || [[ -z "$result" ]]; then
        echo "❌ Gemini returned empty response" >&2
        return 1
    fi
    
    echo "$result"
}