---
platform: both
scope: agent:wendy
---

# mgrep - Semantic Search CLI

语义搜索工具，支持自然语言查询代码、文档、PDF、图片等文件。

## Installation

```bash
npm install -g @mixedbread/mgrep
```

## Authentication

### Option 1: Browser Login
```bash
mgrep login
# Follow browser prompts
```

### Option 2: API Key (CI/CD)
```bash
export MXBAI_API_KEY=your_api_key_here
```

## Basic Usage

### Index Project
```bash
# Navigate to project directory
cd ~/work/agents-co/knowledge-graph

# Start indexing and watching
mgrep watch
```

### Search Commands
```bash
# Basic semantic search
mgrep "where do we set up authentication?"

# Search specific directory
mgrep "trading algorithms" ~/work/agents-co/knowledge-graph/research/

# Limit results
mgrep -m 10 "AI agent orchestration"

# Show content in results
mgrep -c "machine learning models"

# Get AI-generated answer
mgrep -a "how does the system handle errors?"

# Web search integration
mgrep --web --answer "React best practices 2024"

# Agentic mode (complex queries)
mgrep --agentic "What are the performance metrics for last quarter?"
```

### Advanced Options
```bash
# Sync files before search
mgrep -s "search query"

# Disable reranking
mgrep --no-rerank "search query"

# Custom file limits
mgrep --max-file-size 5242880 --max-file-count 2000 watch
```

## Configuration

### Config File (.mgreprc.yaml)
```yaml
# Local: .mgreprc.yaml in project root
# Global: ~/.config/mgrep/config.yaml

maxFileSize: 5242880    # 5MB
maxFileCount: 5000      # Max files to sync
```

### Environment Variables
```bash
# Search options
export MGREP_MAX_COUNT=25
export MGREP_CONTENT=1
export MGREP_ANSWER=1
export MGREP_WEB=1
export MGREP_RERANK=0

# Sync options  
export MGREP_MAX_FILE_SIZE=1048576
export MGREP_MAX_FILE_COUNT=1000
```

## Integration Examples

### Knowledge Base Search
```bash
# Semantic search across research
mgrep "AI agent coordination patterns" ~/work/agents-co/knowledge-graph/research/

# Multi-language concept search
mgrep "量化交易策略" ~/work/agents-co/knowledge-graph/

# Technical concept discovery
mgrep "authentication flow implementation" ~/clawd/
```

### Code Search
```bash
# Find implementation patterns
mgrep "error handling middleware" ~/clawd/src/

# Discover features
mgrep "user permission management" ./
```

## Ignore Files

### .mgrepignore
```gitignore
# Same syntax as .gitignore
node_modules/
*.log
dist/
.env
```

## Troubleshooting

### Login Issues
```bash
# Clear cached tokens
mgrep logout
mgrep login
```

### Fresh Index
```bash
# Delete store from dashboard, then:
mgrep watch
```

### Performance
```bash
# Use different store for experiments
mgrep --store experiment-store watch
```

## Notes

⚠️ **External Dependency**: Requires Mixedbread API account
💰 **Cost**: API usage may incur charges  
🌐 **Network**: Requires internet connection
👥 **Team**: Cloud-backed stores enable collaboration

## See Also

- [Mixedbread Platform](https://www.platform.mixedbread.com/)
- [GitHub Repository](https://github.com/mixedbread-ai/mgrep)
- Alternative: `ripgrep` for exact matches
- Alternative: Obsidian search for knowledge base