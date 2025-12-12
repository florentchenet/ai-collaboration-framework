# Encrypted Secrets Management & Infrastructure Sync Design

**Date:** 2025-12-12
**Project:** RHINOCEROS AI Collaboration Framework
**Domain:** rhncrs.com
**Status:** Design Complete - Ready for Implementation

---

## Overview

A comprehensive system for managing environment variables (.env files) and infrastructure documentation across multiple projects with mixed shared/unique secrets, using SSH key-based encryption with password fallback for iPhone access.

---

## Problem Statement

**Current Situation:**
- Multiple projects (rhinoceros-music, rhinocrash, rhncrsv1, infrastructure, infrastructure-swarm)
- Mix of unique and shared secrets across projects
- VPS (188.245.183.171) running production services
- Need to access secrets from Mac (Claude/Gemini automation) and iPhone
- Documentation drifts from actual VPS state

**Requirements:**
1. Secure storage of .env files in Obsidian vault (syncs via iCloud)
2. Zero-friction decryption on Mac (for automation)
3. iPhone access with reasonable security
4. Keep infrastructure docs in sync with VPS reality
5. Track secret changes over time

---

## Architecture

### 1. Dual-Encryption System

Each `.env` file is encrypted **twice**:

**Primary: SSH Key Encryption**
- Uses existing SSH public key (~/.ssh/id_ed25519.pub or id_rsa.pub)
- Auto-decrypts on Mac using private key
- Zero password prompts for automation
- File extension: `.env.enc`

**Backup: Password Encryption**
- Same content, encrypted with master password
- For iPhone access and emergencies
- File extension: `.env.password.enc`

