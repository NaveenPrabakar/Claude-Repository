#!/usr/bin/env bash
# Count how many lines match a pattern.
# Usage: count_matches.sh <file> <pattern>
set -euo pipefail
file="${1:?Usage: count_matches.sh <file> <pattern>}"
pattern="${2:?Usage: count_matches.sh <file> <pattern>}"
[[ -f "$file" ]] || { echo "Error: file not found: $file" >&2; exit 1; }
grep -cE -- "$pattern" "$file"
