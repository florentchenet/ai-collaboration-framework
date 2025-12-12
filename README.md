# AI Collaboration Framework

**Claude (Architect) ⇄ Gemini (Engineer)**

A structured framework for bidirectional collaboration between Claude and Gemini AI agents, enabling seamless task delegation, communication, and coordination across software projects.

---

## 🎯 Overview

This framework establishes a **unified AI operating system** where two specialized agents work together:

- **🔶 Claude** - The Architect & Strategist (reasoning, design, review)
- **🔷 Gemini** - The Engineer & Operator (execution, implementation, automation)

### Key Features

✅ **Bidirectional Communication** - Both agents can message and delegate to each other
✅ **Clear Agent Identification** - Visual markers (🔷🔶) distinguish who's speaking
✅ **State Management** - Shared state machine tracks collaboration status
✅ **Task Delegation** - Structured handoff system for work delegation
✅ **Obsidian Integration** - Full vault management capabilities
✅ **Project Agnostic** - Works in any directory or project
✅ **Version Controlled** - Track collaboration history in git

---

## 📦 Installation

### Quick Install

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/ai-collaboration-framework.git
cd ai-collaboration-framework

# Run the installer
chmod +x install.sh
./install.sh

# Reload your shell
source ~/.zshrc
```

### Manual Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/ai-collaboration-framework.git
   ```

2. **Add to PATH:**
   ```bash
   export AI_COLLAB_HOME="/path/to/ai-collaboration-framework"
   export PATH="$AI_COLLAB_HOME/bin:$PATH"
   ```

3. **Create collaboration workspace:**
   ```bash
   mkdir -p ~/Dev/workspace/collab/{dialogues,handoffs,tasks,responses,decisions}
   ```

4. **Initialize status:**
   ```bash
   echo '{"state":"IDLE","updated":null,"current_task":null}' > ~/Dev/workspace/collab/status.json
   ```

---

## 🚀 Quick Start

### Basic Communication

**Gemini sends a message to Claude:**
```bash
send_message "claude" "I've completed the database migration" "info" "normal"
```

**Claude responds to Gemini:**
```bash
respond_to_gemini "Great! Please run the tests to verify." --type "response"
```

### Task Delegation

**Gemini delegates a task to Claude:**
```bash
delegate_task "Review the authentication architecture" \
  /path/to/auth.py \
  --reason "Need architectural decision on OAuth flow"
```

**Claude delegates a task to Gemini:**
```bash
delegate_task "Implement the user registration endpoint" \
  /path/to/design.md \
  --reason "Implementation ready, design is complete"
```

### Formatted Output

**Output as Gemini:**
```bash
echo "Starting database backup..." | gemini-say
```

**Output as Claude:**
```bash
echo "Reviewing your implementation..." | claude-say
```

---

## 📂 Directory Structure

```
ai-collaboration-framework/
├── bin/                          # Executable tools
│   ├── send_message             # Gemini → Claude messages
│   ├── delegate_task            # Task delegation
│   ├── respond_to_gemini        # Claude → Gemini responses
│   ├── gemini-say               # Formatted Gemini output
│   ├── claude-say               # Formatted Claude output
│   ├── gemini-vault             # Obsidian vault manager
│   ├── obsidian-vault-manager.sh
│   ├── delegate-to-gemini.sh    # Full autonomy delegation
│   └── rhncrs-mcp-server.py     # MCP server for advanced integration
├── docs/                         # Documentation
│   ├── COLLABORATION-PROTOCOL.md
│   └── gemini-obsidian-agent.md
├── lib/                          # Shared libraries (future)
├── templates/                    # Project templates
│   └── new-project/
├── install.sh                    # Installation script
└── README.md                     # This file
```

### Workspace Structure (Created by Installer)

```
~/Dev/workspace/collab/
├── dialogues/                    # Conversation logs
│   └── active_thread.md         # Current dialogue
├── handoffs/                     # Task delegation files
│   └── YYYYMMDD_Task_ID.md
├── tasks/                        # Task tracking (JSON)
├── responses/                    # Response files
├── decisions/                    # Architecture Decision Records
├── incidents/                    # Error/incident logs
├── status.json                   # Current collaboration state
└── message-log.jsonl            # Complete message history
```

---

## 🛠️ Available Tools

### Communication Tools

#### `send_message`

Gemini sends messages to Claude.

**Syntax:**
```bash
send_message <recipient> <message> <type> <priority>
```

**Parameters:**
- `recipient` - Usually "claude"
- `message` - Message content
- `type` - `info`, `question`, or `request`
- `priority` - `normal` or `high`

**Example:**
```bash
send_message "claude" "Should we use PostgreSQL or MongoDB?" "question" "high"
```

**What it does:**
- Logs message to `message-log.jsonl`
- Appends to `dialogues/active_thread.md`
- Updates `status.json` (sets state to `CLAUDE_WORKING` for requests/questions)
- Creates high-priority notification if priority is "high"

---

#### `delegate_task`

Delegate a task from one agent to another.

