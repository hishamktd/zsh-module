#!/usr/bin/env zsh
# Default branch configuration per repository

# Get the default branch for the current repository
zmod_get_default_branch() {
    if ! zmod_is_git_repo; then
        echo "main"
        return 1
    fi
    
    # Get the project name from the Git repository's root directory
    local project_name=$(basename "$(git rev-parse --show-toplevel)")
    local config_directory="$HOME/.zsh-modules/git-config"
    local config_file="$config_directory/$project_name.conf"
    
    # Check if there's a per-repository configuration
    if [[ -f "$config_file" ]]; then
        local repo_default_branch=$(grep "^default_branch=" "$config_file" 2>/dev/null | cut -d= -f2)
        if [[ -n "$repo_default_branch" ]]; then
            echo "$repo_default_branch"
            return 0
        fi
    fi
    
    # Fall back to global default
    echo "${ZSH_MODULE_DEFAULT_BRANCH:-main}"
}

# Set the default branch for the current repository
zmod_set_default_branch() {
    local branch_name="$1"
    
    if ! zmod_is_git_repo; then
        echo "❌ Not inside a git repository."
        return 1
    fi
    
    if [[ -z "$branch_name" ]]; then
        echo "❌ Branch name is required."
        echo "Usage: zmod_set_default_branch <branch-name>"
        return 1
    fi
    
    # Get the project name from the Git repository's root directory
    local project_name=$(basename "$(git rev-parse --show-toplevel)")
    local config_directory="$HOME/.zsh-modules/git-config"
    local config_file="$config_directory/$project_name.conf"
    
    # Ensure the config directory exists
    if [[ ! -d "$config_directory" ]]; then
        mkdir -p "$config_directory"
    fi
    
    # Update or create the configuration file
    if [[ -f "$config_file" ]]; then
        # Update existing file
        if grep -q "^default_branch=" "$config_file"; then
            # Replace existing default_branch line
            sed -i "s/^default_branch=.*/default_branch=$branch_name/" "$config_file"
        else
            # Add default_branch line
            echo "default_branch=$branch_name" >> "$config_file"
        fi
    else
        # Create new file
        cat > "$config_file" << EOF
# Git configuration for $project_name
# Generated on $(date)
default_branch=$branch_name
EOF
    fi
    
    echo "✅ Default branch for '$project_name' set to '$branch_name'"
}

# Show default branch configuration
zmod_show_default_branch() {
    if ! zmod_is_git_repo; then
        echo "❌ Not inside a git repository."
        return 1
    fi
    
    local project_name=$(basename "$(git rev-parse --show-toplevel)")
    local config_directory="$HOME/.zsh-modules/git-config"
    local config_file="$config_directory/$project_name.conf"
    local current_default=$(zmod_get_default_branch)
    
    echo "$(zmod_color cyan "Default branch configuration for $project_name:")"
    echo "  Current: $(zmod_color yellow "$current_default")"
    
    if [[ -f "$config_file" ]]; then
        echo "  Source: $(zmod_color green "Repository-specific configuration")"
        echo "  Config file: $config_file"
    else
        echo "  Source: $(zmod_color blue "Global configuration (ZSH_MODULE_DEFAULT_BRANCH)")"
        echo "  Global default: ${ZSH_MODULE_DEFAULT_BRANCH:-main}"
    fi
}

# Clear repository-specific default branch configuration
zmod_clear_default_branch() {
    if ! zmod_is_git_repo; then
        echo "❌ Not inside a git repository."
        return 1
    fi
    
    local project_name=$(basename "$(git rev-parse --show-toplevel)")
    local config_directory="$HOME/.zsh-modules/git-config"
    local config_file="$config_directory/$project_name.conf"
    
    if [[ -f "$config_file" ]]; then
        if grep -q "^default_branch=" "$config_file"; then
            # Remove the default_branch line
            sed -i "/^default_branch=/d" "$config_file"
            
            # If file is empty (except comments), remove it
            if [[ -z "$(grep -v '^#' "$config_file" | grep -v '^$')" ]]; then
                rm "$config_file"
                echo "✅ Cleared default branch configuration for '$project_name' (removed config file)"
            else
                echo "✅ Cleared default branch configuration for '$project_name'"
            fi
        else
            echo "$(zmod_color yellow "No repository-specific default branch configured for '$project_name'")"
        fi
    else
        echo "$(zmod_color yellow "No repository-specific configuration found for '$project_name'")"
    fi
}

# List all repository configurations
zmod_list_default_branches() {
    local config_directory="$HOME/.zsh-modules/git-config"
    
    if [[ ! -d "$config_directory" ]]; then
        echo "$(zmod_color yellow 'No repository-specific configurations found.')"
        return 0
    fi
    
    local config_files=("$config_directory"/*.conf)
    if [[ ! -f "${config_files[0]}" ]]; then
        echo "$(zmod_color yellow 'No repository-specific configurations found.')"
        return 0
    fi
    
    echo "$(zmod_color cyan 'Repository-specific default branch configurations:')"
    for file in "${config_files[@]}"; do
        if [[ -f "$file" ]]; then
            local project=$(basename "$file" .conf)
            local default_branch=$(grep "^default_branch=" "$file" 2>/dev/null | cut -d= -f2)
            if [[ -n "$default_branch" ]]; then
                echo "  $(zmod_color yellow "$project"): $(zmod_color green "$default_branch")"
            fi
        fi
    done
}

# Main function for default branch management
default_branch() {
    case "$1" in
        ""|"show")
            zmod_show_default_branch
            ;;
        "set")
            zmod_set_default_branch "$2"
            ;;
        "clear")
            zmod_clear_default_branch
            ;;
        "list")
            zmod_list_default_branches
            ;;
        "help")
            echo "$(zmod_color white 'Usage: default_branch [command] [args]')"
            echo "$(zmod_color white 'Commands:')"
            echo "  show       - Show current default branch configuration (default)"
            echo "  set <name> - Set default branch for current repository"
            echo "  clear      - Clear repository-specific configuration"
            echo "  list       - List all repository configurations"
            echo "  help       - Show this help message"
            ;;
        *)
            zmod_show_default_branch
            ;;
    esac
}