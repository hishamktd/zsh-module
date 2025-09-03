# Configuration System

The configuration system (`core/config.zsh`) manages framework settings, environment variables, and module preferences.

## 📋 Overview

The configuration system provides:
- Framework-wide environment variables
- Module configuration management
- Path and directory setup
- Feature toggles and preferences
- Runtime configuration validation

## 🔧 Core Functions

### Framework Initialization

#### `zmod_init_config()`
Initializes the framework configuration system.

```bash
# Usage (internal - called during framework startup)
zmod_init_config
```

**Initialization Process:**
1. Sets up directory structure
2. Creates configuration files if missing
3. Validates environment variables
4. Sets default values
5. Ensures proper permissions

### Directory Management

#### `zmod_setup_directories()`
Creates necessary configuration directories.

```bash
# Usage (internal)
zmod_setup_directories

# Creates:
# ~/.config/zsh-module/
# ~/.config/zsh-module/cache/
# ~/.config/zsh-module/themes/ (planned)
```

**Directory Structure:**
```
~/.config/zsh-module/
├── enabled-modules          # Module configuration
├── cache/                   # Built module cache
│   ├── modules.zsh          # Concatenated modules
│   └── lazy-registry.zsh    # Lazy loading registry
├── themes/                  # Custom themes (planned)
└── settings.conf            # Framework settings (planned)
```

### Environment Variables

#### Framework Paths

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `ZSH_MODULE_DIR` | Framework installation directory | Auto-detected | Yes |
| `ZSH_MODULE_CONFIG` | Module configuration file | `~/.config/zsh-module/enabled-modules` | Yes |
| `ZSH_MODULE_CACHE_DIR` | Cache directory | `~/.config/zsh-module/cache` | Yes |

#### Feature Toggles

| Variable | Description | Default | Options |
|----------|-------------|---------|---------|
| `ZSH_MODULE_LAZY_LOAD` | Enable lazy loading | `false` | `true`/`false` |
| `ZSH_MODULE_DEBUG` | Debug mode | `false` | `true`/`false` |
| `ZSH_MODULE_TIMING` | Show timing info | `false` | `true`/`false` |
| `ZSH_MODULE_COLORS` | Enable colors | `true` | `true`/`false` |

#### Git Integration

| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `ZSH_MODULE_DEFAULT_BRANCH` | Default git branch | `main` | `main`, `master`, `develop` |
| `ZSH_MODULE_GIT_EDITOR` | Git editor preference | `$EDITOR` | `code`, `vim`, `nano` |

#### Development Tools

| Variable | Description | Default | Options |
|----------|-------------|---------|---------|
| `ZSH_MODULE_DEV_PORT` | Default dev server port | `3000` | Any valid port |
| `ZSH_MODULE_NODE_MANAGER` | Preferred Node manager | Auto-detect | `npm`, `yarn`, `pnpm`, `bun` |

## 📁 Configuration Files

### Module Configuration
**File:** `~/.config/zsh-module/enabled-modules`
**Purpose:** Lists enabled modules (one per line)

```bash
# Example content
git
dev
system
network
```

**Management:**
```bash
# Enable module
echo "modulename" >> ~/.config/zsh-module/enabled-modules

# Disable module  
grep -v "modulename" ~/.config/zsh-module/enabled-modules > temp && mv temp ~/.config/zsh-module/enabled-modules

# List enabled modules
cat ~/.config/zsh-module/enabled-modules
```

### Framework Settings (Planned)
**File:** `~/.config/zsh-module/settings.conf`
**Purpose:** Framework-wide settings

```ini
# Example planned content
[general]
lazy_load=false
debug=false
colors=true

[git]
default_branch=main
auto_fetch=false

[dev]
default_port=3000
auto_install=true
```

## 🔧 Configuration Functions

### Settings Management

#### `zmod_get_config(key, default)`
Retrieves a configuration value with fallback.

```bash
# Usage
port=$(zmod_get_config "dev_port" "3000")
branch=$(zmod_get_config "default_branch" "main")
```

#### `zmod_set_config(key, value)`
Sets a configuration value (planned).

```bash
# Usage (planned)
zmod_set_config "default_branch" "develop"
zmod_set_config "lazy_load" "true"
```

### Validation Functions

#### `zmod_validate_config()`
Validates current configuration setup.

