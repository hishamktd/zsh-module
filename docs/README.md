# ZSH Module Framework Documentation

Welcome to the comprehensive documentation for the ZSH Module Framework - a powerful, modular shell configuration system that enhances your command-line experience.

## 📚 Documentation Structure

### Core Framework
- [`core/`](core/) - Core framework components
  - [Loader System](core/loader.md) - Module loading and management
  - [Configuration](core/config.md) - Configuration system and settings
  - [Utilities](core/utils.md) - Core utility functions and helpers

### Modules
- [`modules/`](modules/) - Feature modules documentation
  - [Git Module](modules/git.md) - Git workflow automation and enhancements
  - [Development Module](modules/dev.md) - Universal development tools
  - [System Module](modules/system.md) - System utilities and enhancements
  - [Network Module](modules/network.md) - Network diagnostics and tools

### Scripts & Management
- [`scripts/`](scripts/) - Management and build scripts
  - [Installation](scripts/install.md) - Installation and setup process
  - [Build System](scripts/build.md) - Build and optimization system
  - [Manager](scripts/manager.md) - Module lifecycle management

### API Reference
- [`api/`](api/) - Complete function reference
  - [Core Functions](api/core.md) - Framework core functions
  - [Module Functions](api/modules.md) - All module functions
  - [Utility Functions](api/utils.md) - Helper and utility functions

## 🚀 Quick Start

1. **Installation**: See [Installation Guide](scripts/install.md)
2. **Configuration**: Check [Configuration Guide](core/config.md)
3. **Module Usage**: Browse [Modules Documentation](modules/)
4. **Management**: Learn [Module Management](scripts/manager.md)

## 📖 Key Concepts

### Modular Architecture
The framework is built around independent modules that can be enabled/disabled as needed:
- **Core**: Essential framework functionality
- **Modules**: Feature-specific enhancements (Git, Dev, System, Network)
- **Scripts**: Management and build tools

### Loading System
- **Eager Loading**: Load all enabled modules at startup (default)
- **Lazy Loading**: Load modules on-demand (planned)
- **Caching**: Pre-built module cache for faster startup

### Configuration
- **Module Config**: `~/.config/zsh-module/enabled-modules`
- **Framework Settings**: Environment variables and options
- **Per-module Settings**: Module-specific configuration

## 🔧 Management Commands

```bash
# Module management
zmod list                    # List available modules
zmod enable <module>         # Enable a module
zmod disable <module>        # Disable a module
zmod reload                  # Reload all modules

# Framework management
zmod build                   # Build module cache
zmod status                  # Show framework status
zmod update                  # Update framework (planned)
```

## 📊 Module Overview

| Module | Description | Key Functions |
|--------|-------------|---------------|
| **git** | Git workflow automation | `status`, `commit`, `branch`, `working`, `stash-list` |
| **dev** | Development tools | `serve`, `build`, `test`, `lint`, `install` |
| **system** | System utilities | `ll`, `f`, `g`, `sysinfo`, `extract` |
| **network** | Network diagnostics | `httpstatus`, `speedtest`, `netinfo`, `sslcheck` |

## 🛠️ Customization

### Creating Custom Modules
1. Create module directory: `modules/mymodule/`
2. Add module files: `mymodule.zsh`
3. Enable module: `zmod enable mymodule`
4. Rebuild cache: `zmod build`

### Extending Existing Modules
- Add new functions to existing module files
- Follow naming conventions and documentation standards
- Rebuild cache after changes

## 📋 Version Information

- **Current Version**: 1.0.2
- **Last Updated**: 2025-09-02
- **Compatibility**: zsh 5.0+, Linux/macOS

## 🤝 Contributing

See the main [README.md](../README.md) for contribution guidelines and development setup.

## 📄 License

This project follows the same license as the main framework. See [LICENSE](../LICENSE) for details.