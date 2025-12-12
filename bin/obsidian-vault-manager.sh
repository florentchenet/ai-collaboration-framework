#!/bin/bash
# obsidian-vault-manager.sh - Comprehensive vault management tool for Gemini
# Provides Gemini with full access to read, write, and manage Obsidian vault files

VAULT_PATH="/Users/hoe/Library/Mobile Documents/iCloud~md~obsidian/Documents/rhncrs-collab"

usage() {
    cat << EOF
Obsidian Vault Manager - Full vault access for Gemini

USAGE:
    $(basename "$0") <command> [args...]

COMMANDS:
    write <file> <content>       Write content to file (creates parent dirs)
    read <file>                  Read file content
    list [dir]                   List files in directory (default: vault root)
    tree [dir] [depth]           Show directory tree (default depth: 3)
    mkdir <dir>                  Create directory
    mv <src> <dest>              Move/rename file or directory
    rm <file>                    Remove file
    exists <file>                Check if file exists (exit code 0 = exists)
    structure                    Show complete vault structure
    stats                        Show vault statistics

VAULT LOCATION:
    $VAULT_PATH

EXAMPLES:
    # Write a file
    $(basename "$0") write "10_Projects/README.md" "# Project Documentation"

    # Read a file
    $(basename "$0") read "00_Atlas/000_Home.md"

    # List directory
    $(basename "$0") list "10_Projects"

    # Show tree
    $(basename "$0") tree "00_Atlas" 2

EOF
    exit 1
}

# Ensure vault exists
if [ ! -d "$VAULT_PATH" ]; then
    echo "Error: Vault does not exist at: $VAULT_PATH"
    exit 1
fi

# Command handling
cmd="${1:-}"
shift || true

case "$cmd" in
    write)
        file="$1"
        content="$2"
        if [ -z "$file" ]; then
            echo "Error: No file specified"
            usage
        fi
        filepath="$VAULT_PATH/$file"
        mkdir -p "$(dirname "$filepath")"
        echo "$content" > "$filepath"
        echo "✓ Written: $file"
        ;;

    read)
        file="$1"
        if [ -z "$file" ]; then
            echo "Error: No file specified"
            usage
        fi
        filepath="$VAULT_PATH/$file"
        if [ ! -f "$filepath" ]; then
            echo "Error: File does not exist: $file"
            exit 1
        fi
        cat "$filepath"
        ;;

    list)
        dir="${1:-.}"
        dirpath="$VAULT_PATH/$dir"
        if [ ! -d "$dirpath" ]; then
            echo "Error: Directory does not exist: $dir"
            exit 1
        fi
        ls -lh "$dirpath"
        ;;

    tree)
        dir="${1:-.}"
        depth="${2:-3}"
        dirpath="$VAULT_PATH/$dir"
        if [ ! -d "$dirpath" ]; then
            echo "Error: Directory does not exist: $dir"
            exit 1
        fi
        if command -v tree &> /dev/null; then
            tree -L "$depth" "$dirpath"
        else
            find "$dirpath" -maxdepth "$depth" -type d | sort
        fi
        ;;

    mkdir)
        dir="$1"
        if [ -z "$dir" ]; then
            echo "Error: No directory specified"
            usage
        fi
        dirpath="$VAULT_PATH/$dir"
        mkdir -p "$dirpath"
        echo "✓ Created: $dir"
        ;;

    mv)
        src="$1"
        dest="$2"
        if [ -z "$src" ] || [ -z "$dest" ]; then
            echo "Error: Source and destination required"
            usage
        fi
        srcpath="$VAULT_PATH/$src"
        destpath="$VAULT_PATH/$dest"
        if [ ! -e "$srcpath" ]; then
            echo "Error: Source does not exist: $src"
            exit 1
        fi
        mkdir -p "$(dirname "$destpath")"
        mv "$srcpath" "$destpath"
        echo "✓ Moved: $src → $dest"
        ;;

    rm)
        file="$1"
        if [ -z "$file" ]; then
            echo "Error: No file specified"
            usage
        fi
        filepath="$VAULT_PATH/$file"
        if [ ! -e "$filepath" ]; then
            echo "Error: File does not exist: $file"
            exit 1
        fi
        rm -rf "$filepath"
        echo "✓ Removed: $file"
        ;;

    exists)
        file="$1"
        if [ -z "$file" ]; then
            echo "Error: No file specified"
            usage
        fi
        filepath="$VAULT_PATH/$file"
        if [ -e "$filepath" ]; then
            echo "✓ Exists: $file"
            exit 0
        else
            echo "✗ Does not exist: $file"
            exit 1
        fi
        ;;

    structure)
        echo "RHNCRS-COLLAB Vault Structure:"
        echo "=============================="
        echo
        if command -v tree &> /dev/null; then
            tree -L 2 -d "$VAULT_PATH"
        else
            find "$VAULT_PATH" -maxdepth 2 -type d | sort
        fi
        ;;

    stats)
        echo "Vault Statistics"
        echo "================"
        echo "Location: $VAULT_PATH"
        echo
        echo "Files by type:"
        find "$VAULT_PATH" -type f | grep -o '\.[^.]*$' | sort | uniq -c | sort -rn
        echo
        echo "Total files: $(find "$VAULT_PATH" -type f | wc -l)"
        echo "Total directories: $(find "$VAULT_PATH" -type d | wc -l)"
        echo "Markdown files: $(find "$VAULT_PATH" -name "*.md" | wc -l)"
        echo
        echo "Vault size:"
        du -sh "$VAULT_PATH"
        ;;

    *)
        echo "Error: Unknown command: $cmd"
        usage
        ;;
esac
