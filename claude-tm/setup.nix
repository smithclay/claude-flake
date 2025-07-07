{ pkgs }:

''
  echo "⚙️   Checking Claude CLI and Task Master env"

  if ! command -v claude >/dev/null 2>&1; then
    echo "⚠️  Claude CLI not found - please install with: npm install -g @anthropic-ai/claude-code"
  else
    echo "✅ Claude CLI ready: $(claude --version)"
    
    # Configure task-master MCP server
    if ! claude mcp list | grep -q "task-master"; then
      echo "⚙️  Adding task-master MCP server..."
      claude mcp add task-master -- npx -y task-master-ai
    fi
  fi

  if ! command -v task-master >/dev/null 2>&1; then
    echo "⚠️  Task Master not found - please install with: npm install -g task-master-ai"
  else
    echo "✅ Task Master ready: $(task-master --version 2>/dev/null | head -1)"
  fi
''