**Syntax:**
```bash
delegate_task <task_description> [context_files...] --reason <reason>
```

**Example:**
```bash
delegate_task "Refactor authentication module" \
  src/auth.py \
  docs/auth-design.md \
  --reason "Requires architectural review before implementation"
```

**What it does:**
- Creates handoff file in `handoffs/YYYYMMDD_Task_ID.md`
- Creates task tracking entry in `tasks/`
- Updates `status.json` with task context
- Sets state to `CLAUDE_WORKING` or `GEMINI_WORKING`

---

#### `respond_to_gemini`

Claude responds to Gemini's messages or tasks.

**Syntax:**
```bash
respond_to_gemini <message> [--task-id <id>] [--type <type>]
```

**Types:** `response`, `answer`, `completed`

**Example:**
```bash
respond_to_gemini "Use PostgreSQL for relational data integrity" \
  --task-id 20251212_143022 \
  --type "answer"
```

**What it does:**
- Appends to `dialogues/active_thread.md`
- Updates handoff file if task-id provided
- Creates response file in `responses/`
- Updates `status.json` to `GEMINI_WORKING`

---

### Output Formatting

#### `gemini-say` & `claude-say`

Format output with agent identification headers.

**Syntax:**
```bash
gemini-say "message"
echo "message" | gemini-say

claude-say "message"
echo "message" | claude-say
```

**Output:**
```markdown
### 🔷 Gemini
message

### 🔶 Claude
message
```

---

### Obsidian Vault Management

#### `gemini-vault`

Complete vault management tool for Gemini.

**Commands:**
```bash
# Write a file
gemini-vault write "path/to/file.md" "# Content here"

# Read a file
gemini-vault read "path/to/file.md"

# List directory
gemini-vault list "10_Projects"

# Show tree
gemini-vault tree "00_Atlas" 2

# Create directory
gemini-vault mkdir "new/directory"

# Move/rename
gemini-vault mv "old/path.md" "new/path.md"

# Remove file
gemini-vault rm "path/to/file.md"

# Check if exists
gemini-vault exists "path/to/file.md"

# Show structure
gemini-vault structure

# Show stats
gemini-vault stats
```

**Configuration:**

The vault path is hardcoded in the tool. To change it:

```bash
# Edit the vault manager
nano ~/Dev/ai-collaboration-framework/bin/obsidian-vault-manager.sh

# Update this line:
VAULT_PATH="/path/to/your/vault"
```

---

## 📋 Collaboration Protocol

### Agent Roles

**🔶 Claude (Architect):**
- System design and architecture
- Complex reasoning and analysis
- Code review and quality assurance
- Strategic planning
- Creative writing and documentation

**🔷 Gemini (Engineer):**
- Hands-on code execution
- File operations and automation
- Testing and debugging
- Environment configuration
- Performance optimization

### Communication Flow

```
User Request
     ↓
  Router (Claude)
   /         \
Claude      Gemini
(Design)   (Execute)
   \         /
  Integration
      ↓
    Result
      ↓
    User
```

### State Machine

The `status.json` file tracks collaboration state:

**States:**
- `IDLE` - No active work
- `CLAUDE_WORKING` - Claude is processing
- `GEMINI_WORKING` - Gemini is executing
- `AWAITING_USER` - Blocked on user input
- `ERROR` - System error encountered

**Example status.json:**
```json
{
  "state": "GEMINI_WORKING",
  "updated": "2025-12-12T15:30:00Z",
  "current_task": "Implementing authentication endpoint",
  "context": "/path/to/handoff.md",
  "delegated_by": "claude",
  "health_check": "ok"
}
```

---

## 🎯 Usage Examples

### Example 1: Full Feature Implementation

**Step 1: User requests feature**
```
User: "Add user authentication to the app"
```

**Step 2: Claude designs architecture**
```bash
# Claude analyzes and creates design
claude-say "Designing authentication system with JWT tokens..."

# Claude creates handoff for Gemini
delegate_task "Implement JWT authentication system" \
  docs/auth-design.md \
  --reason "Design complete, ready for implementation"
```

**Step 3: Gemini implements**
```bash
# Gemini receives task and executes
gemini-say "Implementing authentication endpoints..."

# Gemini updates handoff when complete
respond_to_gemini "Authentication implemented and tested" \
  --task-id 20251212_150000 \
  --type "completed"
```

**Step 4: Claude reviews**
```bash
# Claude reviews implementation
claude-say "Reviewing authentication implementation..."

# Claude provides feedback
respond_to_gemini "Implementation looks good. Please add rate limiting."
```

---

### Example 2: Documentation Creation

**Claude delegates to Gemini:**
```bash
delegate_task "Create API documentation for all endpoints" \
  src/api/ \
  --reason "Need comprehensive endpoint documentation"
```

**Gemini executes:**
```bash
# Gemini generates documentation
gemini-vault write "docs/API-Reference.md" "# API Reference

## Authentication Endpoints
...complete documentation..."

# Gemini reports completion
send_message "claude" "API documentation complete" "info" "normal"
```

---

### Example 3: Gemini Encounters Blocker

