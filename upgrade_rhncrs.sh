#!/bin/bash
set -e

# Configuration
VAULT_ROOT="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/rhncrs-collab"
SOURCE_HARDWARE="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/gemini-scribe/10_Projects/11_Rhinoceros/Rhinoceros_Music/Hardware"
SOURCE_WORKSPACE="$HOME/Dev/workspace/collab"
BACKUP_DIR="$HOME/Desktop/rhncrs_backup_$(date +%Y%m%d_%H%M%S)"

echo "🔶 Starting RHNCRS Vault Upgrade..."
echo "📍 Vault Path: $VAULT_ROOT"

# 0. Safety Backup
echo "📦 Creating backup at $BACKUP_DIR..."
cp -R "$VAULT_ROOT" "$BACKUP_DIR"

# Check if Vault exists
if [ ! -d "$VAULT_ROOT" ]; then
    echo "Error: Vault root not found at $VAULT_ROOT"
    exit 1
fi

cd "$VAULT_ROOT"

# 1. Structure Migration (JD -> PARA)
echo "🏗️  Migrating Structure to PARA..."

# Create new PARA roots
mkdir -p "0_Inbox" "1_Projects" "2_Areas" "3_Resources" "4_Archive" "9_System"

# Move 10_Projects -> 1_Projects
if [ -d "10_Projects" ]; then
    echo "   Moving Projects..."
    mv 10_Projects/* 1_Projects/ 2>/dev/null || true
    rmdir 10_Projects 2>/dev/null || true
fi

# Move 20_Domains -> 2_Areas
if [ -d "20_Domains" ]; then
    echo "   Moving Areas..."
    mv 20_Domains/* 2_Areas/ 2>/dev/null || true
    rmdir 20_Domains 2>/dev/null || true
fi

# Move 30_Resources -> 3_Resources
if [ -d "30_Resources" ]; then
    echo "   Moving Resources..."
    mv 30_Resources/* 3_Resources/ 2>/dev/null || true
    rmdir 30_Resources 2>/dev/null || true
fi

# Move 40_Logs -> 9_System/Logs
if [ -d "40_Logs" ]; then
    echo "   Moving Logs..."
    mkdir -p "9_System/Logs"
    mv 40_Logs/* 9_System/Logs/ 2>/dev/null || true
    rmdir 40_Logs 2>/dev/null || true
fi

# Move 90_Admin -> 9_System/Admin
if [ -d "90_Admin" ]; then
    echo "   Moving Admin..."
    mkdir -p "9_System/Admin"
    mv 90_Admin/* 9_System/Admin/ 2>/dev/null || true
    rmdir 90_Admin 2>/dev/null || true
fi

# Move 00_Atlas -> 9_System/Atlas
if [ -d "00_Atlas" ]; then
    echo "   Moving Atlas..."
    mkdir -p "9_System/Atlas"
    mv 00_Atlas/* 9_System/Atlas/ 2>/dev/null || true
    rmdir 00_Atlas 2>/dev/null || true
fi

# 2. Hardware Migration
echo "🔧 Migrating Hardware Docs..."
DEST_HARDWARE="3_Resources/Hardware"
mkdir -p "$DEST_HARDWARE"
if [ -d "$SOURCE_HARDWARE" ]; then
    cp -R "$SOURCE_HARDWARE/"* "$DEST_HARDWARE/" 2>/dev/null || true
    echo "   ✅ Hardware docs migrated."
else
    echo "   ⚠️  Source Hardware docs not found at $SOURCE_HARDWARE"
fi

# 3. Collaboration Workspace Migration
echo "📲 Migrating Collaboration Workspace..."
DEST_WORKSPACE="9_System/Collaboration"
mkdir -p "$DEST_WORKSPACE"
if [ -d "$SOURCE_WORKSPACE" ]; then
    cp -R "$SOURCE_WORKSPACE/"* "$DEST_WORKSPACE/" 2>/dev/null || true
    # Create symlink so old path still works
    rm -rf "$SOURCE_WORKSPACE"
    ln -s "$DEST_WORKSPACE" "$SOURCE_WORKSPACE"
    echo "   ✅ Collaboration workspace migrated and symlinked."
else
    echo "   Creating new collaboration workspace..."
    mkdir -p "$DEST_WORKSPACE/handoffs"
    mkdir -p "$DEST_WORKSPACE/dialogues"
    mkdir -p "$DEST_WORKSPACE/tasks"
fi

# 4. Create Secrets Directory
echo "🔐 Creating Secrets directory..."
mkdir -p "9_System/Secrets"

# 5. Domain Update (rhncrs.com)
echo "🌐 Updating domain references to rhncrs.com..."
find . -name "*.md" -type f -exec sed -i '' 's/genesis-forge\.duckdns\.org/rhncrs.com/g' {} + 2>/dev/null || true
find . -name "*.md" -type f -exec sed -i '' 's/example\.com/rhncrs.com/g' {} + 2>/dev/null || true
find . -name "*.md" -type f -exec sed -i '' 's/your-website\.com/rhncrs.com/g' {} + 2>/dev/null || true

echo ""
echo "✨ Vault Upgrade Complete!"
echo ""
echo "📊 New Structure:"
ls -1 "$VAULT_ROOT" | grep -v "^\."
echo ""
echo "📦 Backup saved at: $BACKUP_DIR"
echo ""
echo "🎯 Next Steps:"
echo "   1. Open Obsidian and verify structure"
echo "   2. Update any broken wikilinks"
echo "   3. Test collaboration workspace sync"
