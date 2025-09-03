#!/usr/bin/env zsh
# Additional git aliases for compatibility

alias ga='git add'
alias gd='git diff'
alias gdc='git diff --cached'
alias gblame='blame'

# Git differ function (matches PowerShell script)
function differ() {
    if ! zmod_is_git_repo; then
        echo "❌ Not a git repository"
        return 1
    fi
    
    local branch="${1:-$(zmod_get_default_branch)}"
    local changed_files=$(git diff --name-only "$branch")
    
    if [[ -z "$changed_files" ]]; then
        echo "📄 No differences found between current branch and $branch"
        return 0
    fi
    
    if zmod_has_command fzf; then
        local selected=$(echo "$changed_files" | fzf \
            --prompt="Select file to view diff (ESC to cancel): " \
            --preview="git diff --color=always '$branch' -- {}" \
            --preview-window="right:60%:wrap" \
            --bind="ctrl-c:abort,esc:abort" \
            --ansi)
        
        if [[ -n "$selected" ]]; then
            git diff --color=always "$branch" -- "$selected"
        else
            echo "No file selected. Cancelled."
            return 0
        fi
    else
        git diff "$branch"
    fi
}