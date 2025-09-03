# Core Utilities

The utilities system (`core/utils.zsh`) provides essential helper functions used throughout the framework and by all modules.

## 📋 Overview

Core utilities include:
- Git repository detection
- Command availability checking  
- Color and formatting functions
- Text processing helpers
- Cross-platform compatibility functions
- Performance timing utilities

## 🔧 Core Functions

### Git Integration

#### `zmod_is_git_repo()`
Checks if the current directory is inside a git repository.

```bash
# Usage
if zmod_is_git_repo; then
    echo "This is a git repository"
    git status
else
    echo "Not in a git repository"
fi

# Return codes
# 0 = is git repo, 1 = not git repo
```

**Implementation:**
- Uses `git rev-parse --git-dir` for reliable detection
- Handles edge cases (bare repos, submodules, worktrees)
- Silent operation (no error output)

**Use Cases:**
- Module functions that require git
- Conditional git command execution
- Repository-aware prompt customization

### Command Detection

#### `zmod_has_command(command_name)`
Checks if a command is available in the system PATH.

```bash
# Usage
if zmod_has_command "fzf"; then
    # Use fzf for interactive selection
    selected=$(echo "$options" | fzf)
else
    # Fallback to simple selection
    echo "Select an option:"
    select selected in $options; do break; done
fi

# Multiple commands
if zmod_has_command "rg" || zmod_has_command "grep"; then
    echo "Search functionality available"
fi
```

**Features:**
- Fast command lookup using `command -v`
- Caches results for repeated calls
- Works with aliases, functions, and binaries
- Cross-platform compatible

**Common Checks:**
```bash
zmod_has_command "git"        # Git version control
zmod_has_command "fzf"        # Fuzzy finder
zmod_has_command "rg"         # ripgrep search
zmod_has_command "fd"         # Modern find alternative
zmod_has_command "bat"        # Enhanced cat
zmod_has_command "exa"        # Modern ls alternative
zmod_has_command "delta"      # Enhanced git diff
```

### Text Formatting and Colors

#### `zmod_color(color_name, text)`
Applies color formatting to text with fallback support.

```bash
# Usage
echo $(zmod_color red "Error: Something went wrong")
echo $(zmod_color green "✅ Success!")
echo $(zmod_color blue "ℹ️ Information")
echo $(zmod_color yellow "⚠️ Warning")

# Custom colors
echo $(zmod_color "#ff5733" "Custom hex color")
echo $(zmod_color "bold" "Bold text")
echo $(zmod_color "underline" "Underlined text")
```

**Supported Colors:**
- **Basic:** `red`, `green`, `blue`, `yellow`, `magenta`, `cyan`, `white`, `black`
- **Styles:** `bold`, `dim`, `italic`, `underline`, `blink`, `reverse`
- **Extended:** `gray`, `orange`, `purple`, `pink`
- **Hex:** `#rrggbb` format (if terminal supports)

**Features:**
- Automatic color capability detection
- Graceful fallback when colors unsupported
- Respects `NO_COLOR` environment variable
- ANSI escape sequence management

#### `zmod_format_list(items, format)`
Formats arrays and lists with consistent styling.

```bash
# Usage
files=("file1.txt" "file2.js" "file3.py")
zmod_format_list $files "bullet"    # • file1.txt
                                    # • file2.js  
                                    # • file3.py

zmod_format_list $files "numbered"  # 1. file1.txt
                                    # 2. file2.js
                                    # 3. file3.py

zmod_format_list $files "columns"   # file1.txt    file2.js     file3.py
```

### Performance and Timing

#### `zmod_timer_start(name)`
Starts a named performance timer.

```bash
# Usage
zmod_timer_start "module_load"
# ... expensive operation ...
duration=$(zmod_timer_end "module_load")
echo "Module loaded in ${duration}ms"
```

#### `zmod_timer_end(name)`
Ends a named timer and returns duration.

```bash
# Usage with conditional timing
if [[ "$ZSH_MODULE_TIMING" == "true" ]]; then
    zmod_timer_start "git_status"
fi

git status --porcelain

if [[ "$ZSH_MODULE_TIMING" == "true" ]]; then
    duration=$(zmod_timer_end "git_status")
    echo "Git status took ${duration}ms"
fi
```

