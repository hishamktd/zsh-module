#!/usr/bin/env zsh
# System Module - System utilities and shortcuts

# Clear any existing aliases to avoid conflicts
unalias ls ll la l g f p dl serve c h grep df du free 2>/dev/null || true

# Enhanced ls with better defaults
ll() {
    if zmod_has_command exa; then
        exa -la --icons --git
    elif zmod_has_command lsd; then
        lsd -la
    else
        command ls -la --color=auto "$@"
    fi
}

la() {
    if zmod_has_command exa; then
        exa -a --icons
    elif zmod_has_command lsd; then
        lsd -a
    else
        command ls -a --color=auto "$@"
    fi
}

lt() {
    if zmod_has_command exa; then
        exa --tree --level=2 --icons
    elif zmod_has_command tree; then
        tree -L 2
    else
        find . -maxdepth 2 -type d | head -20
    fi
}

# Enhanced find
f() {
    local pattern="$1"
    local path="${2:-.}"
    
    if [[ -z "$pattern" ]]; then
        echo "❌ Search pattern required"
        echo "Usage: f 'pattern' [path]"
        return 1
    fi
    
    if zmod_has_command fd; then
        fd "$pattern" "$path"
    else
        find "$path" -name "*$pattern*" -type f
    fi
}

# Enhanced grep  
g() {
    local pattern="$1"
    shift
    local files=("$@")
    
    if [[ -z "$pattern" ]]; then
        echo "❌ Search pattern required"
        echo "Usage: g 'pattern' [files...]"
        return 1
    fi
    
    if [[ ${#files[@]} -eq 0 ]]; then
        files=(".")
    fi
    
    if zmod_has_command rg; then
        rg "$pattern" "${files[@]}"
    elif zmod_has_command ag; then
        ag "$pattern" "${files[@]}"
    else
        grep -r --color=auto "$pattern" "${files[@]}"
    fi
}

# Process management
psg() {
    local pattern="$1"
    if [[ -z "$pattern" ]]; then
        ps aux
    else
        ps aux | grep -i "$pattern" | grep -v grep
    fi
}

# Kill process by name
pk() {
    local pattern="$1"
    if [[ -z "$pattern" ]]; then
        echo "❌ Process name pattern required"
        echo "Usage: pk 'process_name'"
        return 1
    fi
    
    local pids=$(pgrep -f "$pattern")
    if [[ -z "$pids" ]]; then
        echo "❌ No processes found matching '$pattern'"
        return 1
    fi
    
    echo "Found processes:"
    ps -p $pids -o pid,ppid,cmd
    
    if zmod_confirm "Kill these processes?"; then
        echo $pids | xargs kill
        echo "✅ Processes killed"
    fi
}

# System information
sysinfo() {
    echo "🖥️  System Information:"
    echo "  OS: $(zmod_get_os)"
    echo "  Architecture: $(zmod_get_arch)"
    echo "  Hostname: $(hostname)"
    echo "  Uptime: $(uptime | cut -d',' -f1 | cut -d' ' -f4-)"
    
    if zmod_has_command lscpu; then
        local cpu=$(lscpu | grep "Model name" | cut -d':' -f2 | xargs)
        echo "  CPU: $cpu"
    fi
    
    # Memory info
    if [[ -f /proc/meminfo ]]; then
        local total_mem=$(grep MemTotal /proc/meminfo | awk '{print $2}')
        local available_mem=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
        local mem_used=$(( (total_mem - available_mem) * 100 / total_mem ))
        echo "  Memory: ${mem_used}% used"
    fi
    
    # Disk usage
    echo "  Disk Usage:"
    df -h | grep -E "^/dev/" | awk '{print "    " $6 ": " $5 " used (" $3 "/" $2 ")"}'
}

# Network utilities
myip() {
    echo "🌐 IP Addresses:"
    echo "  Local IP: $(hostname -I | awk '{print $1}')"
    if zmod_is_online; then
        echo "  Public IP: $(zmod_get_public_ip)"
    else
        echo "  Public IP: Not connected"
    fi
}

# Port scanning
portscan() {
    local host="${1:-localhost}"
    local start_port="${2:-1}"
    local end_port="${3:-1000}"
    
    echo "🔍 Scanning ports $start_port-$end_port on $host..."
    
    for port in $(seq $start_port $end_port); do
        if timeout 1 bash -c "</dev/tcp/$host/$port" 2>/dev/null; then
            echo "  ✅ Port $port: Open"
        fi
    done 2>/dev/null
}

# Directory operations
mkcd() {
    local dir="$1"
    if [[ -z "$dir" ]]; then
        echo "❌ Directory name required"
        return 1
    fi
    
    mkdir -p "$dir" && cd "$dir"
}

# Go up multiple directories
up() {
    local levels="${1:-1}"
    zmod_cd_up "$levels"
}

# Archive operations
extract() {
    local file="$1"
    if [[ -z "$file" ]] || [[ ! -f "$file" ]]; then
        echo "❌ File not found: $file"
        return 1
    fi
    
    case "$file" in
        *.tar.bz2)  tar xjf "$file" ;;
        *.tar.gz)   tar xzf "$file" ;;
        *.bz2)      bunzip2 "$file" ;;
        *.rar)      unrar x "$file" ;;
        *.gz)       gunzip "$file" ;;
        *.tar)      tar xf "$file" ;;
        *.tbz2)     tar xjf "$file" ;;
        *.tgz)      tar xzf "$file" ;;
        *.zip)      unzip "$file" ;;
        *.Z)        uncompress "$file" ;;
        *.7z)       7z x "$file" ;;
        *)          echo "❌ Unknown archive format: $file" ;;
    esac
}

