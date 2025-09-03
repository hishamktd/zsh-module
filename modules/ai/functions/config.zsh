#!/usr/bin/env zsh
# AI Configuration Management Functions

# Initialize AI config directory
ai_init() {
    mkdir -p "$ZSH_MODULE_AI_CONFIG_DIR"
    
    # Create default config if it doesn't exist
    local config_file="$ZSH_MODULE_AI_CONFIG_DIR/config.conf"
    if [[ ! -f "$config_file" ]]; then
        cat > "$config_file" << 'EOF'
# AI Module Configuration
# Default provider
ZSH_MODULE_AI_PROVIDER=openai

# Provider configurations will be stored in separate files
EOF
    fi
}

# Save main configuration
ai_save_config() {
    local config_file="$ZSH_MODULE_AI_CONFIG_DIR/config.conf"
    
    cat > "$config_file" << EOF
# AI Module Configuration
# Generated: $(date)

# Default provider
ZSH_MODULE_AI_PROVIDER=$ZSH_MODULE_AI_PROVIDER
EOF
}

# Load configuration
ai_load_config() {
    local config_file="$ZSH_MODULE_AI_CONFIG_DIR/config.conf"
    
    if [[ -f "$config_file" ]]; then
        source "$config_file"
    fi
}

# Get provider configuration
ai_get_config() {
    local provider="${1:-$ZSH_MODULE_AI_PROVIDER}"
    local key="$2"
    local config_file="$ZSH_MODULE_AI_CONFIG_DIR/$provider.conf"
    
    if [[ ! -f "$config_file" ]]; then
        echo "❌ Provider $provider is not configured" >&2
        return 1
    fi
    
    if [[ -n "$key" ]]; then
        grep "^${key}=" "$config_file" 2>/dev/null | cut -d'=' -f2- | tr -d '"'
    else
        cat "$config_file"
    fi
}