#!/usr/bin/env zsh
# Clean merged branches

git_clean_branches() {
    if ! zmod_is_git_repo; then
        echo "❌ Not a git repository"
        return 1
    fi
    
    # Get the configured default branch for this repository
    local main_branch=$(zmod_get_default_branch)
    
    # Fallback to common default branches if configured one doesn't exist
    if ! git show-ref --verify --quiet "refs/heads/$main_branch"; then
        if git show-ref --verify --quiet "refs/heads/main"; then
            main_branch="main"
        elif git show-ref --verify --quiet "refs/heads/master"; then
            main_branch="master"
        else
            echo "❌ Default branch '$main_branch' not found. Available branches:"
            git branch --format="  %(refname:short)" | head -5
            echo "Tip: Set default branch with 'default_branch set <branch-name>'"
            return 1
        fi
    fi
    
    local merged_branches=$(git branch --merged "$main_branch" | grep -v "^\*\|$main_branch" | xargs)
    
    if [[ -z "$merged_branches" ]]; then
        echo "✅ No merged branches to clean"
        return 0
    fi
    
    echo "Merged branches to delete:"
    echo "$merged_branches"
    
    if zmod_confirm "Delete these merged branches?"; then
        echo "$merged_branches" | xargs -r git branch -d
        echo "✅ Merged branches cleaned"
    fi
}

alias gclean='git_clean_branches'