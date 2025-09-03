# Installation System

The installation system provides automated setup, configuration, and maintenance of the ZSH Module Framework with backup and recovery capabilities.

## 📋 Overview

The installation system includes:
- Automated framework installation
- Configuration backup and restore
- Dependency checking and installation
- Shell integration setup
- Uninstallation with cleanup
- Update and migration utilities

## 📁 Installation Structure

```
scripts/
├── install.zsh    # Main installation script
├── build.zsh      # Build and optimization system
└── manager.zsh    # Module lifecycle management
```

## 🚀 Installation Process

### Quick Installation

```bash
# Clone and install
git clone https://github.com/yourusername/zsh-module.git ~/.zsh-module
cd ~/.zsh-module
./scripts/install.zsh
```

### Manual Installation Steps

#### 1. Prerequisites Check
```bash
# Check zsh version
zsh --version  # Requires 5.0+

# Check required utilities
which git grep sed mv cp mkdir
```

#### 2. Download Framework
```bash
# Option 1: Git clone
git clone https://github.com/yourusername/zsh-module.git ~/.zsh-module

# Option 2: Download archive
wget https://github.com/yourusername/zsh-module/archive/main.zip
unzip main.zip -d ~/.zsh-module
```

#### 3. Run Installation
```bash
cd ~/.zsh-module
chmod +x scripts/install.zsh
./scripts/install.zsh
```

## 🔧 Installation Options

### Interactive Installation
```bash
# Full interactive setup
./scripts/install.zsh

# Example interaction:
# 🔧 ZSH Module Framework Installation
# ├── Checking prerequisites... ✅
# ├── Backing up existing configuration... ✅
# ├── Installing framework... ✅
# ├── Which modules would you like to enable?
# │   [y] git - Git workflow automation
# │   [y] dev - Development tools
# │   [n] network - Network diagnostics
# │   [y] system - System utilities
# ├── Configuring shell integration... ✅
# ├── Building module cache... ✅
# └── Installation complete! 🎉
```

### Automated Installation
```bash
# Non-interactive installation
./scripts/install.zsh --auto

# With specific modules
./scripts/install.zsh --auto --modules="git,dev,system"

# Minimal installation
./scripts/install.zsh --minimal
```

### Custom Installation
```bash
# Custom installation directory
./scripts/install.zsh --dir="/opt/zsh-module"

# Skip shell integration
./scripts/install.zsh --no-shell-integration

# Keep existing configuration
./scripts/install.zsh --preserve-config
```

## ⚙️ Installation Functions

### Core Installation Functions

#### `install_main()`
Main installation orchestration function.

```bash
# Installation steps:
1. Prerequisites validation
2. Backup existing configuration
3. Framework installation
4. Module selection and configuration
5. Shell integration setup
6. Cache building
7. Verification and testing
```

#### `check_prerequisites()`
Validates system requirements.

```bash
# Checks:
✅ zsh version (5.0+)
✅ Required utilities (git, grep, sed, mv, cp)
✅ Directory permissions
✅ Shell environment
✅ Terminal capabilities
```

#### `backup_existing_config()`
Creates backup of existing configuration.

```bash
# Backup locations:
~/.config/zsh-module-backup-$(date +%Y%m%d-%H%M%S)/
├── .zshrc.bak              # Original .zshrc
├── enabled-modules.bak     # Module configuration
├── custom-config.bak       # Custom configurations
└── backup-info.txt         # Backup metadata
```

#### `install_framework()`
Installs core framework files.

```bash
# Installation process:
1. Create directory structure
2. Copy core files
3. Set up configuration directories
4. Install module files
5. Create symbolic links
6. Set permissions
```

#### `setup_shell_integration()`
Configures shell integration.

```bash
# Integration methods:
1. .zshrc modification (recommended)
2. .zprofile integration
3. Custom initialization script
4. Symlink approach
```

**Example .zshrc Integration:**
```bash
# ZSH Module Framework
if [[ -f ~/.zsh-module/init.zsh ]]; then
    source ~/.zsh-module/init.zsh
fi
```

