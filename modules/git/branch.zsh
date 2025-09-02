#!/usr/bin/env zsh
# Branch - matches branch.ps1

branch() {
    local ls_flag=""
    local remote_flag=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -ls|--list)
                ls_flag="true"
                shift
                ;;
            -r|--remote)
                remote_flag="true"
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
    
    if [[ -n "$ls_flag" ]] || [[ -n "$remote_flag" ]]; then
        local branches
        if [[ -n "$remote_flag" ]]; then
            branches=$(git branch --list -r)
        else
            branches=$(git branch --list)
        fi
        
        echo "$(zmod_color cyan '\nBranches:')"
        local i=1
        echo "$branches" | while IFS= read -r line; do
            local branch_name=$(echo "$line" | sed 's/^[* ]*//')
            if [[ "$line" == *"* "* ]]; then
                echo "$(zmod_color green "$i. $branch_name")"
            else
                echo "$(zmod_color white "$i. $branch_name")"
            fi
            i=$((i + 1))
        done
        
        # Copy to clipboard if available
        if zmod_has_command xclip; then
            echo "$branches" | xclip -selection clipboard
            echo "$(zmod_color yellow '\nBranch list copied to clipboard!')"
        elif zmod_has_command pbcopy; then
            echo "$branches" | pbcopy
            echo "$(zmod_color yellow '\nBranch list copied to clipboard!')"
        fi
    else
        local current_branch=$(git rev-parse --abbrev-ref HEAD)
        echo -n "Current branch: "
        echo "$(zmod_color green "$current_branch")"
        
        # Copy to clipboard if available
        if zmod_has_command xclip; then
            echo "$current_branch" | xclip -selection clipboard
            echo "$(zmod_color yellow '\nBranch name copied to clipboard!')"
        elif zmod_has_command pbcopy; then
            echo "$current_branch" | pbcopy
            echo "$(zmod_color yellow '\nBranch name copied to clipboard!')"
        fi
    fi
}

# Alias for branch
br() {
    branch "$@"
}

# Create and switch to new branch
gnb() {
    if [[ -z "$1" ]]; then
        echo "❌ Branch name required"
        echo "Usage: gnb branch-name"
        return 1
    fi
    
    git switch -c "$1"
}

# Aliases for compatibility
alias gb='branch'