# AI Module - Quick Reference

## 🚀 Essential Commands

```bash
ai list                    # List all providers
ai select                  # Interactive provider selection  
ai config [provider]       # Configure provider (prompts for API key)
ai status                  # Show current configuration
ai get [provider] [key]    # Get configuration value
ai remove [provider]       # Remove provider configuration
```

## 🔑 Setting API Keys - 4 Methods

### 1. Interactive (Recommended)
```bash
ai config openai
# Prompts: api_key, model, base_url
```

### 2. Environment Variables
```bash
export OPENAI_API_KEY="sk-your-key-here"
export GEMINI_API_KEY="your-gemini-key"
ai config openai  # Will use env var
```

### 3. Direct File Edit
```bash
vim $ZSH_MODULE_DIR/config/ai/openai.conf
```

### 4. Programmatic
```bash
cat > "$ZSH_MODULE_DIR/config/ai/openai.conf" << EOF
api_key="sk-your-key"
model="gpt-4"
base_url="https://api.openai.com/v1"
EOF
```

## 🤖 Provider Quick Setup

| Provider | Command | Key Fields |
|----------|---------|------------|
| **OpenAI** | `ai config openai` | api_key, model, base_url |
| **Gemini** | `ai config gemini` | api_key, model |
| **Claude** | `ai config claude` | api_key, model |
| **Ollama** | `ai config ollama` | base_url, model |

## 📖 Common Examples

```bash
# Setup workflow
ai list                           # See available providers
ai config gemini                  # Configure Gemini
# Enter: your-gemini-key, gemini-2.0-flash
ai select                         # Choose default provider
ai status                         # Verify setup

# Get API key for scripts
API_KEY=$(ai get gemini api_key)

# Switch providers quickly
ai select                         # Interactive menu

# Remove old configuration
ai remove claude
```

## 🔒 Security Notes
- Keys are masked in display: "sk-abc...xyz"
- Files stored in `$ZSH_MODULE_DIR/config/ai/`
- Use `ai get provider api_key` to retrieve full keys
- Never commit config files to git

## 🛠️ Troubleshooting
```bash
# If command not found
zmod build && zmod reload

# Check if module enabled
cat $ZSH_MODULE_DIR/config/enabled.conf | grep ai

# Check configuration
ai status
```