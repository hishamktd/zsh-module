#!/usr/bin/env zsh
# Git push commands

# Load utility functions
if [[ -n "$ZSH_MODULE_DIR" ]]; then
    # Use ZSH_MODULE_DIR when available (in modular loading)
    source "$ZSH_MODULE_DIR/modules/git/functions/clipboard.zsh"
    source "$ZSH_MODULE_DIR/modules/git/functions/remote.zsh"
else
    # Fallback to relative path (for direct sourcing)
    local GIT_MODULE_DIR="${0:A:h}"
    source "$GIT_MODULE_DIR/functions/clipboard.zsh"
    source "$GIT_MODULE_DIR/functions/remote.zsh"
fi

# Helper function to handle URL copying after push
handle_post_push_urls() {
    local push_output="$1"
    local current_branch="$2"
    
    local remote_url=$(get_remote_url)
    if [[ -n "$remote_url" ]]; then
        # Check for MR/PR URLs in push output
        local mr_urls=($(extract_mr_urls "$push_output"))
        
        if [[ ${#mr_urls[@]} -gt 0 ]]; then
            # Copy the first MR/PR URL found
            copy_with_feedback "${mr_urls[1]}" "Pull Request URL"
        elif [[ "$current_branch" != "main" ]] && [[ "$current_branch" != "master" ]]; then
            # Generate MR URL for feature branches
            local default_branch=$(zmod_get_default_branch)
            local mr_url=$(generate_mr_url "$remote_url" "$current_branch" "$default_branch")
            copy_with_feedback "$mr_url" "Create Pull Request URL"
        else
            # Copy remote URL for main/master branches
            copy_with_feedback "$remote_url" "Remote URL"
        fi
    fi
}

# Git push with upstream
git_push_upstream() {
    local current_branch=$(zmod_git_branch)
    if [[ -z "$current_branch" ]]; then
        echo "❌ Not on any branch"
        return 1
    fi
    
    local push_success=false
    local push_output=""
    local temp_file=$(mktemp)
    
    # Check if upstream is set
    if ! has_upstream; then
        echo "🚀 Setting upstream and pushing..."
        if git push --set-upstream origin "$current_branch" 2>&1 | tee "$temp_file"; then
            push_success=true
            push_output=$(cat "$temp_file")
        fi
    else
        if git push "$@" 2>&1 | tee "$temp_file"; then
            push_success=true
            push_output=$(cat "$temp_file")
        fi
    fi
    
    rm -f "$temp_file"
    
    # If push was successful, handle URL copying
    if [[ "$push_success" == true ]]; then
        handle_post_push_urls "$push_output" "$current_branch"
    fi
}

# Force push with safety checks
git_push_force() {
    local current_branch=$(zmod_git_branch)
    if [[ -z "$current_branch" ]]; then
        echo "❌ Not on any branch"
        return 1
    fi
    
    # Safety check for protected branches
    if [[ "$current_branch" =~ ^(main|master|develop|dev)$ ]]; then
        echo "⚠️  Force pushing to '$current_branch' branch!"
        echo -n "Are you sure? (y/N): "
        read confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo "❌ Force push cancelled"
            return 1
        fi
    fi
    
    echo "💪 Force pushing..."
    local temp_file=$(mktemp)
    if git push --force-with-lease "$@" 2>&1 | tee "$temp_file"; then
        local push_output=$(cat "$temp_file")
        rm -f "$temp_file"
        
        handle_post_push_urls "$push_output" "$current_branch"
    else
        rm -f "$temp_file"
    fi
}

# Main push commands
push() {
    git_push_upstream "$@"
}

push_force() {
    git_push_force "$@"
}

# Push all branches
push_all() {
    echo "🚀 Pushing all branches..."
    local temp_file=$(mktemp)
    if git push --all 2>&1 | tee "$temp_file"; then
        local push_output=$(cat "$temp_file")
        rm -f "$temp_file"
        local current_branch=$(zmod_git_branch)
        handle_post_push_urls "$push_output" "$current_branch"
    else
        rm -f "$temp_file"
    fi
}

# Push tags
push_tags() {
    echo "🏷️  Pushing tags..."
    local temp_file=$(mktemp)
    if git push --tags 2>&1 | tee "$temp_file"; then
        local push_output=$(cat "$temp_file")
        rm -f "$temp_file"
        # For tags, just copy the remote URL
        local remote_url=$(get_remote_url)
        if [[ -n "$remote_url" ]]; then
            copy_with_feedback "$remote_url" "Remote URL"
        fi
    else
        rm -f "$temp_file"
    fi
}

# Push current branch and tags
push_with_tags() {
    echo "🚀 Pushing branch and tags..."
    local current_branch=$(zmod_git_branch)
    local temp_file1=$(mktemp)
    local temp_file2=$(mktemp)
    
    # Push branch first
    local branch_success=false
    if git_push_upstream 2>&1 | tee "$temp_file1"; then
        branch_success=true
    fi
    
    # Push tags
    local tags_success=false  
    if git push --tags 2>&1 | tee "$temp_file2"; then
        tags_success=true
    fi
    
    if [[ "$branch_success" == true ]]; then
        local push_output=$(cat "$temp_file1")
        handle_post_push_urls "$push_output" "$current_branch"
    fi
    
    rm -f "$temp_file1" "$temp_file2"
}

# Aliases
alias gpu='git_push_upstream'
alias gp='git_push_upstream'
alias gpf='push_force'
alias gpa='push_all'
alias gpt='push_tags'
alias gpwt='push_with_tags'