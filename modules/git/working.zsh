#!/usr/bin/env zsh
# Working - matches working.ps1

working() {
    # Set the working directory (adapt path for Linux/Mac)
    local working_directory="$HOME/.zsh-modules/git-working"
    
    # Ensure the working directory exists
    if [[ ! -d "$working_directory" ]]; then
        mkdir -p "$working_directory"
    fi
    
    # Get the project name from the Git repository's root directory
    local project_name
    if zmod_is_git_repo; then
        project_name=$(basename "$(git rev-parse --show-toplevel)")
    else
        echo "$(zmod_color red 'Not inside a git repository.')"
        return 1
    fi
    
    # Define the path for the project-specific file
    local file_path="$working_directory/$project_name.txt"
    
    # Get the current branch name
    local branch=$(git rev-parse --abbrev-ref HEAD 2>&1)
    if [[ "$branch" =~ fatal ]]; then
        echo "$(zmod_color red 'Not inside a git repository.')"
        return 1
    fi
    
    # Function to display saved branches
    show_branches() {
        if [[ -f "$file_path" ]]; then
            echo "$(zmod_color cyan "Working branches listed in $project_name:")"
            local branches_content=$(cat "$file_path")
            if [[ -z "$branches_content" ]]; then
                echo "$(zmod_color yellow 'No branches saved.')"
            else
                local i=1
                while IFS= read -r branch_line; do
                    echo "$(zmod_color yellow "$i. $branch_line")"
                    i=$((i + 1))
                done < "$file_path"
            fi
        else
            echo "$(zmod_color yellow 'No branches saved.')"
        fi
    }
    
    # Function to add the current branch
    add_branch() {
        if [[ ! -f "$file_path" ]]; then
            touch "$file_path"
        fi
        
        if ! grep -q "^$branch$" "$file_path"; then
            echo "$branch" >> "$file_path"
            echo "$(zmod_color green "Working branch '$branch' added to $project_name.")"
        else
            echo "$(zmod_color yellow "Branch '$branch' is already in $project_name.")"
        fi
    }
    
    # Function to remove the current branch
    remove_branch() {
        if [[ -f "$file_path" ]]; then
            if grep -q "^$branch$" "$file_path"; then
                grep -v "^$branch$" "$file_path" > "$file_path.tmp" && mv "$file_path.tmp" "$file_path"
                echo "$(zmod_color purple "Working branch '$branch' removed from $project_name.")"
                
                if [[ ! -s "$file_path" ]]; then
                    rm "$file_path"
                    echo "$(zmod_color red "File $project_name.txt is empty and has been deleted.")"
                fi
            else
                echo "$(zmod_color red "Branch '$branch' is not a working branch in $project_name.")"
            fi
        else
            echo "$(zmod_color red "No file found for this project: $project_name.")"
        fi
    }
    
    # Function to view branches
    view_branches() {
        if [[ -f "$file_path" ]]; then
            if zmod_has_command code; then
                code "$file_path"
            elif zmod_has_command nano; then
                nano "$file_path"
            elif zmod_has_command vim; then
                vim "$file_path"
            else
                cat "$file_path"
            fi
        else
            echo "$(zmod_color red "No file found for this project: $project_name.")"
        fi
    }
    
    # Function to clear all branches for the current project
    clear_branches() {
        if [[ -f "$file_path" ]]; then
            rm "$file_path"
            echo "$(zmod_color red "All branches cleared for $project_name.")"
        else
            echo "$(zmod_color yellow "No branches to clear for $project_name.")"
        fi
    }
    
    # Function to list all projects with saved branches
    list_projects() {
        local project_files=("$working_directory"/*.txt)
        if [[ ! -f "${project_files[0]}" ]]; then
            echo "$(zmod_color yellow 'No projects with saved branches.')"
        else
            echo "$(zmod_color cyan 'Projects with saved branches:')"
            for file in "${project_files[@]}"; do
                if [[ -f "$file" ]]; then
                    echo "$(zmod_color yellow "- $(basename "$file" .txt)")"
                fi
            done
        fi
    }
    
    # Function to switch to a saved branch by branch number
    switch_branch() {
        local index="$1"
        
        if [[ ! -f "$file_path" ]]; then
            echo "$(zmod_color yellow 'No branches saved for this project.')"
            return
        fi
        
        if [[ ! "$index" =~ ^[0-9]+$ ]]; then
            echo "$(zmod_color red 'Please provide a valid branch number.')"
            return
        fi
        
        local branch_index=$((index - 1))
        local branch_list=($(cat "$file_path"))
        
        if [[ $branch_index -lt 0 ]] || [[ $branch_index -ge ${#branch_list[@]} ]]; then
            echo "$(zmod_color red 'Invalid branch number.')"
            return
        fi
        
        local target_branch="${branch_list[$branch_index]}"
        echo "$(zmod_color green "Switching to branch '$target_branch'...")"
        git checkout "$target_branch"
    }
    
    # Function to display usage instructions
    show_help() {
        echo "$(zmod_color white 'Usage: working [command]')"
        echo "$(zmod_color white 'Commands:')"
        echo "  add        - Add the current branch to the working branches list."
        echo "  remove     - Remove the current branch from the working branches list."
        echo "  clear      - Clear all saved branches for the current project."
        echo "  list       - List all projects with saved branches."
        echo "  switch [n] - Switch to a branch by its list number (from 'working' list)."
        echo "  view       - View the project file"
        echo "  help       - Show this help message."
    }
    
    # Check command options
    case "$1" in
        ""|"show")
            show_branches
            ;;
        "add")
            add_branch
            ;;
        "remove")
            remove_branch
            ;;
        "clear")
            clear_branches
            ;;
        "list")
            list_projects
            ;;
        "switch")
            switch_branch "$2"
            ;;
        "view")
            view_branches
            ;;
        "help")
            show_help
            ;;
        *)
            show_branches
            ;;
    esac
}