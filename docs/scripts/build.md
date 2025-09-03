# Build System

The build system optimizes the ZSH Module Framework for faster loading through caching, concatenation, and performance optimization techniques.

## 📋 Overview

The build system provides:
- Module caching and concatenation
- Performance optimization
- Lazy loading registry generation
- Build artifact management
- Development vs production builds
- Incremental build support

## 📁 Build Structure

```
scripts/build.zsh         # Main build script
dist/                     # Built artifacts
├── modules.zsh          # Concatenated modules
├── lazy-registry.zsh    # Lazy loading registry
├── build-info.json      # Build metadata
└── performance.log      # Build performance data
```

## 🚀 Build Process

### Standard Build

```bash
# Build all enabled modules
./scripts/build.zsh

# Or using zmod command
zmod build
```

**Build Output Example:**
```
🔨 Building ZSH Module Framework
├── Scanning modules... ✅ Found 4 enabled modules
├── Validating syntax... ✅ All modules valid
├── Building cache... ✅ Generated modules.zsh (1,247 lines)
├── Creating lazy registry... ✅ 23 functions registered
├── Optimizing... ✅ Removed 15% whitespace
├── Performance test... ✅ Load time: 42ms
└── Build complete! 🎉

📊 Build Statistics:
├── Total Functions: 127
├── Module Files: 26
├── Cache Size: 89KB
├── Compression: 23% smaller
└── Load Time: 42ms (68% faster)
```

### Build Options

#### Development Build
```bash
# Development build with debug info
./scripts/build.zsh --dev

# Features:
- Preserves comments and formatting
- Includes debug information
- Adds performance timing
- Enables verbose output
```

#### Production Build
```bash
# Production build (optimized)
./scripts/build.zsh --prod

# Features:  
- Removes comments and debug code
- Minifies whitespace
- Optimizes function definitions
- Maximum performance
```

#### Incremental Build
```bash
# Only rebuild changed modules
./scripts/build.zsh --incremental

# Checks:
- Module file modification times
- Configuration changes
- Dependency updates
```

## 🔧 Build Functions

### Core Build Functions

#### `build_main()`
Main build orchestration function.

```bash
# Build process:
1. Environment setup
2. Module discovery and validation
3. Dependency resolution
4. Cache generation
5. Lazy loading registry creation
6. Optimization
7. Performance testing
8. Artifact cleanup
```

#### `discover_enabled_modules()`
Identifies enabled modules for building.

```bash
# Discovery process:
✅ Read enabled-modules configuration
✅ Validate module directories exist
✅ Check file permissions
✅ Resolve dependencies
✅ Determine build order
```

#### `validate_modules()`
Validates module syntax and structure.

```bash
# Validation checks:
✅ zsh syntax validation (zsh -n)
✅ Function naming conventions
✅ Required function presence
✅ Module structure compliance
✅ Dependency validation
```

### Cache Generation

#### `build_module_cache()`
Creates concatenated module cache file.

```bash
# Cache generation process:
build_module_cache() {
    local cache_file="$ZSH_MODULE_CACHE_DIR/modules.zsh"
    local temp_file=$(mktemp)
    
    echo "# Generated module cache - $(date)" > "$temp_file"
    echo "# DO NOT EDIT - Regenerate with 'zmod build'" >> "$temp_file"
    echo >> "$temp_file"
    
    # Add modules in dependency order
    for module in $(get_build_order); do
        echo "# ============= $module module =============" >> "$temp_file"
        concatenate_module_files "$module" >> "$temp_file"
        echo >> "$temp_file"
    done
    
    mv "$temp_file" "$cache_file"
    chmod 644 "$cache_file"
}
```

**Cache Features:**
- Preserves function definitions
- Maintains proper scoping
- Includes module metadata
- Handles dependencies correctly

#### `build_lazy_registry()`
Creates lazy loading function registry.

```bash
# Registry format:
# Function -> Module mapping for lazy loading
typeset -gA ZSH_MODULE_LAZY_FUNCTIONS
ZSH_MODULE_LAZY_FUNCTIONS[git_status]="git"
ZSH_MODULE_LAZY_FUNCTIONS[serve]="dev"
ZSH_MODULE_LAZY_FUNCTIONS[ll]="system"
```

### Optimization

#### `optimize_cache()`
Optimizes generated cache for performance.

```bash
# Optimization techniques:
1. Remove unnecessary whitespace
2. Optimize variable assignments
3. Combine similar operations
4. Remove debug statements (production)
5. Compress repeated patterns
```

