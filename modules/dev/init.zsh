#!/usr/bin/env zsh
# Project initialization commands

# Project initialization
init() {
    local project_type="${1:-node}"
    local project_name="${2:-$(basename $(pwd))}"
    
    case "$project_type" in
        "node"|"js"|"ts")
            if zmod_has_command bun; then
                bun init
            elif zmod_has_command pnpm; then
                pnpm init
            else
                npm init -y
            fi
            ;;
        "rust")
            cargo init --name "$project_name"
            ;;
        "python")
            if zmod_has_command poetry; then
                poetry init
            else
                echo "# $project_name" > README.md
                touch requirements.txt
                python -m venv .venv
                echo ".venv/" > .gitignore
                echo "✅ Python project initialized"
            fi
            ;;
        "go")
            go mod init "$project_name"
            echo "package main\n\nimport \"fmt\"\n\nfunc main() {\n    fmt.Println(\"Hello, World!\")\n}" > main.go
            ;;
        *)
            echo "❌ Unknown project type: $project_type"
            echo "Available types: node, rust, python, go"
            return 1
            ;;
    esac
}