```bash
# Usage
zmod_validate_config

# Checks:
# - Required directories exist
# - Configuration files are readable
# - Environment variables are set
# - Permissions are correct
```

## 🎨 Theme System (Planned)

### Theme Configuration
```bash
# Environment variables for theming
ZSH_MODULE_THEME="default"          # Theme name
ZSH_MODULE_THEME_DIR=""              # Custom theme directory
ZSH_MODULE_PROMPT_STYLE="minimal"   # Prompt styling
```

### Custom Themes
```bash
# Theme structure
~/.config/zsh-module/themes/mytheme/
├── theme.zsh                # Main theme file
├── colors.zsh              # Color definitions
├── prompt.zsh              # Prompt configuration
└── README.md               # Theme documentation
```

## 🔄 Configuration Lifecycle

### Startup Process
1. **Environment Detection** → Detect installation directory
2. **Directory Setup** → Create config directories
3. **File Validation** → Check config file existence
4. **Default Setting** → Apply framework defaults
5. **User Overrides** → Apply user customizations
6. **Validation** → Verify configuration integrity

### Runtime Updates
```bash
# Reload configuration
zmod config reload

# Reset to defaults
zmod config reset

# Validate current setup
zmod config validate

# Show current settings
zmod config show
```

## 🛠️ Customization Examples

### Custom Installation Directory
```bash
# In your .zshrc before loading framework
export ZSH_MODULE_DIR="/opt/zsh-module"
```

### Development Configuration
```bash
# Enable debug mode and timing
export ZSH_MODULE_DEBUG=true
export ZSH_MODULE_TIMING=true

# Custom git settings
export ZSH_MODULE_DEFAULT_BRANCH="develop"
export ZSH_MODULE_GIT_EDITOR="code --wait"
```

### Production Configuration
```bash
# Disable debug features
export ZSH_MODULE_DEBUG=false
export ZSH_MODULE_TIMING=false

# Enable optimizations
export ZSH_MODULE_LAZY_LOAD=true
```

## 📊 Configuration Validation

### Health Check
```bash
# Run configuration health check
zmod config check

# Expected output:
# ✅ Framework directory: /path/to/zsh-module
# ✅ Configuration directory: ~/.config/zsh-module
# ✅ Module config file: Found (4 modules enabled)
# ✅ Cache directory: Writable
# ✅ Environment variables: All set
```

### Common Issues

#### Missing Directories
```bash
# Symptom: Config files not found
# Solution: Run setup
zmod_setup_directories
```

#### Permission Errors
```bash
# Symptom: Cannot write config
# Solution: Fix permissions
chmod -R 755 ~/.config/zsh-module
```

#### Invalid Module Names
```bash
# Symptom: Module not loading
# Solution: Validate config file
zmod list  # Shows available vs enabled modules
```

## 🔍 Debugging Configuration

### Debug Output
```bash
# Enable debug mode
export ZSH_MODULE_DEBUG=true

# Reload framework
exec zsh

# Shows detailed configuration loading
```

### Configuration Inspection
```bash
# Show all framework variables
env | grep ZSH_MODULE

# Check configuration file
cat ~/.config/zsh-module/enabled-modules

# Validate setup
ls -la ~/.config/zsh-module/
```

## 🚀 Performance Considerations

### Fast Startup
- Configuration is cached at startup
- Environment variables are set once
- File operations are minimized

### Memory Usage
- Configuration variables are stored efficiently
- No persistent background processes
- Clean environment namespace

## 🔮 Future Configuration Features

### Planned Enhancements
- **GUI Configuration Tool** - Web-based config interface
- **Configuration Profiles** - Environment-specific settings
- **Module Dependencies** - Automatic dependency resolution
- **Remote Configuration** - Sync settings across machines
- **Configuration Validation** - Advanced validation rules
- **Migration Tools** - Upgrade configuration formats

### Advanced Features
```bash
# Planned commands
zmod config profile create work      # Create work profile
zmod config profile switch work     # Switch to work profile
zmod config sync --remote github    # Sync with remote
zmod config migrate --from v1.0.1   # Migrate old config
```

## 📚 Related Documentation

- [Loader System](loader.md) - Module loading and management
- [Utilities](utils.md) - Core utility functions
- [Installation](../scripts/install.md) - Setup and installation
- [Module Management](../scripts/manager.md) - Module lifecycle