#### `minify_functions()`
Minifies function definitions while preserving functionality.

```bash
# Minification process:
- Remove comments (except essential)
- Reduce whitespace
- Optimize control structures
- Preserve functionality
```

### Performance Testing

#### `test_build_performance()`
Tests build performance and loading speed.

```bash
# Performance metrics:
✅ Cache loading time
✅ Function availability
✅ Memory usage
✅ Startup overhead
✅ Function execution time
```

## 📊 Build Optimization

### Caching Strategy

#### File-Level Caching
```bash
# Caches entire module files
~/.config/zsh-module/cache/
├── modules.zsh              # All enabled modules
├── git.zsh.cache           # Individual module cache
├── dev.zsh.cache           # Individual module cache  
└── last-build.timestamp    # Build timestamp
```

#### Function-Level Caching
```bash
# Lazy loading with function registry
ZSH_MODULE_LAZY_FUNCTIONS=(
    [status]="git"
    [commit]="git"
    [serve]="dev"
    [build]="dev"
    [ll]="system"
    [f]="system"
)
```

### Build Performance

#### Parallel Processing
```bash
# Parallel module validation
validate_modules_parallel() {
    local modules=($@)
    local pids=()
    
    for module in "${modules[@]}"; do
        validate_single_module "$module" &
        pids+=($!)
    done
    
    # Wait for all validations to complete
    for pid in "${pids[@]}"; do
        wait $pid || return 1
    done
}
```

#### Incremental Building
```bash
# Only rebuild changed components
should_rebuild_module() {
    local module="$1"
    local module_dir="$ZSH_MODULE_DIR/modules/$module"
    local cache_file="$ZSH_MODULE_CACHE_DIR/$module.zsh.cache"
    
    # Check if cache exists and is newer than module files
    if [[ -f "$cache_file" ]]; then
        find "$module_dir" -name "*.zsh" -newer "$cache_file" | grep -q .
        return $?
    else
        return 0  # No cache, needs rebuild
    fi
}
```

## 🎯 Advanced Build Features

### Conditional Compilation
```bash
# Build different versions based on environment
build_conditional() {
    if [[ "$BUILD_ENV" == "development" ]]; then
        include_debug_functions
        preserve_comments
        enable_timing
    else
        remove_debug_functions
        minify_output
        optimize_performance
    fi
}
```

### Module Dependencies
```bash
# Handle module dependencies during build
resolve_dependencies() {
    local module="$1"
    local deps_file="$ZSH_MODULE_DIR/modules/$module/dependencies.txt"
    
    if [[ -f "$deps_file" ]]; then
        while IFS= read -r dep; do
            if ! module_is_enabled "$dep"; then
                echo "Warning: $module requires $dep module"
            fi
        done < "$deps_file"
    fi
}
```

### Build Hooks
```bash
# Pre/post build hooks for customization
run_build_hooks() {
    local phase="$1"  # pre_build, post_build, pre_module, post_module
    local hook_dir="$ZSH_MODULE_DIR/hooks/$phase"
    
    if [[ -d "$hook_dir" ]]; then
        for hook in "$hook_dir"/*.zsh; do
            [[ -x "$hook" ]] && source "$hook"
        done
    fi
}
```

## 🛠️ Build Configuration

### Environment Variables

| Variable | Description | Default | Options |
|----------|-------------|---------|---------|
| `ZSH_MODULE_BUILD_ENV` | Build environment | `production` | `development`, `production` |
| `ZSH_MODULE_BUILD_PARALLEL` | Enable parallel building | `true` | `true`, `false` |
| `ZSH_MODULE_BUILD_MINIFY` | Enable minification | `true` | `true`, `false` |
| `ZSH_MODULE_BUILD_DEBUG` | Include debug info | `false` | `true`, `false` |

### Build Configuration File
```bash
# .buildrc in project root
BUILD_ENV=production
PARALLEL_BUILD=true
MINIFY_OUTPUT=true
INCLUDE_DEBUG=false
OPTIMIZE_LEVEL=2
COMPRESSION=true
```

### Custom Build Settings
```bash
# Environment-specific builds
export ZSH_MODULE_BUILD_ENV=development
export ZSH_MODULE_BUILD_DEBUG=true
export ZSH_MODULE_BUILD_MINIFY=false

./scripts/build.zsh
```

## 🚨 Error Handling

