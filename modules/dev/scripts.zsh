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
                scripts+=("$line")
            done < <(jq -r '.scripts | keys[]' package.json 2>/dev/null)
        else
            while IFS= read -r line; do
                local script_name=$(echo "$line" | sed 's/.*"\([^"]*\)": *.*/\1/')
                [[ -n "$script_name" && "$script_name" != "$line" ]] && scripts+=("$script_name")
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
        # Create a temporary preview function  
        local preview_cmd='
        script="{}";
        echo "🔍 Script: $script";
        echo "";
        
        # Detect script type based on context and name
        if [[ "$script" == *":"* ]]; then
            type="${script%%:*}";
            name="${script#*:}";
        else
            # No prefix, check context to determine type
            if [[ -f "package.json" ]] && command -v jq >/dev/null 2>&1; then
                if jq -r ".scripts | keys[]" package.json 2>/dev/null | grep -q "^$script$"; then
                    type="npm";
                    name="$script";
                fi
            elif [[ "$script" =~ ^(run|build|test|check|fmt|clippy)$ ]]; then
                type="cargo";
                name="$script";
            elif [[ "$script" =~ ^(runserver|migrate|makemigrations|shell|test)$ ]]; then
                type="django";
                name="$script";
            else
                # Default to npm if package.json exists
                if [[ -f "package.json" ]]; then
                    type="npm";
                    name="$script";
                else
                    type="unknown";
                    name="$script";
                fi
            fi
        fi
        
        case "$type" in
            npm)
                echo "📦 NPM Script: $name";
                if command -v jq >/dev/null 2>&1 && [[ -f "package.json" ]]; then
                    cmd=$(jq -r ".scripts.\"$name\"" package.json 2>/dev/null);
                    echo "Command: $cmd";
                    echo "";
                    case "$name" in
                        dev|serve|start:dev) echo "🚀 Purpose: Start development server with hot reload" ;;
                        build|build:prod) echo "🏗️  Purpose: Build application for production" ;;
                        start) echo "▶️  Purpose: Start production server" ;;
                        test*) echo "🧪 Purpose: Run test suite" ;;
                        lint*) echo "🔍 Purpose: Check code quality and style" ;;
                        format*) echo "🛠️  Purpose: Auto-fix code style issues" ;;
                        type-check|typecheck) echo "📋 Purpose: Check TypeScript types" ;;
                        *) 
                            if [[ "$cmd" =~ "next dev" ]]; then echo "🚀 Purpose: Start Next.js development server";
                            elif [[ "$cmd" =~ "next build" ]]; then echo "🏗️  Purpose: Build Next.js application";
                            elif [[ "$cmd" =~ "prettier" ]]; then echo "🎨 Purpose: Code formatting";
                            elif [[ "$cmd" =~ "eslint" ]]; then echo "🔍 Purpose: JavaScript/TypeScript linting";
                            else echo "⚙️  Purpose: Custom project script"; fi ;;
                    esac;
                fi ;;
            cargo)
                echo "🦀 Cargo Command: $name";
                echo "Will run: cargo $name";
                echo "";
                case "$name" in
                    run) echo "🚀 Purpose: Compile and run the main binary" ;;
                    build) echo "🏗️  Purpose: Compile the project without running" ;;
                    test) echo "🧪 Purpose: Run all tests in the project" ;;
                    check) echo "✅ Purpose: Fast compilation check" ;;
                    fmt) echo "🎨 Purpose: Format Rust code" ;;
                    clippy) echo "🔍 Purpose: Run Rust linter" ;;
                esac ;;
            make)
                echo "🔨 Make Target: $name";
                echo "Will run: make $name" ;;
            django)
                echo "🐍 Django Command: $name";
                echo "Will run: python manage.py $name";
                echo "";
                case "$name" in
                    runserver) echo "🚀 Purpose: Start Django development server" ;;
                    migrate) echo "🗃️  Purpose: Apply database migrations" ;;
                    makemigrations) echo "📝 Purpose: Create new database migrations" ;;
                    shell) echo "🐍 Purpose: Start Django interactive shell" ;;
                    test) echo "🧪 Purpose: Run Django test suite" ;;
                esac ;;
        esac'
        
        local selected=$(printf '%s\n' "${scripts[@]}" | fzf \
            --prompt="Select script to run: " \
            --preview="$preview_cmd" \
            --preview-window="right:50%:wrap")
        
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
                local cmd=$(jq -r ".scripts.\"$name\"" package.json 2>/dev/null)
                echo "📦 NPM Script: $name"
                echo "Command: $cmd"
                echo ""
                _dev_analyze_npm_script "$name" "$cmd"
            else
                echo "📦 NPM Script: $name"
                echo "Command: $(grep -A 20 '"scripts"' package.json | grep "\"$name\"" | sed 's/.*: *"\([^"]*\)".*/\1/')"
            fi
            ;;
        "cargo")
            echo "🦀 Cargo Command: $name"
            echo "Will run: cargo $name"
            echo ""
            _dev_analyze_cargo_command "$name"
            ;;
        "cargo-example")
            echo "🦀 Cargo Example: $name"
            echo "Will run: cargo run --example $name"
            echo ""
            echo "📝 Purpose: Run example code demonstrating specific functionality"
            if [[ -f "examples/$name.rs" ]]; then
                echo "📄 File: examples/$name.rs"
                local desc=$(head -10 "examples/$name.rs" | grep -E '^//[[:space:]]*' | head -3 | sed 's|^//[[:space:]]*||')
                [[ -n "$desc" ]] && echo "📖 Description: $desc"
            fi
            ;;
        "cargo-bin")
            echo "🦀 Cargo Binary: $name"
            echo "Will run: cargo run --bin $name"
            echo ""
            echo "📝 Purpose: Run a specific binary target from this crate"
            ;;
        "make")
            echo "🔨 Make Target: $name"
            echo "Will run: make $name"
            echo ""
            _dev_analyze_make_target "$name"
            ;;
        "django")
            echo "🐍 Django Command: $name"
            echo "Will run: python manage.py $name"
            echo ""
            _dev_analyze_django_command "$name"
            ;;
    esac
}

