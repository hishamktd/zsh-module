#!/usr/bin/env zsh
# ZSH Module Framework - Installation Script
# Installs the framework to .zshrc and sets up the environment

# Set framework directory
if [[ -z "$ZSH_MODULE_DIR" ]]; then
    export ZSH_MODULE_DIR="$(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]:-${(%):-%x}}")")")"
fi

# Installation functions
install_to_zshrc() {
    local zshrc="$HOME/.zshrc"
    local backup_created=false
    
    echo "📦 Installing ZSH Module Framework..."
    echo "  Framework directory: $ZSH_MODULE_DIR"
    
    # Check if already installed
    if [[ -f "$zshrc" ]] && grep -q "ZSH Module Framework" "$zshrc"; then
        echo "✅ ZSH Module Framework already installed in .zshrc"
        echo "💡 Run 'zmod update' to refresh"
        return 0
    fi
    
    # Backup existing .zshrc
    if [[ -f "$zshrc" ]]; then
        local timestamp=$(date +%Y%m%d_%H%M%S)
        local backup="$HOME/.zshrc.backup.$timestamp"
        cp "$zshrc" "$backup"
        echo "  📋 Backup created: $backup"
        backup_created=true
    fi
    
    # Create .zshrc if it doesn't exist
    if [[ ! -f "$zshrc" ]]; then
        touch "$zshrc"
        echo "  📝 Created new .zshrc"
    fi
    
    # Add installation lines
    cat >> "$zshrc" << EOF

# ZSH Module Framework
# Auto-installed on $(date)
export ZSH_MODULE_DIR="$ZSH_MODULE_DIR"
source "\$ZSH_MODULE_DIR/scripts/manager.zsh"

# Initialize the framework
zmod_init
EOF
    
    echo "✅ ZSH Module Framework installed successfully!"
    echo ""
    echo "📋 Installation Summary:"
    echo "  ✅ Added to .zshrc"
    if [[ "$backup_created" == "true" ]]; then
        echo "  ✅ Backup created"
    fi
    echo "  ✅ Framework directory set: $ZSH_MODULE_DIR"
    
    return 0
}

# Setup framework directory structure
setup_framework() {
    echo "🏗️  Setting up framework structure..."
    
    # Create necessary directories
    local dirs=(
        "config"
        "dist" 
        "themes"
        "plugins"
        "modules/custom"
    )
    
    for dir in "${dirs[@]}"; do
        local full_path="$ZSH_MODULE_DIR/$dir"
        if [[ ! -d "$full_path" ]]; then
            mkdir -p "$full_path"
            echo "  📁 Created: $dir"
        fi
    done
    
    # Create default configuration if it doesn't exist
    local config_file="$ZSH_MODULE_DIR/config/enabled.conf"
    if [[ ! -f "$config_file" ]]; then
        cat > "$config_file" << EOF
# ZSH Module Framework - Enabled Modules
# Add module names here (one per line) to enable them
# Lines starting with # are comments

git
dev
system
network
EOF
        echo "  ⚙️  Created default configuration"
    fi
    
    # Create user config
    local user_config="$ZSH_MODULE_DIR/config/zshrc.conf"
    if [[ ! -f "$user_config" ]]; then
        cat > "$user_config" << EOF
# ZSH Module Framework User Configuration
# Generated on $(date)

# Enable lazy loading for faster shell startup
export ZSH_MODULE_LAZY_LOAD=true

# Disable debug output by default
export ZSH_MODULE_DEBUG=false

# Enable auto updates
export ZSH_MODULE_AUTO_UPDATE=true
EOF
        echo "  ⚙️  Created user configuration"
    fi
    
    echo "✅ Framework structure setup complete"
}

# Build initial caches
build_initial_caches() {
    echo "⚡ Building initial caches..."
    
    # Source the build script and run it
    source "$ZSH_MODULE_DIR/scripts/build.zsh"
    
    # Build both eager and lazy caches
    build_eager_cache >/dev/null
    build_lazy_cache >/dev/null
    
    echo "✅ Initial caches built"
}

# Set executable permissions
set_permissions() {
    echo "🔒 Setting executable permissions..."
    
    local scripts=(
        "$ZSH_MODULE_DIR/scripts/build.zsh"
        "$ZSH_MODULE_DIR/scripts/install.zsh"
        "$ZSH_MODULE_DIR/scripts/manager.zsh"
    )
    
    for script in "${scripts[@]}"; do
        if [[ -f "$script" ]]; then
            chmod +x "$script"
        fi
    done
    
    echo "✅ Permissions set"
}

