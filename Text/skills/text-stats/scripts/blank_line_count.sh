#!/usr/bin/env bash
# Count blank lines.
# Usage: blank_line_count.sh <file>
set -euo pipefail
file="${1:?Usage: blank_line_count.sh <file>}"
[[ -f "$file" ]] || { echo "Error: file not found: $file" >&2; exit 1; }
grep -c '^[[:space:]]*$' "$file" || true
