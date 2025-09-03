# API Reference

Complete function reference for the ZSH Module Framework, organized by category and module.

## 📚 API Documentation Structure

### Core Framework API
- [Core Functions](core.md) - Framework core functions and utilities
- [Module Functions](modules.md) - All module functions organized by module
- [Utility Functions](utils.md) - Helper and utility functions

## 🔧 Core Framework Functions

### Configuration and Management
```bash
zmod_init_config()              # Initialize framework configuration
zmod_setup_directories()        # Create configuration directories
zmod_validate_config()          # Validate configuration setup
```

### Module Management
```bash
zmod_is_enabled(module)         # Check if module is enabled
zmod_enable(module)             # Enable a module  
zmod_disable(module)            # Disable a module
zmod_list()                     # List available modules
zmod_load_module(module)        # Load a specific module
zmod_load_enabled_modules()     # Load all enabled modules
```

### Build and Cache System
```bash
zmod_build_cache()              # Build module cache
zmod_reload()                   # Reload all modules
zmod_discover_modules()         # Discover available modules
```

## 🚀 Module Functions by Category

### Git Module (`modules/git/`)
#### Status and Information
```bash
status                          # Enhanced git status with colors
stats [options]                 # Repository statistics
log [options]                   # Enhanced git log
blame [file] [options]          # Enhanced git blame
```

#### Branch Management
```bash
branch [options] [name]         # Branch management commands
working [command] [branch]      # Working branch system
swap [branch]                   # Quick branch switching
```

#### Commit and Changes
```bash
commit [message] [flags]        # Smart commit workflow
stash [message]                 # Create stash with message
stash-list                      # Interactive stash manager
apply [stash_id]                # Apply stash
differ [branch]                 # Interactive file diff viewer
```

#### Repository Operations
```bash
gclean [options]                # Repository cleanup
undo [type] [options]           # Safe undo operations
find [pattern] [options]        # Search git history
pull-rebase                     # Pull with rebase
push-upstream                   # Push and set upstream
```

### Development Module (`modules/dev/`)
#### Server Management
```bash
serve [port] [options]          # Auto-detect and start dev server
serve-stop                      # Stop development server
serve-restart                   # Restart development server
serve-status                    # Show server status
```

#### Package Management
```bash
install [packages...]           # Universal package installer
uninstall [packages...]         # Remove packages
deps [command]                  # Dependency management
```

#### Build and Testing
```bash
build [target] [options]        # Universal build command
test [pattern] [options]        # Universal test runner
lint [files...] [options]       # Code formatting and linting
```

#### Project Management
```bash
init [template] [name]          # Initialize new projects
run [script] [args...]          # Run package scripts
dev-status                      # Development environment status
```

### System Module (`modules/system/`)
#### File Operations
```bash
ll                              # Enhanced long listing
la                              # List all files (including hidden)
lt                              # Tree view listing
f [pattern] [path]              # Smart find utility
g [pattern] [path]              # Smart grep utility
```

#### Archive Operations
```bash
extract [file]                  # Universal archive extractor
archive [type] [name] [files]   # Create archives
```

#### Process Management
```bash
psg [pattern]                   # Enhanced process search
pk [pattern]                    # Safe process killing
service [action] [service]      # Service management
```

#### System Information
```bash
sysinfo                         # Comprehensive system info
disk-usage [path]               # Enhanced disk usage
weather [location]              # Weather information
ip-info [ip]                    # IP address information
```

### Network Module (`modules/network/`)
#### Web Diagnostics
```bash
httpstatus [url]                # HTTP status checker
httpheaders [url]               # HTTP response headers
speedtest                       # Internet speed testing
```

#### Network Information
```bash
netinfo                         # Network interface information
sslcheck [domain] [port]        # SSL certificate validation
nettest [options]               # Comprehensive connectivity testing
```

#### Troubleshooting
```bash
netdebug [target]               # Network debugging utilities
portcheck [host] [port]         # Check port accessibility
dnsinfo [domain]                # DNS record information
```

## 🔧 Utility Functions

### Git Integration
```bash
zmod_is_git_repo()              # Check if current directory is git repo
```

### Command Detection
```bash
zmod_has_command(command)       # Check if command is available
```

### Text Processing and Colors
```bash
zmod_color(color, text)         # Apply color formatting to text
zmod_format_list(items, format) # Format arrays and lists
zmod_trim(string)               # Remove leading/trailing whitespace
zmod_split(string, delimiter)   # Split string into array
zmod_join(array, delimiter)     # Join array elements
```

### File System Operations
```bash
zmod_find_up(filename, start)   # Search for file walking up directory tree
zmod_get_relative_path(from, to) # Calculate relative path
zmod_is_safe_path(path)         # Validate path safety
```

