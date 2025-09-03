# System Module

The System module provides enhanced system utilities, file operations, process management, and system information tools that improve upon standard Unix commands.

## 📋 Overview

The System module includes:
- Enhanced file listing with icons and git integration
- Smart find and search utilities
- Archive and compression operations
- Process management and system monitoring
- System information and diagnostics
- Cross-platform compatibility utilities

## 📁 Module Structure

```
modules/system/
└── system.zsh    # Complete system module (all functions in one file)
```

## 🚀 Core Commands

### Enhanced File Operations

#### `ll`, `la`, `lt`
Enhanced file listing with modern features.

```bash
# Usage
ll                      # Long format listing
la                      # All files (including hidden)
lt                      # Tree view listing

# Output features:
# - File type icons
# - Git status indicators
# - Color-coded file types
# - Human-readable sizes
# - Modern column layout
```

**Features:**
- **Icons**: File type icons for quick recognition
- **Git Integration**: Shows git status (M, A, ??, etc.) next to files
- **Smart Colors**: Color-coded by file type and status
- **Modern Tools**: Uses `exa`/`eza` if available, falls back to `ls`
- **Responsive Layout**: Adapts to terminal width

**Implementation:**
```bash
# Uses modern tools when available
if zmod_has_command "exa"; then
    alias ll="exa -la --icons --git"
    alias lt="exa --tree --icons --git"
elif zmod_has_command "eza"; then
    alias ll="eza -la --icons --git"
    alias lt="eza --tree --icons --git"
else
    alias ll="ls -la --color=auto"
    alias lt="tree -C"
fi
```

### Smart Search Tools

#### `f [pattern] [path]`
Smart find utility with modern tool integration.

```bash
# Usage
f "*.js"                    # Find JavaScript files
f "config" ~/projects       # Find files containing "config"  
f "test" --type f           # Find only files (not directories)
f "node_modules" --exclude  # Find excluding node_modules
```

**Tool Priority:**
1. **fd** - Modern, fast alternative to find
2. **find** - Traditional Unix find (fallback)

**Features:**
- Respects `.gitignore` and other ignore files
- Smart exclusions (node_modules, .git, etc.)
- Fast parallel search
- Color-coded results
- Type filtering (files, directories, symlinks)

#### `g [pattern] [path]`
Smart grep utility with enhanced search capabilities.

```bash
# Usage
g "function.*test"          # Regex search
g "TODO" --exclude="*.log"  # Exclude file types
g "import" --js             # Search only JavaScript files
g "class" --context=3       # Show 3 lines of context
```

**Tool Priority:**
1. **ripgrep (rg)** - Extremely fast text search
2. **ag (the_silver_searcher)** - Fast alternative
3. **grep** - Traditional grep (fallback)

**Features:**
- Respects ignore files (.gitignore, .rgignore)
- Context lines around matches
- File type filtering
- Color-coded output
- Multi-threaded search
- Smart case sensitivity

### Archive Operations

#### `extract [file]`
Universal archive extractor supporting multiple formats.

```bash
# Usage
extract file.tar.gz         # Extract tar.gz
extract archive.zip         # Extract zip
extract data.rar           # Extract rar
extract backup.7z          # Extract 7z
extract multiple files*    # Extract multiple archives
```

**Supported Formats:**
- **Tar**: `.tar`, `.tar.gz`, `.tgz`, `.tar.bz2`, `.tbz2`, `.tar.xz`
- **Zip**: `.zip`, `.jar`, `.war`, `.ear`
- **Rar**: `.rar`
- **7-Zip**: `.7z`
- **Other**: `.Z`, `.gz`, `.bz2`, `.xz`, `.lzma`

**Features:**
- Auto-detects format from extension
- Creates directory if archive contains multiple files
- Preserves file permissions
- Shows extraction progress
- Validates archive integrity

#### `archive [type] [name] [files...]`
Create archives in various formats.

```bash
# Usage
archive zip backup.zip src/ docs/      # Create zip archive
archive tar backup.tar.gz project/     # Create tar.gz
archive 7z data.7z important_files/    # Create 7z archive
```

**Supported Creation:**
- **zip**: Cross-platform compatibility
- **tar.gz**: Unix standard
- **7z**: High compression ratio
- **tar.xz**: Modern compression

### Process Management

#### `psg [pattern]`
Enhanced process search with filtering.

```bash
# Usage
psg node                    # Find Node.js processes
psg :3000                  # Find processes using port 3000
psg --user $USER           # Find processes by current user
psg --tree                 # Show process tree
```

**Features:**
- Color-coded process information
- Memory and CPU usage display
- Process tree visualization
- Port usage detection
- User filtering

#### `pk [pattern]`
Safe process killing with confirmation.

