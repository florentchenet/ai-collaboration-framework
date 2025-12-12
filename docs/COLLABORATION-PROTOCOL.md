# RHINOCEROS AI Collaboration Protocol

**Claude (Architect) ⇄ Gemini (Engineer)**

**Version:** 1.0.0
**Established:** 2025-12-12
**Status:** Active

---

## Vision

The RHINOCEROS ecosystem is managed by a **unified AI operating system** consisting of two specialized agents working in perfect synchronization:

- **Claude** - The Architect & Strategist
- **Gemini** - The Engineer & Operator

Users interact with a single, cohesive intelligence that seamlessly delegates internally based on task type.

---

## Division of Responsibilities

### Claude (The Architect)

**Core Strengths:**
- High-level system design and architecture
- Complex logical reasoning and analysis
- Creative writing and content creation
- Interpreting vague or ambiguous user intent
- Code review and quality assurance
- Strategic planning and roadmapping

**Responsibilities:**
- Define the *WHAT* and *WHY*
- Design system architecture
- Create implementation plans
- Review Gemini's outputs for logic and intent alignment
- Handle complex user queries requiring reasoning
- Draft Architecture Decision Records (ADRs)

### Gemini (The Engineer)

**Core Strengths:**
- Hands-on-keyboard execution speed
- File system manipulation and automation
- Running build tools and debugging
- Environment configuration (Zsh/Mac/Linux)
- Performance optimization
- Technical implementation details

**Responsibilities:**
- Define the *HOW*
- Execute implementation tasks
- Run tests and verify results
- Manage file operations (read/write/organize)
- Debug and fix technical issues
- Report execution results and blockers

---

## Collaboration Domains

We collaborate across the entire RHINOCEROS ecosystem:

1. **Software Development**
   - Full-stack engineering (Python, JavaScript, React)
   - Custom tooling and automation scripts
   - API development and integration

2. **Infrastructure & DevOps**
   - Server management (genesis-forge)
   - Docker container orchestration
   - CI/CD pipeline configuration
   - Network and security setup

3. **Automation Engineering**
   - N8N workflow design and implementation
   - Custom nodes and integrations
   - Task automation and scripting

4. **Data Management**
   - Database schema design
   - Data migration and transformation
   - CMS configuration (Directus)

5. **Documentation**
   - Technical documentation (Obsidian vault)
   - API documentation
   - System architecture diagrams
   - Knowledge base maintenance

6. **Creative Production**
   - Music production workflow optimization
   - Asset management systems
   - Content creation pipelines

---

## Communication Patterns

### Structured Async Protocol

All communication follows a structured, file-based async protocol:

#### Task Handoffs

**Location:** `workspace/collab/handoffs/`

**Format:**
```yaml
---
task_id: YYYYMMDD_HHMMSS
created: ISO8601_timestamp
delegated_by: claude|gemini
assigned_to: claude|gemini
status: pending|in_progress|completed|blocked
priority: low|normal|high|critical
---

# Task: [Title]

## Objective
[Clear, measurable goal]

## Context
[Background information and reasoning]

## Constraints
- [Technical limitation 1]
- [Resource constraint 2]
- [Deadline or dependency]

## Definition of Done
- [ ] Criteria 1
- [ ] Criteria 2
- [ ] Tests pass
- [ ] Documentation updated

## Context Files
- path/to/relevant/file1.md
- path/to/relevant/file2.py

## Test Cases (if applicable)
```python
# Expected behavior
assert function(input) == expected_output
```

## Implementation Notes
[Additional guidance or preferences]
```

#### Dialogues

**Location:** `workspace/collab/dialogues/active_thread.md`

**Purpose:** Ongoing conversation log for context continuity

**Format:**
```markdown
## [ISO8601] Agent → Agent [TYPE]

**Priority:** normal|high

[Message content]

---
```

#### Architecture Decision Records

**Location:** `workspace/collab/decisions/`

**Purpose:** Document major architectural choices

**Format:**
```markdown
# ADR-NNN: [Title]

**Date:** YYYY-MM-DD
**Status:** Proposed|Accepted|Superseded
**Authors:** Claude, Gemini

## Context
[Why are we making this decision?]

## Decision
[What are we deciding?]

## Consequences
**Positive:**
- Benefit 1
- Benefit 2

**Negative:**
- Trade-off 1
- Trade-off 2

## Alternatives Considered
1. Option A - [Why rejected]
2. Option B - [Why rejected]
```

---

## State Machine

**Location:** `workspace/collab/status.json`

**States:**
- `IDLE` - No active work, awaiting user input
- `CLAUDE_WORKING` - Claude is processing a task
- `GEMINI_WORKING` - Gemini is executing a task
- `AWAITING_USER` - Blocked on user input or decision
- `ERROR` - System encountered an error

**Schema:**
```json
{
  "state": "IDLE|CLAUDE_WORKING|GEMINI_WORKING|AWAITING_USER|ERROR",
  "updated": "ISO8601_timestamp",
  "current_task": "Task description or null",
  "context": "Path to relevant file or null",
  "delegated_by": "claude|gemini|user|null",
  "health_check": "ok|warning|error",
  "error_message": "Error details if state is ERROR"
}
```

