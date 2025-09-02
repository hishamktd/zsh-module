#!/usr/bin/env zsh
# Script management and execution

# List and run available scripts interactively
script() {
    local action="${1:-interactive}"
    
    case "$action" in
        "list"|"ls")
            _dev_list_scripts
            ;;
        "run")
            local script_name="$2"
            if [[ -n "$script_name" ]]; then
                _dev_run_script "$script_name"
            else
                _dev_interactive_script_runner
            fi
            ;;
        *)
            _dev_interactive_script_runner
            ;;
    esac
}

# List available scripts based on project type
_dev_list_scripts() {
    echo "📋 Available Scripts:"
    
    if [[ -f "package.json" ]]; then
        echo "\n📦 Node.js Scripts (package.json):"
        if zmod_has_command jq; then
            jq -r '.scripts | to_entries[] | "  \(.key) - \(.value)"' package.json 2>/dev/null
        else
            grep -A 20 '"scripts"' package.json | grep ':' | sed 's/.*"\([^"]*\)": *"\([^"]*\)".*/  \1 - \2/' | head -20
        fi
    fi
    
    if [[ -f "Cargo.toml" ]]; then
        echo "\n🦀 Rust Tasks:"
        echo "  run - cargo run"
        echo "  build - cargo build"
        echo "  test - cargo test"
        echo "  check - cargo check"
        echo "  fmt - cargo fmt"
        echo "  clippy - cargo clippy"
        
        # Check for custom examples
        if [[ -d "examples" ]]; then
            echo "\n  📁 Examples:"
            for example in examples/*.rs; do
                if [[ -f "$example" ]]; then
                    local example_name=$(basename "$example" .rs)
                    echo "    $example_name - cargo run --example $example_name"
                fi
            done
        fi
        
        # Check for binaries in Cargo.toml
        if grep -q '\[\[bin\]\]' Cargo.toml; then
            echo "\n  🔧 Binaries:"
            grep -A 1 '\[\[bin\]\]' Cargo.toml | grep 'name =' | sed 's/.*name = *"\([^"]*\)".*/    \1 - cargo run --bin \1/'
        fi
    fi
    
    if [[ -f "Makefile" ]]; then
        echo "\n🔨 Make Targets:"
        grep '^[a-zA-Z][^:]*:' Makefile | sed 's/:.*$//' | sed 's/^/  /'
    fi
    
    if [[ -f "pyproject.toml" ]]; then
        echo "\n🐍 Python Scripts:"
        if grep -q '\[tool.poetry.scripts\]' pyproject.toml; then
            echo "  📜 Poetry Scripts:"
            grep -A 10 '\[tool.poetry.scripts\]' pyproject.toml | grep '=' | sed 's/\([^=]*\) *= *.*/  \1/'
        fi
    fi
    
    if [[ -f "manage.py" ]]; then
        echo "\n🐍 Django Management Commands:"
        echo "  runserver - Start development server"
        echo "  migrate - Run database migrations"
        echo "  makemigrations - Create new migrations"
        echo "  shell - Django shell"
        echo "  test - Run tests"
    fi
    
    echo "\n💡 Usage:"
    echo "  script           - Interactive script selection"
    echo "  script list      - Show this list"  
    echo "  script run name  - Run specific script"
}

