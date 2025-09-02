#!/usr/bin/env zsh
# ZSH Module Manager - CLI for managing modules

# Source core framework
if [[ -z "$ZSH_MODULE_DIR" ]]; then
    export ZSH_MODULE_DIR="$(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]:-${(%):-%x}}")")")"
fi

source "$ZSH_MODULE_DIR/core/loader.zsh"
source "$ZSH_MODULE_DIR/core/config.zsh"
source "$ZSH_MODULE_DIR/core/utils.zsh"

# Main zmod command
zmod() {
    local command="$1"
    shift
    
    case "$command" in
        "init")
            zmod_init
            ;;
        "enable")
            zmod_enable "$1"
            ;;
        "disable") 
            zmod_disable "$1"
            ;;
        "list"|"ls")
            zmod_list
            ;;
        "reload")
            zmod_reload
            ;;
        "build")
            zmod_build_cache
            if [[ "$ZSH_MODULE_LAZY_LOAD" == "true" ]]; then
                zmod_build_lazy_registry
            fi
            ;;
        "config")
            local config_cmd="$1"
            shift
            case "$config_cmd" in
                "set")
                    zmod_config_set "$1" "$2"
                    ;;
                "get")
                    zmod_config_get "$1"
                    ;;
                "show"|"")
                    zmod_config_show
                    ;;
                *)
                    echo "❌ Unknown config command: $config_cmd"
                    echo "Available: set, get, show"
                    return 1
                    ;;
            esac
            ;;
        "status")
            zmod_status
            ;;
        "update")
            zmod_update
            ;;
        "create")
            zmod_create_module "$1"
            ;;
        "remove")
            zmod_remove_module "$1"
            ;;
        "install")
            zmod_install_to_zshrc
            ;;
        "uninstall")
            zmod_uninstall_from_zshrc
            ;;
        "info")
            zmod_info "$1"
            ;;
        "help"|"--help"|"-h"|"")
            zmod_help
            ;;
        "version"|"--version"|"-v")
            zmod_version
            ;;
        "changelog"|"changes"|"whatsnew")
            zmod_show_changelog "$1"
            ;;
        "upgrade"|"update-framework")
            zmod_upgrade
            ;;
        *)
            echo "❌ Unknown command: $command"
            echo "Run 'zmod help' for usage information"
            return 1
            ;;
    esac
}

