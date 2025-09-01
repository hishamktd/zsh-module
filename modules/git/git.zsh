#!/usr/bin/env zsh
# Git Module - Enhanced Git Workflow Commands (matching PowerShell script functions)

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
    local ahead_behind=$(git rev-list --left-right --count main...HEAD 2>/dev/null)
    if [[ -n "$ahead_behind" ]]; then
        local behind=$(echo $ahead_behind | cut -f1)
        local ahead=$(echo $ahead_behind | cut -f2)
        echo "$(zmod_color blue "Current branch is ahead by $ahead commits and behind by $behind commits relative to 'main'.")"
    else
        echo "$(zmod_color blue "Could not determine ahead/behind status. Ensure 'main' exists in your repository.")"
    fi
}

# Commit - matches commit.ps1
commit() {
    local message="$1"
    local flags="$2"
    
    # If no message is provided, prompt the user to enter one
    if [[ -z "$message" ]]; then
        echo -n "Please enter a commit message: "
        read message
    fi
    
    # Stage all changes
    git add .
    
    # Ensure git add was successful
    if [[ $? -eq 0 ]]; then
        echo "$(zmod_color green 'Files staged successfully')"
        
        # Check if there are any changes to commit
        local status=$(git status --porcelain)
        if [[ -n "$status" ]]; then
            # Commit with the message and optional flags
            git commit -m "$message" $flags
            
            # Display commit success message
            if [[ $? -eq 0 ]]; then
                echo "$(zmod_color green 'Commit successful!')"
            fi
        else
            echo "$(zmod_color yellow 'No changes to commit. Working tree is clean.')"
        fi
    else
        echo "$(zmod_color red 'Failed to stage files for commit')"
    fi
}

# Enhanced git log
git_log() {
    local count="${1:-10}"
    git log --oneline --graph --decorate --color=always -n "$count"
}

# Alias for git_log
alias glog='git_log'

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

# Git push with upstream
git_push_upstream() {
    local current_branch=$(zmod_git_branch)
    if [[ -z "$current_branch" ]]; then
        echo "❌ Not on any branch"
        return 1
    fi
    
    # Check if upstream is set
    if ! git config --get "branch.$current_branch.remote" >/dev/null; then
        echo "🚀 Setting upstream and pushing..."
        git push --set-upstream origin "$current_branch"
    else
        git push
    fi
}

# Git pull with rebase
git_pull_rebase() {
    git pull --rebase
}

# Aliases
alias gpu='git_push_upstream'
alias gpr='git_pull_rebase'

# Undo last commit (keep changes)
gundo() {
    if zmod_confirm "Undo last commit but keep changes?"; then
        git reset --soft HEAD~1
        echo "✅ Last commit undone, changes kept"
    fi
}

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

# Git stash with message
gstash() {
    local message="${1:-WIP: $(date)}"
    git stash push -m "$message"
}

# Interactive stash manager
gstash-list() {
    if ! zmod_is_git_repo; then
        echo "❌ Not a git repository"
        return 1
    fi
    
    local stashes=$(git stash list)
    if [[ -z "$stashes" ]]; then
        echo "📦 No stashes found"
        return 0
    fi
    
    if zmod_has_command fzf; then
        local selected=$(echo "$stashes" | fzf --prompt="Select stash: " --preview="git stash show -p {1}")
        if [[ -n "$selected" ]]; then
            local stash_id=$(echo "$selected" | cut -d: -f1)
            echo "Selected: $selected"
            echo -n "Action [a]pply [p]op [d]rop [s]how: "
            read action
            case "$action" in
                a) git stash apply "$stash_id" ;;
                p) git stash pop "$stash_id" ;;
                d) git stash drop "$stash_id" ;;
                s) git stash show -p "$stash_id" ;;
                *) echo "❌ Invalid action" ;;
            esac
        fi
    else
        echo "$stashes"
    fi
}

# Find files in git history
gfind() {
    if [[ -z "$1" ]]; then
        echo "❌ Filename pattern required"
        echo "Usage: gfind 'pattern'"
        return 1
    fi
    
    git log --all --full-history -- "*$1*"
}

# Git blame with better formatting
gblame() {
    if [[ -z "$1" ]]; then
        echo "❌ File path required"
        echo "Usage: gblame file.txt"
        return 1
    fi
    
    git blame --color-lines --color-by-age "$1"
}

# Show git repository statistics
gstats() {
    if ! zmod_is_git_repo; then
        echo "❌ Not a git repository"
        return 1
    fi
    
    echo "📊 Repository Statistics:"
    echo "  Total commits: $(git rev-list --count HEAD)"
    echo "  Contributors: $(git shortlog -sn | wc -l)"
    echo "  Branches: $(git branch -a | wc -l)"
    echo "  Tags: $(git tag | wc -l)"
    echo "  Repository size: $(du -sh .git | cut -f1)"
    
    echo ""
    echo "🏆 Top contributors:"
    git shortlog -sn | head -5
}

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

# Aliases for compatibility
alias gs='status'
alias ga='git add'
alias gc='commit'
alias gco='git checkout'
alias gl='git_log'
alias gp='git_push_upstream'
alias gpull='git_pull_rebase'
alias gb='branch'
alias gd='git diff'
alias gdc='git diff --cached'