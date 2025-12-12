---
name: gemini-obsidian-agent
description: Use Gemini CLI to write and manage Obsidian vault files, structure directories, and create comprehensive documentation
version: 1.0.0
tags: [gemini, obsidian, documentation, vault-management]
---

# Gemini Obsidian Agent

## Overview

This skill enables using Gemini as the primary agent for writing and managing Obsidian vault files. Gemini excels at creating comprehensive documentation, structuring knowledge bases, and maintaining consistent formatting across large documentation projects.

## When to Use This Skill

Use this skill when you need to:

- **Create multiple related documentation files** for an Obsidian vault
- **Structure entire vault sections** with consistent formatting
- **Write comprehensive technical documentation** with deep context
- **Aggregate information** from multiple sources into Obsidian notes
- **Maintain documentation standards** across a knowledge base
- **Generate MOCs (Maps of Content)** and navigation structures

## Core Principle

**Gemini writes, Claude coordinates.** Claude acts as the user's assistant and project manager, while Gemini acts as the documentation writer and vault architect.

## Workflow

### 1. Define the Documentation Task

Before invoking Gemini, clearly define:
- **Vault location:** Full path to the Obsidian vault
- **Target directory:** Where files should be created
- **File structure:** What files need to be created
- **Content requirements:** What each file should contain
- **Linking strategy:** How files should reference each other

### 2. Construct the Gemini Prompt

Create a comprehensive prompt that includes:

```bash
gemini "You are the Obsidian documentation agent.

TASK: [Clear description of what to create]

VAULT LOCATION: [Full path]

FILES TO CREATE:
1. [filename.md] - [purpose]
2. [filename.md] - [purpose]
...

REQUIREMENTS:
- Use consistent frontmatter with tags, dates, status
- Follow [specific formatting standards]
- Include [[wikilinks]] for cross-references
- Create comprehensive, production-ready content
- [Any other specific requirements]

CONTEXT:
[Relevant background information Gemini needs]

OUTPUT FORMAT:
Provide the complete content for each file, clearly separated with:

=== FILENAME: path/to/file.md ===
[complete file content]
===

Be comprehensive and production-ready."
```

### 3. Execute and Capture Output

Run Gemini and capture the output:

```bash
gemini "[prompt]" > /tmp/gemini-output.txt
```

Or for real-time viewing:

```bash
gemini "[prompt]" | tee /tmp/gemini-output.txt
```

### 4. Parse and Write Files

Parse Gemini's output and write files to the vault:

**Option A: Manual parsing**
- Read the output
- Extract each file section
- Write to the appropriate location using the Write tool

**Option B: Automated script**
```bash
# Example parsing script
awk '
  /^=== FILENAME: / {
    if (file) close(file)
    file = $3
    next
  }
  /^===$/ {
    if (file) close(file)
    file = ""
    next
  }
  file { print > file }
' /tmp/gemini-output.txt
```

### 5. Verify and Commit

- Check that all files were created correctly
- Verify links and formatting in Obsidian
- Commit to git if vault is version controlled

## Best Practices

### Prompt Construction

**DO:**
- Provide complete context about the vault structure
- Specify exact formatting requirements
- Include examples of desired output
- Request production-ready content
- Ask for comprehensive coverage

**DON'T:**
- Give vague instructions like "create some docs"
- Assume Gemini knows your vault structure
- Skip specifying the output format
- Request partial or placeholder content

### File Management

**Use Gemini for:**
- Creating multiple related files in one operation
- Writing comprehensive documentation (500+ words)
- Generating structured content with consistent formatting
- Creating navigation structures (MOCs, indexes)
- Aggregating information from multiple sources

**Use Claude/Direct tools for:**
- Single file edits
- Quick updates or corrections
- File operations (moving, renaming, deleting)
- Simple templating
- Interactive editing sessions

### Content Quality

Gemini produces best results when:
- Given clear structure and requirements
- Provided with relevant context
- Asked for specific examples
- Told to be comprehensive
- Given formatting templates to follow

## Common Patterns

### Pattern 1: Bulk File Creation

```bash
gemini "Create 5 technical specification files for:
- Component A
- Component B
- Component C
- Component D
- Component E

Use this template for each:
[paste template]

Vault: /path/to/vault
Location: 10_Projects/Specs/

Output each file clearly marked with === FILENAME: === delimiters."
```

### Pattern 2: MOC Generation

```bash
gemini "Create a comprehensive Map of Content for [domain].

Include:
- Overview section
- Categorized links to related notes
- Quick reference tables
- Visual diagrams (ASCII/mermaid if applicable)

Vault structure:
[describe relevant parts of vault]

Target file: /path/to/vault/MOC_Name.md"
```

### Pattern 3: Documentation Aggregation

