# Git Module

The Git module provides comprehensive git workflow automation and enhancements, converting PowerShell git scripts to zsh with improved functionality.

## 📋 Overview

The Git module includes:
- Enhanced status and commit workflows
- Branch management and working branch system
- Interactive stash management with colored previews
- Smart diff tools with file selection
- Git statistics and log visualization
- Cleanup and maintenance utilities

## 📁 Module Structure

```
modules/git/
├── git.zsh          # Main module file and core functions
├── aliases.zsh      # Git aliases and compatibility functions
├── status.zsh       # Enhanced git status with colors
├── commit.zsh       # Smart commit workflow
├── branch.zsh       # Branch management commands
├── working.zsh      # Working branch system
├── stash.zsh        # Interactive stash management
├── log.zsh          # Git log enhancements
├── stats.zsh        # Repository statistics
├── find.zsh         # File and commit search
├── blame.zsh        # Enhanced git blame
├── clean.zsh        # Repository cleanup utilities
├── pull.zsh         # Enhanced pull operations
├── push.zsh         # Smart push commands
├── swap.zsh         # Branch swapping utilities
└── undo.zsh         # Git undo operations
```

## 🚀 Core Commands

### Status and Information

#### `status`
Enhanced git status with colored output and organized sections.

```bash
# Usage
status

# Output example:
# ==== Git Status ======
# M  modified_file.js
# A  new_file.py  
# ?? untracked_file.txt
# 
# Current branch: feature/new-feature
# Ahead of origin by 2 commits
```

**Features:**
- Color-coded file status
- Branch information
- Ahead/behind tracking
- Clean, organized display

### Commit Workflow

#### `commit [message] [flags]`
Smart commit with automatic staging and validation.

```bash
# Usage
commit "feat: add new feature"                    # Simple commit
commit "fix: resolve bug" --no-verify            # Skip hooks
commit                                            # Interactive commit

# With scope
commit "feat(auth): add login functionality"
```

**Features:**
- Auto-detects changes and prompts to stage
- Validates commit message format
- Supports conventional commits
- Handles commit hooks gracefully
- Interactive mode when no message provided

**Workflow:**
1. Checks for changes to commit
2. Prompts to stage unstaged files if needed
3. Validates commit message
4. Executes commit with provided flags
5. Reports success/failure with helpful messages

### Branch Management

#### `branch [options] [branch_name]`
Comprehensive branch management with multiple sub-commands.

```bash
# List branches
branch -ls                    # List local branches
branch -ls -r                # List remote branches  
branch -ls -a                # List all branches

# Create and switch
branch feature/new-feature    # Create and switch to new branch
branch -c feature/auth        # Create branch from current
branch -d old-feature         # Delete branch (safe)
branch -D old-feature         # Force delete branch

# Branch operations
branch -m new-name            # Rename current branch
branch -u origin/main         # Set upstream
```

**Features:**
- Interactive branch listing with fzf (if available)
- Safe branch deletion with validation
- Upstream tracking setup
- Branch rename with remote updates
- Color-coded branch display

### Working Branch System

#### `working [command] [branch_name]`
Manages a working branch system for temporary work.

```bash
# Working branch commands
working add feature-work      # Add branch to working list
working remove feature-work   # Remove from working list  
working list                  # List working branches
working switch feature-work   # Switch to working branch
working clean                 # Clean up merged working branches
```

**Use Case:**
Perfect for managing multiple feature branches, experiments, or temporary work that shouldn't clutter your main branch list.

### Interactive Stash Management

#### `stash [message]`
Create stash with optional message.

```bash
# Usage
stash                                    # Auto-timestamped stash
stash "WIP: working on authentication"   # Custom message stash
```

#### `stash-list`
Interactive stash browser with colored diff previews.

```bash
# Usage
stash-list

# Interactive interface:
# - Browse stashes with arrow keys
# - Preview changes with colored diff
# - Actions: [a]pply [p]op [d]rop [s]how [c]ancel
```

**Features:**
- fzf integration for smooth selection
- Live colored diff preview (`--color=always` + `--ansi`)
- Multiple actions per stash
- Safe operations with confirmation

#### `apply [stash_id]`
Apply stash with smart ID handling.

```bash
# Usage
apply              # Apply latest stash (stash@{0})
apply 1            # Apply stash@{1}
apply stash@{2}    # Apply specific stash
```

### File Difference Tools

#### `differ [branch]`
Interactive file difference viewer with branch comparison.

```bash
# Usage  
differ                    # Compare with default branch
differ main               # Compare with main branch
differ origin/develop     # Compare with remote branch
```

**Features:**
- Interactive file selection with fzf
- Colored diff preview for each file
- Shows differences between current branch and target
- ESC to cancel without output
- File-by-file diff viewing

**Workflow:**
1. Lists all changed files between branches
2. Interactive selection with colored preview
3. Full diff display for selected file
4. Clean exit on cancellation

### Repository Statistics

#### `stats [options]`
Comprehensive repository statistics and insights.

```bash
# Usage
stats                     # Basic repository stats
stats --detailed         # Detailed statistics
stats --authors          # Author contribution stats
stats --files            # File type statistics
```

**Includes:**
- Commit count and frequency
- Author contributions
- File type distribution
- Repository age and activity
- Branch and tag counts

### Log and History

#### `log [options]`
Enhanced git log with better formatting and filtering.

```bash
# Usage
log                      # Standard enhanced log
log --oneline           # Compact one-line format
log --graph             # Graph view with branches
log --author="John"     # Filter by author
log --since="1 week"    # Time-based filtering
```

**Features:**
- Colored output with consistent formatting
- Graph visualization for branch history
- Smart date formatting
- Author and message highlighting

