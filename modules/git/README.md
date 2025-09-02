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
- Defaults to configured default branch (`ZSH_MODULE_DEFAULT_BRANCH`) if no argument provided
- Fetches from origin before pulling
- Uses `--rebase` for clean history
- Displays colored status messages
- Error handling for non-git repositories

### `swap [branch]`
**Enhanced branch switching with intelligent defaults**

**Usage:**
```bash
swap              # Switches to default branch (configurable via ZSH_MODULE_DEFAULT_BRANCH)
swap feature-123  # Switches to feature-123 branch
```

**Features:**
- **Smart default branch detection:** Tries configured default first, then fallbacks: master → develop → dev → remote default
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

1. **Configured default** - Value of `ZSH_MODULE_DEFAULT_BRANCH` (default: "main")
2. **master** - Traditional default  
3. **develop** - GitFlow main development
4. **dev** - Short development branch
5. **Remote default** - What origin/HEAD points to

## Configuration

Set your preferred default branch:
```bash
zmod config set default_branch develop  # Use 'develop' as default
zmod config set default_branch main     # Use 'main' as default (default)
zmod config show                         # View current configuration
```

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

## Stash Commands

### `stash [message]`
Stash changes with optional message.
```bash
stash                    # Stash with auto-generated message
stash "work in progress" # Stash with custom message
```

### `apply [stash-id]`
Apply a stash without removing it from stash list.
```bash
apply       # Apply most recent stash (stash@{0})
apply 0     # Apply stash@{0} 
apply 2     # Apply stash@{2}
```

### `stash-list`
Interactive stash management with fzf (if available).
- Preview stash contents
- Apply, pop, drop, or show stashes
- ESC to cancel selection
- [c]ancel option in action menu

## Branch Commands

### `branch [-ls|-r]`
Enhanced branch listing and management.

### `clean`
Clean merged branches (uses configured default branch for merge detection).

## Status Commands

### `status`
Enhanced git status showing:
- Working directory changes
- Staged changes
- Branch information
- Ahead/behind count relative to configured default branch

## Additional Functions

### `differ [branch]` 
Show diff against specified branch (defaults to configured default branch).

### `pull [branch]`
Pull from specified branch (defaults to configured default branch).

### `swap`
Switch to default branch or specified branch with smart detection.