#!/usr/bin/env zsh
# Git status - matches status.ps1

status() {
    if ! zmod_is_git_repo; then
        echo "❌ Not a git repository"
        return 1
    fi
    
    echo "$(zmod_color blue '==== Git Status ======')"
    
    local git_status=$(git status -s)
    if [[ -n "$git_status" ]]; then
        echo "$git_status"
    else
        echo "$(zmod_color green 'Clean working directory (no changes).')"
    fi
    
    echo "\n$(zmod_color blue '==== Unstaged Changes ======')"
    if git diff --stat >/dev/null 2>&1; then
        git diff --color=always
    else
        echo "$(zmod_color green 'No unstaged changes found.')"
    fi
    
    echo "\n$(zmod_color blue '==== Staged Changes ======')"
    if git diff --cached --stat >/dev/null 2>&1; then
        git diff --cached --color=always
    else
        echo "$(zmod_color green 'No staged changes found.')"
    fi
    
    echo "\n$(zmod_color blue '==== Branch and Remote Status ======')"
    git branch -v | while read line; do
        if [[ "$line" == *"* "* ]]; then
            echo "$line" | sed "s/^\* /$(zmod_color yellow '* ')/"
        elif [[ "$line" =~ origin/ ]]; then
            echo "$line" | sed "s/origin\//$(zmod_color purple 'origin\/')/"
        else
            echo "$(zmod_color cyan "$line")"
        fi
    done
    
    # Ahead/Behind count
    local default_branch=$(zmod_get_default_branch)
    local ahead_behind=$(git rev-list --left-right --count $default_branch...HEAD 2>/dev/null)
    if [[ -n "$ahead_behind" ]]; then
        local behind=$(echo $ahead_behind | cut -f1)
        local ahead=$(echo $ahead_behind | cut -f2)
        echo "$(zmod_color blue "Current branch is ahead by $ahead commits and behind by $behind commits relative to '$default_branch'.")"
    else
        echo "$(zmod_color blue "Could not determine ahead/behind status. Ensure '$default_branch' exists in your repository.")"
    fi
}

# Alias for compatibility
alias gs='status'