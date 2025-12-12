#!/bin/bash
# gemini-to-obsidian.sh - Parse Gemini output and write files to Obsidian vault
# Usage: gemini "[prompt]" | ./gemini-to-obsidian.sh /path/to/vault

set -e

VAULT_PATH="${1:-}"
TEMP_OUTPUT="/tmp/gemini-obsidian-output-$$.txt"

if [ -z "$VAULT_PATH" ]; then
    echo "Usage: gemini \"[prompt]\" | $0 /path/to/vault"
    echo "   or: $0 /path/to/vault < gemini-output.txt"
    exit 1
fi

if [ ! -d "$VAULT_PATH" ]; then
    echo "Error: Vault path does not exist: $VAULT_PATH"
    exit 1
fi

echo "Reading Gemini output..."
cat > "$TEMP_OUTPUT"

echo "Parsing files..."
awk -v vault="$VAULT_PATH" '
BEGIN {
    file = ""
    content = ""
    count = 0
}

/^=== FILENAME: / {
    # Write previous file if exists
    if (file != "") {
        filepath = vault "/" file
        # Create parent directory if needed
        cmd = "mkdir -p \"$(dirname \"" filepath "\")\""
        system(cmd)
        # Write content
        print content > filepath
        close(filepath)
        print "Created: " file
        count++
        content = ""
    }
    # Extract new filename
    file = $3
    for (i = 4; i <= NF; i++) {
        file = file " " $i
    }
    next
}

/^===\s*$/ {
    # End of file marker
    if (file != "" && content != "") {
        filepath = vault "/" file
        cmd = "mkdir -p \"$(dirname \"" filepath "\")\""
        system(cmd)
        print content > filepath
        close(filepath)
        print "Created: " file
        count++
        content = ""
        file = ""
    }
    next
}

{
    # Accumulate content
    if (file != "") {
        if (content == "") {
            content = $0
        } else {
            content = content "\n" $0
        }
    }
}

END {
    # Write final file if exists
    if (file != "" && content != "") {
        filepath = vault "/" file
        cmd = "mkdir -p \"$(dirname \"" filepath "\")\""
        system(cmd)
        print content > filepath
        close(filepath)
        print "Created: " file
        count++
    }
    print "\nTotal files created: " count
}
' "$TEMP_OUTPUT"

# Cleanup
rm -f "$TEMP_OUTPUT"

echo "Done! Files written to: $VAULT_PATH"
