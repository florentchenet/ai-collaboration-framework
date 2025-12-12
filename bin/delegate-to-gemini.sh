#!/bin/bash
# delegate-to-gemini.sh - Full task delegation framework
# Claude acts as manager, Gemini acts as autonomous worker

set -e

VAULT_PATH="/Users/hoe/Library/Mobile Documents/iCloud~md~obsidian/Documents/rhncrs-collab"
PROJECT_ROOT="/Users/hoe/Dev/org"
VAULT_MANAGER="/Users/hoe/Dev/workspace/tools/gemini-vault"
TEMP_DIR="/tmp/gemini-delegation-$$"

usage() {
    cat << EOF
Delegate to Gemini - Autonomous Worker Framework

USAGE:
    $(basename "$0") [--task-file FILE] [--context-files FILES...]

This script delegates complete autonomy to Gemini for vault management tasks.

Gemini will:
1. Receive full task description
2. Get access to all necessary files and context
3. Execute vault operations independently
4. Report results when complete

OPTIONS:
    --task-file FILE         File containing the task description
    --context FILES...       Additional context files to provide Gemini
    --help                   Show this help

EXAMPLE:
    # Delegate with inline task
    echo "Create complete Rhinoceros Music documentation" | $(basename "$0")

    # Delegate with task file
    $(basename "$0") --task-file /path/to/task.txt

EOF
    exit 1
}

# Parse arguments
TASK_FILE=""
CONTEXT_FILES=()

