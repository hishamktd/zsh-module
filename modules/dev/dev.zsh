#!/usr/bin/env zsh
# Development Module - Development workflow commands

# Clear any existing aliases to avoid conflicts
unalias s i b t l st serve install build test lint 2>/dev/null || true

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

# Package manager shortcuts
install() {
    if [[ -f "package.json" ]]; then
        if zmod_has_command bun; then
            echo "⚡ Installing with bun..."
            bun install "$@"
        elif zmod_has_command pnpm; then
            echo "📦 Installing with pnpm..."
            pnpm install "$@"
        elif zmod_has_command yarn; then
            echo "🧶 Installing with yarn..."
            yarn add "$@"
        else
            echo "📦 Installing with npm..."
            npm install "$@"
        fi
    elif [[ -f "Cargo.toml" ]]; then
        echo "🦀 Installing Rust dependencies..."
        cargo add "$@"
    elif [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]]; then
        if zmod_has_command poetry; then
            echo "🎭 Installing with poetry..."
            poetry add "$@"
        elif zmod_has_command pipenv; then
            echo "🐍 Installing with pipenv..."
            pipenv install "$@"
        else
            echo "🐍 Installing with pip..."
            pip install "$@"
        fi
    elif [[ -f "go.mod" ]]; then
        echo "🐹 Installing Go dependencies..."
        go get "$@"
    else
        echo "❌ No package manager detected"
        return 1
    fi
}

# Build project
build() {
    if [[ -f "package.json" ]]; then
        if zmod_has_command bun; then
            bun run build
        elif zmod_has_command pnpm; then
            pnpm build
        elif zmod_has_command yarn; then
            yarn build
        else
            npm run build
        fi
    elif [[ -f "Cargo.toml" ]]; then
        cargo build --release
    elif [[ -f "Makefile" ]]; then
        make
    elif [[ -f "go.mod" ]]; then
        go build
    else
        echo "❌ No build system detected"
        return 1
    fi
}

# Test runner
test() {
    if [[ -f "package.json" ]]; then
        if zmod_has_command bun; then
            bun test "$@"
        elif zmod_has_command pnpm; then
            pnpm test "$@"
        elif zmod_has_command yarn; then
            yarn test "$@"
        else
            npm test "$@"
        fi
    elif [[ -f "Cargo.toml" ]]; then
        cargo test "$@"
    elif [[ -f "pytest.ini" ]] || [[ -f "pyproject.toml" ]]; then
        if zmod_has_command pytest; then
            pytest "$@"
        else
            python -m pytest "$@"
        fi
    elif [[ -f "go.mod" ]]; then
        go test "$@"
    else
        echo "❌ No test runner detected"
        return 1
    fi
}

# Lint and format
lint() {
    local fixed=false
    
    if [[ -f "package.json" ]]; then
        if zmod_has_command eslint; then
            eslint . --fix && fixed=true
        fi
        if zmod_has_command prettier; then
            prettier . --write && fixed=true
        fi
    elif [[ -f "Cargo.toml" ]]; then
        if zmod_has_command cargo-fmt; then
            cargo fmt && fixed=true
        fi
        if zmod_has_command clippy; then
            cargo clippy --fix --allow-dirty && fixed=true
        fi
    elif [[ -f "pyproject.toml" ]] || [[ -f "setup.py" ]]; then
        if zmod_has_command black; then
            black . && fixed=true
        fi
        if zmod_has_command isort; then
            isort . && fixed=true
        fi
        if zmod_has_command flake8; then
            flake8 .
        fi
    elif [[ -f "go.mod" ]]; then
        if zmod_has_command gofmt; then
            gofmt -w . && fixed=true
        fi
    fi
    
    if [[ "$fixed" == "false" ]]; then
        echo "❌ No linting tools found"
        return 1
    else
        echo "✅ Code formatted and linted"
    fi
}

# Project initialization
init() {
    local project_type="${1:-node}"
    local project_name="${2:-$(basename $(pwd))}"
    
    case "$project_type" in
        "node"|"js"|"ts")
            if zmod_has_command bun; then
                bun init
            elif zmod_has_command pnpm; then
                pnpm init
            else
                npm init -y
            fi
            ;;
        "rust")
            cargo init --name "$project_name"
            ;;
        "python")
            if zmod_has_command poetry; then
                poetry init
            else
                echo "# $project_name" > README.md
                touch requirements.txt
                python -m venv .venv
                echo ".venv/" > .gitignore
                echo "✅ Python project initialized"
            fi
            ;;
        "go")
            go mod init "$project_name"
            echo "package main\n\nimport \"fmt\"\n\nfunc main() {\n    fmt.Println(\"Hello, World!\")\n}" > main.go
            ;;
        *)
            echo "❌ Unknown project type: $project_type"
            echo "Available types: node, rust, python, go"
            return 1
            ;;
    esac
}

# Quick project status
status() {
    echo "📁 Project: $(basename $(pwd))"
    echo "📂 Directory: $(pwd)"
    
    # Git status
    if zmod_is_git_repo; then
        echo "🌿 Branch: $(zmod_git_branch)"
        local dirty_files=$(git status --porcelain | wc -l)
        if [[ $dirty_files -gt 0 ]]; then
            echo "📝 Modified files: $dirty_files"
        else
            echo "✅ Working directory clean"
        fi
    else
        echo "❌ Not a git repository"
    fi
    
    # Package info
    if [[ -f "package.json" ]]; then
        local pkg_name=$(grep '"name"' package.json | cut -d'"' -f4)
        local pkg_version=$(grep '"version"' package.json | cut -d'"' -f4)
        echo "📦 Package: $pkg_name@$pkg_version"
    elif [[ -f "Cargo.toml" ]]; then
        local crate_name=$(grep '^name = ' Cargo.toml | cut -d'"' -f2)
        local crate_version=$(grep '^version = ' Cargo.toml | cut -d'"' -f2)
        echo "🦀 Crate: $crate_name@$crate_version"
    elif [[ -f "pyproject.toml" ]]; then
        local py_name=$(grep '^name = ' pyproject.toml | cut -d'"' -f2)
        echo "🐍 Python project: $py_name"
    fi
}

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

# Development aliases
alias s='serve'
alias i='install'
alias b='build' 
alias t='test'
alias l='lint'
alias st='status'