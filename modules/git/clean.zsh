#!/usr/bin/env zsh
# Clean merged branches

git_clean_branches() {
    if ! zmod_is_git_repo; then
        echo "❌ Not a git repository"
        return 1
    fi
    
    local main_branch="main"
    if ! git show-ref --verify --quiet "refs/heads/$main_branch"; then
        main_branch="master"
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