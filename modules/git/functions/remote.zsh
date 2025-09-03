#!/usr/bin/env zsh
# Remote repository utilities for Git module

# Get remote repository URL
get_remote_url() {
    local remote="${1:-origin}"
    local url=$(git config --get "remote.$remote.url")
    
    if [[ -z "$url" ]]; then
        return 1
    fi
    
    # Convert SSH URL to HTTPS for web browsing
    if [[ "$url" =~ ^git@ ]]; then
        # Convert git@github.com:user/repo.git to https://github.com/user/repo
        url=$(echo "$url" | sed 's/git@\([^:]*\):/https:\/\/\1\//' | sed 's/\.git$//')
    elif [[ "$url" =~ \.git$ ]]; then
        # Remove .git suffix from HTTPS URLs
        url=$(echo "$url" | sed 's/\.git$//')
    fi
    
    echo "$url"
}

# Get current branch's remote name
get_current_remote() {
    local current_branch=$(zmod_git_branch)
    if [[ -z "$current_branch" ]]; then
        echo "origin" # fallback to origin
        return 1
    fi
    
    local remote=$(git config --get "branch.$current_branch.remote")
    echo "${remote:-origin}"
}

# Check if current branch has upstream set
has_upstream() {
    local current_branch=$(zmod_git_branch)
    [[ -n "$current_branch" ]] && git config --get "branch.$current_branch.remote" >/dev/null
}

# Extract merge/pull request URLs from git push output
extract_mr_urls() {
    local push_output="$1"
    local urls=()
    
    # Look for common MR/PR URL patterns in push output
    while IFS= read -r line; do
        # GitHub pull request URLs
        if [[ "$line" =~ https://github\.com/[^/]+/[^/]+/pull/[0-9]+ ]]; then
            urls+=("${BASH_REMATCH[0]}")
        fi
        # GitLab merge request URLs (gitlab.com and self-hosted)
        if [[ "$line" =~ https://[^/]*gitlab[^/]*/[^/]+/[^/]+/-/merge_requests/[0-9]+ ]]; then
            urls+=("${BASH_REMATCH[0]}")
        fi
        # GitLab merge request creation URLs
        if [[ "$line" =~ https://[^/]*gitlab[^/]*/[^/]+/[^/]+/-/merge_requests/new[^[:space:]]* ]]; then
            urls+=("${BASH_REMATCH[0]}")
        fi
        # GitHub compare URLs (for creating PRs)
        if [[ "$line" =~ https://github\.com/[^/]+/[^/]+/compare/[^[:space:]]+ ]]; then
            urls+=("${BASH_REMATCH[0]}")
        fi
        # Generic patterns - look for URLs that contain merge_requests, pull, or compare
        if [[ "$line" =~ https://[^[:space:]]+/(merge_requests|pull|compare)/[^[:space:]]* ]]; then
            # Extract the full URL from the line
            local full_url=$(echo "$line" | grep -oE 'https://[^[:space:]]+/(merge_requests|pull|compare)/[^[:space:]]*')
            if [[ -n "$full_url" ]]; then
                urls+=("$full_url")
            fi
        fi
        # Look for "remote:" lines that contain URLs (common in GitLab)
        if [[ "$line" =~ remote:[[:space:]]+https://[^[:space:]]+ ]]; then
            local remote_url=$(echo "$line" | grep -oE 'https://[^[:space:]]+')
            if [[ "$remote_url" =~ /(merge_requests|pull|compare)/ ]]; then
                urls+=("$remote_url")
            fi
        fi
    done <<< "$push_output"
    
    # Return unique URLs, filtering out empty ones
    printf '%s\n' "${urls[@]}" | grep -v '^[[:space:]]*$' | sort -u
}

# Generate merge request URL based on remote and branch
generate_mr_url() {
    local remote_url="$1"
    local current_branch="$2"
    local default_branch="${3:-main}"
    
    # URL encode branch names (replace special characters)
    local encoded_current=$(echo "$current_branch" | sed 's/ /%20/g; s/#/%23/g; s/&/%26/g')
    local encoded_default=$(echo "$default_branch" | sed 's/ /%20/g; s/#/%23/g; s/&/%26/g')
    
    # GitHub
    if [[ "$remote_url" =~ github\.com ]]; then
        echo "${remote_url}/compare/${encoded_default}...${encoded_current}"
    # GitLab (both gitlab.com and self-hosted instances)
    elif [[ "$remote_url" =~ gitlab ]]; then
        echo "${remote_url}/-/merge_requests/new?merge_request[source_branch]=${encoded_current}&merge_request[target_branch]=${encoded_default}"
    # Bitbucket
    elif [[ "$remote_url" =~ bitbucket\.org ]]; then
        echo "${remote_url}/pull-requests/new?source=${encoded_current}&dest=${encoded_default}"
    # Azure DevOps / VSTS
    elif [[ "$remote_url" =~ (dev\.azure\.com|visualstudio\.com) ]]; then
        echo "${remote_url}/pullrequestcreate?sourceRef=${encoded_current}&targetRef=${encoded_default}"
    else
        # Generic fallback - try GitHub-style compare
        echo "${remote_url}/compare/${encoded_default}...${encoded_current}"
    fi
}