### Configuration Functions

#### `configure_modules()`
Interactive module selection and configuration.

```bash
# Module selection interface:
configure_modules() {
    echo "🔧 Module Configuration"
    
    for module in git dev system network; do
        local desc=$(get_module_description "$module")
        if prompt_yes_no "Enable $module module? ($desc)" "y"; then
            echo "$module" >> "$ZSH_MODULE_CONFIG"
            echo "  ✅ Enabled: $module"
        else
            echo "  ❌ Skipped: $module"
        fi
    done
}
```

#### `setup_default_config()`
Creates default configuration files.

```bash
# Default configuration:
~/.config/zsh-module/
├── enabled-modules          # Default enabled modules
├── settings.conf           # Framework settings
├── cache/                  # Cache directory
└── themes/                 # Theme directory (planned)
```

### Verification Functions

#### `verify_installation()`
Verifies installation integrity.

```bash
# Verification steps:
✅ Core files present
✅ Configuration files valid
✅ Modules loadable
✅ Shell integration working
✅ Basic functions accessible
✅ No critical errors
```

#### `run_installation_tests()`
Runs basic functionality tests.

```bash
# Test categories:
1. Framework Loading Tests
2. Module Function Tests  
3. Configuration Tests
4. Integration Tests
5. Performance Tests
```

## 🛠️ Configuration Options

### Installation Modes

#### Full Installation (Default)
```bash
# Includes:
- All core components
- Interactive module selection
- Shell integration
- Performance optimization
- Documentation
```

#### Minimal Installation
```bash
./scripts/install.zsh --minimal

# Includes:
- Core framework only
- No modules enabled by default
- Basic shell integration
- Manual configuration required
```

#### Development Installation
```bash
./scripts/install.zsh --dev

# Includes:
- All modules enabled
- Debug mode enabled
- Development tools
- Extended logging
```

### Customization Options

#### Custom Installation Directory
```bash
# Environment variable
export ZSH_MODULE_INSTALL_DIR="/opt/zsh-module"
./scripts/install.zsh

# Command line option
./scripts/install.zsh --dir="/opt/zsh-module"
```

#### Module Preselection
```bash
# Specify modules to enable
./scripts/install.zsh --modules="git,dev,system"

# Enable all modules
./scripts/install.zsh --all-modules

# No modules (core only)
./scripts/install.zsh --no-modules
```

#### Shell Integration Options
```bash
# Automatic .zshrc modification
./scripts/install.zsh --integrate-zshrc

# Manual integration only
./scripts/install.zsh --no-shell-integration

# Create init script only
./scripts/install.zsh --init-script-only
```

## 🔄 Update and Maintenance

### Update Process
```bash
# Update framework
cd ~/.zsh-module
git pull origin main
./scripts/install.zsh --update

# Or use built-in update
zmod update  # (planned)
```

### Migration Between Versions
```bash
# Migrate configuration
./scripts/install.zsh --migrate-from-1.0.1

# Import old configuration
./scripts/install.zsh --import-config ~/.old-zsh-config
```

### Repair Installation
```bash
# Repair broken installation
./scripts/install.zsh --repair

# Rebuild everything
./scripts/install.zsh --rebuild
```

## 🗑️ Uninstallation

### Complete Uninstallation
```bash
# Interactive uninstallation
./scripts/install.zsh --uninstall

# Automatic uninstallation
./scripts/install.zsh --uninstall --auto
```

### Selective Removal
```bash
# Remove only modules
./scripts/install.zsh --remove-modules

# Remove shell integration only
./scripts/install.zsh --remove-integration

# Keep configuration
./scripts/install.zsh --uninstall --keep-config
```

### Uninstallation Process
```bash
# Uninstallation steps:
1. Create backup of current state
2. Remove shell integration
3. Clean up configuration files
4. Remove framework files
5. Restore original shell configuration
6. Verify complete removal
```

## 📋 Backup and Recovery