### Performance and Timing
```bash
zmod_timer_start(name)          # Start named performance timer
zmod_timer_end(name)            # End timer and return duration
```

### User Interaction
```bash
zmod_confirm(message, default)  # Prompt for yes/no confirmation
```

### Cross-Platform Compatibility
```bash
zmod_detect_os()                # Detect current operating system
zmod_get_clipboard_cmd()        # Get appropriate clipboard command
```

## 📋 Function Categories

### By Functionality

#### File and Directory Operations
- `ll`, `la`, `lt` - Enhanced file listings
- `f` - Smart find utility
- `extract`, `archive` - Archive operations
- `zmod_find_up()` - Directory traversal search

#### Git and Version Control
- `status`, `commit`, `branch` - Core git operations
- `stash-list`, `apply` - Stash management
- `differ`, `log`, `stats` - Repository analysis
- `working` - Working branch system

#### Development Workflow
- `serve` - Development server management
- `install`, `build`, `test` - Development lifecycle
- `lint`, `init` - Code quality and project setup
- `run` - Script execution

#### System Administration
- `psg`, `pk`, `service` - Process and service management
- `sysinfo`, `disk-usage` - System monitoring
- `netinfo`, `httpstatus` - Network diagnostics

#### Text Processing
- `g` - Enhanced grep functionality
- `zmod_color()` - Text coloring
- `zmod_trim()`, `zmod_split()` - String manipulation

### By Module

#### Core Framework (Always Available)
```bash
zmod_is_git_repo()
zmod_has_command()
zmod_color()
zmod_timer_start()
zmod_timer_end()
zmod_confirm()
zmod_detect_os()
# ... and other core utilities
```

#### Git Module (When Enabled)
```bash
status, commit, branch, stash-list, differ
working, swap, log, stats, blame
gclean, undo, find, apply
gpu, gpr  # aliases
```

#### Development Module (When Enabled)
```bash
serve, install, build, test, lint
init, run, dev-status
serve-stop, serve-restart, serve-status
deps, dev-env  # advanced features
```

#### System Module (When Enabled)
```bash
ll, la, lt, f, g
extract, archive
psg, pk, service
sysinfo, disk-usage, weather, ip-info
```

#### Network Module (When Enabled)
```bash
httpstatus, speedtest, netinfo
sslcheck, nettest, netdebug
portcheck, dnsinfo
httpheaders  # advanced features
```

## 📚 Usage Examples

### Core Framework
```bash
# Check if in git repository
if zmod_is_git_repo; then
    echo "This is a git repository"
fi

# Check command availability
if zmod_has_command "fzf"; then
    # Use fzf for selection
fi

# Apply colors
echo $(zmod_color red "Error message")
echo $(zmod_color green "Success message")
```

### Git Module
```bash
# Enhanced status
status

# Smart commit
commit "feat: add new feature"

# Interactive stash management
stash-list

# File difference viewer
differ main
```

### Development Module
```bash
# Start development server
serve

# Install dependencies
install

# Run tests with coverage
test --coverage

# Build for production
build production
```

### System Module
```bash
# Enhanced file listing
ll

# Smart find
f "*.js" ~/projects

# Extract any archive
extract package.zip
```

### Network Module
```bash
# Check website status
httpstatus https://google.com

# Test internet speed
speedtest

# Validate SSL certificate
sslcheck github.com
```

## 🔗 Function Dependencies

### Internal Dependencies
- Most module functions depend on core utilities (`zmod_is_git_repo`, `zmod_has_command`, etc.)
- Git module functions require `zmod_is_git_repo()` validation
- Enhanced functions prefer modern tools but fallback to standard tools

### External Dependencies
- Git module requires `git`
- Development module requires language-specific tools (`node`, `python`, etc.)
- System module enhanced features require modern alternatives (`exa`, `fd`, `rg`)
- Network module requires network utilities (`curl`, `netcat`)

## 📊 API Stability

### Stable API (v1.x compatibility guaranteed)
- Core utility functions (`zmod_*`)
- Main module functions (`status`, `commit`, `serve`, `ll`, etc.)
- Standard command interfaces

### Evolving API (may change in minor versions)
- Advanced features and options
- Internal helper functions
- Debug and development functions

### Experimental API (may change or be removed)
- Functions marked with `_experimental` suffix
- Alpha features in development
- Platform-specific functions

## 📚 Related Documentation

- [Core Framework](../core/) - Detailed core system documentation
- [Modules](../modules/) - Individual module documentation
- [Scripts](../scripts/) - Management and build systems
- [Installation](../scripts/install.md) - Setup and configuration