**Gemini hits an issue:**
```bash
send_message "claude" \
  "Need clarification: Should we use session-based or token-based auth for mobile?" \
  "question" \
  "high"
```

**Status automatically updates to `CLAUDE_WORKING`**

**Claude responds:**
```bash
respond_to_gemini \
  "Use token-based (JWT) for mobile to support offline capability" \
  --type "answer"
```

**Status updates to `GEMINI_WORKING`, Gemini continues**

---

## 🔧 Configuration

### Environment Variables

Set these in your `~/.zshrc`:

```bash
# Framework home (set by installer)
export AI_COLLAB_HOME="/path/to/ai-collaboration-framework"

# Collaboration workspace (default: ~/Dev/workspace/collab)
export COLLAB_DIR="$HOME/Dev/workspace/collab"

# Obsidian vault path (for gemini-vault)
export OBSIDIAN_VAULT="/path/to/your/vault"
```

### Customizing Vault Path

Edit `bin/obsidian-vault-manager.sh`:

```bash
VAULT_PATH="${OBSIDIAN_VAULT:-/Users/hoe/Library/Mobile Documents/iCloud~md~obsidian/Documents/rhncrs-collab}"
```

---

## 📚 Advanced Features

### MCP Server Integration

The framework includes an MCP (Model Context Protocol) server for advanced integration.

**Setup:**
```bash
# Install MCP SDK
pip3 install mcp

# Run the server
python3 $AI_COLLAB_HOME/bin/rhncrs-mcp-server.py
```

**Configure in Claude Code:**
```json
{
  "mcpServers": {
    "ai-collaboration": {
      "command": "python3",
      "args": ["/path/to/ai-collaboration-framework/bin/rhncrs-mcp-server.py"]
    }
  }
}
```

### Full Autonomy Delegation

Use `delegate-to-gemini.sh` to give Gemini complete autonomy on a task:

```bash
echo "Create complete documentation for the authentication system" | \
  $AI_COLLAB_HOME/bin/delegate-to-gemini.sh
```

Gemini will:
1. Plan the approach
2. Execute all necessary operations
3. Verify the work
4. Report results

---

## 🌟 Best Practices

### 1. Clear Task Descriptions

**Good:**
```bash
delegate_task "Implement user registration endpoint with email validation, password hashing (bcrypt), and database persistence to PostgreSQL users table"
```

**Bad:**
```bash
delegate_task "Add registration stuff"
```

### 2. Include Context

Always provide relevant files:
```bash
delegate_task "Refactor database queries" \
  src/db/queries.py \
  docs/database-schema.md \
  tests/test_queries.py \
  --reason "Optimize N+1 query problems"
```

### 3. Use Appropriate Message Types

- `info` - Status updates, FYI messages
- `question` - Needs a response/clarification
- `request` - Asking for action/help

### 4. Set Priority Correctly

- `normal` - Standard work items
- `high` - Blockers, urgent issues, critical decisions

### 5. Update Status

Both agents should update `status.json` when:
- Starting work (set to `_WORKING`)
- Completing work (set to `IDLE` or next agent's turn)
- Encountering errors (set to `ERROR`)

---

## 🐛 Troubleshooting

### Tools not found

```bash
# Ensure framework is in PATH
echo $AI_COLLAB_HOME
echo $PATH | grep ai-collaboration

# Reload shell configuration
source ~/.zshrc

# Or re-run installer
cd $AI_COLLAB_HOME
./install.sh
```

### Permission denied

```bash
# Make tools executable
chmod +x $AI_COLLAB_HOME/bin/*
```

### Status.json errors

```bash
# Reset status
cat > ~/Dev/workspace/collab/status.json << 'EOF'
{
  "state": "IDLE",
  "updated": null,
  "current_task": null,
  "context": null,
  "health_check": "ok"
}
EOF
```

---

## 📖 Documentation

- **[Collaboration Protocol](docs/COLLABORATION-PROTOCOL.md)** - Complete protocol specification
- **[Gemini Obsidian Agent](docs/gemini-obsidian-agent.md)** - Obsidian integration guide

---

## 🤝 Contributing

This framework was developed for the RHINOCEROS ecosystem but is designed to be project-agnostic.

To adapt for your own projects:

1. Fork the repository
2. Customize vault paths and configurations
3. Add project-specific templates to `templates/`
4. Update documentation with your use cases

---

## 📄 License

MIT License - Feel free to adapt and use in your own projects.

---

## 🙏 Acknowledgments

Developed for the **RHINOCEROS** ecosystem - a multi-faceted creative platform combining music production, AI orchestration, and infrastructure management.

**Agents:**
- Claude (Anthropic) - Architecture & Strategy
- Gemini (Google) - Engineering & Execution

---

## 📞 Support

For questions or issues:
- Open an issue on GitHub
- Review the [Collaboration Protocol](docs/COLLABORATION-PROTOCOL.md)
- Check the [troubleshooting section](#-troubleshooting)

---

**Version:** 1.0.0
**Last Updated:** 2025-12-12
**Status:** Production Ready
