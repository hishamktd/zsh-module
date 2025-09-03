# Module Manager

The module manager (`scripts/manager.zsh`) provides comprehensive lifecycle management for framework modules including enabling, disabling, creation, removal, and status monitoring.

## 📋 Overview

The module manager provides:
- Module lifecycle management (enable/disable/list)
- Module creation and scaffolding
- Module removal and cleanup
- Status monitoring and health checks
- Configuration management
- Update and maintenance utilities

## 📁 Manager Structure

```
scripts/manager.zsh           # Main manager script
zmod command interface        # CLI commands
├── list/ls                  # List available modules
├── enable <module>          # Enable module
├── disable <module>         # Disable module
├── status                   # Framework status
├── create <module>          # Create new module
├── remove <module>          # Remove module
├── info <module>           # Module information
├── update                  # Update framework
├── build                   # Build module cache
└── reload                  # Reload modules
```

## 🚀 Core Commands

### Module Listing

#### `zmod list` / `zmod ls`
Lists all available modules with their status.

```bash
# Usage
zmod list
zmod ls

# Output example:
# Available modules:
#   ✅ git
#   ✅ dev
#   ❌ network
#   ✅ system
```

**Features:**
- Shows enabled (✅) vs disabled (❌) status
- Alphabetically sorted
- Color-coded output
- Module description on hover (planned)

### Module Management

#### `zmod enable <module>`
Enables a module and adds it to configuration.

```bash
# Usage
zmod enable network
# ✅ Enabled module 'network'

zmod enable git dev system
# ✅ Enabled module 'git'
# ✅ Enabled module 'dev'  
# ✅ Enabled module 'system'
```

**Process:**
1. Validates module exists
2. Checks if already enabled
3. Adds to configuration file
4. Rebuilds module cache
5. Provides user feedback

#### `zmod disable <module>`
Disables a module and removes from configuration.

```bash
# Usage
zmod disable network
# ✅ Disabled module 'network'

zmod disable git dev
# ✅ Disabled module 'git'
# ✅ Disabled module 'dev'
```

**Process:**
1. Validates module is enabled
2. Removes from configuration file
3. Provides user feedback
4. Note: Cache rebuild recommended

### Framework Status

#### `zmod status`
Shows comprehensive framework status information.

```bash
# Usage
zmod status

# Output example:
# 🔧 ZSH Module Framework Status
# ├── Version: 1.0.2
# ├── Installation: ~/.zsh-module
# ├── Configuration: ~/.config/zsh-module
# ├── Enabled Modules: 3 (git, dev, system)
# ├── Cache Status: ✅ Built (last: 2 hours ago)
# ├── Load Time: 42ms
# ├── Shell Integration: ✅ Active (.zshrc)
# ├── Framework Health: ✅ Healthy
# └── Last Update: 2023-11-01 14:30:22
```

**Status Information:**
- Framework version and paths
- Module count and status
- Cache information
- Performance metrics
- Integration status
- Health indicators

### Module Creation

#### `zmod create <module_name>`
Creates a new module with scaffolding.

```bash
# Usage
zmod create mymodule

# Interactive creation:
# 📦 Creating new module: mymodule
# ├── Module description: Custom utilities
# ├── Author: John Doe <john@example.com>  
# ├── Create main file? [y/n]: y
# ├── Create README? [y/n]: y
# ├── Create tests? [y/n]: n
# └── Module created successfully!
```

**Generated Structure:**
```
modules/mymodule/
├── mymodule.zsh         # Main module file
├── README.md            # Module documentation
├── functions/           # Function definitions (optional)
├── aliases/            # Alias definitions (optional)
├── completions/        # Shell completions (optional)
└── tests/              # Test files (optional)
```

**Template Files:**

*mymodule.zsh:*
```bash
#!/usr/bin/env zsh
# MyModule - Custom utilities
# Author: John Doe <john@example.com>

# Example function
mymodule_hello() {
    echo "Hello from mymodule!"
}

# Alias for convenience
alias hello='mymodule_hello'
```

