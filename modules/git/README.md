# Git Module Documentation

This module provides enhanced git workflow commands that match the PowerShell script functionality.

## Core Functions

### `pull [branch]`
**Matches:** `pull.ps1`

Pulls changes from remote repository with rebase.

**Usage:**
```bash
pull              # Pulls from origin/main (default)
pull develop      # Pulls from origin/develop
pull feature-123  # Pulls from origin/feature-123
```

**Features:**
- Defaults to "main" branch if no argument provided
- Fetches from origin before pulling
- Uses `--rebase` for clean history
- Displays colored status messages
- Error handling for non-git repositories

### `swap [branch]`
**Enhanced branch switching with intelligent defaults**

**Usage:**
```bash
swap              # Switches to main branch (auto-detects main/master/develop/dev)
swap feature-123  # Switches to feature-123 branch
```

**Features:**
- **Smart main branch detection:** Tries in order: main → master → develop → dev → remote default
- **Remote branch support:** Automatically creates local branch from remote if needed
- **Branch validation:** Checks if branch exists before switching
- **Helpful error messages:** Shows available branches when branch not found

### `status`
Enhanced git status with detailed information.

### `commit [message]`
Stages all changes and commits with message.

### `push`
Smart push with upstream tracking.

### `branch [-ls|-r]`
List branches with numbering and clipboard support.

### `working [command]`
Manage working branches per project.

## Branch Detection Priority

When no branch is specified, functions use this priority:

1. **main** - Modern default
2. **master** - Traditional default  
3. **develop** - GitFlow main development
4. **dev** - Short development branch
5. **Remote default** - What origin/HEAD points to

## PowerShell Compatibility

All functions are designed to match their PowerShell script counterparts:

- Same parameter handling
- Same colored output
- Same error messages  
- Same default behaviors

## Aliases

### Git Commands
- `gs` → `status`
- `gc` → `commit`  
- `gp` → `push`
- `gpr` → `git_pull_rebase`
- `gb` → `branch`
- `gco` → `git checkout`

### Additional
- `ga` → `git add`
- `gd` → `git diff`
- `gdc` → `git diff --cached`

## Examples

```bash
# Quick workflow
swap              # Go to main branch
pull              # Pull latest changes  
swap feature-123  # Switch to feature branch
# ... make changes ...
commit "Add new feature"
push              # Push changes

# Branch management
branch -ls        # List all branches
working add       # Add current branch to working set
working           # Show working branches
swap              # Return to main
```

## File Structure

Each function is in its own file following PowerShell script patterns:

- `status.zsh` - Git status display
- `commit.zsh` - Commit functionality
- `branch.zsh` - Branch management  
- `push.zsh` - Push operations
- `pull.zsh` - Pull operations
- `swap.zsh` - Branch switching
- `working.zsh` - Working branch management
- `stash.zsh` - Stash operations
- `undo.zsh` - Undo operations
- `clean.zsh` - Cleanup operations
- `aliases.zsh` - Git aliases