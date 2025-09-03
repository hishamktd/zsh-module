# Development Module

The Development module provides universal development workflow automation, supporting multiple programming languages and frameworks with intelligent tool detection.

## 📋 Overview

The Development module includes:
- Universal development server management
- Smart package manager detection and operations
- Build system automation across languages
- Test runner integration
- Code formatting and linting
- Project initialization templates
- Development environment status

## 📁 Module Structure

```
modules/dev/
├── dev.zsh        # Main module file and core functions  
├── server.zsh     # Development server management
├── package.zsh    # Package manager operations
├── build.zsh      # Universal build system
├── test.zsh       # Test runner integration
├── lint.zsh       # Code formatting and linting
├── init.zsh       # Project initialization
├── scripts.zsh    # Package script runner
├── status.zsh     # Development environment status
└── utils.zsh      # Development utilities
```

## 🚀 Core Commands

### Development Server Management

#### `serve [port] [options]`
Auto-detects and starts the appropriate development server.

```bash
# Usage
serve                    # Auto-detect and serve on default port
serve 8080              # Serve on specific port  
serve --host 0.0.0.0    # Serve on all interfaces
serve --open            # Auto-open browser
```

**Supported Frameworks:**
- **Node.js**: `npm start`, `yarn start`, `pnpm start`, `bun start`
- **Python**: `python -m http.server`, `flask run`, `django runserver`
- **PHP**: `php -S localhost:port`
- **Ruby**: `rails server`, `sinatra`, `rackup`
- **Go**: `go run .`, custom go servers
- **Rust**: `cargo run`
- **Static**: Simple HTTP server for static files

**Auto-Detection Logic:**
1. Checks for `package.json` → Node.js ecosystem
2. Looks for `requirements.txt`, `app.py` → Python
3. Finds `Gemfile`, `config.ru` → Ruby
4. Detects `go.mod`, `main.go` → Go
5. Looks for `Cargo.toml` → Rust
6. Falls back to static file server

**Features:**
- Intelligent port selection (avoids conflicts)
- Background process management
- Auto-restart on file changes (when supported)
- Browser integration
- Process cleanup on exit

#### Server Management
```bash
# Additional server commands
serve-stop              # Stop development server
serve-restart           # Restart current server
serve-status           # Show running servers
serve-logs             # Show server logs
```

### Package Management

#### `install [packages...]`
Universal package installer with smart package manager detection.

```bash
# Usage
install                     # Install all dependencies
install express react      # Install specific packages
install --dev typescript   # Install dev dependencies
install --global yarn      # Global installation
```

**Package Manager Priority:**
1. **Node.js**: `bun` → `pnpm` → `yarn` → `npm`
2. **Python**: `poetry` → `pipenv` → `pip`
3. **Ruby**: `bundle` → `gem`
4. **Go**: `go get`, `go mod`
5. **Rust**: `cargo add`, `cargo install`
6. **PHP**: `composer`

**Features:**
- Lockfile-aware installation
- Development vs production dependencies
- Global package management
- Dependency conflict resolution
- Installation progress tracking

#### `uninstall [packages...]`
Remove packages using appropriate package manager.

```bash
# Usage
uninstall lodash          # Remove specific package
uninstall --dev @types/*  # Remove dev dependencies
uninstall --global yarn   # Global uninstallation
```

### Build System

#### `build [target] [options]`
Universal build command with multi-language support.

```bash
# Usage
build                     # Default build
build production         # Production build
build --watch            # Watch mode for development
build --clean            # Clean build (remove artifacts first)
```

**Build System Detection:**
- **Node.js**: `npm run build`, `yarn build`, package.json scripts
- **Python**: `setup.py`, `pyproject.toml`, `Makefile`
- **Go**: `go build`, `Makefile`
- **Rust**: `cargo build`, `cargo build --release`
- **Java**: `maven`, `gradle`, `ant`
- **C/C++**: `make`, `cmake`, `ninja`
- **Generic**: `Makefile`, `build.sh`, `Dockerfile`

**Features:**
- Parallel builds when supported
- Build artifact management
- Environment-specific builds
- Build caching optimization
- Error reporting and recovery

#### Build Utilities
```bash
# Additional build commands
build-clean             # Clean build artifacts
build-watch             # Watch for changes and rebuild
build-analyze           # Analyze build output
build-stats             # Build statistics and timing
```

### Testing Framework

#### `test [pattern] [options]`
Universal test runner with framework detection.

```bash
# Usage
test                      # Run all tests
test unit                # Run unit tests only  
test src/components      # Test specific directory
test --watch            # Watch mode
test --coverage         # Generate coverage report
```

