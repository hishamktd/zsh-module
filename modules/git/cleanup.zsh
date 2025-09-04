#!/usr/bin/env zsh
# Git Module Cleanup - Remove problematic Oh My Zsh aliases that cause parse errors

# This script should be sourced after Oh My Zsh initialization
# to clean up problematic aliases that contain complex syntax

# Function to clean up problematic aliases
zmod_cleanup_git_aliases() {
    # Get all aliases that start with 'g' (most Oh My Zsh git aliases)
    local git_aliases=($(alias | grep "^g" | cut -d'=' -f1))
    
    # Also include common problematic aliases
    local other_aliases=(ls)
    
    # Combine all aliases to clean up
    local all_aliases=("${git_aliases[@]}" "${other_aliases[@]}")
    
    for alias_name in "${all_aliases[@]}"; do
        # Skip if it's one of our safe aliases we want to keep
        case "$alias_name" in
            # Add any aliases you want to keep here
            grep|git) continue ;;
        esac
        
        unalias "$alias_name" 2>/dev/null || true
        unfunction "$alias_name" 2>/dev/null || true
    done
}

# Clean up immediately when this file is sourced
zmod_cleanup_git_aliases

# Set option to prevent alias to function conversion entirely
unsetopt ALIASES_TO_FUNCTIONS 2>/dev/null || true
setopt NO_GLOBAL_RCS  # Prevent loading system-wide config that might cause issues

# Also set up a hook to clean up after Oh My Zsh loads
zmod_git_cleanup_hook() {
    zmod_cleanup_git_aliases
    # Remove the hook after first run to avoid repeated execution
    add-zsh-hook -d precmd zmod_git_cleanup_hook
}

# Add the cleanup hook to precmd to run after Oh My Zsh initialization
autoload -Uz add-zsh-hook
add-zsh-hook precmd zmod_git_cleanup_hook