while [[ $# -gt 0 ]]; do
    case $1 in
        --task-file)
            TASK_FILE="$2"
            shift 2
            ;;
        --context)
            shift
            while [[ $# -gt 0 ]] && [[ ! "$1" =~ ^-- ]]; do
                CONTEXT_FILES+=("$1")
                shift
            done
            ;;
        --help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# Create temp directory
mkdir -p "$TEMP_DIR"
trap "rm -rf '$TEMP_DIR'" EXIT

# Read task description
if [ -n "$TASK_FILE" ]; then
    TASK="$(cat "$TASK_FILE")"
elif [ ! -t 0 ]; then
    TASK="$(cat)"
else
    echo "Error: No task provided. Use --task-file or pipe task via stdin"
    usage
fi

# Build comprehensive Gemini prompt
cat > "$TEMP_DIR/delegation-prompt.txt" << 'EOFPROMPT'
You are the autonomous Obsidian vault agent for the RHINOCEROS ecosystem.

You have been delegated FULL AUTHORITY to manage the vault independently.

## YOUR ROLE

**You are the worker. Claude is the manager.**

- Claude defines WHAT needs to be done
- YOU decide HOW to do it
- YOU execute all operations
- YOU report results when complete

## YOUR TOOLS

You have access to the `gemini-vault` command-line tool:

**Location:** /Users/hoe/Dev/workspace/tools/gemini-vault

**Available Commands:**
```bash
# Write a file (creates parent directories automatically)
/Users/hoe/Dev/workspace/tools/gemini-vault write "path/to/file.md" "complete content here"

# Read a file
/Users/hoe/Dev/workspace/tools/gemini-vault read "path/to/file.md"

# List directory
/Users/hoe/Dev/workspace/tools/gemini-vault list "10_Projects"

# Show tree structure
/Users/hoe/Dev/workspace/tools/gemini-vault tree "00_Atlas" 2

# Create directory
/Users/hoe/Dev/workspace/tools/gemini-vault mkdir "new/directory"

# Check if file exists
/Users/hoe/Dev/workspace/tools/gemini-vault exists "path/file.md"

# Show vault structure
/Users/hoe/Dev/workspace/tools/gemini-vault structure
```

## VAULT INFORMATION

**Vault Path:** /Users/hoe/Library/Mobile Documents/iCloud~md~obsidian/Documents/rhncrs-collab

**Projects to Document:**
- rhinoceros-music: /Users/hoe/Dev/org/rhinoceros-music
- rhinocrash: /Users/hoe/Dev/org/rhinocrash
- rhncrsv1: /Users/hoe/Dev/org/rhncrsv1
- infrastructure: /Users/hoe/Dev/org/infrastructure
- infrastructure-swarm: /Users/hoe/Dev/org/infrastructure-swarm

**Vault Structure:**
```
00_Atlas/         - Navigation and MOCs
10_Projects/      - Active project documentation
  11_Rhinoceros_Music/
  12_Rhinocrash/
  13_Rhncrs_V1/
  14_Infrastructure/
  15_Infra_Swarm/
20_Domains/       - Permanent knowledge domains
30_Resources/     - Reference materials
40_Logs/          - Chronological records
90_Admin/         - Vault maintenance
```

## DOCUMENTATION STANDARDS

**Frontmatter Template:**
```yaml
---
created: 2025-12-12
updated: 2025-12-12
tags: [#type/xxx, #domain/xxx, #project/xxx]
status: active|deprecated|draft
---
```

**Required Elements:**
- Comprehensive content (no placeholders)
- Wikilinks for internal references: [[path/to/file|Display Text]]
- Navigation sections (Up, Related)
- Production-ready quality

**Tags to Use:**
- Status: #status/seed, #status/sapling, #status/evergreen, #status/deprecated
- Type: #type/guide, #type/spec, #type/moc, #type/reference
- Domain: #domain/audio, #domain/code, #domain/infra, #domain/business
- Project: #project/music, #project/crash, #project/v1, #project/infra-core, #project/infra-swarm

## YOUR TASK

EOFPROMPT

# Append the actual task
echo "$TASK" >> "$TEMP_DIR/delegation-prompt.txt"

# Append context information
cat >> "$TEMP_DIR/delegation-prompt.txt" << 'EOFCONTEXT'

## ADDITIONAL CONTEXT

EOFCONTEXT

# Add context files if provided
if [ ${#CONTEXT_FILES[@]} -gt 0 ]; then
    for context_file in "${CONTEXT_FILES[@]}"; do
        if [ -f "$context_file" ]; then
            echo "### Context from: $context_file" >> "$TEMP_DIR/delegation-prompt.txt"
            echo '```' >> "$TEMP_DIR/delegation-prompt.txt"
            cat "$context_file" >> "$TEMP_DIR/delegation-prompt.txt"
            echo '```' >> "$TEMP_DIR/delegation-prompt.txt"
            echo >> "$TEMP_DIR/delegation-prompt.txt"
        fi
    done
fi

# Append execution instructions
cat >> "$TEMP_DIR/delegation-prompt.txt" << 'EOFINSTRUCTIONS'

## EXECUTION INSTRUCTIONS

1. **Plan your approach** - Break down the task into logical steps
2. **Execute autonomously** - Use gemini-vault commands to complete the work
3. **Verify your work** - Check that all files were created correctly
4. **Report results** - Provide a summary of what was created/modified

**IMPORTANT:**
- Execute gemini-vault commands directly (they're available in your environment)
- Create comprehensive, production-ready content
- Do NOT create placeholder content
- Include proper frontmatter, wikilinks, and navigation
- Report any errors or issues encountered

## OUTPUT FORMAT

Provide your response in this format:

### Planning
[Describe your approach and steps]

### Execution
[Show the gemini-vault commands you're executing and their results]

### Verification
[Confirm all files were created successfully]

### Summary
[Concise summary of what was accomplished]

---

**BEGIN AUTONOMOUS EXECUTION NOW**

EOFINSTRUCTIONS

# Echo the delegation to user
echo "========================================="
echo "DELEGATING TO GEMINI (Autonomous Worker)"
echo "========================================="
echo
echo "Task:"
echo "$TASK"
echo
echo "Context files: ${#CONTEXT_FILES[@]}"
echo
echo "Executing delegation..."
echo

# Execute Gemini with full context and autonomy
gemini < "$TEMP_DIR/delegation-prompt.txt"

echo
echo "========================================="
echo "DELEGATION COMPLETE"
echo "========================================="
