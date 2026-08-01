#!/usr/bin/env bash
# Print the first N lines.
# Usage: head_lines.sh <file> <n>
set -euo pipefail
file="${1:?Usage: head_lines.sh <file> <n>}"
n="${2:?Usage: head_lines.sh <file> <n>}"
[[ -f "$file" ]] || { echo "Error: file not found: $file" >&2; exit 1; }
head -n "$n" "$file"