# Create archive
archive() {
    local name="$1"
    shift
    local files=("$@")
    
    if [[ -z "$name" ]] || [[ ${#files[@]} -eq 0 ]]; then
        echo "❌ Usage: archive name.tar.gz file1 file2 ..."
        return 1
    fi
    
    case "$name" in
        *.tar.gz)   tar czf "$name" "${files[@]}" ;;
        *.tar.bz2)  tar cjf "$name" "${files[@]}" ;;
        *.zip)      zip -r "$name" "${files[@]}" ;;
        *)          echo "❌ Unsupported format. Use .tar.gz, .tar.bz2, or .zip" ;;
    esac
}

# File size
fsize() {
    local target="${1:-.}"
    if [[ -d "$target" ]]; then
        du -sh "$target"/*
    elif [[ -f "$target" ]]; then
        du -sh "$target"
    else
        echo "❌ File or directory not found: $target"
        return 1
    fi
}

# Disk usage top
duf() {
    local path="${1:-.}"
    du -h "$path" | sort -hr | head -20
}

# System monitoring
top10() {
    echo "🔥 Top 10 processes by CPU:"
    ps aux --sort=-%cpu | head -11
    
    echo ""
    echo "🧠 Top 10 processes by Memory:"
    ps aux --sort=-%mem | head -11
}

# Service management (systemd)
service() {
    local action="$1"
    local service_name="$2"
    
    if [[ -z "$action" ]]; then
        echo "Usage: service [status|start|stop|restart|enable|disable] [service_name]"
        return 1
    fi
    
    case "$action" in
        "list")
            systemctl list-units --type=service
            ;;
        "status"|"start"|"stop"|"restart"|"enable"|"disable")
            if [[ -z "$service_name" ]]; then
                echo "❌ Service name required"
                return 1
            fi
            sudo systemctl "$action" "$service_name"
            ;;
        *)
            echo "❌ Unknown action: $action"
            return 1
            ;;
    esac
}

# Quick clipboard operations (if xclip/pbcopy available)
copy() {
    if zmod_has_command xclip; then
        xclip -selection clipboard
    elif zmod_has_command pbcopy; then
        pbcopy
    else
        echo "❌ No clipboard utility found (xclip/pbcopy)"
        return 1
    fi
}

paste() {
    if zmod_has_command xclip; then
        xclip -selection clipboard -o
    elif zmod_has_command pbpaste; then
        pbpaste
    else
        echo "❌ No clipboard utility found (xclip/pbpaste)"
        return 1
    fi
}

# System aliases
alias c='clear'
alias h='history'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias l='ll'
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias cls='clear'