**Features:**
- Millisecond precision timing
- Multiple concurrent timers
- Memory-efficient implementation
- Optional timing output control

### File System Utilities

#### `zmod_find_up(filename, start_dir)`
Searches for a file walking up the directory tree.

```bash
# Usage
package_json=$(zmod_find_up "package.json")
if [[ -n "$package_json" ]]; then
    echo "Found Node.js project at $(dirname $package_json)"
fi

# Common use cases
makefile=$(zmod_find_up "Makefile")
dockerfile=$(zmod_find_up "Dockerfile")  
cargo_toml=$(zmod_find_up "Cargo.toml")
```

**Use Cases:**
- Project root detection
- Configuration file discovery
- Build system integration
- Context-aware command behavior

#### `zmod_get_relative_path(from, to)`
Calculates relative path between two directories.

```bash
# Usage
rel_path=$(zmod_get_relative_path "/home/user/projects" "/home/user/projects/myapp/src")
echo $rel_path  # myapp/src

# Useful for display purposes
current_dir=$(pwd)
project_root=$(zmod_find_up ".git" | xargs dirname)
rel_path=$(zmod_get_relative_path "$project_root" "$current_dir")
echo "Working in: $rel_path"
```

### String Processing

#### `zmod_trim(string)`
Removes leading and trailing whitespace.

```bash
# Usage
dirty_string="  hello world  "
clean_string=$(zmod_trim "$dirty_string")
echo "'$clean_string'"  # 'hello world'

# Useful for cleaning user input
user_input=$(read -r input; echo $input)
clean_input=$(zmod_trim "$user_input")
```

#### `zmod_split(string, delimiter)`
Splits string into array by delimiter.

```bash
# Usage
path_str="/usr/local/bin:/usr/bin:/bin"
IFS=':' read -ra path_array <<< "$(zmod_split "$path_str" ":")"

for dir in "${path_array[@]}"; do
    echo "PATH contains: $dir"
done
```

#### `zmod_join(array, delimiter)`
Joins array elements with delimiter.

```bash
# Usage
files=("file1.txt" "file2.js" "file3.py")
file_list=$(zmod_join $files ", ")
echo "Files: $file_list"  # Files: file1.txt, file2.js, file3.py
```

### Validation and Safety

#### `zmod_is_safe_path(path)`
Validates that a path is safe for operations.

```bash
# Usage
user_path="/some/user/input/path"
if zmod_is_safe_path "$user_path"; then
    cd "$user_path"
else
    echo "❌ Unsafe path detected"
    return 1
fi
```

**Safety Checks:**
- No path traversal attempts (`../`)
- No absolute paths to system directories
- No null bytes or control characters
- Reasonable path length limits

#### `zmod_confirm(message, default)`
Prompts user for yes/no confirmation.

```bash
# Usage
if zmod_confirm "Delete all temporary files?" "n"; then
    echo "Deleting files..."
    rm -rf /tmp/myapp-*
else
    echo "Operation cancelled"
fi

# With different default
if zmod_confirm "Save changes?" "y"; then
    save_changes
fi
```

**Features:**
- Customizable default response
- Accepts multiple input formats (y/yes/Y/YES)
- Handles EOF and interrupts gracefully
- Color-coded prompts

### Cross-Platform Compatibility

#### `zmod_detect_os()`
Detects the current operating system.

```bash
# Usage
os=$(zmod_detect_os)
case $os in
    "linux")   echo "Running on Linux" ;;
    "macos")   echo "Running on macOS" ;;
    "windows") echo "Running on Windows (WSL)" ;;
    *)         echo "Unknown OS: $os" ;;
esac
```

**Detected Systems:**
- `linux` - Linux distributions
- `macos` - macOS/Darwin
- `windows` - Windows with WSL
- `freebsd` - FreeBSD
- `unknown` - Unrecognized systems

#### `zmod_get_clipboard_cmd()`
Returns appropriate clipboard command for the OS.

