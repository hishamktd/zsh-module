# Changelog

All notable changes to the ZSH Module Framework will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.2] - 2025-09-02

### Added
- **Git Module**: Enhanced `stash-list` command with color separation in preview
  - Added `--color=always` and `--ansi` flags for proper diff coloring in fzf preview
- **Git Module**: Enhanced `differ` command with interactive file selection
  - Added fzf-based file selection with colored diff preview
  - Interactive file browsing with ESC to cancel cleanly
  - Shows differences between current branch and specified branch (or default)

### Fixed
- **Core Framework**: Fixed `zmod list`/`zmod ls` commands failing with "read-only variable: status"
  - Renamed conflicting `status` variable to `module_status` to avoid zsh built-in conflicts
- **Core Framework**: Fixed `zmod disable` command failing with "bad output format specification"
  - Corrected malformed sed character class `[[\.*^$()+?{|]` to `[[.*^$()+?{|]` in regex escaping
- **Git Module**: Fixed `differ` command fallback behavior
  - ESC now properly cancels without showing full diff output
  - Improved user experience with clean exit on cancellation

### Enhanced
- **Git Module**: Improved consistency across interactive commands
  - Both `stash-list` and `differ` now use consistent fzf patterns with colored previews
  - Better error handling and user feedback across git commands

## [1.0.1] - 2025-09-01

### Fixed
- **Git Module**: Fixed regex pattern issues in branch command
  - Replaced problematic `^\*` regex patterns with zsh-compatible string matching
  - Fixed `branch -ls` command that was failing due to regex compilation errors
- **Core Framework**: Improved regex handling across modules for better zsh compatibility

### Changed
- Enhanced regex patterns for better cross-shell compatibility
- Improved error handling in git branch operations

## [1.0.0] - 2025-09-01

### Added
- **Core Framework**: Modular shell configuration system with lazy/eager loading
- **Git Module**: Complete PowerShell script conversion with enhanced functionality
  - `status` - Comprehensive git status with colors and sections
  - `commit` - Smart commit with automatic staging and validation
  - `branch` - Branch management with listing and clipboard integration
  - `working` - Working branch management system (add/remove/switch/list)
  - Enhanced workflow commands: `gpu`, `gpr`, `gclean`, `gstash`
- **Development Module**: Universal development workflow automation
  - `serve` - Auto-detect and start development servers
  - `install` - Smart package manager detection (npm, yarn, pnpm, bun, etc.)
  - `build` - Universal build command for any project type
  - `test` - Universal test runner with framework detection
  - `lint` - Auto-format and lint with tool detection
  - `init` - Project initialization for multiple languages
- **System Module**: Enhanced system utilities
  - `ll/la/lt` - Enhanced file listing with icons and git integration
  - `f/g` - Smart find and grep with modern tool integration
  - `sysinfo` - Comprehensive system information display
  - `extract/archive` - Universal archive operations
  - Process management: `psg`, `pk`, `service`
- **Network Module**: Network diagnostics and utilities
  - `httpstatus` - HTTP status checker with timing
  - `speedtest` - Internet speed testing
  - `netinfo` - Network interface information
  - `sslcheck` - SSL certificate validation
  - `nettest` - Comprehensive connectivity testing
- **Management System**: Complete CLI for framework management
  - `zmod` command with full module lifecycle management
  - Installation/uninstallation scripts with backup
  - Build system with performance optimization
  - Configuration management with lazy/eager loading modes
- **Performance Features**:
  - Module caching system for fast loading
  - Lazy loading registry (currently disabled due to alias conflicts)
  - Selective module enabling/disabling
  - Built-in performance timing utilities

### Architecture
- Modular design with clean separation of concerns
- Core framework (loader, config, utils) + feature modules
- Build system for cache optimization
- Plugin ecosystem support
- Theme system foundation

### PowerShell Compatibility
- Converted all major PowerShell script functions to zsh
- Maintained function names and behavior for seamless migration
- Enhanced functionality with better error handling and colors
- Cross-platform compatibility (Linux/macOS)

### Documentation
- Comprehensive README with usage examples
- Inline documentation for all functions
- Architecture documentation
- Installation and configuration guides

## [Unreleased]

### Known Issues
- Lazy loading has alias conflicts (functions vs aliases) - currently disabled
- Some shell loading edge cases on certain configurations

### Planned Features
- Fix lazy loading system
- Theme system implementation
- Plugin ecosystem expansion
- Web-based configuration interface
- Auto-update system