**Test Framework Support:**
- **JavaScript/TypeScript**: Jest, Mocha, Vitest, Cypress, Playwright
- **Python**: pytest, unittest, nose2, tox
- **Go**: `go test`, testify
- **Rust**: `cargo test`
- **Ruby**: RSpec, Minitest
- **Java**: JUnit, TestNG, Maven/Gradle test
- **PHP**: PHPUnit, Codeception

**Features:**
- Parallel test execution
- Coverage reporting
- Test result formatting
- Failed test re-running  
- CI/CD integration support

#### Test Management
```bash
# Additional test commands
test-watch              # Continuous testing
test-coverage           # Generate coverage reports
test-ci                 # CI-optimized test run
test-debug             # Debug failing tests
```

### Code Quality

#### `lint [files...] [options]`
Auto-format and lint code with tool detection.

```bash
# Usage
lint                     # Lint all files
lint src/               # Lint specific directory
lint --fix              # Auto-fix issues
lint --staged           # Lint only staged files
```

**Linter Support:**
- **JavaScript/TypeScript**: ESLint, Prettier, Biome
- **Python**: flake8, black, ruff, mypy
- **Go**: gofmt, golint, staticcheck
- **Rust**: rustfmt, clippy
- **Ruby**: RuboCop, StandardRB
- **PHP**: PHP_CodeSniffer, PHP-CS-Fixer
- **Shell**: shellcheck, shfmt

**Features:**
- Auto-fix where possible
- Pre-commit hook integration
- Editor config respect
- Custom rule configuration
- Performance optimization

### Project Initialization

#### `init [template] [project_name]`
Initialize new projects with templates.

```bash
# Usage
init                        # Interactive project setup
init react my-app          # React project
init python my-script      # Python project  
init go my-service         # Go service
init rust my-tool          # Rust application
```

**Available Templates:**
- **Frontend**: React, Vue, Svelte, Angular, Vanilla JS
- **Backend**: Node.js (Express, Fastify), Python (Flask, Django), Go, Rust
- **Mobile**: React Native, Flutter (planned)
- **Desktop**: Electron, Tauri (planned)
- **CLI**: Node.js, Python, Go, Rust
- **Library**: Multi-language library templates

**Features:**
- Interactive configuration
- Git repository initialization
- Dependency installation
- IDE/editor setup
- Documentation generation
- CI/CD pipeline setup (optional)

### Script Running

#### `run [script] [args...]`
Run package scripts with smart detection.

```bash
# Usage
run                      # List available scripts
run start               # Run start script
run test:unit           # Run specific test script
run "build && deploy"   # Run compound commands
```

**Script Sources:**
- `package.json` scripts (Node.js)
- `Makefile` targets
- `setup.py` commands (Python)
- `Cargo.toml` scripts (Rust)
- Custom `.scripts/` directory

### Development Status

#### `dev-status`
Show comprehensive development environment status.

```bash
# Usage
dev-status

# Output example:
# 🔧 Development Environment Status
# ├── Project: my-awesome-app (Node.js)
# ├── Package Manager: yarn (1.22.19)
# ├── Runtime: Node.js 18.17.0  
# ├── Dependencies: ✅ Up to date
# ├── Build: ✅ Ready
# ├── Tests: ✅ Passing (95% coverage)
# ├── Linting: ⚠️ 3 warnings
# └── Git: 🔄 2 commits ahead of origin
```

**Status Checks:**
- Project type and configuration
- Package manager and version
- Runtime environment
- Dependency status
- Build readiness
- Test status
- Code quality
- Git repository status
- Development server status

## 🎯 Advanced Features

### Environment Management

#### `dev-env [command]`
Manage development environments.

```bash
# Usage
dev-env list            # List available environments
dev-env use node18      # Switch Node.js version
dev-env create myenv    # Create new environment
dev-env remove oldenv   # Remove environment
```

**Environment Types:**
- Node.js version management (nvm, fnm, n)
- Python virtual environments
- Ruby version management (rbenv, rvm)
- Go version management
- Docker development containers

### Dependency Management

#### `deps [command]`
Advanced dependency management.

```bash
# Usage
deps outdated           # Show outdated dependencies
deps update             # Update dependencies
deps audit              # Security audit
deps clean              # Clean dependency cache
deps tree               # Show dependency tree
```

### Performance Monitoring

#### `perf [command]`
Development performance monitoring.

```bash
# Usage
perf build              # Measure build performance
perf test               # Test execution timing
perf bundle             # Bundle size analysis
perf deps               # Dependency impact analysis
```

## 🛠️ Configuration

### Environment Variables

| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `ZSH_MODULE_DEV_PORT` | Default dev server port | `3000` | `8080`, `4000` |
| `ZSH_MODULE_NODE_MANAGER` | Preferred Node manager | Auto-detect | `npm`, `yarn`, `pnpm`, `bun` |
| `ZSH_MODULE_PYTHON_MANAGER` | Python package manager | Auto-detect | `pip`, `poetry`, `pipenv` |
| `ZSH_MODULE_AUTO_INSTALL` | Auto-install missing deps | `true` | `true`, `false` |

