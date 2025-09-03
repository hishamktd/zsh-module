# AI Module Documentation

The AI Module provides configurable AI provider management with support for multiple AI services including OpenAI, Claude, Gemini, and Ollama.

## File Structure

```
modules/ai/
├── ai.zsh              # Main module entry point
├── providers/          # AI provider implementations
│   ├── openai.zsh     # OpenAI API integration
│   ├── claude.zsh     # Anthropic Claude API integration
│   ├── gemini.zsh     # Google Gemini API integration
│   └── ollama.zsh     # Ollama local model integration
├── functions/          # Core functionality modules
│   ├── config.zsh     # Configuration management
│   ├── management.zsh # Provider management (list, select, configure)
│   ├── chat.zsh       # General AI chat functionality
│   └── commit.zsh     # Git commit message generation
└── README.md          # This documentation
```

## Supported Providers

| Provider | Description | Configuration Keys |
|----------|-------------|-------------------|
| **openai** | OpenAI GPT | `api_key`, `model`, `base_url` |
| **claude** | Anthropic Claude | `api_key`, `model` |
| **gemini** | Google Gemini | `api_key`, `model` |
| **ollama** | Local Ollama | `base_url`, `model` |

## 🚀 Quick Start

```bash
# List available providers
ai list

# Interactive provider selection
ai select

# Configure a provider (will prompt for API key and settings)
ai config openai

# Check current configuration
ai status
```

## 🤖 Supported Providers

| Provider | Description | Required Fields |
|----------|-------------|-----------------|
| `openai` | OpenAI GPT | api_key, model, base_url |
| `claude` | Anthropic Claude | api_key, model |
| `gemini` | Google Gemini | api_key, model |
| `ollama` | Ollama (Local) | base_url, model |
| `azure` | Azure OpenAI | api_key, endpoint, deployment, api_version |
| `huggingface` | Hugging Face | api_key, model |
| `cohere` | Cohere | api_key, model |
| `palm` | Google PaLM | api_key, model |

## 📋 Commands

### `ai list`
Lists all available AI providers with their configuration status.

```bash
ai list
```

**Output:**
```
🤖 Available AI Providers:
━━━━━━━━━━━━━━━━━━━━━━━━━━
  ❌ azure        Azure OpenAI
  ✅ claude       Anthropic Claude
  ❌ cohere       Cohere
  ✅ gemini       Google Gemini (current)
  ❌ huggingface  Hugging Face
  ❌ ollama       Ollama (Local)
  ✅ openai       OpenAI GPT
  ❌ palm         Google PaLM

Legend: ✅ Configured | ❌ Not configured
```

### `ai select`
Interactive provider selection menu.

```bash
ai select
```

**Example interaction:**
```
🤖 Select AI Provider:
━━━━━━━━━━━━━━━━━━━━━━
 1. ❌ azure        Azure OpenAI
 2. ✅ claude       Anthropic Claude
 3. ❌ cohere       Cohere
 4. ✅ gemini       Google Gemini
 5. ❌ huggingface  Hugging Face
 6. ❌ ollama       Ollama (Local)
 7. ✅ openai       OpenAI GPT
 8. ❌ palm         Google PaLM

Enter selection (1-8): 4
✅ Selected provider: gemini (Google Gemini)
```

### `ai config [provider]`
Configure API keys and settings for a provider. If no provider is specified, configures the current provider.

```bash
# Configure specific provider
ai config openai

# Configure current provider
ai config
```

**Example configuration session:**
```bash
ai config gemini
```

**Output:**
```
🔧 Configuring Google Gemini (gemini)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
api_key: your-gemini-api-key-here
model: gemini-2.0-flash

✅ Configuration saved to /path/to/config/ai/gemini.conf
Set as default provider? (y/N): y
✅ Set gemini as default provider
```

### `ai status`
Shows current AI module configuration and settings.

```bash
ai status
```

**Output:**
```
🤖 AI Module Status:
━━━━━━━━━━━━━━━━━━━━━━
Current Provider: gemini (Google Gemini)
Config Directory: /path/to/config/ai
Configuration: ✅ Configured

Settings:
  api_key: "your-gem...here"
  model: "gemini-2.0-flash"
```

### `ai get [provider] [key]`
Retrieve configuration values. Useful for scripts and integrations.

```bash
# Get specific configuration value
ai get gemini api_key

# Get all configuration for a provider
ai get gemini

# Get current provider's API key
ai get "" api_key
```

### `ai remove [provider]`
Remove provider configuration with confirmation prompt.

```bash
ai remove claude
```

**Output:**
```
Remove configuration for claude (Anthropic Claude)? (y/N): y
✅ Removed configuration for claude
⚠️  Reset default provider to openai
```

## 🔑 Setting API Keys

### Method 1: Interactive Configuration
The easiest way to set API keys is through the interactive configuration:

```bash
ai config openai
```

Then enter your API key when prompted:
```
api_key: sk-your-openai-api-key-here
model: gpt-4
base_url: https://api.openai.com/v1
```

### Method 2: Environment Variables
You can pre-set API keys as environment variables and the configuration will use them:

```bash
export OPENAI_API_KEY="sk-your-openai-api-key-here"
export GEMINI_API_KEY="your-gemini-api-key-here"
export CLAUDE_API_KEY="your-claude-api-key-here"

# Then configure normally - it will pick up the environment variable
ai config openai
```