*README.md:*
```markdown
# MyModule

Custom utilities module for ZSH Module Framework.

## Functions

- `mymodule_hello()` - Example function

## Usage

```bash
hello
```
```

#### `zmod create --template <template> <module_name>`
Creates module from template.

```bash
# Available templates
zmod create --template basic mymodule       # Basic module template
zmod create --template git-ext git-extra    # Git extension template  
zmod create --template dev-tools devtools   # Development tools template
zmod create --template network netutils     # Network utilities template
```

### Module Information

#### `zmod info <module>`
Shows detailed information about a module.

```bash
# Usage
zmod info git

# Output example:
# 📦 Module Information: git
# ├── Status: ✅ Enabled
# ├── Description: Git workflow automation and enhancements
# ├── Version: 1.0.2
# ├── Files: 15 files, 1,247 lines
# ├── Functions: 42 functions, 8 aliases
# ├── Dependencies: None
# ├── Last Modified: 2023-11-01 10:15:33
# ├── Documentation: modules/git/README.md
# └── Health: ✅ All functions accessible
```

**Information Includes:**
- Module status and metadata
- File and function counts
- Dependencies and requirements
- Documentation references
- Health and validation status

### Module Removal

#### `zmod remove <module>`
Removes a module with safety checks.

```bash
# Usage
zmod remove mymodule

# Interactive removal:
# 🗑️ Remove module 'mymodule'?
# 
# Module contents:
# total 16K
# drwxr-xr-x 2 user user 4.0K Nov  1 14:30 .
# drwxr-xr-x 6 user user 4.0K Nov  1 14:25 ..
# -rw-r--r-- 1 user user  245 Nov  1 14:30 mymodule.zsh
# -rw-r--r-- 1 user user  156 Nov  1 14:30 README.md
# 
# Delete module 'mymodule' permanently? [y/N]: y
# ✅ Module 'mymodule' removed
```

**Safety Features:**
- Shows module contents before removal
- Requires explicit confirmation
- Disables module first
- Creates backup before removal
- Validates removal success

## 🎯 Advanced Management Features

### Batch Operations

#### `zmod enable-all`
Enables all available modules.

```bash
# Usage
zmod enable-all

# With confirmation
zmod enable-all --confirm
```

#### `zmod disable-all`
Disables all modules (keeps core framework).

```bash
# Usage
zmod disable-all

# Keep specific modules
zmod disable-all --except git,dev
```

### Module Updates

#### `zmod update [module]`
Updates modules or entire framework.

```bash
# Update all modules
zmod update

# Update specific module
zmod update git

# Update framework core
zmod update --core

# Check for updates without applying
zmod update --check-only
```

### Health Monitoring

#### `zmod health [module]`
Performs health checks on modules.

```bash
# Check all modules
zmod health

# Check specific module  
zmod health git

# Detailed health report
zmod health --detailed
```

**Health Checks:**
- Function availability
- Syntax validation
- Performance testing
- Configuration validation
- Dependency verification

### Configuration Management

#### `zmod config [operation]`
Manages framework configuration.

```bash
# Show current configuration
zmod config show

# Edit configuration
zmod config edit

# Validate configuration
zmod config validate

# Reset to defaults
zmod config reset

# Export configuration
zmod config export > my-config.json

# Import configuration
zmod config import my-config.json
```

## 🔧 Manager Functions

### Core Management Functions

#### `zmod_main(command, args...)`
Main command dispatcher and argument handler.

```bash
# Command routing
zmod_main() {
    local command="$1"
    shift
    
    case "$command" in
        "list"|"ls") zmod_list "$@" ;;
        "enable") zmod_enable "$@" ;;
        "disable") zmod_disable "$@" ;;
        "status") zmod_status "$@" ;;
        "create") zmod_create "$@" ;;
        "remove") zmod_remove "$@" ;;
        "info") zmod_info "$@" ;;
        "update") zmod_update "$@" ;;
        "build") zmod_build_cache "$@" ;;
        "reload") zmod_reload "$@" ;;
        *) zmod_help "$@" ;;
    esac
}
```

#### `zmod_validate_module(module_name)`
Validates module name and existence.

