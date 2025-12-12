#!/bin/bash
# AI Collaboration Framework Installer
# Installs the Claude-Gemini collaboration system globally

set -e

FRAMEWORK_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="$FRAMEWORK_DIR/bin"
ZSHRC="$HOME/.zshrc"

echo "🤖 AI Collaboration Framework Installer"
echo "========================================"
echo ""
echo "Framework location: $FRAMEWORK_DIR"
echo ""

# Check if already in PATH
if grep -q "ai-collaboration-framework/bin" "$ZSHRC" 2>/dev/null; then
    echo "⚠️  Framework already in PATH"
    read -p "Reinstall anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
fi

# Add to PATH in .zshrc
echo "" >> "$ZSHRC"
echo "# AI Collaboration Framework (Claude + Gemini)" >> "$ZSHRC"
echo "export AI_COLLAB_HOME=\"$FRAMEWORK_DIR\"" >> "$ZSHRC"
echo "export PATH=\"\$AI_COLLAB_HOME/bin:\$PATH\"" >> "$ZSHRC"
echo "" >> "$ZSHRC"

echo "✓ Added to PATH in ~/.zshrc"

# Create symlinks for commonly used tools
SYMLINK_DIR="$HOME/.local/bin"
mkdir -p "$SYMLINK_DIR"

ln -sf "$BIN_DIR/send_message" "$SYMLINK_DIR/send_message" 2>/dev/null || true
ln -sf "$BIN_DIR/delegate_task" "$SYMLINK_DIR/delegate_task" 2>/dev/null || true
ln -sf "$BIN_DIR/respond_to_gemini" "$SYMLINK_DIR/respond_to_gemini" 2>/dev/null || true
ln -sf "$BIN_DIR/gemini-say" "$SYMLINK_DIR/gemini-say" 2>/dev/null || true
ln -sf "$BIN_DIR/claude-say" "$SYMLINK_DIR/claude-say" 2>/dev/null || true
ln -sf "$BIN_DIR/gemini-vault" "$SYMLINK_DIR/gemini-vault" 2>/dev/null || true

echo "✓ Created symlinks in ~/.local/bin"

# Initialize collaboration directories in user's workspace
WORKSPACE_COLLAB="$HOME/Dev/workspace/collab"
if [ ! -d "$WORKSPACE_COLLAB" ]; then
    mkdir -p "$WORKSPACE_COLLAB"/{dialogues,handoffs,tasks,responses,decisions,incidents}

    # Initialize status.json
    cat > "$WORKSPACE_COLLAB/status.json" << 'EOF'
{
  "state": "IDLE",
  "updated": null,
  "current_task": null,
  "context": null,
  "health_check": "ok"
}
EOF

    echo "✓ Initialized workspace collaboration directory"
else
    echo "ℹ️  Workspace collaboration directory already exists"
fi

echo ""
echo "✅ Installation complete!"
echo ""
echo "NEXT STEPS:"
echo "1. Restart your terminal or run: source ~/.zshrc"
echo "2. Test the installation: send_message --help"
echo "3. Read the documentation: $FRAMEWORK_DIR/README.md"
echo ""
echo "Available commands:"
echo "  • send_message       - Gemini → Claude communication"
echo "  • delegate_task      - Delegate tasks between agents"
echo "  • respond_to_gemini  - Claude → Gemini responses"
echo "  • gemini-say         - Formatted Gemini output"
echo "  • claude-say         - Formatted Claude output"
echo "  • gemini-vault       - Obsidian vault management"
echo ""