# Show module status
zmod_status() {
    echo "📊 ZSH Module Framework Status:"
    echo "  Framework Dir: $ZSH_MODULE_DIR"
    echo "  Lazy Loading: $(zmod_config_get lazy_load)"
    echo "  Debug Mode: $(zmod_config_get debug)"
    
    echo ""
    echo "📦 Modules:"
    local total_modules=0
    local enabled_modules=0
    
    for module_dir in "$ZSH_MODULE_DIR/modules"/*; do
        if [[ -d "$module_dir" ]]; then
            total_modules=$((total_modules + 1))
            local module_name=$(basename "$module_dir")
            if zmod_is_enabled "$module_name"; then
                enabled_modules=$((enabled_modules + 1))
                echo "  ✅ $module_name"
            else
                echo "  ❌ $module_name"
            fi
        fi
    done
    
    echo ""
    echo "📈 Summary:"
    echo "  Total modules: $total_modules"
    echo "  Enabled modules: $enabled_modules"
    
    # Cache status
    if [[ "$ZSH_MODULE_LAZY_LOAD" == "true" ]]; then
        local lazy_cache="$ZSH_MODULE_DIR/dist/lazy-registry.zsh"
        if [[ -f "$lazy_cache" ]]; then
            echo "  Lazy cache: ✅ Built ($(date -r "$lazy_cache" '+%Y-%m-%d %H:%M'))"
        else
            echo "  Lazy cache: ❌ Not built"
        fi
    else
        local module_cache="$ZSH_MODULE_DIR/dist/modules.zsh" 
        if [[ -f "$module_cache" ]]; then
            echo "  Module cache: ✅ Built ($(date -r "$module_cache" '+%Y-%m-%d %H:%M'))"
        else
            echo "  Module cache: ❌ Not built"
        fi
    fi
}

# Update framework
zmod_update() {
    echo "🔄 Updating ZSH Module Framework..."
    
    # Rebuild caches
    zmod_build_cache
    if [[ "$ZSH_MODULE_LAZY_LOAD" == "true" ]]; then
        zmod_build_lazy_registry
    fi
    
    echo "✅ Framework updated"
    echo "🔄 Reloading shell configuration..."
    
    # Clear any conflicting aliases before reloading
    unalias ls 2>/dev/null || true
    
    # Reload the shell configuration
    if [[ -n "$ZSH_VERSION" ]]; then
        exec zsh
    elif [[ -n "$BASH_VERSION" ]]; then
        exec bash
    else
        echo "💡 Please restart your shell or run 'source ~/.zshrc' to apply changes"
    fi
}

# Create new module
zmod_create_module() {
    local module_name="$1"
    
    if [[ -z "$module_name" ]]; then
        echo "❌ Module name required"
        echo "Usage: zmod create module_name"
        return 1
    fi
    
    local module_dir="$ZSH_MODULE_DIR/modules/$module_name"
    
    if [[ -d "$module_dir" ]]; then
        echo "❌ Module '$module_name' already exists"
        return 1
    fi
    
    echo "📝 Creating module '$module_name'..."
    
    mkdir -p "$module_dir"
    
    # Create main module file
    cat > "$module_dir/$module_name.zsh" << EOF
#!/usr/bin/env zsh
# $module_name Module - Description

# Example function
${module_name}_hello() {
    echo "Hello from $module_name module!"
}

# Example alias
alias ${module_name}='${module_name}_hello'
EOF
    
    # Create lazy config
    cat > "$module_dir/lazy.conf" << EOF
# $module_name module lazy loading configuration
# Format: command_name[:function_name]

${module_name}_hello
${module_name}:${module_name}_hello
EOF
    
    echo "✅ Module '$module_name' created at $module_dir"
    echo "💡 Edit $module_dir/$module_name.zsh to add your functions"
    echo "💡 Run 'zmod enable $module_name' to enable the module"
}

# Remove module
zmod_remove_module() {
    local module_name="$1"
    
    if [[ -z "$module_name" ]]; then
        echo "❌ Module name required"
        echo "Usage: zmod remove module_name"
        return 1
    fi
    
    local module_dir="$ZSH_MODULE_DIR/modules/$module_name"
    
    if [[ ! -d "$module_dir" ]]; then
        echo "❌ Module '$module_name' does not exist"
        return 1
    fi
    
    echo "🗑️  Module contents:"
    ls -la "$module_dir"
    
    if zmod_confirm "Delete module '$module_name' permanently?"; then
        # Disable first
        zmod_disable "$module_name" 2>/dev/null
        
        # Remove directory
        rm -rf "$module_dir"
        echo "✅ Module '$module_name' removed"
    fi
}

# Show module info
zmod_info() {
    local module_name="$1"
    
    if [[ -z "$module_name" ]]; then
        echo "❌ Module name required"
        echo "Usage: zmod info module_name"
        return 1
    fi
    
    local module_dir="$ZSH_MODULE_DIR/modules/$module_name"
    
    if [[ ! -d "$module_dir" ]]; then
        echo "❌ Module '$module_name' does not exist"
        return 1
    fi
    
    echo "📋 Module Information: $module_name"
    echo "  Location: $module_dir"
    
    if zmod_is_enabled "$module_name"; then
        echo "  Status: ✅ Enabled"
    else
        echo "  Status: ❌ Disabled"
    fi
    
    echo "  Files:"
    for file in "$module_dir"/*; do
        if [[ -f "$file" ]]; then
            local size=$(du -h "$file" | cut -f1)
            echo "    $(basename "$file") ($size)"
        fi
    done
    
    # Show lazy commands if available
    if [[ -f "$module_dir/lazy.conf" ]]; then
        echo "  Lazy commands:"
        while IFS= read -r line || [[ -n "$line" ]]; do
            [[ "$line" =~ ^[[:space:]]*# ]] && continue
            [[ -z "${line// }" ]] && continue
            echo "    $line"
        done < "$module_dir/lazy.conf"
    fi
}

# Install to .zshrc
zmod_install_to_zshrc() {
    local zshrc="$HOME/.zshrc"
    local install_line="source \"$ZSH_MODULE_DIR/scripts/manager.zsh\" && zmod_init"
    
    if grep -q "zmod_init" "$zshrc" 2>/dev/null; then
        echo "✅ ZSH Module Framework already installed in .zshrc"
        return 0
    fi
    
    echo "📝 Installing ZSH Module Framework to .zshrc..."
    
    # Backup existing .zshrc
    if [[ -f "$zshrc" ]]; then
        local backup=$(zmod_backup_file "$zshrc")
        echo "  Backup created: $backup"
    fi
    
    # Add to .zshrc
    echo "" >> "$zshrc"
    echo "# ZSH Module Framework" >> "$zshrc"
    echo "$install_line" >> "$zshrc"
    
    echo "✅ ZSH Module Framework installed to .zshrc"
    echo "💡 Restart your shell or run 'source ~/.zshrc' to activate"
}

# Uninstall from .zshrc  
zmod_uninstall_from_zshrc() {
    local zshrc="$HOME/.zshrc"
    
    if ! grep -q "zmod_init" "$zshrc" 2>/dev/null; then
        echo "⚠️  ZSH Module Framework not found in .zshrc"
        return 0
    fi
    
    echo "🗑️  Removing ZSH Module Framework from .zshrc..."
    
    # Backup existing .zshrc
    local backup=$(zmod_backup_file "$zshrc")
    echo "  Backup created: $backup"
    
    # Remove installation lines
    sed -i '/# ZSH Module Framework/d' "$zshrc"
    sed -i '/zmod_init/d' "$zshrc"
    
    echo "✅ ZSH Module Framework uninstalled from .zshrc"
    echo "💡 Restart your shell to deactivate"
}

# Show help
zmod_help() {
    cat << 'EOF'
ZSH Module Framework - Modular shell configuration

USAGE:
    zmod <command> [args...]

COMMANDS:
    init                Initialize the framework
    enable <module>     Enable a module
    disable <module>    Disable a module  
    list, ls           List all available modules
    reload             Reload all enabled modules
    build              Rebuild module caches
    
    config show        Show current configuration
    config get <key>   Get configuration value
    config set <key> <value>  Set configuration value
    
    status             Show framework status
    update             Update framework and rebuild caches
    create <name>      Create a new module
    remove <name>      Remove a module
    info <module>      Show module information
    
    install            Install framework to .zshrc
    uninstall          Remove framework from .zshrc
    
    help, -h           Show this help message
    version, -v        Show version information
    changelog, whatsnew [version]  Show changelog (all or specific version)
    upgrade            Upgrade framework and rebuild caches

CONFIGURATION KEYS:
    lazy_load          Enable/disable lazy loading (true/false)
    debug              Enable/disable debug output (true/false)  
    auto_update        Enable/disable auto updates (true/false)

EXAMPLES:
    zmod list                    # List all modules
    zmod enable git              # Enable git module
    zmod config set lazy_load true  # Enable lazy loading
    zmod create mymodule         # Create new module
    zmod install                 # Install to .zshrc

For more information, visit: https://github.com/your-repo/zsh-module
EOF
}

# Show version
zmod_version() {
    local version_file="$ZSH_MODULE_DIR/VERSION"
    local version="unknown"
    
    if [[ -f "$version_file" ]]; then
        version=$(cat "$version_file")
    fi
    
    echo "ZSH Module Framework v$version"
    echo "A modular shell configuration system"
    echo "Built for performance and extensibility"
    
    if [[ -f "$ZSH_MODULE_DIR/CHANGELOG.md" ]]; then
        echo ""
        echo "Recent changes:"
        grep -A 5 "^## \[$version\]" "$ZSH_MODULE_DIR/CHANGELOG.md" | tail -n +2
    fi
}

# Show changelog/what's new
zmod_show_changelog() {
    local version_filter="$1"
    local changelog="$ZSH_MODULE_DIR/CHANGELOG.md"
    
    if [[ ! -f "$changelog" ]]; then
        echo "❌ Changelog not found"
        return 1
    fi
    
    echo "📋 ZSH Module Framework - Changelog"
    echo ""
    
    if [[ -n "$version_filter" ]]; then
        # Show specific version
        local found=false
        while IFS= read -r line; do
            if [[ "$line" =~ ^##[[:space:]]\[$version_filter\] ]]; then
                found=true
                echo "$line"
                continue
            elif [[ "$found" == true ]] && [[ "$line" =~ ^##[[:space:]] ]]; then
                # Next version found, stop
                break
            elif [[ "$found" == true ]]; then
                echo "$line"
            fi
        done < "$changelog"
        
        if [[ "$found" == false ]]; then
            echo "❌ Version $version_filter not found in changelog"
            return 1
        fi
    else
        # Show recent changes (last 3 versions)
        local version_count=0
        local in_version=false
        
        while IFS= read -r line; do
            if [[ "$line" =~ ^##.*\[.*\] ]]; then
                if [[ $version_count -ge 3 ]]; then
                    break
                fi
                version_count=$((version_count + 1))
                in_version=true
                echo "$line"
            elif [[ "$in_version" == true ]]; then
                echo "$line"
            fi
        done < "$changelog"
    fi
}

# Framework upgrade
zmod_upgrade() {
    echo "🚀 Upgrading ZSH Module Framework..."
    
    local current_dir=$(pwd)
    local version_file="$ZSH_MODULE_DIR/VERSION"
    local current_version="unknown"
    
    if [[ -f "$version_file" ]]; then
        current_version=$(cat "$version_file")
    fi
    
    echo "  Current version: $current_version"
    
    # In a real implementation, this would check for updates
    # For now, just rebuild everything
    echo "  Rebuilding framework..."
    
    cd "$ZSH_MODULE_DIR"
    
    # Rebuild caches
    source scripts/build.zsh
    build_eager_cache >/dev/null
    if [[ "$ZSH_MODULE_LAZY_LOAD" == "true" ]]; then
        build_lazy_cache >/dev/null
    fi
    
    # Update permissions
    chmod +x scripts/*.zsh 2>/dev/null
    
    cd "$current_dir"
    
    echo "✅ Framework upgraded successfully!"
    echo "💡 Restart your shell or run 'zmod reload' to apply changes"
    
    # Show what's new
    echo ""
    zmod_show_changelog
}

# Auto-completion for zmod command
_zmod_completion() {
    local commands=(
        'init:Initialize the framework'
        'enable:Enable a module'
        'disable:Disable a module'
        'list:List all available modules'
        'ls:List all available modules'
        'reload:Reload all enabled modules'
        'build:Rebuild module caches'
        'config:Manage configuration'
        'status:Show framework status'
        'update:Update framework'
        'create:Create a new module'
        'remove:Remove a module'
        'info:Show module information'
        'install:Install to .zshrc'
        'uninstall:Remove from .zshrc'
        'help:Show help message'
        'version:Show version'
    )
    
    if [[ $CURRENT -eq 2 ]]; then
        _describe 'zmod commands' commands
    elif [[ $words[2] == "enable" ]] || [[ $words[2] == "disable" ]] || [[ $words[2] == "info" ]]; then
        # Complete with available modules
        local modules=()
        for module_dir in "$ZSH_MODULE_DIR/modules"/*; do
            if [[ -d "$module_dir" ]]; then
                modules+=($(basename "$module_dir"))
            fi
        done
        _describe 'modules' modules
    fi
}

# Register completion if running interactively
if [[ $- == *i* ]]; then
    compdef _zmod_completion zmod
fi