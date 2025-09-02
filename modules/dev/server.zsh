#!/usr/bin/env zsh
# Development server commands

# Smart development command - detects project type and runs appropriate dev server
dev() {
    local dir="${1:-.}"
    
    if [[ -f "$dir/package.json" ]]; then
        # Check if dev script exists in package.json
        if ! grep -q '"dev"' "$dir/package.json"; then
            echo "❌ No dev script found in package.json"
            return 1
        fi
        
        # Try package managers in order of preference
        if zmod_has_command bun; then
            echo "⚡ Starting bun dev server..."
            bun dev
        elif zmod_has_command pnpm; then
            echo "📦 Starting pnpm dev server..."
            pnpm dev
        elif zmod_has_command yarn; then
            echo "🧶 Starting yarn dev server..."
            yarn dev
        elif zmod_has_command npm; then
            echo "🚀 Starting npm dev server..."
            npm run dev
        else
            echo "❌ No package manager found (npm, yarn, pnpm, bun)"
            return 1
        fi
    elif [[ -f "$dir/Cargo.toml" ]]; then
        echo "🦀 Starting Rust development..."
        cargo run
    elif [[ -f "$dir/manage.py" ]]; then
        echo "🐍 Starting Django dev server..."
        python manage.py runserver
    elif [[ -f "$dir/app.py" ]] || [[ -f "$dir/main.py" ]]; then
        echo "🐍 Starting Python dev server..."
        if [[ -f "$dir/app.py" ]]; then
            python app.py
        else
            python main.py
        fi
    else
        echo "❌ No recognized development project found"
        echo "Supported: package.json (Node), Cargo.toml (Rust), manage.py (Django), app.py/main.py (Python)"
        return 1
    fi
}

# Development server shortcuts
serve() {
    local port="${1:-3000}"
    local dir="${2:-.}"
    
    if [[ -f "$dir/package.json" ]] && zmod_has_command npm; then
        echo "🚀 Starting npm dev server..."
        npm run dev
    elif [[ -f "$dir/Cargo.toml" ]] && zmod_has_command cargo; then
        echo "🦀 Starting Rust dev server..."
        cargo run
    elif [[ -f "$dir/requirements.txt" ]] && zmod_has_command python; then
        echo "🐍 Starting Python dev server..."
        python -m http.server "$port"
    elif zmod_has_command python; then
        echo "🌐 Starting simple HTTP server on port $port..."
        python -m http.server "$port"
    else
        echo "❌ No suitable dev server found"
        return 1
    fi
}

# Alias
alias s='serve'