```bash
# Validation process:
✅ Module name format (alphanumeric, hyphens, underscores)
✅ Module directory exists
✅ Main module file exists
✅ File permissions correct
✅ No naming conflicts
```

#### `zmod_get_module_info(module_name)`
Retrieves comprehensive module information.

```bash
# Information gathered:
- File count and sizes
- Function definitions
- Alias definitions  
- Dependencies
- Modification dates
- Health status
```

### Module Creation Functions

#### `zmod_create_module_structure(module_name, template)`
Creates module directory structure and files.

```bash
# Structure creation:
create_module_structure() {
    local module="$1"
    local template="${2:-basic}"
    local module_dir="$ZSH_MODULE_DIR/modules/$module"
    
    # Create directories
    mkdir -p "$module_dir"/{functions,aliases,completions,tests}
    
    # Create main module file
    create_main_module_file "$module_dir/$module.zsh" "$template"
    
    # Create documentation
    create_module_readme "$module_dir/README.md" "$module"
    
    # Set permissions
    chmod -R 755 "$module_dir"
}
```

#### `zmod_scaffold_templates()`
Provides module templates for different use cases.

```bash
# Available templates:
- basic: Simple module template
- git-extension: Git workflow extensions
- dev-tools: Development utilities
- network-utils: Network diagnostic tools
- system-admin: System administration tools
```

### Module Lifecycle Functions

#### `zmod_enable_module_safe(module_name)`
Safely enables module with validation and rollback.

```bash
# Safe enable process:
1. Validate module integrity
2. Check dependencies
3. Create configuration backup
4. Enable module
5. Test module loading
6. Rollback on failure
7. Report status
```

#### `zmod_remove_module_safe(module_name)`
Safely removes module with backup and confirmation.

```bash
# Safe removal process:
1. Confirm removal intent
2. Create module backup
3. Disable module
4. Remove files
5. Clean configuration
6. Verify removal
7. Provide recovery info
```

## 🛠️ Configuration

### Manager Configuration

| Variable | Description | Default | Options |
|----------|-------------|---------|---------|
| `ZSH_MODULE_AUTO_BUILD` | Auto-rebuild after changes | `true` | `true`, `false` |
| `ZSH_MODULE_BACKUP_ON_REMOVE` | Backup before removal | `true` | `true`, `false` |
| `ZSH_MODULE_CONFIRM_DESTRUCTIVE` | Confirm destructive operations | `true` | `true`, `false` |
| `ZSH_MODULE_TEMPLATE_DIR` | Custom template directory | `templates/` | Any path |

### Custom Templates

#### Creating Custom Templates
```bash
# Template structure
templates/my-template/
├── module.zsh.template      # Main module template
├── README.md.template       # Documentation template
├── functions/              # Function templates
└── manifest.json           # Template metadata
```

#### Template Variables
```bash
# Available in templates:
{{MODULE_NAME}}             # Module name
{{MODULE_DESCRIPTION}}      # Module description  
{{AUTHOR_NAME}}            # Author name
{{AUTHOR_EMAIL}}           # Author email
{{CREATION_DATE}}          # Creation date
{{FRAMEWORK_VERSION}}      # Framework version
```

## 🎨 Customization Examples

### Custom Management Commands
```bash
# Add to your .zshrc or custom module
function zmod-dev() {
    # Enable development modules only
    zmod disable-all
    zmod enable git dev system
    echo "✅ Development environment ready"
}

function zmod-minimal() {
    # Minimal setup
    zmod disable-all
    zmod enable git
    echo "✅ Minimal environment ready"
}
```

### Module Health Monitoring
```bash
# Automated health checks
function zmod-health-check() {
    echo "🏥 Module Health Check"
    
    for module in $(zmod list --enabled-only); do
        if zmod health "$module" --quiet; then
            echo "  ✅ $module: Healthy"
        else
            echo "  ❌ $module: Issues detected"
            zmod health "$module" --detailed
        fi
    done
}
```

