#!/usr/bin/env zsh
# Development utility commands

# Port management
port() {
    local action="$1"
    local port_num="$2"
    
    case "$action" in
        "kill")
            if [[ -z "$port_num" ]]; then
                echo "❌ Port number required"
                echo "Usage: port kill 3000"
                return 1
            fi
            zmod_kill_by_port "$port_num"
            ;;
        "check"|"list")
            if [[ -n "$port_num" ]]; then
                lsof -i ":$port_num"
            else
                echo "🔍 Active ports:"
                lsof -i -P -n | grep LISTEN
            fi
            ;;
        *)
            echo "Usage: port [kill|check] [port_number]"
            echo "  port kill 3000    - Kill process on port 3000"
            echo "  port check 3000   - Check what's running on port 3000"  
            echo "  port list         - List all active ports"
            ;;
    esac
}

# Environment management
env() {
    local action="${1:-show}"
    
    case "$action" in
        "show")
            echo "🌍 Development Environment:"
            echo "  Node: $(node --version 2>/dev/null || echo 'Not installed')"
            echo "  npm: $(npm --version 2>/dev/null || echo 'Not installed')"
            echo "  Python: $(python --version 2>/dev/null || echo 'Not installed')"
            echo "  Rust: $(rustc --version 2>/dev/null || echo 'Not installed')"
            echo "  Go: $(go version 2>/dev/null | cut -d' ' -f3 || echo 'Not installed')"
            ;;
        "activate")
            if [[ -f ".venv/bin/activate" ]]; then
                source .venv/bin/activate
                echo "✅ Python virtual environment activated"
            elif [[ -f "venv/bin/activate" ]]; then
                source venv/bin/activate
                echo "✅ Python virtual environment activated"
            else
                echo "❌ No virtual environment found"
                return 1
            fi
            ;;
        *)
            echo "Usage: env [show|activate]"
            ;;
    esac
}