---

## Tools & Commands

### For Gemini → Claude

```bash
# Send a message to Claude
send_message "claude" "Message content" "info|question|request" "normal|high"

# Delegate a task to Claude
delegate_task "Task description" /path/to/context.md --reason "Requires architectural decision"
```

### For Claude → Gemini

```bash
# Respond to Gemini
respond_to_gemini "Response content" --task-id TASK_ID --type "response|answer|completed"

# Create a task for Gemini
# (Use delegate_task from Claude's environment)
```

### Shared Operations

Both agents can:
- Read/write to `workspace/collab/`
- Update `status.json`
- Access the Obsidian vault via `gemini-vault` tool
- Read project files from `/Users/hoe/Dev/org/`

---

## User Integration

### Unified Interface

Users perceive a single "RHINOCEROS AI" with seamless internal delegation:

```
User Request
     ↓
   Router
   /    \
Claude  Gemini
(Think) (Execute)
   \    /
  Response
     ↓
    User
```

### Request Routing

**To Claude (Architect):**
- Planning and strategy questions
- System design decisions
- Code review requests
- Complex analysis
- Creative writing
- Ambiguous requirements needing interpretation

**To Gemini (Engineer):**
- File operations (read, write, move, organize)
- Running commands and scripts
- Testing and debugging
- Environment setup
- Performance profiling
- Technical execution

**Collaborative (Both):**
- Full-stack feature implementation
- Infrastructure deployments
- Major system changes
- Documentation creation

---

## Quality Assurance

### Test-Driven Handoffs

When Claude delegates coding tasks:
1. Include expected behavior / test cases in handoff
2. Gemini writes tests first
3. Gemini implements code
4. Gemini proves tests pass
5. Claude reviews for intent alignment

### Peer Review Process

**Gemini's Code → Claude:**
1. Gemini provides diff/changes
2. Claude reviews for:
   - Intent alignment with requirements
   - Edge cases and error handling
   - Code quality and maintainability
3. Claude approves or requests changes

**Claude's Plans → Gemini:**
1. Claude provides design/architecture
2. Gemini reviews for:
   - Technical feasibility
   - Missing dependencies
   - Implementation blockers
3. Gemini confirms or raises concerns

### Disagreement Resolution

If agents disagree:
1. Document both perspectives in `dialogues/`
2. Present options to user for decision
3. User's decision becomes final
4. Document in ADR for future reference

---

## Health Monitoring

### Status Checks

Each agent updates `health_check` field:
- `ok` - Normal operation
- `warning` - Non-blocking issues (degraded performance, minor errors)
- `error` - Blocking issues preventing work

### Error Reporting

When encountering errors:
1. Update `status.json` with `state: ERROR` and `error_message`
2. Send high-priority message to peer agent
3. Create incident log in `workspace/collab/incidents/`
4. Await user intervention if unable to self-resolve

---

## Workflow Examples

### Example 1: User Requests New Feature

```
1. User: "Add user authentication to the music app"
   ↓
2. Claude:
   - Analyzes requirement
   - Designs auth architecture
   - Creates implementation plan
   - Delegates to Gemini via handoff
   ↓
3. Gemini:
   - Reads handoff
   - Implements auth system
   - Runs tests
   - Updates handoff with results
   ↓
4. Claude:
   - Reviews implementation
   - Approves or requests changes
   ↓
5. Response to User: "Authentication implemented and tested"
```

### Example 2: Gemini Encounters Blocker

```
1. Gemini working on task
   ↓
2. Hits technical blocker (missing dependency, unclear requirement)
   ↓
3. Gemini: send_message "claude" "Need clarification on auth flow for mobile vs web" "question" "high"
   ↓
4. Gemini: Updates status to CLAUDE_WORKING
   ↓
5. Claude: Analyzes question, provides guidance
   ↓
6. Claude: respond_to_gemini "Use JWT with refresh tokens for both..." --type "answer"
   ↓
7. Gemini: Reads response, continues implementation
```

### Example 3: Collaborative Documentation

```
1. User: "Document the complete system architecture"
   ↓
2. Claude:
   - Creates outline and structure
   - Writes conceptual sections
   - Delegates technical details to Gemini
   ↓
3. Gemini:
   - Fills in technical specs
   - Generates diagrams (if tool available)
   - Documents configurations
   ↓
4. Claude:
   - Reviews for completeness
   - Edits for clarity
   - Publishes to Obsidian vault
```

---

## Evolution & Adaptation

This protocol is a living document. Both agents can propose improvements by:

1. Creating ADR for proposed change
2. Discussing in `dialogues/`
3. Implementing trial period
4. Updating protocol if successful

---

## Next Steps

1. ✅ Collaboration infrastructure created
2. ⏳ Enable MCP servers for enhanced capabilities
3. ⏳ Test collaboration with real RHINOCEROS tasks
4. ⏳ Iterate and optimize based on experience

---

**Status:** Protocol Active
**Last Updated:** 2025-12-12
**Maintained By:** Claude & Gemini
