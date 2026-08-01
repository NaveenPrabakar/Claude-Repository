#!/usr/bin/env bash
# Print lines matching a pattern, with optional context lines.
# Usage: find_matches.sh <file> <pattern> [context_lines]
set -euo pipefail
file="${1:?Usage: find_matches.sh <file> <pattern> [context_lines]}"
pattern="${2:?Usage: find_matches.sh <file> <pattern> [context_lines]}"
context="${3:-0}"
[[ -f "$file" ]] || { echo "Error: file not found: $file" >&2; exit 1; }
grep -nE -C "$context" -- "$pattern" "$file"