# Analyze NPM script and provide context
_dev_analyze_npm_script() {
    local script_name="$1"
    local script_cmd="$2"
    
    case "$script_name" in
        "dev"|"serve"|"start:dev")
            echo "🚀 Purpose: Start development server with hot reload"
            echo "🔧 Typical use: Local development and testing"
            ;;
        "build"|"build:prod")
            echo "🏗️  Purpose: Build application for production"
            echo "🔧 Typical use: Creating optimized, deployable assets"
            ;;
        "start")
            echo "▶️  Purpose: Start production server"
            echo "🔧 Typical use: Running built application in production"
            ;;
        "test"|"test:unit"|"test:integration")
            echo "🧪 Purpose: Run test suite"
            echo "🔧 Typical use: Validate code functionality and catch bugs"
            ;;
        "lint"|"eslint")
            echo "🔍 Purpose: Check code quality and style"
            echo "🔧 Typical use: Maintain consistent code formatting"
            ;;
        "lint:fix"|"format"|"format:fix")
            echo "🛠️  Purpose: Auto-fix code style issues"
            echo "🔧 Typical use: Automatically format code to standards"
            ;;
        "type-check"|"typecheck")
            echo "📋 Purpose: Check TypeScript types without compilation"
            echo "🔧 Typical use: Validate type safety in TypeScript projects"
            ;;
        "clean")
            echo "🧹 Purpose: Clean build artifacts and cache"
            echo "🔧 Typical use: Fresh start when build issues occur"
            ;;
        "install"|"preinstall"|"postinstall")
            echo "📦 Purpose: Package installation lifecycle hook"
            echo "🔧 Typical use: Setup dependencies and project configuration"
            ;;
        *)
            # Try to infer from command content
            if [[ "$script_cmd" =~ "next dev" ]]; then
                echo "🚀 Purpose: Start Next.js development server with hot reload"
            elif [[ "$script_cmd" =~ "next build" ]]; then
                echo "🏗️  Purpose: Build Next.js application for production"
            elif [[ "$script_cmd" =~ "vite" ]]; then
                echo "⚡ Purpose: Vite build tool command"
            elif [[ "$script_cmd" =~ "webpack" ]]; then
                echo "📦 Purpose: Webpack bundler command"
            elif [[ "$script_cmd" =~ "prettier" ]]; then
                echo "🎨 Purpose: Code formatting with Prettier"
            elif [[ "$script_cmd" =~ "eslint" ]]; then
                echo "🔍 Purpose: JavaScript/TypeScript linting"
            elif [[ "$script_cmd" =~ "jest" ]]; then
                echo "🧪 Purpose: Testing with Jest framework"
            elif [[ "$script_cmd" =~ "cypress" ]]; then
                echo "🌐 Purpose: End-to-end testing with Cypress"
            else
                echo "⚙️  Purpose: Custom project script"
            fi
            ;;
    esac
}

