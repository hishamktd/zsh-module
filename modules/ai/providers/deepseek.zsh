#!/usr/bin/env zsh
# DeepSeek Provider for AI Module

# DeepSeek API call
ai_call_deepseek() {
    local prompt="$1"
    local config_file="$2"
    
    if [[ ! -f "$config_file" ]]; then
        echo "❌ DeepSeek configuration not found: $config_file" >&2
        return 1
    fi
    
    source "$config_file"
    
    local api_key="${api_key}"
    local model="${model:-deepseek-chat}"
    local base_url="${base_url:-https://api.deepseek.com/v1}"
    
    if [[ -z "$api_key" ]]; then
        echo "❌ DeepSeek API key not configured" >&2
        return 1
    fi
    
    local response=$(curl -s -X POST "${base_url}/chat/completions" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${api_key}" \
        -d "{
            \"model\": \"${model}\",
            \"messages\": [{\"role\": \"user\", \"content\": $(printf '%s' "$prompt" | jq -R -s .)}],
            \"max_tokens\": 150,
            \"temperature\": 0.7
        }")
    
    # Check for errors
    local error_message=$(echo "$response" | jq -r '.error.message' 2>/dev/null)
    if [[ "$error_message" != "null" ]] && [[ -n "$error_message" ]]; then
        echo "❌ DeepSeek API error: $error_message" >&2
        return 1
    fi
    
    # Extract the text response
    local result=$(printf '%s' "$response" | jq -r '.choices[0].message.content' 2>/dev/null)
    
    # Check if result is null or empty
    if [[ "$result" == "null" ]] || [[ -z "$result" ]]; then
        echo "❌ DeepSeek returned empty response" >&2
        return 1
    fi
    
    # Trim whitespace and newlines
    result=$(echo "$result" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    
    echo "$result"
}