```bash
# Usage
pk node                     # Kill Node.js processes (with confirmation)
pk --force 1234            # Force kill specific PID
pk --signal TERM myapp     # Send specific signal
```

**Safety Features:**
- Shows processes before killing
- Requires confirmation for destructive actions
- Supports different signals (TERM, KILL, etc.)
- Protects system processes

#### `service [action] [service_name]`
Service management wrapper.

```bash
# Usage
service status nginx        # Check service status
service restart apache2     # Restart service
service list               # List all services
service enable postgresql  # Enable service at startup
```

**Cross-Platform:**
- **systemd** (Linux)
- **launchctl** (macOS)
- **service** (traditional Unix)

### System Information

#### `sysinfo`
Comprehensive system information display.

```bash
# Usage
sysinfo

# Example output:
# 🖥️  System Information
# ├── OS: Ubuntu 22.04 LTS
# ├── Kernel: 5.15.0-58-generic
# ├── CPU: Intel Core i7-9750H @ 2.60GHz (12 cores)
# ├── Memory: 15.3GB / 32.0GB (48% used)
# ├── Disk: 234GB / 512GB (46% used)
# ├── Uptime: 2 days, 14 hours, 32 minutes
# └── Load: 1.23, 1.45, 1.67
```

**Information Includes:**
- Operating system and version
- Kernel version
- CPU information and load
- Memory usage statistics
- Disk space usage
- System uptime
- Network interfaces (summary)
- Currently logged-in users

**Features:**
- Color-coded status indicators
- Progress bars for usage metrics
- Cross-platform compatibility
- Caches information for performance

### System Utilities

#### `weather [location]`
Weather information from command line.

```bash
# Usage
weather                     # Weather for current location
weather "New York"         # Weather for specific city
weather --forecast         # Extended forecast
```

**Features:**
- Current weather conditions
- Temperature in multiple units
- Extended forecasts
- Location auto-detection
- Colored output

#### `ip-info [ip]`
IP address information lookup.

```bash
# Usage
ip-info                     # Info about current public IP
ip-info 8.8.8.8            # Info about specific IP
ip-info --local            # Show local network information
```

**Information Includes:**
- Public IP address
- Geographic location
- ISP information
- Network details
- Security status

#### `disk-usage [path]`
Enhanced disk usage analysis.

```bash
# Usage  
disk-usage                  # Current directory usage
disk-usage /home           # Specific directory
disk-usage --top 10        # Show top 10 largest items
```

**Features:**
- Visual size representation
- Sorted by size
- Excludes common junk directories
- Shows both absolute and relative sizes
- Color-coded size categories

## 🎯 Advanced Features

### Performance Monitoring

#### System Performance
```bash
# CPU and memory monitoring
function monitor() {
    while true; do
        clear
        sysinfo
        echo "\n$(zmod_color blue '=== Top Processes ===')"
        if zmod_has_command "htop"; then
            htop -n 10
        else
            top -n 10
        fi
        sleep 5
    done
}
```

#### Network Monitoring
```bash
# Network usage monitoring
function netmon() {
    if zmod_has_command "iftop"; then
        sudo iftop
    elif zmod_has_command "nethogs"; then
        sudo nethogs
    else
        netstat -i
    fi
}
```

### File System Operations

#### Bulk Operations
```bash
# Bulk rename using modern tools
function rename-bulk() {
    if zmod_has_command "rename"; then
        rename "$1" "$2" *
    elif zmod_has_command "mmv"; then
        mmv "$1" "$2"
    else
        echo "Install 'rename' or 'mmv' for bulk renaming"
    fi
}
```

#### Safe File Operations
```bash
# Safe file deletion with confirmation
function rm-safe() {
    local files=("$@")
    echo "Files to be deleted:"
    for file in "${files[@]}"; do
        echo "  $(zmod_color red "✗") $file"
    done
    
    if zmod_confirm "Delete these files?" "n"; then
        rm -rf "${files[@]}"
        echo $(zmod_color green "✅ Files deleted")
    else
        echo "Operation cancelled"
    fi
}
```

## 🛠️ Configuration

### Environment Variables

| Variable | Description | Default | Options |
|----------|-------------|---------|---------|
| `ZSH_MODULE_LS_TOOL` | Preferred ls alternative | Auto-detect | `exa`, `eza`, `ls` |
| `ZSH_MODULE_FIND_TOOL` | Preferred find tool | Auto-detect | `fd`, `find` |
| `ZSH_MODULE_GREP_TOOL` | Preferred grep tool | Auto-detect | `rg`, `ag`, `grep` |
| `ZSH_MODULE_SHOW_ICONS` | Show file icons | `true` | `true`, `false` |

