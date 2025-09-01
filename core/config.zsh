#!/usr/bin/env zsh
# ZSH Module Framework - Configuration Management

# Configuration variables
export ZSH_MODULE_LAZY_LOAD=${ZSH_MODULE_LAZY_LOAD:-true}
export ZSH_MODULE_DEBUG=${ZSH_MODULE_DEBUG:-false}
export ZSH_MODULE_AUTO_UPDATE=${ZSH_MODULE_AUTO_UPDATE:-true}

# Lazy loading registry
typeset -gA ZSH_MODULE_LAZY_COMMANDS
typeset -gA ZSH_MODULE_LAZY_MODULES
typeset -gA ZSH_MODULE_LOADED

# Debug logging
zmod_debug() {
    [[ "$ZSH_MODULE_DEBUG" == "true" ]] && echo "[ZSH-MODULE] $*" >&2
}

# Register a command for lazy loading
zmod_lazy_register() {
    local command="$1"
    local module="$2"
    local function_name="${3:-$command}"
    
    ZSH_MODULE_LAZY_COMMANDS[$command]="$module:$function_name"
    ZSH_MODULE_LAZY_MODULES[$module]="$ZSH_MODULE_DIR/modules/$module"
    
    zmod_debug "Registered lazy command: $command -> $module:$function_name"
    
    # Create lazy loading wrapper function
    eval "
    $command() {
        zmod_debug \"Lazy loading module '$module' for command '$command'\"
        zmod_load_lazy_module '$module'
        unset -f $command  # Remove this wrapper
        $function_name \"\$@\"  # Call the real function
    }
    "
}

# Load a module lazily
zmod_load_lazy_module() {
    local module="$1"
    
    # Skip if already loaded
    if [[ -n "${ZSH_MODULE_LOADED[$module]}" ]]; then
        return 0
    fi
    
    local module_path="${ZSH_MODULE_LAZY_MODULES[$module]}"
    
    if [[ -d "$module_path" ]]; then
        zmod_debug "Loading lazy module: $module"
        
        # Load module files
        [[ -f "$module_path/init.zsh" ]] && source "$module_path/init.zsh"
        [[ -f "$module_path/$module.zsh" ]] && source "$module_path/$module.zsh"
        
        for file in "$module_path"/*.zsh; do
            [[ -f "$file" ]] && [[ "$(basename "$file")" != "init.zsh" ]] && source "$file"
        done
        
        # Mark as loaded
        ZSH_MODULE_LOADED[$module]=1
        
        # Remove lazy command wrappers for this module
        for cmd in ${(k)ZSH_MODULE_LAZY_COMMANDS}; do
            local module_func="${ZSH_MODULE_LAZY_COMMANDS[$cmd]}"
            if [[ "$module_func" =~ "^$module:" ]]; then
                unset "ZSH_MODULE_LAZY_COMMANDS[$cmd]"
            fi
        done
        
        zmod_debug "Lazy module '$module' loaded successfully"
    else
        echo "❌ Lazy module '$module' not found at $module_path" >&2
        return 1
    fi
}

# Load configuration from file
zmod_load_config() {
    local config_file="$ZSH_MODULE_DIR/config/zshrc.conf"
    
    if [[ -f "$config_file" ]]; then
        zmod_debug "Loading configuration from $config_file"
        source "$config_file"
    fi
}

# Save current configuration
zmod_save_config() {
    local config_file="$ZSH_MODULE_DIR/config/zshrc.conf"
    mkdir -p "$(dirname "$config_file")"
    
    cat > "$config_file" << EOF
# ZSH Module Framework Configuration
# Generated on $(date)

# Enable/disable lazy loading
export ZSH_MODULE_LAZY_LOAD=$ZSH_MODULE_LAZY_LOAD

# Enable/disable debug output
export ZSH_MODULE_DEBUG=$ZSH_MODULE_DEBUG

# Enable/disable auto updates
export ZSH_MODULE_AUTO_UPDATE=$ZSH_MODULE_AUTO_UPDATE
EOF
    
    echo "✅ Configuration saved to $config_file"
}

# Set configuration option
zmod_config_set() {
    local key="$1"
    local value="$2"
    
    case "$key" in
        "lazy_load"|"lazy-load")
            export ZSH_MODULE_LAZY_LOAD="$value"
            ;;
        "debug")
            export ZSH_MODULE_DEBUG="$value"
            ;;
        "auto_update"|"auto-update")
            export ZSH_MODULE_AUTO_UPDATE="$value"
            ;;
        *)
            echo "❌ Unknown configuration key: $key" >&2
            echo "Available keys: lazy_load, debug, auto_update" >&2
            return 1
            ;;
    esac
    
    zmod_save_config
    echo "✅ Set $key = $value"
}

# Get configuration option
zmod_config_get() {
    local key="$1"
    
    case "$key" in
        "lazy_load"|"lazy-load")
            echo "$ZSH_MODULE_LAZY_LOAD"
            ;;
        "debug")
            echo "$ZSH_MODULE_DEBUG"
            ;;
        "auto_update"|"auto-update")
            echo "$ZSH_MODULE_AUTO_UPDATE"
            ;;
        *)
            echo "❌ Unknown configuration key: $key" >&2
            return 1
            ;;
    esac
}

# Show all configuration
zmod_config_show() {
    echo "ZSH Module Framework Configuration:"
    echo "  Lazy Load:   $(zmod_config_get lazy_load)"
    echo "  Debug:       $(zmod_config_get debug)"
    echo "  Auto Update: $(zmod_config_get auto_update)"
    echo "  Module Dir:  $ZSH_MODULE_DIR"
}