### Backup Management
```bash
# Custom backup functions
function zmod-backup() {
    local backup_dir="$HOME/.zsh-module-backups/$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"
    
    cp -r "$ZSH_MODULE_DIR" "$backup_dir/framework"
    cp -r ~/.config/zsh-module "$backup_dir/config"
    
    echo "✅ Backup created: $backup_dir"
}
```

## 🚨 Error Handling

### Safe Operations
```bash
# Rollback on enable failure
enable_with_rollback() {
    local module="$1"
    local backup_config=$(mktemp)
    
    # Backup current config
    cp "$ZSH_MODULE_CONFIG" "$backup_config"
    
    # Attempt enable
    if zmod_enable "$module"; then
        # Test loading
        if ! test_module_loading "$module"; then
            echo "❌ Module loading failed, rolling back"
            cp "$backup_config" "$ZSH_MODULE_CONFIG"
            return 1
        fi
        echo "✅ Module enabled successfully"
    else
        echo "❌ Enable failed"
        return 1
    fi
    
    rm "$backup_config"
}
```

### Recovery Functions
```bash
# Emergency recovery
zmod_emergency_recovery() {
    echo "🚨 Emergency recovery mode"
    
    # Disable all modules
    echo "git" > "$ZSH_MODULE_CONFIG"  # Keep only git
    
    # Rebuild cache
    zmod build --safe
    
    # Test basic functionality
    if source "$ZSH_MODULE_CACHE_DIR/modules.zsh"; then
        echo "✅ Recovery successful"
    else
        echo "❌ Recovery failed, manual intervention required"
    fi
}
```

## 📊 Status and Monitoring

### Framework Metrics
```bash
# Collect framework metrics
zmod_collect_metrics() {
    local metrics_file="$ZSH_MODULE_CACHE_DIR/metrics.json"
    
    cat > "$metrics_file" << EOF
{
  "timestamp": "$(date -Iseconds)",
  "version": "$ZSH_MODULE_VERSION",
  "enabled_modules": $(zmod list --enabled-only | wc -l),
  "total_modules": $(zmod list | wc -l),
  "total_functions": $(count_total_functions),
  "cache_size": $(stat -f%z "$ZSH_MODULE_CACHE_DIR/modules.zsh" 2>/dev/null || stat -c%s "$ZSH_MODULE_CACHE_DIR/modules.zsh"),
  "load_time_ms": $(measure_current_load_time),
  "health_score": $(calculate_health_score)
}
EOF
}
```

### Performance Monitoring
```bash
# Monitor module performance
zmod_performance_report() {
    echo "📊 Performance Report"
    echo "├── Framework Load Time: $(measure_load_time)ms"
    echo "├── Cache Size: $(format_bytes $(get_cache_size))"
    echo "├── Function Count: $(count_total_functions)"
    echo "├── Memory Usage: $(get_memory_usage)MB"
    echo "└── Health Score: $(calculate_health_score)/100"
}
```

## 📚 Dependencies

### Required for Manager
- `zsh` 5.0+
- Core utilities (`mkdir`, `cp`, `mv`, `rm`, `chmod`)
- `grep`, `sed`, `awk` for text processing

### Optional
- `jq` - JSON processing for advanced features
- `fzf` - Interactive module selection
- `git` - Version control integration

## 🔮 Future Manager Features

### Planned Enhancements
- **GUI Module Manager** - Web-based management interface
- **Module Marketplace** - Community module repository
- **Automated Testing** - Continuous integration for modules
- **Dependency Management** - Advanced dependency resolution
- **Module Versioning** - Semantic versioning for modules
- **Remote Management** - Manage modules across multiple machines

### Advanced Commands
```bash
# Planned manager features
zmod marketplace search <query>        # Search module marketplace
zmod marketplace install <module>      # Install from marketplace
zmod test <module>                    # Run module tests
zmod deps resolve                     # Resolve dependencies
zmod version <module> <version>       # Pin module version
zmod remote sync                      # Sync with remote config
```

## 📚 Related Documentation

- [Installation](install.md) - Framework installation process
- [Build System](build.md) - Module building and optimization
- [Core Loader](../core/loader.md) - Module loading system
- [Configuration](../core/config.md) - Framework configuration system