### Build Validation
```bash
# Comprehensive build validation
validate_build() {
    local cache_file="$1"
    
    # Syntax validation
    if ! zsh -n "$cache_file"; then
        echo "❌ Build failed: syntax errors in cache"
        return 1
    fi
    
    # Function availability test
    if ! test_function_availability "$cache_file"; then
        echo "❌ Build failed: functions not accessible"
        return 1
    fi
    
    # Performance test
    if ! test_loading_performance "$cache_file"; then
        echo "⚠️ Build warning: performance degraded"
    fi
    
    echo "✅ Build validation passed"
}
```

### Recovery Mechanisms
```bash
# Automatic build recovery
recover_from_build_failure() {
    echo "🔄 Attempting build recovery..."
    
    # Clean cache
    rm -rf "$ZSH_MODULE_CACHE_DIR"/*
    
    # Validate modules individually
    for module in $(get_enabled_modules); do
        if ! validate_single_module "$module"; then
            echo "❌ Module $module has issues, disabling temporarily"
            disable_module "$module"
        fi
    done
    
    # Retry build
    ./scripts/build.zsh --safe-mode
}
```

## 📊 Build Metrics

### Performance Monitoring
```bash
# Build performance tracking
track_build_performance() {
    local start_time=$(date +%s%3N)
    
    # Run build
    build_modules
    
    local end_time=$(date +%s%3N)
    local duration=$((end_time - start_time))
    
    # Log metrics
    echo "Build completed in ${duration}ms" >> "$ZSH_MODULE_CACHE_DIR/performance.log"
    
    # Test loading performance
    test_loading_time >> "$ZSH_MODULE_CACHE_DIR/performance.log"
}
```

### Build Statistics
```bash
# Generate build statistics
generate_build_stats() {
    local stats_file="$ZSH_MODULE_CACHE_DIR/build-stats.json"
    
    cat > "$stats_file" << EOF
{
  "build_time": "$(date -Iseconds)",
  "modules_count": $(get_enabled_modules | wc -l),
  "functions_count": $(count_functions_in_cache),
  "cache_size": $(stat -f%z "$ZSH_MODULE_CACHE_DIR/modules.zsh" 2>/dev/null || stat -c%s "$ZSH_MODULE_CACHE_DIR/modules.zsh"),
  "load_time_ms": $(measure_load_time),
  "optimization_ratio": $(calculate_optimization_ratio)
}
EOF
}
```

## 🔍 Debugging Builds

### Debug Mode
```bash
# Enable debug mode
export ZSH_MODULE_BUILD_DEBUG=true
./scripts/build.zsh

# Debug output includes:
- Module discovery details
- File processing steps  
- Optimization decisions
- Performance measurements
- Error contexts
```

### Build Inspection
```bash
# Inspect build artifacts
zmod build --inspect

# Shows:
- Module dependency tree
- Function definitions
- Cache composition
- Performance metrics
- Build warnings
```

### Manual Testing
```bash
# Test specific build components
test_module_cache() {
    local cache_file="$ZSH_MODULE_CACHE_DIR/modules.zsh"
    
    # Load in isolated environment
    (
        unset ZSH_MODULE_*
        source "$cache_file"
        
        # Test function availability
        type status >/dev/null && echo "✅ Git functions loaded"
        type serve >/dev/null && echo "✅ Dev functions loaded"
        type ll >/dev/null && echo "✅ System functions loaded"
    )
}
```

## 📚 Dependencies

### Build Dependencies
- `zsh` 5.0+ - Syntax validation
- `grep`, `sed`, `awk` - Text processing
- `find`, `xargs` - File operations
- `stat`, `wc` - File statistics

### Optional Dependencies
- `parallel` - Parallel processing
- `jq` - JSON processing for metrics
- Modern `find` - Better performance

## 🔮 Future Build Features

### Planned Enhancements
- **Webpack-style Module Bundling** - Advanced dependency resolution
- **Tree Shaking** - Remove unused functions
- **Source Maps** - Debug original module files
- **Hot Reloading** - Live module updates
- **Build Plugins** - Extensible build system
- **Distributed Builds** - Build across multiple machines

### Advanced Build Commands
```bash
# Planned build features
zmod build --tree-shake          # Remove unused functions
zmod build --source-maps         # Generate debug maps
zmod build --profile            # Performance profiling
zmod build --watch              # Continuous building
zmod build --plugin webpack     # Use build plugin
```

## 📚 Related Documentation

- [Installation](install.md) - Framework installation process
- [Module Manager](manager.md) - Module lifecycle management  
- [Core Loader](../core/loader.md) - Module loading system
- [Configuration](../core/config.md) - Framework configuration