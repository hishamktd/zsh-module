#!/usr/bin/env zsh
# ZSH Module Framework - Core Loader
# Handles module loading, enabling/disabling, and configuration

# Framework variables
export ZSH_MODULE_DIR="${ZSH_MODULE_DIR:-$HOME/.zsh-modules}"
export ZSH_MODULE_CONFIG="$ZSH_MODULE_DIR/config/enabled.conf"
export ZSH_MODULE_CACHE="$ZSH_MODULE_DIR/dist/modules.zsh"

# Initialize module system
zmod_init() {
    # Load user configuration first
    local user_config="$ZSH_MODULE_DIR/config/zshrc.conf"
    [[ -f "$user_config" ]] && source "$user_config"
    
    # Create config if it doesn't exist
    if [[ ! -f "$ZSH_MODULE_CONFIG" ]]; then
        mkdir -p "$(dirname "$ZSH_MODULE_CONFIG")"
        echo "# Enabled modules - one per line" > "$ZSH_MODULE_CONFIG"
        echo "git" >> "$ZSH_MODULE_CONFIG"
        echo "dev" >> "$ZSH_MODULE_CONFIG"
        echo "system" >> "$ZSH_MODULE_CONFIG"
    fi
    
    # Load enabled modules
    zmod_load_enabled
}

# Load all enabled modules
zmod_load_enabled() {
    if [[ "$ZSH_MODULE_LAZY_LOAD" == "true" ]]; then
        # Lazy loading mode - only register commands
        zmod_load_lazy_registry
    else
        # Eager loading mode - load all modules immediately  
        if [[ -f "$ZSH_MODULE_CACHE" ]] && [[ "$ZSH_MODULE_CACHE" -nt "$ZSH_MODULE_CONFIG" ]]; then
            # Use cached version if available and newer
            source "$ZSH_MODULE_CACHE"
        else
            # Load modules individually and rebuild cache
            zmod_build_cache
            [[ -f "$ZSH_MODULE_CACHE" ]] && source "$ZSH_MODULE_CACHE"
        fi
    fi
}

# Load lazy registry for fast shell startup
zmod_load_lazy_registry() {
    local lazy_cache="$ZSH_MODULE_DIR/dist/lazy-registry.zsh"
    
    if [[ -f "$lazy_cache" ]] && [[ "$lazy_cache" -nt "$ZSH_MODULE_CONFIG" ]]; then
        source "$lazy_cache"
    else
        zmod_build_lazy_registry
        [[ -f "$lazy_cache" ]] && source "$lazy_cache"
    fi
}

