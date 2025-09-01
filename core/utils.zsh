#!/usr/bin/env zsh
# ZSH Module Framework - Common Utilities

# Performance timing
zmod_time_start() {
    local timer_name="${1:-default}"
    typeset -gA ZSH_MODULE_TIMERS
    ZSH_MODULE_TIMERS[$timer_name]=$EPOCHREALTIME
}

zmod_time_end() {
    local timer_name="${1:-default}"
    if [[ -n "${ZSH_MODULE_TIMERS[$timer_name]}" ]]; then
        local start_time="${ZSH_MODULE_TIMERS[$timer_name]}"
        local end_time=$EPOCHREALTIME
        local duration=$(( end_time - start_time ))
        echo "${duration}s"
        unset "ZSH_MODULE_TIMERS[$timer_name]"
    else
        echo "Timer '$timer_name' not found"
        return 1
    fi
}

# Check if command exists
zmod_has_command() {
    command -v "$1" >/dev/null 2>&1
}

# Check if we're in a git repository
zmod_is_git_repo() {
    git rev-parse --is-inside-work-tree >/dev/null 2>&1
}

# Get current git branch
zmod_git_branch() {
    git branch --show-current 2>/dev/null
}

# Check if directory is writable
zmod_is_writable() {
    [[ -w "$1" ]]
}

# Safe path operations
zmod_add_to_path() {
    local dir="$1"
    local position="${2:-end}"
    
    # Check if directory exists and is not already in PATH
    if [[ -d "$dir" ]] && [[ ":$PATH:" != *":$dir:"* ]]; then
        if [[ "$position" == "start" ]]; then
            export PATH="$dir:$PATH"
        else
            export PATH="$PATH:$dir"
        fi
        return 0
    fi
    return 1
}

# File operations
zmod_backup_file() {
    local file="$1"
    local backup_dir="${2:-$(dirname "$file")/.backups}"
    
    if [[ -f "$file" ]]; then
        mkdir -p "$backup_dir"
        local timestamp=$(date +%Y%m%d_%H%M%S)
        local backup_file="$backup_dir/$(basename "$file").${timestamp}.bak"
        cp "$file" "$backup_file"
        echo "$backup_file"
        return 0
    fi
    return 1
}

# String utilities
zmod_trim() {
    local var="$1"
    # Remove leading and trailing whitespace
    echo "${var#"${var%%[![:space:]]*}"}" | sed 's/[[:space:]]*$//'
}

zmod_lower() {
    echo "$1" | tr '[:upper:]' '[:lower:]'
}

zmod_upper() {
    echo "$1" | tr '[:lower:]' '[:upper:]'
}

# Array utilities
zmod_array_contains() {
    local element="$1"
    shift
    local array=("$@")
    
    for item in "${array[@]}"; do
        [[ "$item" == "$element" ]] && return 0
    done
    return 1
}

# Network utilities
zmod_is_online() {
    ping -c 1 8.8.8.8 >/dev/null 2>&1
}

zmod_get_public_ip() {
    if zmod_has_command curl; then
        curl -s https://ipinfo.io/ip 2>/dev/null
    elif zmod_has_command wget; then
        wget -qO- https://ipinfo.io/ip 2>/dev/null
    else
        echo "No curl or wget available"
        return 1
    fi
}

# System info utilities
zmod_get_os() {
    case "$OSTYPE" in
        linux*)   echo "linux" ;;
        darwin*)  echo "macos" ;;
        msys*)    echo "windows" ;;
        cygwin*)  echo "windows" ;;
        *)        echo "unknown" ;;
    esac
}

zmod_get_arch() {
    uname -m
}

# Process utilities
zmod_kill_by_port() {
    local port="$1"
    if [[ -z "$port" ]]; then
        echo "Port number required"
        return 1
    fi
    
    local pid=$(lsof -ti:$port)
    if [[ -n "$pid" ]]; then
        kill -9 $pid
        echo "Killed process $pid on port $port"
    else
        echo "No process found on port $port"
        return 1
    fi
}

# Directory navigation utilities
zmod_cd_up() {
    local levels="${1:-1}"
    local path=""
    
    for ((i=0; i<levels; i++)); do
        path="../$path"
    done
    
    cd "$path"
}

# Fuzzy finder utilities (if fzf is available)
zmod_fzf_file() {
    if zmod_has_command fzf; then
        find . -type f | fzf --preview 'head -100 {}'
    else
        echo "fzf not available"
        return 1
    fi
}

zmod_fzf_dir() {
    if zmod_has_command fzf; then
        find . -type d | fzf
    else
        echo "fzf not available"  
        return 1
    fi
}

# Confirmation prompt
zmod_confirm() {
    local message="${1:-Are you sure?}"
    local default="${2:-n}"
    
    if [[ "$default" == "y" ]]; then
        read -q "REPLY?$message [Y/n] "
    else
        read -q "REPLY?$message [y/N] "
    fi
    
    echo # new line
    [[ "$REPLY" =~ ^[Yy]$ ]]
}

# Color output utilities
zmod_color() {
    local color="$1"
    shift
    local text="$*"
    
    case "$color" in
        red)     echo "\033[0;31m$text\033[0m" ;;
        green)   echo "\033[0;32m$text\033[0m" ;;
        yellow)  echo "\033[0;33m$text\033[0m" ;;
        blue)    echo "\033[0;34m$text\033[0m" ;;
        purple)  echo "\033[0;35m$text\033[0m" ;;
        cyan)    echo "\033[0;36m$text\033[0m" ;;
        white)   echo "\033[0;37m$text\033[0m" ;;
        *)       echo "$text" ;;
    esac
}