```bash
# Usage
clip_cmd=$(zmod_get_clipboard_cmd)
echo "Branch name copied!" | $clip_cmd

# Platform-specific commands:
# Linux: xclip, xsel, or wl-copy
# macOS: pbcopy
# Windows: clip.exe
```

## 🎯 Usage Patterns

### Error Handling with Colors
```bash
function my_function() {
    if ! zmod_is_git_repo; then
        echo $(zmod_color red "❌ Not a git repository")
        return 1
    fi
    
    echo $(zmod_color green "✅ Success: Operation completed")
}
```

### Performance Monitoring
```bash
function expensive_operation() {
    [[ "$ZSH_MODULE_TIMING" == "true" ]] && zmod_timer_start "expensive_op"
    
    # ... your expensive operation here ...
    
    if [[ "$ZSH_MODULE_TIMING" == "true" ]]; then
        duration=$(zmod_timer_end "expensive_op")
        echo $(zmod_color yellow "⏱️ Operation took ${duration}ms")
    fi
}
```

### Progressive Enhancement
```bash
function smart_search() {
    local query="$1"
    
    if zmod_has_command "rg"; then
        rg --color=always "$query"
    elif zmod_has_command "ag"; then
        ag --color "$query"
    elif zmod_has_command "grep"; then
        grep --color=always -r "$query" .
    else
        echo $(zmod_color red "❌ No search tool available")
        return 1
    fi
}
```

### Safe File Operations
```bash
function safe_remove() {
    local target="$1"
    
    if ! zmod_is_safe_path "$target"; then
        echo $(zmod_color red "❌ Unsafe path: $target")
        return 1
    fi
    
    if zmod_confirm "Remove $target?" "n"; then
        rm -rf "$target"
        echo $(zmod_color green "✅ Removed: $target")
    fi
}
```

## 📊 Performance Considerations

### Caching
- Command existence checks are cached
- OS detection results are cached
- Color capability detection is cached

### Efficiency
- Minimal external command usage
- Built-in zsh operations preferred
- Lazy evaluation where possible

### Memory Usage
- No persistent background processes
- Minimal global variable usage
- Clean function scoping

## 🔧 Customization

### Custom Colors
```bash
# Add to your configuration
zmod_color_custom() {
    case "$1" in
        "brand") echo "\033[38;5;208m$2\033[0m" ;;  # Orange
        "success") zmod_color green "$2" ;;
        "error") zmod_color red "$2" ;;
        *) zmod_color "$1" "$2" ;;
    esac
}
```

### Custom Validators
```bash
# Add project-specific validation
zmod_is_node_project() {
    [[ -f "package.json" ]] || zmod_find_up "package.json" >/dev/null
}

zmod_is_rust_project() {
    [[ -f "Cargo.toml" ]] || zmod_find_up "Cargo.toml" >/dev/null
}
```

## 🚨 Error Handling

### Common Patterns
```bash
# Safe command execution
if zmod_has_command "command_name"; then
    command_name "$@"
else
    echo $(zmod_color yellow "⚠️ command_name not available, using fallback")
    fallback_function "$@"
fi

# Git repository checks
function git_function() {
    if ! zmod_is_git_repo; then
        echo $(zmod_color red "❌ Not a git repository")
        return 1
    fi
    # ... git operations ...
}
```

## 📚 Dependencies

### Required
- `zsh` 5.0+
- POSIX-compatible utilities (`grep`, `sed`, `cut`, `tr`)

### Optional
- `git` - For git repository detection
- Modern terminal - For full color support
- `xclip`/`pbcopy` - For clipboard operations

## 🔮 Future Enhancements

- **Async Operations** - Non-blocking utility functions
- **Plugin System** - User-defined utility functions
- **Advanced Formatting** - Table and tree display utilities
- **Network Utilities** - HTTP requests and network checks
- **Configuration Management** - Settings persistence utilities
- **Internationalization** - Multi-language support

## 📚 Related Documentation

- [Loader System](loader.md) - Module loading and management
- [Configuration](config.md) - Framework configuration system
- [Git Module](../modules/git.md) - Git workflow automation
- [Development Module](../modules/dev.md) - Development tools