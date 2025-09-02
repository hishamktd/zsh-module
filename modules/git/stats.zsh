#!/usr/bin/env zsh
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