### Project Configuration

#### `.devrc` Configuration
Create a `.devrc` file in your project root:

```bash
# .devrc example
DEV_PORT=8080
DEV_HOST=0.0.0.0
BUILD_TARGET=production
TEST_COMMAND="npm run test:ci"
LINT_FIX=true
AUTO_OPEN_BROWSER=true
```

#### Framework-Specific Configuration
The module respects existing framework configurations:
- `package.json` (Node.js)
- `pyproject.toml`, `setup.cfg` (Python)
- `Cargo.toml` (Rust)
- `go.mod` (Go)
- `Gemfile` (Ruby)

## 🎨 Customization Examples

### Custom Build Commands
```bash
# Add to your .zshrc
function build-docker() {
    echo "🐳 Building Docker image..."
    docker build -t $(basename $PWD) .
}

function build-docs() {
    echo "📚 Building documentation..."
    if zmod_has_command "sphinx-build"; then
        sphinx-build docs docs/_build
    elif [[ -f "mkdocs.yml" ]]; then
        mkdocs build
    fi
}
```

### Project Templates
```bash
# Custom project initializers
function init-fullstack() {
    init react frontend
    cd ..
    init node backend
    echo "✅ Fullstack project initialized!"
}
```

### Development Workflow
```bash
# Combined workflow commands
function dev-start() {
    echo "🚀 Starting development environment..."
    install          # Install dependencies
    lint --fix       # Fix linting issues  
    test --coverage  # Run tests with coverage
    serve --open     # Start server and open browser
}

function dev-deploy() {
    echo "🚢 Preparing for deployment..."
    test             # Ensure tests pass
    lint             # Check code quality
    build production # Production build
    echo "✅ Ready for deployment!"
}
```

## 🚨 Error Handling

### Dependency Issues
```bash
# Automatic dependency resolution
if ! zmod_has_command "node"; then
    echo $(zmod_color yellow "⚠️ Node.js not found. Install Node.js first.")
    return 1
fi

if [[ ! -f "package.json" ]]; then
    echo $(zmod_color red "❌ No package.json found. Run 'init node' first.")
    return 1
fi
```

### Build Failures
- Detailed error reporting
- Suggests common solutions
- Provides recovery commands
- Offers alternative build methods

### Environment Conflicts
- Detects version conflicts
- Suggests resolution strategies
- Provides environment switching commands

## 📊 Performance Features

### Build Optimization
- Parallel execution where supported
- Build caching
- Incremental builds
- Dead code elimination hints

### Development Server
- Hot reloading support
- Asset optimization
- Memory usage monitoring
- Port conflict resolution

## 🔍 Troubleshooting

### Common Issues

#### Package Manager Not Found
```bash
# Install preferred package manager
npm install -g yarn pnpm

# Or use specific manager
ZSH_MODULE_NODE_MANAGER=npm install
```

#### Port Already in Use
```bash
# Automatic port selection
serve              # Will find available port
serve 8080         # Try specific port, fallback if busy
```

#### Build Failures
```bash
# Clean build
build --clean

# Check dependencies
deps outdated
deps audit
```

### Debug Mode
```bash
# Enable debug output
export ZSH_MODULE_DEBUG=true
build

# Shows detailed build information
```

## 📚 Dependencies

### Required
- `zsh` 5.0+
- At least one package manager for your language
- Core utilities (`curl`, `wget` for downloads)

### Language-Specific
- **Node.js**: `node`, `npm` (minimum)
- **Python**: `python3`, `pip`
- **Go**: `go`
- **Rust**: `cargo`
- **Ruby**: `ruby`, `gem`

### Optional
- `fzf` - Interactive selection
- Modern terminals - Better output formatting
- Docker - Container-based development

## 🔮 Future Enhancements

### Planned Features
- **Container Integration** - Docker/Podman development environments
- **Cloud Development** - Remote development environment support  
- **AI Integration** - Code generation and optimization suggestions
- **Performance Profiling** - Advanced performance analysis
- **Dependency Security** - Automated security scanning
- **Multi-Language Projects** - Polyglot project support

### Advanced Tooling
```bash
# Planned commands  
dev-container create        # Create dev container
dev-cloud sync             # Sync with cloud environment
dev-ai suggest             # AI-powered suggestions
dev-profile analyze        # Performance profiling
dev-secure scan           # Security vulnerability scan
```

## 📚 Related Documentation

- [Git Module](git.md) - Git workflow integration
- [System Module](system.md) - System utilities
- [Core Utilities](../core/utils.md) - Helper functions
- [Installation](../scripts/install.md) - Setup and configuration