### Automatic Backups
```bash
# Backups created during:
- Installation
- Updates
- Module changes
- Configuration modifications
- Uninstallation
```

### Manual Backup
```bash
# Create manual backup
./scripts/install.zsh --backup

# Backup to specific location
./scripts/install.zsh --backup --backup-dir="/path/to/backups"
```

### Recovery Process
```bash
# List available backups
./scripts/install.zsh --list-backups

# Restore from backup
./scripts/install.zsh --restore --backup-date="20231101-143022"

# Emergency recovery
./scripts/install.zsh --emergency-restore
```

## 🚨 Error Handling

### Common Installation Issues

#### Permission Errors
```bash
# Fix permission issues
sudo chown -R $USER:$USER ~/.zsh-module
chmod -R 755 ~/.zsh-module
```

#### Missing Dependencies
```bash
# Install missing dependencies
# Ubuntu/Debian
sudo apt update
sudo apt install git zsh curl

# macOS
brew install git zsh
```

#### Shell Integration Conflicts
```bash
# Resolve .zshrc conflicts
./scripts/install.zsh --fix-integration

# Manual resolution
cp ~/.zshrc ~/.zshrc.backup
./scripts/install.zsh --integrate-zshrc --force
```

### Installation Recovery
```bash
# Recovery from failed installation
./scripts/install.zsh --recover

# Clean failed installation
./scripts/install.zsh --clean-failed
```

## 📊 Installation Verification

### Post-Installation Checks
```bash
# Verify installation
zmod status

# Expected output:
# 🔧 ZSH Module Framework Status
# ├── Version: 1.0.2
# ├── Installation: ~/.zsh-module
# ├── Configuration: ~/.config/zsh-module
# ├── Enabled Modules: 3 (git, dev, system)
# ├── Cache: Built (542ms load time)
# ├── Shell Integration: ✅ Active
# └── Status: ✅ Operational
```

### Function Testing
```bash
# Test core functions
zmod_is_git_repo && echo "Git detection works"
zmod_has_command "ls" && echo "Command detection works"

# Test module functions
status  # Git module
serve   # Dev module
ll      # System module
```

## 🔧 Troubleshooting

### Debug Installation
```bash
# Run installation with debug output
DEBUG=true ./scripts/install.zsh

# Verbose logging
VERBOSE=true ./scripts/install.zsh
```

### Common Solutions

#### Installation Hangs
```bash
# Kill hanging processes
pkill -f "install.zsh"

# Clean up and retry
rm -rf ~/.zsh-module-tmp
./scripts/install.zsh --clean-retry
```

#### Module Loading Errors
```bash
# Check module syntax
zsh -n ~/.zsh-module/modules/*/*.zsh

# Rebuild cache
zmod build
```

#### Shell Integration Issues
```bash
# Check shell integration
grep -n "zsh-module" ~/.zshrc

# Re-run integration
./scripts/install.zsh --fix-integration
```

## 📚 Dependencies

### System Requirements
- **Operating System**: Linux, macOS, WSL
- **Shell**: zsh 5.0 or later
- **Utilities**: git, grep, sed, mv, cp, mkdir, chmod

### Optional Dependencies
- `curl` or `wget` - For downloading updates
- `fzf` - Enhanced interactive features
- Modern terminal - Full feature support

## 🔮 Future Installation Features

### Planned Enhancements
- **GUI Installer** - Graphical installation interface
- **Package Manager Integration** - Homebrew, APT packages
- **Cloud Configuration** - Sync settings across machines
- **Containerized Installation** - Docker-based setup
- **Automated Updates** - Background update system

### Advanced Installation Options
```bash
# Planned features
./scripts/install.zsh --cloud-sync
./scripts/install.zsh --container-mode
./scripts/install.zsh --auto-update-enable
```

## 📚 Related Documentation

- [Build System](build.md) - Framework build and optimization
- [Module Manager](manager.md) - Module lifecycle management
- [Configuration](../core/config.md) - Framework configuration
- [Core Loader](../core/loader.md) - Module loading system