```bash
gemini "Aggregate information from these sources into an Obsidian note:

SOURCES:
- /path/to/file1.md
- /path/to/file2.md
- https://url

Create a comprehensive technical guide that:
- Synthesizes information from all sources
- Adds clear structure and navigation
- Includes cross-references
- Follows our documentation standards

Output to: /path/to/vault/output.md"
```

### Pattern 4: Vault Section Creation

```bash
gemini "Design and create a complete vault section for [topic].

Structure needed:
/Topic/
  ├── 00_Index.md (overview and navigation)
  ├── 01_Getting_Started.md
  ├── 02_Core_Concepts.md
  ├── 03_Advanced_Topics.md
  ├── 04_Troubleshooting.md
  └── 05_References.md

Requirements:
- Comprehensive content for each file
- Cross-links between files
- Consistent frontmatter
- Technical depth appropriate for [audience]

Base path: /path/to/vault/Topic/"
```

## Integration with TodoWrite

When using this skill with complex documentation projects:

```markdown
1. Define vault section structure
2. Construct Gemini prompt for content generation
3. Execute Gemini and capture output
4. Parse output and write files to vault
5. Verify all files created correctly
6. Review content quality and links
7. Commit to git
```

## Error Handling

### Gemini Output Issues

If Gemini doesn't follow the format:
- Make the output format more explicit in the prompt
- Provide an example of the expected format
- Use clear delimiters (=== FILENAME: ===)
- Request one file at a time if needed

### File Creation Failures

If files aren't created properly:
- Verify vault path is correct
- Check file permissions
- Ensure parent directories exist
- Validate file names (no invalid characters)

### Content Quality Issues

If content isn't comprehensive enough:
- Add "Be comprehensive and detailed" to prompt
- Provide more context about requirements
- Give examples of desired depth
- Request specific sections or topics to cover

## Examples

### Example 1: Creating Project Documentation

```bash
# Define task
vault="/Users/hoe/Library/Mobile Documents/iCloud~md~obsidian/Documents/rhncrs-collab"
project="10_Projects/12_Rhinocrash"

# Execute Gemini
gemini "Create comprehensive project documentation for RhinoCrash.

FILES TO CREATE:
1. README.md - Project overview, quick start, architecture
2. Development-Workflow.md - How to use RhinoChat agents
3. Agent-Specifications.md - Detailed agent capabilities
4. API-Reference.md - CLI commands and usage

Vault: $vault
Location: $project/

Each file should be:
- Production-ready and comprehensive
- Include frontmatter with appropriate tags
- Cross-link to related files
- Follow technical documentation standards

Context: RhinoCrash is an AI development orchestration system using Claude and Gemini agents...

Output format:
=== FILENAME: README.md ===
[content]
===

=== FILENAME: Development-Workflow.md ===
[content]
===" > /tmp/rhinocrash-docs.txt

# Parse and write files
# [implement parsing logic]
```

### Example 2: Bulk MOC Creation

```bash
gemini "Create all Maps of Content for the rhncrs-collab vault.

MOCs NEEDED:
1. MOC_Master.md - Top-level navigation
2. MOC_Production.md - Creative workflows
3. MOC_Development.md - Code and patterns
4. MOC_Infrastructure.md - Servers and deployment
5. MOC_Hardware_Lab.md - Equipment and DIY

Location: $vault/00_Atlas/MOCs/

Requirements:
- Comprehensive navigation for each domain
- Links to relevant project areas
- Quick reference sections
- Consistent formatting
- Production-ready content

Output each MOC with clear delimiters." | tee /tmp/mocs.txt
```

## Coordination Protocol

### Claude's Role (You)
1. Understand user's documentation needs
2. Design overall vault structure
3. Create directory structure
4. Construct detailed Gemini prompts
5. Execute Gemini commands
6. Parse and write Gemini's output to files
7. Verify completeness and quality
8. Commit changes to git
9. Report results to user

### Gemini's Role
1. Generate comprehensive documentation content
2. Follow specified structure and formatting
3. Maintain consistency across multiple files
4. Create cross-references and links
5. Provide production-ready output

## Tips for Success

1. **Be Specific:** Don't ask Gemini to "create some docs" - specify exactly what you need
2. **Provide Context:** Give Gemini relevant background about the project
3. **Use Templates:** Provide examples of desired output format
4. **Request Completeness:** Explicitly ask for comprehensive, production-ready content
5. **Structure Output:** Use clear delimiters to make parsing easier
6. **Verify Results:** Always check that files were created correctly
7. **Iterate if Needed:** If output isn't perfect, refine the prompt and try again

## Related Skills

- **superpowers:writing-plans** - For creating implementation plans
- **superpowers:brainstorming** - For designing documentation structure
- **superpowers:verification-before-completion** - For ensuring docs are complete

---

**Version:** 1.0.0
**Author:** RHINOCEROS Development Team
**Last Updated:** 2025-12-12