### Method 3: Direct Configuration File Edit
Advanced users can directly edit configuration files:

```bash
# Edit the configuration file directly
vim $ZSH_MODULE_DIR/config/ai/openai.conf
```

**Configuration file format:**
```bash
# OpenAI GPT Configuration
# Provider: openai
# Generated: Wed Sep  3 11:49:33 IST 2025

api_key="sk-your-openai-api-key-here"
model="gpt-4"
base_url="https://api.openai.com/v1"
```

### Method 4: Programmatic Configuration
For scripts and automation:

```bash
# Create config directory
mkdir -p "$ZSH_MODULE_DIR/config/ai"

# Write configuration file
cat > "$ZSH_MODULE_DIR/config/ai/openai.conf" << EOF
api_key="sk-your-openai-api-key-here"
model="gpt-4"
base_url="https://api.openai.com/v1"
EOF

# Set as current provider
zmod config set ai_provider openai
```

## 🔒 Security Best Practices

### API Key Storage
- API keys are stored in separate configuration files per provider
- Keys are masked when displayed (e.g., "sk-abc...xyz")
- Configuration files are created with appropriate permissions
- Never commit API keys to version control

### Viewing Masked Keys
```bash
# Shows masked key: "sk-abc...xyz"
ai status

# Shows full key (use carefully)
ai get openai api_key
```

### Configuration File Locations
```
$ZSH_MODULE_DIR/config/ai/
├── config.conf          # Main AI module config
├── openai.conf          # OpenAI configuration
├── claude.conf          # Claude configuration
├── gemini.conf          # Gemini configuration
└── [provider].conf      # Other provider configs
```

## 📖 Provider-Specific Examples

### OpenAI Configuration
```bash
ai config openai
```
Required fields:
- **api_key**: Your OpenAI API key (sk-...)
- **model**: Model name (e.g., gpt-4, gpt-3.5-turbo)
- **base_url**: API endpoint (usually https://api.openai.com/v1)

### Google Gemini Configuration
```bash
ai config gemini
```
Required fields:
- **api_key**: Your Google API key
- **model**: Model name (e.g., gemini-2.0-flash, gemini-pro)

### Anthropic Claude Configuration
```bash
ai config claude
```
Required fields:
- **api_key**: Your Anthropic API key
- **model**: Model name (e.g., claude-3-sonnet, claude-3-haiku)

### Ollama (Local) Configuration
```bash
ai config ollama
```
Required fields:
- **base_url**: Ollama server URL (e.g., http://localhost:11434)
- **model**: Model name (e.g., llama2, codellama)

### Azure OpenAI Configuration
```bash
ai config azure
```
Required fields:
- **api_key**: Your Azure OpenAI API key
- **endpoint**: Your Azure OpenAI endpoint
- **deployment**: Deployment name
- **api_version**: API version (e.g., 2023-12-01-preview)

## 🔧 Integration with ZSH Module Framework

### Global Configuration
The AI module integrates with the zsh-module framework configuration:

```bash
# Set default AI provider globally
zmod config set ai_provider gemini

# View all framework configuration including AI
zmod config show
```

### Lazy Loading
The AI module supports lazy loading - commands are only loaded when first used:

```bash
# Enable lazy loading
zmod config set lazy_load true
zmod reload

# AI commands will be loaded on first use
ai list  # This will load the AI module
```

## 🛠️ Troubleshooting

### Command Not Found
If `ai` command is not available:

1. Check if the module is enabled:
   ```bash
   cat $ZSH_MODULE_DIR/config/enabled.conf
   ```
   Should contain `ai` in the list.

2. Rebuild and reload:
   ```bash
   zmod build
   zmod reload
   ```

3. Check loading mode:
   ```bash
   zmod config get lazy_load
   ```

### Configuration Issues
- Check configuration file permissions
- Verify API key format for your provider
- Ensure all required fields are filled

### Provider Not Working
1. Verify API key is valid
2. Check provider-specific requirements
3. Test with a simple API call using curl

## 📚 Examples

### Complete Setup Workflow
```bash
# 1. List available providers
ai list

# 2. Configure OpenAI
ai config openai
# Enter: sk-your-key-here, gpt-4, https://api.openai.com/v1

# 3. Configure Gemini  
ai config gemini
# Enter: your-gemini-key, gemini-2.0-flash

# 4. Select default provider
ai select
# Choose your preferred provider

# 5. Verify configuration
ai status

# 6. Test retrieval
ai get openai api_key
```

### Script Integration
```bash
#!/bin/bash
# Example script using AI module

# Get current provider's API key
API_KEY=$(ai get "" api_key)
MODEL=$(ai get "" model)

# Use in your application
curl -H "Authorization: Bearer $API_KEY" \
     -H "Content-Type: application/json" \
     -d '{"model": "'$MODEL'", "messages": [...]}' \
     https://api.openai.com/v1/chat/completions
```

## 🎯 Tips

1. **Use interactive configuration** for first-time setup
2. **Set environment variables** for automated deployments  
3. **Use `ai get`** for script integration
4. **Regularly check `ai status`** to verify your setup
5. **Use `ai select`** to quickly switch between configured providers
6. **Keep API keys secure** - never commit them to version control