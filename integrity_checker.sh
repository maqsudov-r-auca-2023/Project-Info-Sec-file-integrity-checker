#!/bin/bash

# ===== Colors =====
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
RESET="\e[0m"

# ===== Config =====
HASH_FILE="/home/vagrant/file-integrity-checker/hashes.db"
LOG_FILE="./integrity_check.log"

# ===== Usage =====
if [ "$#" -lt 1 ]; then
    echo -e "${YELLOW}⚠️  Usage: $0 [--init] [file1] [file2] ...${RESET}"
    exit 1
fi

# ===== Rebuild Hash Database =====
if [ "$1" == "--init" ]; then
    echo -e "${YELLOW}⚡ Rebuilding hashes...${RESET}"
    > "$HASH_FILE"  # Clear old hashes
    shift  # Skip the --init argument
    for file in "$@"; do
        if [ -f "$file" ]; then
            sha256sum "$file" >> "$HASH_FILE"
            echo -e "${GREEN}Added: $file${RESET}"
        else
            echo -e "${RED}File not found: $file${RESET}"
        fi
    done
    echo -e "${GREEN}✅ Hash database rebuilt.${RESET}"
    exit 0
fi

# ===== Integrity Check =====
echo -e "${YELLOW}🔍 Checking file integrity...${RESET}"
while read -r old_hash old_file; do
    if [ -f "$old_file" ]; then
        new_hash=$(sha256sum "$old_file" | awk '{print $1}')
        if [ "$old_hash" != "$new_hash" ]; then
            echo -e "${RED}🚨 WARNING: File changed -> $old_file${RESET}"
            echo "$(date): File changed -> $old_file" >> "$LOG_FILE"
        fi
    else
        echo -e "${RED}⚠️ WARNING: File missing -> $old_file${RESET}"
        echo "$(date): File missing -> $old_file" >> "$LOG_FILE"
    fi
done < "$HASH_FILE"

echo -e "${GREEN}✅ Integrity check completed.${RESET}"