**Encryption Tool:** `age` (https://github.com/FiloSottile/age)
- Modern, simple alternative to GPG
- Native SSH key support
- Lightweight and fast

### 2. Vault Structure

```
rhncrs-collab/
└── 9_System/
    └── Secrets/
        ├── README.md                          # Usage documentation
        ├── MASTER_PASSWORD.txt.enc            # Master password (SSH-encrypted only)
        │
        ├── infrastructure.env.enc             # SSH-encrypted
        ├── infrastructure.env.password.enc    # Password-encrypted
        │
        ├── rhinocrash.env.enc
        ├── rhinocrash.env.password.enc
        │
        ├── rhinoceros-music.env.enc
        ├── rhinoceros-music.env.password.enc
        │
        ├── rhncrsv1.env.enc
        ├── rhncrsv1.env.password.enc
        │
        └── shared-secrets.env.enc             # Common secrets across projects
            shared-secrets.env.password.enc
```

### 3. Infrastructure Sync System

**Bidirectional Sync:**
- **Pull:** VPS → Vault (daily automatic)
- **Push:** Vault → VPS (manual deployment)

**Auto-Generated Documentation:**
- `1_Projects/Infrastructure/CURRENT_STATE.md` - Live VPS state
- `40_Logs/Daily_Notes/YYYY-MM-DD.md` - Daily sync logs
- `9_System/Collaboration/incidents/` - Conflict reports

---

## Implementation

### Tool Suite

| Tool | Purpose | Automation |
|------|---------|------------|
| `encrypt-env` | Encrypt .env file to vault | Manual |
| `decrypt-env` | Decrypt from vault | Auto (Mac), Manual (iPhone) |
| `vault-secrets` | Manage all secrets (list/edit/validate) | Manual |
| `infra-pull` | Sync VPS state → Vault | Daily @ 9 AM |
| `infra-push` | Deploy Vault secrets → VPS | Manual |

### 1. encrypt-env

**Location:** `bin/encrypt-env`

**Usage:**
```bash
encrypt-env <project-name> <path-to-.env>

# Example:
encrypt-env infrastructure /root/infrastructure/.env
```

**Behavior:**
1. Validates input .env file exists
2. Encrypts with SSH public key → `${PROJECT}.env.enc`
3. Prompts for master password (first time)
4. Encrypts with password → `${PROJECT}.env.password.enc`
5. Saves both to `9_System/Secrets/` in vault
6. Outputs success message with file locations

**Implementation:**
```bash
#!/bin/bash
set -e

PROJECT_NAME="$1"
ENV_FILE="$2"
VAULT_SECRETS="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/rhncrs-collab/9_System/Secrets"
SSH_KEY="$HOME/.ssh/id_ed25519.pub"

# Validate inputs
if [ -z "$PROJECT_NAME" ] || [ -z "$ENV_FILE" ]; then
    echo "Usage: encrypt-env <project-name> <path-to-.env>"
    exit 1
fi

if [ ! -f "$ENV_FILE" ]; then
    echo "Error: File not found: $ENV_FILE"
    exit 1
fi

# SSH key encryption
echo "🔐 Encrypting with SSH key..."
age -R "$SSH_KEY" -o "$VAULT_SECRETS/${PROJECT_NAME}.env.enc" "$ENV_FILE"

# Password encryption
echo "🔑 Encrypting with master password..."
age --passphrase -o "$VAULT_SECRETS/${PROJECT_NAME}.env.password.enc" "$ENV_FILE"

echo "✅ Encrypted to vault:"
echo "   - ${PROJECT_NAME}.env.enc (SSH)"
echo "   - ${PROJECT_NAME}.env.password.enc (Password)"
```

### 2. decrypt-env

**Location:** `bin/decrypt-env`

**Usage:**
```bash
decrypt-env <project-name> [output-path]

# Examples:
decrypt-env infrastructure                    # Prints to stdout
decrypt-env infrastructure /tmp/.env          # Writes to file
decrypt-env infrastructure > .env             # Redirect to file
```

**Behavior:**
1. Locates encrypted file in vault
2. Auto-detects SSH vs password encryption
3. Decrypts using appropriate method
4. Outputs to stdout or specified file

**Implementation:**
```bash
#!/bin/bash
set -e

PROJECT_NAME="$1"
OUTPUT="${2:--}"  # Default to stdout
VAULT_SECRETS="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/rhncrs-collab/9_System/Secrets"
SSH_KEY="$HOME/.ssh/id_ed25519"

# Try SSH key first (silent, for automation)
if [ -f "$VAULT_SECRETS/${PROJECT_NAME}.env.enc" ]; then
    age -d -i "$SSH_KEY" "$VAULT_SECRETS/${PROJECT_NAME}.env.enc" 2>/dev/null > "$OUTPUT" && exit 0
fi

# Fallback to password
if [ -f "$VAULT_SECRETS/${PROJECT_NAME}.env.password.enc" ]; then
    echo "🔑 SSH key failed, using password..." >&2
    age -d "$VAULT_SECRETS/${PROJECT_NAME}.env.password.enc" > "$OUTPUT"
else
    echo "Error: No encrypted file found for: $PROJECT_NAME" >&2
    exit 1
fi
```

### 3. vault-secrets

**Location:** `bin/vault-secrets`

**Usage:**
```bash
vault-secrets list                    # List all encrypted secrets
vault-secrets edit <project-name>     # Decrypt, edit, re-encrypt
vault-secrets validate                # Check all files decrypt successfully
vault-secrets info <project-name>     # Show metadata (size, modified date)
```

**Behavior:**

**list:**
```bash
# Output:
🔐 Encrypted Secrets in Vault:

infrastructure.env.enc          (Modified: 2025-12-12)
  └─ infrastructure.env.password.enc
rhinocrash.env.enc              (Modified: 2025-12-10)
  └─ rhinocrash.env.password.enc
shared-secrets.env.enc          (Modified: 2025-12-01)
  └─ shared-secrets.env.password.enc

Total: 3 projects, 6 files
```

**edit:**
1. Decrypts to temp file
2. Opens in $EDITOR (vim, nano, code)
3. On save, re-encrypts both versions
4. Updates vault files
5. Logs change to `40_Logs/Daily_Notes/`

**validate:**
- Attempts to decrypt all .env.enc files
- Reports any corruption or key issues
- Useful after vault sync conflicts

### 4. infra-pull

**Location:** `bin/infra-pull`

**Usage:**
```bash
infra-pull [--force]  # Runs manually or via launchd daily
```

**Behavior:**
1. SSH to VPS (188.245.183.171)
2. Collects current state:
   - `docker ps` (running containers)
   - `systemctl list-units --state=running` (services)
   - `nginx -T` (nginx config)
   - Finds all .env files in `/root/*/` directories
3. Encrypts .env files and stores in vault
4. Generates `1_Projects/Infrastructure/CURRENT_STATE.md`
5. Appends summary to daily log
6. Checks for conflicts (vault edited + VPS changed)
7. Sends macOS notification

**Implementation:**
```bash
#!/bin/bash
set -e

VPS="root@188.245.183.171"
VAULT_BASE="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/rhncrs-collab"
STATE_FILE="$VAULT_BASE/1_Projects/Infrastructure/CURRENT_STATE.md"
LOG_FILE="$VAULT_BASE/40_Logs/Daily_Notes/$(date +%Y-%m-%d).md"

echo "🔄 Pulling infrastructure state from VPS..."

# Collect state
DOCKER_STATE=$(ssh $VPS "docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'")
SERVICES=$(ssh $VPS "systemctl list-units --type=service --state=running | grep -E '(docker|nginx|rhino)'")

# Find and encrypt .env files
ssh $VPS "find /root -name '.env' -type f" | while read -r env_path; do
    project=$(basename $(dirname "$env_path"))
    scp "$VPS:$env_path" /tmp/pulled.env
    encrypt-env "$project" /tmp/pulled.env
    rm /tmp/pulled.env
done

# Generate CURRENT_STATE.md
cat > "$STATE_FILE" << EOF
# Infrastructure Current State
*Last Updated: $(date '+%Y-%m-%d %H:%M:%S')* (auto-generated)

## Running Services (rhncrs.com)

### Docker Containers
\`\`\`
$DOCKER_STATE
\`\`\`

### System Services
\`\`\`
$SERVICES
\`\`\`

## Environment Variables
$(vault-secrets list | grep -E '\.env\.enc')

[Manage Secrets] → [[9_System/Secrets/README]]
EOF

# Log sync
echo "## Infrastructure Sync - $(date '+%H:%M')" >> "$LOG_FILE"
echo "✅ Pulled latest state from VPS" >> "$LOG_FILE"

# Notify
osascript -e 'display notification "Infrastructure synced successfully" with title "rhncrs.com"'
```

### 5. infra-push

**Location:** `bin/infra-push`

**Usage:**
```bash
infra-push <project-name>

# Example:
infra-push infrastructure  # Deploys infrastructure.env to VPS
```

**Behavior:**
1. Decrypts specified .env from vault
2. SCPs to VPS at `/root/<project>/.env`
3. Optionally runs deployment command (docker-compose restart, etc.)
4. Updates vault with deployment timestamp
5. Logs to daily notes

**Implementation:**
```bash
#!/bin/bash
set -e

PROJECT_NAME="$1"
VPS="root@188.245.183.171"

if [ -z "$PROJECT_NAME" ]; then
    echo "Usage: infra-push <project-name>"
    exit 1
fi

echo "🚀 Deploying $PROJECT_NAME secrets to VPS..."

# Decrypt to temp file
decrypt-env "$PROJECT_NAME" /tmp/deploy.env

# Deploy
scp /tmp/deploy.env "$VPS:/root/$PROJECT_NAME/.env"
rm /tmp/deploy.env

# Optional: restart service
read -p "Restart service? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ssh $VPS "cd /root/$PROJECT_NAME && docker-compose restart"
fi

echo "✅ Deployed $PROJECT_NAME.env to VPS"
```

---

## Daily Automation

### LaunchAgent Setup

**File:** `~/Library/LaunchAgents/com.rhncrs.infra-sync.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.rhncrs.infra-sync</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/hoe/.local/bin/infra-pull</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>9</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    <key>StandardOutPath</key>
    <string>/tmp/infra-sync.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/infra-sync.error.log</string>
</dict>
</plist>
```

**Installation:**
```bash
cp ~/Library/LaunchAgents/com.rhncrs.infra-sync.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.rhncrs.infra-sync.plist
```

---

## iPhone Workflow

### Setup

1. **Install `a-Shell`** (App Store) - Provides `age` binary on iOS
2. **Install Obsidian Mobile** - Access vault files
3. **Create Shortcuts:**

**Shortcut: "Decrypt Secret"**
```
Input: Text (from clipboard or manual entry)
Action 1: Show prompt "Enter master password"
Action 2: Run a-Shell command: age -d -p
Action 3: Show result in Quick Look
```

### Usage

1. Open Obsidian Mobile → `9_System/Secrets/infrastructure.env.password.enc`
2. Long-press file content → Copy
3. Run Shortcut "Decrypt Secret"
4. Enter master password
5. View decrypted secrets

**Alternative (Simpler):**
- Just view `CURRENT_STATE.md` for infrastructure overview
- Only decrypt when actually need secret values

---

## Security Considerations

### Threat Model

**Protected Against:**
- ✅ Vault files leaked via iCloud breach (encrypted at rest)
- ✅ Laptop stolen (SSH key encrypted by macOS keychain)
- ✅ iPhone lost (requires master password)
- ✅ Accidental git commit (encrypted files safe in public repos)

**Not Protected Against:**
- ❌ Master password compromised (all password.enc files readable)
- ❌ SSH key + laptop access (full decryption possible)
- ❌ VPS root access (attacker can read running .env files)

### Best Practices

1. **Master Password:**
   - Minimum 20 characters
   - Use passphrase (e.g., "correct-horse-battery-staple-rhino-2025")
   - Store nowhere digital (memorize only)

2. **SSH Key:**
   - Use Ed25519 (modern, secure)
   - Passphrase-protected (macOS keychain unlocks)
   - Never copy private key off Mac

3. **VPS Access:**
   - SSH key authentication only (no password auth)
   - Separate SSH key for VPS (not same as encryption key)
   - Regular security updates

4. **Rotation:**
   - Rotate secrets quarterly
   - Re-encrypt with new keys annually
   - Track rotation in `9_System/Secrets/ROTATION_LOG.md`

---

## Conflict Resolution

### Scenario: Vault & VPS Both Changed

**Detection:**
```bash
# infra-pull detects:
# - infrastructure.env.enc modified 2 hours ago in vault
# - /root/infrastructure/.env modified 1 hour ago on VPS
```

**Resolution Workflow:**
1. Auto-creates: `9_System/Collaboration/incidents/conflict-2025-12-12-0930.md`
2. Sends notification: "⚠️ Infrastructure conflict detected"
3. Manual steps:
   ```bash
   # Review vault version
   decrypt-env infrastructure > /tmp/vault-version.env

   # Review VPS version
   ssh root@188.245.183.171 cat /root/infrastructure/.env > /tmp/vps-version.env

   # Compare
   diff /tmp/vault-version.env /tmp/vps-version.env

   # Merge manually, then:
   encrypt-env infrastructure /tmp/merged.env
   infra-push infrastructure
   ```

---

## Testing Plan

### Unit Tests (Manual)

**Test 1: Encrypt/Decrypt Round-Trip**
```bash
echo "TEST_VAR=secret123" > /tmp/test.env
encrypt-env test-project /tmp/test.env
decrypt-env test-project | grep "TEST_VAR=secret123" && echo "✅ PASS"
```

**Test 2: SSH Key Auto-Decrypt**
```bash
# Should succeed without password prompt
decrypt-env test-project > /dev/null && echo "✅ SSH key works"
```

**Test 3: Password Fallback**
```bash
# Temporarily rename .enc file to force password path
mv "$VAULT/test-project.env.enc" "$VAULT/test-project.env.enc.bak"
decrypt-env test-project  # Should prompt for password
```

**Test 4: Daily Sync**
```bash
# Run manually
infra-pull
# Check CURRENT_STATE.md updated
# Check log entry created
```

### Integration Tests

**Test 5: Full Deploy Cycle**
```bash
# Edit secret in vault
vault-secrets edit infrastructure
# Deploy to VPS
infra-push infrastructure
# Verify on VPS
ssh root@188.245.183.171 cat /root/infrastructure/.env
```

---

## Migration Plan

### Phase 1: Setup (Day 1)

1. Install `age`: `brew install age`
2. Create tools: `encrypt-env`, `decrypt-env`, `vault-secrets`
3. Create vault directory: `9_System/Secrets/`
4. Generate master password (20+ chars)
5. Store master password: `echo "your-master-pass" | age -R ~/.ssh/id_ed25519.pub > 9_System/Secrets/MASTER_PASSWORD.txt.enc`

### Phase 2: Encrypt Existing Secrets (Day 1)

1. Find all current .env files:
   ```bash
   find ~/Dev/org -name ".env" -type f
   ```
2. Encrypt each:
   ```bash
   encrypt-env infrastructure ~/Dev/org/infrastructure/.env
   encrypt-env rhinocrash ~/Dev/org/rhinocrash/.env
   # etc.
   ```
3. Verify decryption works
4. **BACKUP** original .env files to external drive
5. Delete unencrypted .env files from disk

### Phase 3: VPS Integration (Day 2)

1. Setup SSH key access to VPS
2. Create `infra-pull` script
3. Run initial pull: `infra-pull`
4. Verify `CURRENT_STATE.md` generated correctly
5. Create `infra-push` script
6. Test deploy cycle

### Phase 4: Automation (Day 3)

1. Create LaunchAgent plist
2. Install and load: `launchctl load ...`
3. Test notification system
4. Monitor first automated run next day

### Phase 5: iPhone Setup (Day 4)

1. Install a-Shell on iPhone
2. Create "Decrypt Secret" shortcut
3. Test decrypting a password.enc file
4. Document workflow in vault README

---

## Documentation

### Files to Create

**`9_System/Secrets/README.md`** - User guide for secrets system
**`1_Projects/Infrastructure/RUNBOOK.md`** - How to deploy changes
**`docs/SECRETS_MANAGEMENT.md`** - Technical reference (this document)

---

## Success Criteria

- ✅ All .env files encrypted and stored in vault
- ✅ Mac auto-decrypts without password prompts
- ✅ iPhone can decrypt with master password
- ✅ Daily VPS sync runs automatically
- ✅ Infrastructure docs stay current (< 24h staleness)
- ✅ Claude & Gemini can decrypt in automation
- ✅ Conflict detection works
- ✅ Deployment to VPS takes < 2 minutes

---

## Future Enhancements

### V2 Features

1. **Multi-VPS Support:** Track dev/staging/prod separately
2. **Secret Rotation Automation:** Auto-rotate API keys quarterly
3. **Audit Log:** Track who decrypted what and when
4. **Shared Secrets Discovery:** Auto-detect common values across .env files
5. **Web UI:** Browser-based secret viewer (auth via SSH key)
6. **Backup Encryption:** Encrypted backups to external drive
7. **Integration with 1Password:** Sync critical secrets to 1Password vault

---

**Design Status:** ✅ Complete
**Next Step:** Implementation
**Estimated Build Time:** 4-6 hours across 5 days (phased)
**Assigned To:** Claude (scripts), Gemini (vault documentation)
