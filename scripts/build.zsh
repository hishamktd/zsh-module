#!/usr/bin/env zsh
# ZSH Module Framework - Build Script
# Builds optimized module cache for fast loading

# Set framework directory
if [[ -z "$ZSH_MODULE_DIR" ]]; then
    # Get the directory of this script
    local script_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]:-${(%):-%x}}")")"
    export ZSH_MODULE_DIR="$(dirname "$script_dir")"
fi

# Source configuration
source "$ZSH_MODULE_DIR/core/config.zsh"

# Build timestamps
build_start_time=$EPOCHREALTIME

echo "🔨 Building ZSH Module Framework..."
echo "  Directory: $ZSH_MODULE_DIR"

# Create dist directory
mkdir -p "$ZSH_MODULE_DIR/dist"

# Create config if it doesn't exist
if [[ ! -f "$ZSH_MODULE_DIR/config/enabled.conf" ]]; then
    mkdir -p "$ZSH_MODULE_DIR/config"
    cat > "$ZSH_MODULE_DIR/config/enabled.conf" << EOF
# Enabled modules - one per line
# Add module names here to enable them
git
dev
system
network
EOF
    echo "✅ Created default module configuration"
fi

# Function to build eager loading cache
build_eager_cache() {
    local cache_file="$ZSH_MODULE_DIR/dist/modules.zsh"
    local config_file="$ZSH_MODULE_DIR/config/enabled.conf"
    
    echo "📦 Building eager loading cache..."
    
    cat > "$cache_file" << EOF
# Auto-generated module cache - $(date)
# This file contains all enabled modules for fast eager loading
# Do not edit manually - regenerate with 'zmod build'

EOF
    
    # Add core utilities first
    echo "# === Core Utilities ===" >> "$cache_file"
    cat "$ZSH_MODULE_DIR/core/utils.zsh" >> "$cache_file"
    echo "" >> "$cache_file"
    
    # Process each enabled module
    local module_count=0
    while IFS= read -r module || [[ -n "$module" ]]; do
        # Skip comments and empty lines
        [[ "$module" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${module// }" ]] && continue
        
        module=$(echo "$module" | xargs) # trim whitespace
        local current_module_path="$ZSH_MODULE_DIR/modules/$module"
        
        if [[ -d "$current_module_path" ]]; then
            echo "  Adding module: $module"
            echo "# === Module: $module ===" >> "$cache_file"
            
            # Add init file first if exists
            if [[ -f "$current_module_path/init.zsh" ]]; then
                cat "$current_module_path/init.zsh" >> "$cache_file"
                echo "" >> "$cache_file"
            fi
            
            # Add main module file
            if [[ -f "$current_module_path/$module.zsh" ]]; then
                cat "$current_module_path/$module.zsh" >> "$cache_file"
                echo "" >> "$cache_file"
            fi
            
            # Add other .zsh files (excluding init.zsh and main module file)
            for file in "$current_module_path"/*.zsh; do
                if [[ -f "$file" ]]; then
                    local filename=$(basename "$file")
                    if [[ "$filename" != "init.zsh" ]] && [[ "$filename" != "$module.zsh" ]]; then
                        cat "$file" >> "$cache_file"
                        echo "" >> "$cache_file"
                    fi
                fi
            done
            
            module_count=$((module_count + 1))
        else
            echo "⚠️  Module '$module' not found at $current_module_path"
        fi
    done < "$config_file"
    
    echo "✅ Eager cache built with $module_count modules"
    return $module_count
}

# Function to build lazy loading registry
build_lazy_cache() {
    local lazy_cache="$ZSH_MODULE_DIR/dist/lazy-registry.zsh"
    local config_file="$ZSH_MODULE_DIR/config/enabled.conf"
    
    echo "⚡ Building lazy loading registry..."
    
    cat > "$lazy_cache" << EOF
# Auto-generated lazy loading registry - $(date)
# This file contains command registrations for lazy loading
# Do not edit manually - regenerate with 'zmod build'

# Load core utilities first
source "$ZSH_MODULE_DIR/core/utils.zsh"

EOF
    
    # Add lazy loading function
    cat >> "$lazy_cache" << 'EOF'
# Lazy loading implementation
zmod_lazy_register() {
    local command="$1"
    local module="$2" 
    local function_name="${3:-$command}"
    
    # Create lazy loading wrapper function
    eval "
    $command() {
        # Load the module
        local current_module_path=\"\$ZSH_MODULE_DIR/modules/$module\"
        
        if [[ -d \"\$current_module_path\" ]]; then
            # Load module files
            [[ -f \"\$current_module_path/init.zsh\" ]] && source \"\$current_module_path/init.zsh\"
            [[ -f \"\$current_module_path/$module.zsh\" ]] && source \"\$current_module_path/$module.zsh\"
            
            for file in \"\$current_module_path\"/*.zsh; do
                [[ -f \"\$file\" ]] && [[ \"\$(basename \"\$file\")\" != \"init.zsh\" ]] && source \"\$file\"
            done
            
            # Remove this wrapper
            unset -f $command
            
            # Call the real function
            $function_name \"\$@\"
        else
            echo \"❌ Module '$module' not found\" >&2
            return 1
        fi
    }
    "
}

EOF
    
    # Process each enabled module for lazy loading
    local command_count=0
    while IFS= read -r module || [[ -n "$module" ]]; do
        # Skip comments and empty lines
        [[ "$module" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${module// }" ]] && continue
        
        module=$(echo "$module" | xargs) # trim whitespace
        local current_module_path="$ZSH_MODULE_DIR/modules/$module"
        local lazy_config="$current_module_path/lazy.conf"
        
        if [[ -f "$lazy_config" ]]; then
            echo "  Registering lazy commands for: $module"
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
                command_count=$((command_count + 1))
            done < "$lazy_config"
            
            echo "" >> "$lazy_cache"
        fi
    done < "$config_file"
    
    echo "✅ Lazy registry built with $command_count commands"
    return $command_count
}

# Main build function
main() {
    local build_type="${1:-auto}"
    
    case "$build_type" in
        "eager")
            build_eager_cache
            ;;
        "lazy")
            build_lazy_cache
            ;;
        "auto"|"both"|"")
            # Build both caches
            build_eager_cache
            local eager_modules=$?
            
            build_lazy_cache  
            local lazy_commands=$?
            
            echo ""
            echo "📊 Build Summary:"
            echo "  Eager cache: $eager_modules modules"
            echo "  Lazy cache: $lazy_commands commands"
            ;;
        "clean")
            echo "🧹 Cleaning build artifacts..."
            rm -f "$ZSH_MODULE_DIR/dist"/*.zsh
            echo "✅ Build artifacts cleaned"
            return 0
            ;;
        *)
            echo "❌ Unknown build type: $build_type"
            echo "Usage: build.zsh [eager|lazy|both|clean]"
            return 1
            ;;
    esac
    
    # Calculate build time
    local build_end_time=$EPOCHREALTIME
    local build_duration=$(( build_end_time - build_start_time ))
    echo "⏱️  Build completed in ${build_duration}s"
    
    echo ""
    echo "💡 Next steps:"
    echo "  - Restart your shell or run 'zmod reload'"
    echo "  - Use 'zmod status' to verify everything is working"
    echo "  - Use 'zmod config set lazy_load true/false' to switch loading modes"
}

# Make script executable when sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]] || [[ "${(%):-%x}" == "${0}" ]]; then
    # Script is being executed directly
    main "$@"
fi