#!/usr/bin/env bash
# Print the last N lines.
# Usage: tail_lines.sh <file> <n>
set -euo pipefail
file="${1:?Usage: tail_lines.sh <file> <n>}"
n="${2:?Usage: tail_lines.sh <file> <n>}"
[[ -f "$file" ]] || { echo "Error: file not found: $file" >&2; exit 1; }
tail -n "$n" "$file"