# Verification
verify_installation() {
    echo "🔍 Verifying installation..."
    
    local issues=()
    
    # Check framework directory
    if [[ ! -d "$ZSH_MODULE_DIR" ]]; then
        issues+=("Framework directory not found: $ZSH_MODULE_DIR")
    fi
    
    # Check core files
    local core_files=("core/loader.zsh" "core/config.zsh" "core/utils.zsh")
    for file in "${core_files[@]}"; do
        if [[ ! -f "$ZSH_MODULE_DIR/$file" ]]; then
            issues+=("Core file missing: $file")
        fi
    done
    
    # Check .zshrc installation
    if [[ -f "$HOME/.zshrc" ]] && ! grep -q "ZSH Module Framework" "$HOME/.zshrc"; then
        issues+=(".zshrc installation not found")
    fi
    
    # Report issues
    if [[ ${#issues[@]} -gt 0 ]]; then
        echo "❌ Installation issues found:"
        for issue in "${issues[@]}"; do
            echo "  • $issue"
        done
        return 1
    else
        echo "✅ Installation verified successfully"
        return 0
    fi
}

# Uninstall function
uninstall() {
    echo "🗑️  Uninstalling ZSH Module Framework..."
    
    local zshrc="$HOME/.zshrc"
    
    if [[ -f "$zshrc" ]] && grep -q "ZSH Module Framework" "$zshrc"; then
        # Backup before uninstalling
        local timestamp=$(date +%Y%m%d_%H%M%S)
        local backup="$HOME/.zshrc.backup.$timestamp"
        cp "$zshrc" "$backup"
        echo "  📋 Backup created: $backup"
        
        # Remove installation lines
        sed -i '/# ZSH Module Framework/,/zmod_init/d' "$zshrc"
        
        # Remove empty lines at end
        sed -i -e :a -e '/^\s*$/N;ba;s/\(.*[^\s]\)\s*$/\1/' "$zshrc"
        
        echo "✅ Removed from .zshrc"
    else
        echo "⚠️  ZSH Module Framework not found in .zshrc"
    fi
    
    echo "💡 Framework files remain at: $ZSH_MODULE_DIR"
    echo "💡 Remove manually if desired: rm -rf \"$ZSH_MODULE_DIR\""
    echo "💡 Restart your shell to complete uninstallation"
}

# Show installation status
status() {
    echo "📊 ZSH Module Framework Installation Status:"
    echo "  Framework Dir: $ZSH_MODULE_DIR"
    
    if [[ -d "$ZSH_MODULE_DIR" ]]; then
        echo "  Directory: ✅ Exists"
    else
        echo "  Directory: ❌ Missing"
    fi
    
    if [[ -f "$HOME/.zshrc" ]] && grep -q "ZSH Module Framework" "$HOME/.zshrc"; then
        echo "  .zshrc Integration: ✅ Installed"
    else
        echo "  .zshrc Integration: ❌ Not installed"
    fi
    
    local config_file="$ZSH_MODULE_DIR/config/enabled.conf"
    if [[ -f "$config_file" ]]; then
        echo "  Configuration: ✅ Present"
        local enabled_count=$(grep -v '^#' "$config_file" | grep -v '^[[:space:]]*$' | wc -l)
        echo "  Enabled Modules: $enabled_count"
    else
        echo "  Configuration: ❌ Missing"
    fi
    
    # Check caches
    if [[ -f "$ZSH_MODULE_DIR/dist/modules.zsh" ]]; then
        echo "  Eager Cache: ✅ Built"
    else
        echo "  Eager Cache: ❌ Not built"
    fi
    
    if [[ -f "$ZSH_MODULE_DIR/dist/lazy-registry.zsh" ]]; then
        echo "  Lazy Cache: ✅ Built"
    else
        echo "  Lazy Cache: ❌ Not built"
    fi
}

# Help message
show_help() {
    cat << 'EOF'
ZSH Module Framework - Installation Script

USAGE:
    install.zsh [command]

COMMANDS:
    install     Install framework to .zshrc (default)
    setup       Setup framework directory structure
    build       Build initial caches
    verify      Verify installation
    uninstall   Remove from .zshrc
    status      Show installation status
    help        Show this help message

EXAMPLES:
    ./install.zsh           # Full installation
    ./install.zsh setup     # Setup directories only
    ./install.zsh status    # Check installation status
    ./install.zsh uninstall # Remove from .zshrc

The installation will:
1. Setup directory structure
2. Create default configuration
3. Build module caches
4. Add framework to .zshrc
5. Verify installation

After installation, restart your shell or run:
    source ~/.zshrc
EOF
}

# Main installation function
main() {
    local command="${1:-install}"
    
    case "$command" in
        "install"|"")
            setup_framework
            build_initial_caches
            set_permissions
            install_to_zshrc
            verify_installation
            
            if [[ $? -eq 0 ]]; then
                echo ""
                echo "🎉 Installation complete!"
                echo "💡 Restart your shell or run: source ~/.zshrc"
                echo "💡 Use 'zmod help' to get started"
            fi
            ;;
        "setup")
            setup_framework
            ;;
        "build")
            build_initial_caches
            ;;
        "verify")
            verify_installation
            ;;
        "uninstall")
            uninstall
            ;;
        "status")
            status
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            echo "❌ Unknown command: $command"
            echo "Run 'install.zsh help' for usage information"
            return 1
            ;;
    esac
}

# Make script executable when run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]] || [[ "${(%):-%x}" == "${0}" ]]; then
    main "$@"
fi