# Analyze Cargo command
_dev_analyze_cargo_command() {
    local cmd="$1"
    
    case "$cmd" in
        "run")
            echo "🚀 Purpose: Compile and run the main binary"
            echo "🔧 Typical use: Quick development testing"
            ;;
        "build")
            echo "🏗️  Purpose: Compile the project without running"
            echo "🔧 Typical use: Check compilation without execution"
            ;;
        "test")
            echo "🧪 Purpose: Run all tests in the project"
            echo "🔧 Typical use: Validate code correctness"
            ;;
        "check")
            echo "✅ Purpose: Fast compilation check without producing executable"
            echo "🔧 Typical use: Quick syntax and type checking"
            ;;
        "fmt")
            echo "🎨 Purpose: Format Rust code according to style guidelines"
            echo "🔧 Typical use: Maintain consistent code formatting"
            ;;
        "clippy")
            echo "🔍 Purpose: Run Rust linter for code quality improvements"
            echo "🔧 Typical use: Catch common mistakes and improve code"
            ;;
    esac
}

# Analyze Make target
_dev_analyze_make_target() {
    local target="$1"
    
    # Try to get description from Makefile comments
    if [[ -f "Makefile" ]]; then
        local desc=$(grep -B1 "^$target:" Makefile | grep "^#" | sed 's/^#[[:space:]]*//')
        [[ -n "$desc" ]] && echo "📖 Description: $desc" && echo ""
    fi
    
    case "$target" in
        "build"|"compile")
            echo "🏗️  Purpose: Compile/build the project"
            ;;
        "clean")
            echo "🧹 Purpose: Remove build artifacts and temporary files"
            ;;
        "install")
            echo "📥 Purpose: Install the compiled program"
            ;;
        "test"|"check")
            echo "🧪 Purpose: Run project tests"
            ;;
        "run")
            echo "🚀 Purpose: Run the compiled program"
            ;;
        "dist"|"package")
            echo "📦 Purpose: Create distribution package"
            ;;
        "docs"|"doc")
            echo "📚 Purpose: Generate project documentation"
            ;;
        *)
            echo "⚙️  Purpose: Custom build target"
            ;;
    esac
}

# Analyze Django management command
_dev_analyze_django_command() {
    local cmd="$1"
    
    case "$cmd" in
        "runserver")
            echo "🚀 Purpose: Start Django development server"
            echo "🔧 Typical use: Local development with hot reload"
            ;;
        "migrate")
            echo "🗃️  Purpose: Apply database migrations"
            echo "🔧 Typical use: Update database schema to match models"
            ;;
        "makemigrations")
            echo "📝 Purpose: Create new database migrations"
            echo "🔧 Typical use: Generate migration files for model changes"
            ;;
        "shell")
            echo "🐍 Purpose: Start Django interactive shell"
            echo "🔧 Typical use: Test models and queries interactively"
            ;;
        "test")
            echo "🧪 Purpose: Run Django test suite"
            echo "🔧 Typical use: Validate application functionality"
            ;;
        "collectstatic")
            echo "📁 Purpose: Collect static files for production"
            echo "🔧 Typical use: Prepare static assets for deployment"
            ;;
        "createsuperuser")
            echo "👤 Purpose: Create admin user account"
            echo "🔧 Typical use: Set up administrative access"
            ;;
        *)
            echo "⚙️  Purpose: Django management command"
            ;;
    esac
}

# Run a specific script
_dev_run_script() {
    local script="$1"
    
    echo "🚀 Running: $script"
    
    # Detect script type based on context and name
    local type name
    if [[ "$script" == *":"* ]]; then
        type="${script%%:*}"
        name="${script#*:}"
    else
        # No prefix, determine type from context
        if [[ -f "package.json" ]] && zmod_has_command jq; then
            if jq -r '.scripts | keys[]' package.json 2>/dev/null | grep -q "^$script$"; then
                type="npm"
                name="$script"
            fi
        elif [[ "$script" =~ ^(run|build|test|check|fmt|clippy)$ ]] && [[ -f "Cargo.toml" ]]; then
            type="cargo"
            name="$script"
        elif [[ "$script" =~ ^(runserver|migrate|makemigrations|shell|test)$ ]] && [[ -f "manage.py" ]]; then
            type="django"
            name="$script"
        else
            # Default to npm if package.json exists
            if [[ -f "package.json" ]]; then
                type="npm"
                name="$script"
            else
                type="unknown"
                name="$script"
            fi
        fi
    fi
    
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