# Interactive script runner with fzf
_dev_interactive_script_runner() {
    local scripts=()
    
    # Collect available scripts
    if [[ -f "package.json" ]]; then
        if zmod_has_command jq; then
            while IFS= read -r line; do
                scripts+=("npm:$line")
            done < <(jq -r '.scripts | keys[]' package.json 2>/dev/null)
        else
            while IFS= read -r line; do
                local script_name=$(echo "$line" | sed 's/.*"\([^"]*\)": *.*/\1/')
                [[ -n "$script_name" && "$script_name" != "$line" ]] && scripts+=("npm:$script_name")
            done < <(grep -A 20 '"scripts"' package.json | grep ':')
        fi
    fi
    
    if [[ -f "Cargo.toml" ]]; then
        scripts+=("cargo:run" "cargo:build" "cargo:test" "cargo:check" "cargo:fmt" "cargo:clippy")
        
        # Add examples
        for example in examples/*.rs(N); do
            local example_name=$(basename "$example" .rs)
            scripts+=("cargo-example:$example_name")
        done
        
        # Add binaries
        while IFS= read -r bin_name; do
            scripts+=("cargo-bin:$bin_name")
        done < <(grep -A 1 '\[\[bin\]\]' Cargo.toml | grep 'name =' | sed 's/.*name = *"\([^"]*\)".*/\1/')
    fi
    
    if [[ -f "Makefile" ]]; then
        while IFS= read -r target; do
            scripts+=("make:$target")
        done < <(grep '^[a-zA-Z][^:]*:' Makefile | sed 's/:.*$//')
    fi
    
    if [[ -f "manage.py" ]]; then
        scripts+=("django:runserver" "django:migrate" "django:makemigrations" "django:shell" "django:test")
    fi
    
    if [[ ${#scripts[@]} -eq 0 ]]; then
        echo "❌ No scripts found in current project"
        return 1
    fi
    
    # Use fzf if available, otherwise simple selection
    if zmod_has_command fzf; then
        local selected=$(printf '%s\n' "${scripts[@]}" | fzf \
            --prompt="Select script to run: " \
            --preview="_dev_preview_script {}" \
            --preview-window="right:40%:wrap")
        
        if [[ -n "$selected" ]]; then
            _dev_run_script "$selected"
        else
            echo "No script selected"
        fi
    else
        echo "\n🎯 Select script to run:"
        local i=1
        for script in "${scripts[@]}"; do
            echo "  $i) $script"
            ((i++))
        done
        
        echo -n "\nEnter selection (1-${#scripts[@]}): "
        read selection
        
        if [[ "$selection" =~ ^[0-9]+$ ]] && [[ $selection -ge 1 ]] && [[ $selection -le ${#scripts[@]} ]]; then
            _dev_run_script "${scripts[$(($selection))]}"
        else
            echo "❌ Invalid selection"
            return 1
        fi
    fi
}

# Preview script information for fzf
_dev_preview_script() {
    local script="$1"
    local type="${script%%:*}"
    local name="${script#*:}"
    
    case "$type" in
        "npm")
            if [[ -f "package.json" ]] && zmod_has_command jq; then
                echo "📦 NPM Script: $name"
                echo "Command: $(jq -r ".scripts.\"$name\"" package.json 2>/dev/null)"
            fi
            ;;
        "cargo")
            echo "🦀 Cargo Command: $name"
            echo "Will run: cargo $name"
            ;;
        "cargo-example")
            echo "🦀 Cargo Example: $name"
            echo "Will run: cargo run --example $name"
            ;;
        "cargo-bin")
            echo "🦀 Cargo Binary: $name"
            echo "Will run: cargo run --bin $name"
            ;;
        "make")
            echo "🔨 Make Target: $name"
            echo "Will run: make $name"
            ;;
        "django")
            echo "🐍 Django Command: $name"
            echo "Will run: python manage.py $name"
            ;;
    esac
}

# Run a specific script
_dev_run_script() {
    local script="$1"
    local type="${script%%:*}"
    local name="${script#*:}"
    
    echo "🚀 Running: $script"
    
    case "$type" in
        "npm")
            if zmod_has_command bun; then
                bun run "$name"
            elif zmod_has_command pnpm; then
                pnpm run "$name"
            elif zmod_has_command yarn; then
                yarn run "$name"
            else
                npm run "$name"
            fi
            ;;
        "cargo")
            cargo "$name"
            ;;
        "cargo-example")
            cargo run --example "$name"
            ;;
        "cargo-bin")
            cargo run --bin "$name"
            ;;
        "make")
            make "$name"
            ;;
        "django")
            python manage.py "$name"
            ;;
        *)
            echo "❌ Unknown script type: $type"
            return 1
            ;;
    esac
}