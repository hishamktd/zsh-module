# Dev Module Documentation

This module provides development workflow commands for various project types and package managers.

## Core Functions

### `dev [directory]`
**Smart development server launcher**

Automatically detects project type and runs appropriate development server.

**Usage:**
```bash
dev           # Start dev server in current directory
dev ./my-app  # Start dev server in specified directory
```

**Supported Project Types:**
- **Node.js** (`package.json`) - Runs `npm run dev`, `yarn dev`, `pnpm dev`, or `bun dev`
- **Rust** (`Cargo.toml`) - Runs `cargo run`
- **Django** (`manage.py`) - Runs `python manage.py runserver`
- **Python** (`app.py`/`main.py`) - Runs the Python file directly

### `serve [port] [directory]`
**Development server with fallbacks**

Starts appropriate development server with port specification.

**Usage:**
```bash
serve         # Default port 3000, current directory
serve 8080    # Custom port 8080
serve 3000 .  # Port 3000, current directory
```

**Server Priority:**
1. `npm run dev` (if package.json exists)
2. `cargo run` (if Cargo.toml exists)  
3. Python HTTP server (fallback)

### `install [packages...]`
**Smart package installation**

Detects project type and uses appropriate package manager.

**Usage:**
```bash
install              # Install all dependencies
install express      # Install specific package
install -D typescript # Install with dev dependency flag
```

**Package Manager Priority:**
- **Node.js**: bun → pnpm → yarn → npm
- **Rust**: `cargo add`
- **Python**: poetry → pip

### `build`
**Smart build system**

Runs appropriate build command based on project type.

**Usage:**
```bash
build         # Build current project
build --prod  # Production build (if supported)
```

**Build Commands:**
- **Node.js**: `npm run build`, `yarn build`, etc.
- **Rust**: `cargo build --release`
- **Python**: Various build tools based on project structure

### `test`
**Smart test runner**

Runs tests using appropriate test framework.

**Usage:**
```bash
test              # Run all tests
test unit         # Run specific test suite
test --watch      # Watch mode (if supported)
```

### `lint`
**Code linting and formatting**

Runs linters and formatters based on project type.

**Usage:**
```bash
lint          # Run linter
lint --fix    # Auto-fix issues
```

**Supported Linters:**
- **JavaScript/TypeScript**: ESLint, Prettier
- **Rust**: rustfmt, clippy
- **Python**: flake8, black, mypy

## Project Initialization

### `init [project-type] [name]`
**Initialize new project**

Creates new project with appropriate template.

**Usage:**
```bash
init                    # Interactive project creation
init node my-app        # Create Node.js project
init rust my-cli        # Create Rust project
init python my-script   # Create Python project
```

**Project Types:**
- `node` - Node.js with package.json
- `rust` - Rust with Cargo.toml
- `python` - Python with basic structure
- `react` - React application
- `nextjs` - Next.js application

## Utility Functions

### `status`
**Development environment status**

Shows information about development tools and project.

**Usage:**
```bash
status        # Show dev environment info
```

**Information Displayed:**
- Project type detection
- Available package managers
- Development tools versions
- Current project dependencies

### `port [port-number]`
**Port management**

Check if port is in use or kill processes on port.

**Usage:**
```bash
port 3000           # Check if port 3000 is in use
port kill 3000      # Kill process on port 3000  
port list           # List all listening ports
```

### `env`
**Environment management**

Manage environment variables and configuration.

**Usage:**
```bash
env                 # Show current environment
env set KEY=value   # Set environment variable
env load .env       # Load from .env file
```

## Short Aliases

For faster development workflow:

- `s` → `serve`
- `i` → `install` 
- `b` → `build`
- `t` → `test`
- `l` → `lint`
- `st` → `status`

## Examples

```bash
# Quick project setup
init react my-app
cd my-app
i                    # Install dependencies
dev                  # Start development server

# Working with existing project  
cd existing-project
status               # Check project info
i lodash            # Install new dependency
t                   # Run tests
b                   # Build for production

# Port management
port 3000           # Check if port is busy
dev                 # Start on different port if needed
```

## Project Detection Logic

The module uses the following files to detect project types:

1. **Node.js**: `package.json` presence
2. **Rust**: `Cargo.toml` presence  
3. **Python Django**: `manage.py` presence
4. **Python**: `app.py` or `main.py` presence
5. **General Python**: `requirements.txt` or `pyproject.toml`

## Configuration

The dev module respects standard configuration files:
- `.nvmrc` for Node.js version
- `rust-toolchain` for Rust version
- `.python-version` for Python version
- Project-specific configs (package.json scripts, etc.)