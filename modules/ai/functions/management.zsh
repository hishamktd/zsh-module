#!/usr/bin/env zsh
# AI Provider Management Functions

# Load config functions
source "$ZSH_MODULE_DIR/modules/ai/functions/config.zsh"

# List all available AI providers
ai_list() {
    local current_provider="$ZSH_MODULE_AI_PROVIDER"
    
    echo "🤖 Available AI Providers:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    for provider in ${(ko)AI_PROVIDERS}; do
        local description="${AI_PROVIDERS[$provider]}"
        local config_status="❌"
        local marker=""
        
        # Check if provider is configured
        if [[ -f "$ZSH_MODULE_AI_CONFIG_DIR/$provider.conf" ]]; then
            config_status="✅"
        fi
        
        # Mark current provider
        if [[ "$provider" == "$current_provider" ]]; then
            marker=" (current)"
        fi
        
        printf "  %s %-12s %s%s\n" "$config_status" "$provider" "$description" "$marker"
    done
    
    echo ""
    echo "Legend: ✅ Configured | ❌ Not configured"
}

# Interactive provider selection
ai_select() {
    echo "🤖 Select AI Provider:"
    echo "━━━━━━━━━━━━━━━━━━━━━━"
    
    local -a providers
    local -a descriptions
    local i=1
    
    for provider in ${(ko)AI_PROVIDERS}; do
        providers+="$provider"
        descriptions+="${AI_PROVIDERS[$provider]}"
        
        local config_status="❌"
        if [[ -f "$ZSH_MODULE_AI_CONFIG_DIR/$provider.conf" ]]; then
            config_status="✅"
        fi
        
        printf "%2d. %s %-12s %s\n" $i "$config_status" "$provider" "${AI_PROVIDERS[$provider]}"
        ((i++))
    done
    
    echo ""
    echo -n "Enter selection (1-${#providers}): "
    read selection
    
    if [[ "$selection" =~ ^[0-9]+$ ]] && [[ $selection -ge 1 ]] && [[ $selection -le ${#providers} ]]; then
        local selected_provider="${providers[$selection]}"
        
        # Set as current provider
        export ZSH_MODULE_AI_PROVIDER="$selected_provider"
        
        # Update config file
        ai_save_config
        
        echo "✅ Selected provider: $selected_provider (${AI_PROVIDERS[$selected_provider]})"
        
        # Check if provider is configured, offer to configure if not
        if [[ ! -f "$ZSH_MODULE_AI_CONFIG_DIR/$selected_provider.conf" ]]; then
            echo ""
            echo "⚠️  Provider not configured. Run 'ai config $selected_provider' to configure it."
        fi
    else
        echo "❌ Invalid selection"
        return 1
    fi
}

# Configure AI provider
ai_config() {
    local provider="${1:-$ZSH_MODULE_AI_PROVIDER}"
    
    if [[ -z "${AI_PROVIDERS[$provider]}" ]]; then
        echo "❌ Unknown provider: $provider"
        echo "Available providers: ${(k)AI_PROVIDERS}"
        return 1
    fi
    
    local config_file="$ZSH_MODULE_AI_CONFIG_DIR/$provider.conf"
    local config_keys="${AI_CONFIG_KEYS[$provider]}"
    
    echo "🔧 Configuring ${AI_PROVIDERS[$provider]} ($provider)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Create config file
    cat > "$config_file" << EOF
# ${AI_PROVIDERS[$provider]} Configuration
# Provider: $provider
# Generated: $(date)

EOF
    
    # Configure each required key
    IFS=',' read -rA keys <<< "$config_keys"
    for key in "${keys[@]}"; do
        local current_value=""
        
        # Load existing value if config exists
        if [[ -f "$config_file" ]]; then
            current_value=$(grep "^${key}=" "$config_file" 2>/dev/null | cut -d'=' -f2- | tr -d '"')
        fi
        
        # Show current value if exists
        if [[ -n "$current_value" ]]; then
            echo -n "$key (current: $current_value): "
        else
            echo -n "$key: "
        fi
        
        read value
        
        # Use current value if empty input
        if [[ -z "$value" ]] && [[ -n "$current_value" ]]; then
            value="$current_value"
        fi
        
        # Add to config file
        echo "${key}=\"${value}\"" >> "$config_file"
    done
    
    echo ""
    echo "✅ Configuration saved to $config_file"
    
    # Set as current provider if not already
    if [[ "$ZSH_MODULE_AI_PROVIDER" != "$provider" ]]; then
        echo -n "Set as default provider? (y/N): "
        read set_default
        if [[ "$set_default" =~ ^[Yy]$ ]]; then
            export ZSH_MODULE_AI_PROVIDER="$provider"
            ai_save_config
            echo "✅ Set $provider as default provider"
        fi
    fi
}

# Show current configuration
ai_status() {
    local provider="$ZSH_MODULE_AI_PROVIDER"
    local config_file="$ZSH_MODULE_AI_CONFIG_DIR/$provider.conf"
    
    echo "🤖 AI Module Status:"
    echo "━━━━━━━━━━━━━━━━━━━━━━"
    echo "Current Provider: $provider (${AI_PROVIDERS[$provider]:-Unknown})"
    echo "Config Directory: $ZSH_MODULE_AI_CONFIG_DIR"
    
    if [[ -f "$config_file" ]]; then
        echo "Configuration: ✅ Configured"
        echo ""
        echo "Settings:"
        while IFS='=' read -r key value; do
            [[ "$key" =~ ^[[:space:]]*# ]] && continue
            [[ -z "$key" ]] && continue
            
            # Mask sensitive values
            if [[ "$key" == "api_key" ]]; then
                local masked_value="${value:0:8}...${value: -4}"
                echo "  $key: $masked_value"
            else
                echo "  $key: $value"
            fi
        done < "$config_file" | grep -v '^[[:space:]]*$'
    else
        echo "Configuration: ❌ Not configured"
        echo ""
        echo "Run 'ai config' to configure the current provider."
    fi
}

# Remove provider configuration
ai_remove() {
    local provider="${1:-$ZSH_MODULE_AI_PROVIDER}"
    
    if [[ -z "${AI_PROVIDERS[$provider]}" ]]; then
        echo "❌ Unknown provider: $provider"
        return 1
    fi
    
    local config_file="$ZSH_MODULE_AI_CONFIG_DIR/$provider.conf"
    
    if [[ ! -f "$config_file" ]]; then
        echo "❌ Provider $provider is not configured"
        return 1
    fi
    
    echo -n "Remove configuration for $provider (${AI_PROVIDERS[$provider]})? (y/N): "
    read confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        rm "$config_file"
        echo "✅ Removed configuration for $provider"
        
        # If this was the current provider, reset to default
        if [[ "$ZSH_MODULE_AI_PROVIDER" == "$provider" ]]; then
            export ZSH_MODULE_AI_PROVIDER="openai"
            ai_save_config
            echo "⚠️  Reset default provider to openai"
        fi
    else
        echo "❌ Cancelled"
    fi
}