### Tool Preferences
```bash
# Force specific tools
export ZSH_MODULE_LS_TOOL="exa"
export ZSH_MODULE_FIND_TOOL="fd"
export ZSH_MODULE_GREP_TOOL="rg"

# Disable icons for compatibility
export ZSH_MODULE_SHOW_ICONS=false
```

## 🎨 Customization Examples

### Custom File Listings
```bash
# Custom listing functions
function lll() {
    ll | grep "$(date +%Y-%m-%d)"  # Files modified today
}

function lls() {
    ll | sort -k5 -nr  # Sort by size (largest first)
}

function llg() {
    ll | grep -i "$1"  # Search in listings
}
```

### Enhanced Search
```bash
# Project-specific search
function search-code() {
    g "$1" --type-add "code:*.{js,ts,py,go,rs,c,cpp,h}" --type code
}

function search-config() {
    g "$1" --type-add "config:*.{json,yaml,yml,toml,ini,conf}" --type config
}
```

### System Monitoring
```bash
# Custom system alerts
function disk-alert() {
    local usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    if [[ $usage -gt 85 ]]; then
        echo $(zmod_color red "🚨 Disk usage critical: ${usage}%")
    elif [[ $usage -gt 75 ]]; then
        echo $(zmod_color yellow "⚠️ Disk usage high: ${usage}%")
    fi
}
```

## 🚨 Error Handling

### File Operation Safety
```bash
# Prevent accidental overwrites
function cp-safe() {
    if [[ -e "$2" ]]; then
        if ! zmod_confirm "Overwrite $2?" "n"; then
            echo "Copy cancelled"
            return 1
        fi
    fi
    cp "$1" "$2"
}
```

### Archive Validation
```bash
# Validate archives before extraction
function extract-safe() {
    local archive="$1"
    
    # Check if file exists
    if [[ ! -f "$archive" ]]; then
        echo $(zmod_color red "❌ File not found: $archive")
        return 1
    fi
    
    # Validate archive integrity
    case "$archive" in
        *.zip) unzip -t "$archive" >/dev/null ;;
        *.tar.gz|*.tgz) tar -tzf "$archive" >/dev/null ;;
        *.tar) tar -tf "$archive" >/dev/null ;;
        *) echo "Archive validation not supported for this format" ;;
    esac
    
    if [[ $? -eq 0 ]]; then
        extract "$archive"
    else
        echo $(zmod_color red "❌ Archive appears to be corrupted")
        return 1
    fi
}
```

## 📊 Performance Features

### Caching
- Command existence checks are cached
- System information is cached for short periods
- File listings use efficient tools

### Modern Tool Integration
- Automatically uses faster alternatives when available
- Falls back gracefully to standard tools
- Respects user preferences

## 🔍 Troubleshooting

### Common Issues

#### Icons Not Displaying
```bash
# Install a Nerd Font or disable icons
export ZSH_MODULE_SHOW_ICONS=false
```

#### Tools Not Found
```bash
# Install modern alternatives
# Ubuntu/Debian
sudo apt install exa fd-find ripgrep

# macOS
brew install exa fd ripgrep

# Or use fallbacks
export ZSH_MODULE_LS_TOOL="ls"
export ZSH_MODULE_FIND_TOOL="find"
export ZSH_MODULE_GREP_TOOL="grep"
```

#### Permission Issues
```bash
# Use sudo for system operations
sudo service restart nginx
sudo pk --force stubborn_process
```

## 📚 Dependencies

### Required
- `zsh` 5.0+
- Standard Unix utilities (`ls`, `find`, `grep`, `tar`, `unzip`)

### Recommended
- **exa** or **eza** - Modern ls replacement
- **fd** - Modern find replacement  
- **ripgrep (rg)** - Fast text search
- **bat** - Enhanced cat with syntax highlighting
- **htop** - Interactive process viewer
- **tree** - Directory tree display

### Optional
- **7zip** - 7z archive support
- **unrar** - RAR archive support
- **iftop** - Network monitoring
- **nethogs** - Per-process network monitoring

## 🔮 Future Enhancements

### Planned Features
- **File Preview Integration** - Quick file previews with `bat`, `fzf`
- **Smart Bookmarks** - Quick directory navigation
- **System Health Monitoring** - Automated system checks
- **Cloud Integration** - Cloud storage operations
- **Security Tools** - File integrity checking, permission auditing

### Advanced System Integration
```bash
# Planned commands
bookmark add ~/projects              # Add directory bookmark
bookmark list                        # List bookmarks
health-check                        # System health analysis
secure-audit /path                  # Security audit
cloud-sync ~/documents              # Cloud synchronization
```

## 📚 Related Documentation

- [Development Module](dev.md) - Development tool integration  
- [Network Module](network.md) - Network utilities and diagnostics
- [Core Utilities](../core/utils.md) - Framework utility functions
- [Git Module](git.md) - Git integration features