# Build lazy loading registry
zmod_build_lazy_registry() {
    local lazy_cache="$ZSH_MODULE_DIR/dist/lazy-registry.zsh"
    mkdir -p "$(dirname "$lazy_cache")"
    
    echo "# Auto-generated lazy loading registry - $(date)" > "$lazy_cache"
    echo "# Fast shell startup - commands registered for lazy loading" >> "$lazy_cache"
    echo "" >> "$lazy_cache"
    
    # Process each enabled module for lazy loading
    while IFS= read -r module || [[ -n "$module" ]]; do
        # Skip comments and empty lines
        [[ "$module" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${module// }" ]] && continue
        
        module=$(echo "$module" | xargs) # trim whitespace
        local current_module_path="$ZSH_MODULE_DIR/modules/$module"
        local lazy_config="$current_module_path/lazy.conf"
        
        if [[ -f "$lazy_config" ]]; then
            echo "# Lazy commands for module: $module" >> "$lazy_cache"
            
            # Read lazy command definitions
            while IFS= read -r line || [[ -n "$line" ]]; do
                [[ "$line" =~ ^[[:space:]]*# ]] && continue
                [[ -z "${line// }" ]] && continue
                
                # Format: command_name[:function_name]
                local cmd_name="${line%:*}"
                local func_name="${line#*:}"
                [[ "$cmd_name" == "$func_name" ]] && func_name="$cmd_name"
                
                echo "zmod_lazy_register '$cmd_name' '$module' '$func_name'" >> "$lazy_cache"
            done < "$lazy_config"
            
            echo "" >> "$lazy_cache"
        fi
    done < "$ZSH_MODULE_CONFIG"
    
    zmod_debug "Lazy registry built: $lazy_cache"
}

# Load a specific module
zmod_load_module() {
    local module_name="$1"
    local module_path="$ZSH_MODULE_DIR/modules/$module_name"
    
    if [[ -d "$module_path" ]]; then
        # Load main module file
        [[ -f "$module_path/init.zsh" ]] && source "$module_path/init.zsh"
        [[ -f "$module_path/$module_name.zsh" ]] && source "$module_path/$module_name.zsh"
        
        # Load all .zsh files in module directory
        for file in "$module_path"/*.zsh; do
            [[ -f "$file" ]] && [[ "$(basename "$file")" != "init.zsh" ]] && source "$file"
        done
    else
        echo "❌ Module '$module_name' not found at $module_path" >&2
        return 1
    fi
}

# Build module cache for faster loading
zmod_build_cache() {
    local cache_file="$ZSH_MODULE_CACHE"
    mkdir -p "$(dirname "$cache_file")"
    
    echo "# Auto-generated module cache - $(date)" > "$cache_file"
    echo "# Do not edit manually" >> "$cache_file"
    echo "" >> "$cache_file"
    echo "# Prevent alias to function conversion that causes parse errors" >> "$cache_file"
    echo "unsetopt ALIASES_TO_FUNCTIONS 2>/dev/null || true" >> "$cache_file"
    echo "" >> "$cache_file"
    
    # Read enabled modules and combine them
    while IFS= read -r module || [[ -n "$module" ]]; do
        # Skip comments and empty lines
        [[ "$module" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${module// }" ]] && continue
        
        module=$(echo "$module" | xargs) # trim whitespace
        
        if [[ -d "$ZSH_MODULE_DIR/modules/$module" ]]; then
            echo "# === Module: $module ===" >> "$cache_file"
            
            # Add init file first
            if [[ -f "$ZSH_MODULE_DIR/modules/$module/init.zsh" ]]; then
                cat "$ZSH_MODULE_DIR/modules/$module/init.zsh" >> "$cache_file"
                echo "" >> "$cache_file"
            fi
            
            # Add main module file
            if [[ -f "$ZSH_MODULE_DIR/modules/$module/$module.zsh" ]]; then
                cat "$ZSH_MODULE_DIR/modules/$module/$module.zsh" >> "$cache_file"
                echo "" >> "$cache_file"
            fi
            
            # Add other .zsh files
            for file in "$ZSH_MODULE_DIR/modules/$module"/*.zsh; do
                if [[ -f "$file" ]] && [[ "$(basename "$file")" != "init.zsh" ]] && [[ "$(basename "$file")" != "$module.zsh" ]]; then
                    cat "$file" >> "$cache_file"
                    echo "" >> "$cache_file"
                fi
            done
        fi
    done < "$ZSH_MODULE_CONFIG"
    
    echo "✅ Module cache built: $cache_file"
}

# Check if module is enabled
zmod_is_enabled() {
    local module="$1"
    if [[ -f "$ZSH_MODULE_CONFIG" ]]; then
        grep -Fxq "$module" "$ZSH_MODULE_CONFIG" 2>/dev/null || \
        grep -q "^[[:space:]]*$(printf '%s\n' "$module" | sed 's/[[.*^$()+?{|]/\\&/g')[[:space:]]*$" "$ZSH_MODULE_CONFIG" 2>/dev/null
    else
        return 1
    fi
}

# Enable a module
zmod_enable() {
    local module="$1"
    
    if [[ -z "$module" ]]; then
        echo "❌ Module name required" >&2
        return 1
    fi
    
    if ! [[ -d "$ZSH_MODULE_DIR/modules/$module" ]]; then
        echo "❌ Module '$module' does not exist" >&2
        return 1
    fi
    
    if zmod_is_enabled "$module"; then
        echo "✅ Module '$module' is already enabled"
        return 0
    fi
    
    echo "$module" >> "$ZSH_MODULE_CONFIG"
    echo "✅ Enabled module '$module'"
    
    # Rebuild cache
    zmod_build_cache
}

# Disable a module
zmod_disable() {
    local module="$1"
    
    if [[ -z "$module" ]]; then
        echo "❌ Module name required" >&2
        return 1
    fi
    
    if ! zmod_is_enabled "$module"; then
        echo "⚠️  Module '$module' is not enabled"
        return 0
    fi
    
    # Remove from config (create temp file to avoid issues)
    local temp_config=$(mktemp)
    grep -v "^[[:space:]]*$module[[:space:]]*$" "$ZSH_MODULE_CONFIG" > "$temp_config"
    mv "$temp_config" "$ZSH_MODULE_CONFIG"
    
    echo "✅ Disabled module '$module'"
    
    # Rebuild cache
    zmod_build_cache
}

# List available modules
zmod_list() {
    echo "Available modules:"
    for module_dir in "$ZSH_MODULE_DIR/modules"/*; do
        if [[ -d "$module_dir" ]]; then
            local module_name=$(basename "$module_dir")
            local module_status="❌"
            if zmod_is_enabled "$module_name"; then
                module_status="✅"
            fi
            echo "  $module_status $module_name"
        fi
    done
}

# Reload all modules
zmod_reload() {
    echo "🔄 Reloading modules..."
    # Prevent alias to function conversion that causes parse errors
    unsetopt ALIASES_TO_FUNCTIONS 2>/dev/null || true
    zmod_build_cache
    source "$ZSH_MODULE_CACHE"
    echo "✅ Modules reloaded"
}