### Search and Find

#### `find [pattern] [options]`
Search through git history and files.

```bash
# Usage
find "function_name"     # Find in current files
find "bug fix" --log    # Search commit messages
find "password" --all   # Search all history (careful!)
```

**Search Types:**
- Current working tree
- Commit messages
- Commit content
- Full git history

### Cleanup and Maintenance

#### `gclean [options]`
Repository cleanup and maintenance.

```bash
# Usage
gclean                   # Interactive cleanup menu
gclean --branches       # Clean merged branches
gclean --stale          # Remove stale remote branches
gclean --all            # Full cleanup (with confirmation)
```

**Cleanup Options:**
- Remove merged branches
- Clean up stale remote references
- Optimize repository (gc, prune)
- Remove untracked files (interactive)

### Undo Operations

#### `undo [type] [options]`
Safe git undo operations.

```bash
# Usage
undo commit              # Undo last commit (keep changes)
undo commit --hard       # Undo last commit (lose changes)  
undo merge               # Undo last merge
undo file filename.txt   # Restore file to last commit
```

**Safety Features:**
- Confirms destructive operations
- Shows what will be undone
- Provides recovery information

## 🎯 Advanced Features

### Blame Enhancement

#### `blame [file] [options]`
Enhanced git blame with better formatting.

```bash
# Usage
blame src/main.js        # Blame with enhanced formatting
blame src/main.js -L10,20 # Blame specific line range
```

**Features:**
- Color-coded output
- Author highlighting
- Date formatting
- Line number alignment

### Smart Push/Pull

#### `gpu` (Git Push Upstream)
Smart push with upstream setup.

```bash
# Usage
gpu                      # Push current branch, set upstream if needed
gpu --force             # Force push (with safety checks)
```

#### `gpr` (Git Pull Rebase)
Pull with automatic rebase.

```bash
# Usage
gpr                     # Pull with rebase
gpr --autostash        # Auto-stash changes before pull
```

### Branch Swapping

#### `swap [branch]`
Quick branch switching with smart behavior.

```bash
# Usage
swap main               # Switch to main branch
swap -                  # Switch to previous branch
swap                    # Interactive branch selection
```

## 🛠️ Configuration

### Environment Variables

| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `ZSH_MODULE_DEFAULT_BRANCH` | Default git branch | `main` | `main`, `master`, `develop` |
| `ZSH_MODULE_GIT_EDITOR` | Git editor preference | `$EDITOR` | `code --wait`, `vim` |

### Git Aliases

The module includes compatibility aliases for common git operations:

```bash
# Basic aliases
alias ga='git add'
alias gd='git diff'
alias gdc='git diff --cached' 
alias gblame='blame'
```

## 🎨 Customization Examples

### Custom Commit Templates
```bash
# Add to your .zshrc
export ZSH_MODULE_COMMIT_TEMPLATE="type(scope): description

Detailed description here...

Closes: #issue"
```

### Custom Branch Naming
```bash
# Custom branch creation
function feature() {
    local feature_name="$1"
    branch "feature/$feature_name"
}

function hotfix() {
    local fix_name="$1"  
    branch "hotfix/$fix_name"
}
```

### Enhanced Status Display
```bash
# Override status function for custom format
function my_status() {
    echo $(zmod_color blue "=== Custom Git Status ===")
    status  # Call original function
    echo $(zmod_color green "Branch: $(git branch --show-current)")
}
```

## 🚨 Error Handling

### Repository Validation
All git functions include repository validation:

```bash
if ! zmod_is_git_repo; then
    echo $(zmod_color red "❌ Not a git repository")
    return 1
fi
```

### Safe Operations
- Confirms destructive operations
- Validates branch names
- Checks for uncommitted changes
- Handles merge conflicts gracefully

### Recovery Information
- Provides recovery commands for destructive operations
- Shows what was undone
- Offers alternative approaches

## 📊 Performance Features

### Caching
- Branch lists are cached during session
- Status information is optimized
- Reduces git command calls

### Lazy Loading
- Commands load only when used
- Minimal startup overhead
- Progressive enhancement

## 🔍 Troubleshooting

### Common Issues

#### Colors Not Working
```bash
# Check git color configuration
git config --global color.ui auto

# Or force colors
git config --global color.ui always
```

#### fzf Not Available
```bash
# Install fzf for enhanced experience
# Fallbacks are provided for all interactive features
```

#### Slow Performance
```bash
# Rebuild git cache
git gc --aggressive

# Check repository size
git count-objects -vH
```

## 📚 Dependencies

### Required
- `git` 2.0+
- `zsh` 5.0+
- Core utilities (`grep`, `sed`, `cut`)

### Optional
- `fzf` - Interactive selection (enhances `stash-list`, `branch`, etc.)
- `delta` - Enhanced diff display
- `bat` - Better file previews
- Modern terminal with color support

## 🔮 Future Enhancements

### Planned Features
- **GitHub Integration** - Pull request management
- **GitLab Integration** - Merge request workflow
- **Conventional Commits** - Automated commit formatting
- **Branch Templates** - Standardized branch creation
- **Workflow Automation** - Custom git workflows
- **Conflict Resolution** - Interactive merge conflict tools

### Advanced Features
```bash
# Planned commands
gh-pr create                    # Create GitHub PR
gl-mr create                   # Create GitLab MR
workflow run "feature"         # Run custom workflow
conflict resolve              # Interactive conflict resolution
```

## 📚 Related Documentation

- [Core Utilities](../core/utils.md) - Helper functions used by git module
- [Development Module](dev.md) - Complementary development tools
- [Scripts Documentation](../scripts/) - Build and management tools