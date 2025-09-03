# Core Loader System

The loader system (`core/loader.zsh`) is the heart of the ZSH Module Framework, responsible for module discovery, loading, and management.

## 📋 Overview

The loader provides:
- Module discovery and validation
- Dynamic module loading/unloading
- Configuration management
- Caching system integration
- Module state tracking

## 🔧 Core Functions

### Module Discovery

#### `zmod_discover_modules()`
Scans the modules directory and discovers available modules.

```bash
# Usage
zmod_discover_modules

# Internal function - called during framework initialization
```

**Behavior:**
- Scans `$ZSH_MODULE_DIR/modules/`
- Identifies valid module directories
- Updates internal module registry

### Module State Management

#### `zmod_is_enabled(module_name)`
Checks if a module is currently enabled.

```bash
# Usage
if zmod_is_enabled "git"; then
    echo "Git module is enabled"
fi

# Return codes
# 0 = enabled, 1 = disabled
```

**Implementation:**
- Checks `$ZSH_MODULE_CONFIG` file
- Uses both exact match and regex patterns
- Handles whitespace and formatting variations

#### `zmod_enable(module_name)`
Enables a module and adds it to the configuration.

```bash
# Usage
zmod_enable git
# ✅ Enabled module 'git'

zmod_enable nonexistent
# ❌ Module 'nonexistent' not found
```

**Process:**
1. Validates module exists
2. Checks if already enabled
3. Adds to configuration file
4. Rebuilds module cache
5. Provides user feedback

#### `zmod_disable(module_name)`
Disables a module and removes it from configuration.

```bash
# Usage
zmod_disable network
# ✅ Disabled module 'network'

zmod_disable notEnabled
# ⚠️ Module 'notEnabled' is not enabled
```

**Process:**
1. Validates module is enabled
2. Removes from configuration file (using temp file for safety)
3. Provides user feedback
4. Note: Does not rebuild cache automatically

### Module Loading

#### `zmod_load_module(module_name)`
Loads a specific module and all its component files.

```bash
# Usage (internal)
zmod_load_module git

# Loads all files from modules/git/
```

**Loading Process:**
1. Validates module directory exists
2. Sources all `.zsh` files in module directory
3. Handles loading errors gracefully
4. Updates loaded module tracking

#### `zmod_load_enabled_modules()`
Loads all currently enabled modules.

```bash
# Usage (internal - called during initialization)
zmod_load_enabled_modules
```

**Process:**
1. Reads enabled modules from configuration
2. Loads each enabled module in order
3. Handles individual module failures
4. Reports loading status

### Module Information

#### `zmod_list()`
Lists all available modules with their status.

```bash
# Usage
zmod list
# Available modules:
#   ✅ git
#   ❌ network
#   ✅ dev
#   ✅ system
```

**Display Format:**
- ✅ = Enabled module
- ❌ = Disabled module
- Sorted alphabetically

### Cache Management

#### `zmod_build_cache()`
Builds optimized module cache for faster loading.

```bash
# Usage
zmod build_cache
# 🔨 Building module cache...
# ✅ Cache built successfully
```

**Cache Process:**
1. Identifies all enabled modules
2. Concatenates module files
3. Generates optimized load script
4. Creates lazy loading registry (when enabled)
5. Outputs cache statistics

#### `zmod_reload()`
Reloads all modules and rebuilds cache.

```bash
# Usage
zmod reload
# 🔄 Reloading modules...
# 🔨 Building module cache...
# ✅ Modules reloaded successfully
```

**Reload Process:**
1. Rebuilds module cache
2. Sources updated cache
3. Refreshes all module functions
4. Updates module state

## 📁 File Structure

```
core/loader.zsh
├── Configuration Management
├── Module Discovery
├── Loading System
├── State Management
└── Cache Integration
```

## 🔧 Configuration Files

### Module Configuration
**Location:** `~/.config/zsh-module/enabled-modules`
**Format:** One module name per line

```
git
dev
system
```

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `ZSH_MODULE_DIR` | Framework installation directory | Auto-detected |
| `ZSH_MODULE_CONFIG` | Module configuration file | `~/.config/zsh-module/enabled-modules` |
| `ZSH_MODULE_LAZY_LOAD` | Enable lazy loading | `false` |

## ⚡ Performance Features

### Caching System
- Pre-concatenates enabled modules
- Eliminates multiple file system calls
- Reduces startup time significantly

### Error Handling
- Graceful degradation on module failures
- Detailed error reporting
- Safe configuration file operations

### Memory Management
- Minimal memory footprint
- Efficient module state tracking
- Clean unloading support (planned)

## 🚨 Error Handling

### Common Errors

#### Module Not Found
```bash
zmod_enable nonexistent
# ❌ Module 'nonexistent' not found
```

#### Read-only Configuration
```bash
# Fixed in v1.0.2 - was caused by using reserved 'status' variable
```

#### Cache Build Failures
- Handles individual module failures
- Reports specific file issues
- Continues with available modules

## 🔄 Module Lifecycle

1. **Discovery** → Scan modules directory
2. **Registration** → Add to available modules list
3. **Enabling** → Add to configuration file
4. **Loading** → Source module files
5. **Caching** → Build optimized cache
6. **Runtime** → Functions available for use
7. **Disabling** → Remove from configuration
8. **Cleanup** → Remove from cache (on rebuild)

## 📚 Dependencies

### Required
- `zsh` 5.0+
- Core utilities: `grep`, `sed`, `mv`, `mktemp`

### Optional
- `fzf` - For interactive module selection (planned)
- Modern core utilities for enhanced functionality

## 🔍 Debugging

### Debug Mode
```bash
# Enable debug output
ZSH_MODULE_DEBUG=true zmod reload

# Shows detailed loading information
```

### Common Issues
- **Slow loading**: Run `zmod build` to rebuild cache
- **Missing functions**: Check if module is enabled with `zmod list`
- **Config errors**: Verify `~/.config/zsh-module/enabled-modules` format
- **Permission issues**: Ensure config directory is writable

## 📈 Performance Metrics

Typical loading times (on modern hardware):
- **Without cache**: 50-100ms (4 modules)
- **With cache**: 10-20ms (4 modules)
- **Cache build time**: 100-200ms

## 🔮 Future Enhancements

- Lazy loading system completion
- Module dependency management
- Hot-reloading without shell restart
- Module versioning support
- Plugin ecosystem integration