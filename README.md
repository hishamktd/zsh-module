# ZSH Module Framework

A high-performance, modular shell configuration system for Zsh that provides lazy loading, easy module management, and extensible architecture.

## ✨ Features

- **🚀 Lazy Loading**: Fast shell startup with on-demand module loading
- **📦 Modular Design**: Organize functionality into discrete, manageable modules
- **⚡ Performance Optimized**: Built-in caching system for lightning-fast loading
- **🛠️ Easy Management**: Simple CLI for enabling/disabling modules
- **🔧 Extensible**: Create custom modules with ease
- **📋 Auto-completion**: Full tab completion for all commands
- **🎨 Theme Support**: Pluggable theme system
- **🔌 Plugin Ecosystem**: Easy integration with external plugins

## 🚀 Quick Start

1. **Install the framework:**
   ```bash
   cd /path/to/zsh-module
   ./scripts/install.zsh
   ```

2. **Restart your shell or reload:**
   ```bash
   source ~/.zshrc
   ```

3. **Verify installation:**
   ```bash
   zmod status
   ```

4. **Start using commands:**
   ```bash
   status          # Enhanced git status
   commit "fix: bug"  # Smart git commit
   working add     # Add current branch to working list
   serve          # Start development server
   ```

## 📖 Usage

### Module Management
```bash
zmod list                    # List all available modules
zmod enable git              # Enable git module
zmod disable network         # Disable network module
zmod info git               # Show module information
zmod reload                 # Reload all modules
```

### Configuration Management
```bash
zmod config show                          # Show all configuration
zmod config set lazy_load true           # Enable lazy loading
zmod config set debug true               # Enable debug output  
zmod config set auto_update false        # Disable auto updates
zmod config set default_branch develop   # Set default git branch
zmod config get default_branch           # Get current default branch
```


### Performance
```bash
zmod build                  # Rebuild caches
zmod config set lazy_load true    # Enable lazy loading for faster startup
```

## 📦 Available Modules

### Git Module
Enhanced git workflow with configurable default branch:
- `status` - Comprehensive git status with colors and ahead/behind tracking
- `commit [message]` - Smart commit with staging and validation
- `pull [branch]` - Pull with rebase (defaults to configured branch)
- `push` - Smart push with upstream handling
- `branch [-ls] [-r]` - Branch management with clipboard integration
- `swap [branch]` - Smart branch switching with fallback detection
- `working [add|remove|list|switch]` - Working branch management
- `stash [message]` - Stash changes with optional message
- `apply [id]` - Apply stash by ID or latest
- `stash-list` - Interactive stash management with fzf
- `gclean` - Clean merged branches (uses configured default branch)

**Configuration:**
- Set default branch: `zmod config set default_branch develop`
- All git commands respect the configured default branch

### Development Module  
Development workflow automation with smart project detection:
- `dev [dir]` - Smart development server launcher (auto-detects project type)
- `script` - Interactive script management (list/run npm scripts, cargo commands, etc.)
- `serve [port] [dir]` - Start development server with port specification
- `install [packages]` - Smart package manager detection (bun/pnpm/yarn/npm)
- `build [--prod]` - Universal build command
- `test [args]` - Universal test runner with watch mode
- `lint [--fix]` - Auto-format and lint code
- `init [type] [name]` - Initialize new projects (node/rust/python/go)
- `status` - Development environment status and project info
- `port [num|kill|list]` - Port management utilities
- `env [show|activate]` - Environment variable management

**Script Management:**
- Interactive fzf selection of available scripts
- Support for npm/yarn/pnpm/bun scripts, cargo commands, Makefile targets
- Preview of actual commands before execution

**Short aliases:** `s` (serve), `i` (install), `b` (build), `t` (test), `l` (lint), `st` (status)

### System Module
System utilities and shortcuts:
- `ll/la/lt` - Enhanced file listing
- `f pattern` - Smart file finding
- `g pattern` - Enhanced grep with colors
- `sysinfo` - System information display
- `myip` - Show local and public IP
- `extract file` - Universal archive extraction
- `port kill/check` - Port management

### Network Module
Network utilities and diagnostics:
- `httpstatus url` - HTTP status checker
- `speedtest` - Internet speed test
- `netinfo` - Network interface information
- `nslookup domain` - DNS lookup
- `sslcheck domain` - SSL certificate checker
- `nettest` - Connectivity test

## 🏗️ Architecture

```
zsh-module/
├── core/                 # Core framework
│   ├── loader.zsh       # Module loading system
│   ├── config.zsh       # Configuration & lazy loading
│   └── utils.zsh        # Common utilities
├── modules/             # Feature modules
│   ├── git/            # Git workflow commands
│   ├── dev/            # Development tools
│   ├── system/         # System utilities
│   └── network/        # Network tools
├── scripts/            # Management scripts
│   ├── install.zsh     # Installation script
│   ├── build.zsh       # Build system
│   └── manager.zsh     # CLI manager (zmod command)
├── config/             # Configuration files
│   ├── enabled.conf    # Enabled modules list
│   └── zshrc.conf      # User preferences
└── dist/               # Built cache files
    ├── modules.zsh     # Eager loading cache
    └── lazy-registry.zsh # Lazy loading registry
```

## 🔧 Creating Custom Modules

1. **Create a new module:**
   ```bash
   zmod create mymodule
   ```

2. **Edit the module file:**
   ```bash
   # modules/mymodule/mymodule.zsh
   my_function() {
       echo "Hello from my module!"
   }
   alias hello='my_function'
   ```

3. **Configure lazy loading:**
   ```bash
   # modules/mymodule/lazy.conf
   my_function
   hello:my_function
   ```

4. **Enable the module:**
   ```bash
   zmod enable mymodule
   ```

## ⚙️ Configuration

### Lazy Loading
Enable lazy loading for faster shell startup:
```bash
zmod config set lazy_load true
```

With lazy loading enabled, commands are only loaded when first used, dramatically reducing shell startup time.

### Debug Mode
Enable debug output to troubleshoot issues:
```bash
zmod config set debug true
```

### Auto Updates
Control automatic cache rebuilding:
```bash
zmod config set auto_update true
```

## 🚀 Performance

- **Lazy Loading**: ~50ms startup time vs ~200ms eager loading
- **Cached Builds**: Pre-built module combinations for instant loading
- **Smart Detection**: Automatic tool detection with fallbacks
- **Minimal Dependencies**: Works with basic shell utilities

## 🔧 Advanced Usage

### Manual Installation
```bash
# Set framework directory
export ZSH_MODULE_DIR="/path/to/zsh-module"

# Add to .zshrc
echo 'export ZSH_MODULE_DIR="/path/to/zsh-module"' >> ~/.zshrc
echo 'source "$ZSH_MODULE_DIR/scripts/manager.zsh"' >> ~/.zshrc
echo 'zmod_init' >> ~/.zshrc
```

### Development Workflow
```bash
# Make changes to modules
vim modules/git/git.zsh

# Rebuild caches
zmod build

# Test changes
zmod reload
```

### Plugin Integration
```bash
# Add external plugins to plugins/ directory
git clone https://github.com/user/plugin plugins/my-plugin

# Enable in config
echo "my-plugin" >> config/enabled.conf

# Rebuild
zmod build
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/new-module`
3. Add your module in `modules/your-module/`
4. Test your changes: `zmod build && zmod reload`
5. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details.

## 🙏 Acknowledgments

Inspired by Oh My Zsh, Prezto, and various shell frameworks, but built for performance and simplicity.