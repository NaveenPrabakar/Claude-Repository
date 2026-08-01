#!/usr/bin/env bash
# Print lines NOT matching a pattern.
# Usage: find_exclude.sh <file> <pattern>
set -euo pipefail
file="${1:?Usage: find_exclude.sh <file> <pattern>}"
pattern="${2:?Usage: find_exclude.sh <file> <pattern>}"
[[ -f "$file" ]] || { echo "Error: file not found: $file" >&2; exit 1; }
grep -nEv -- "$pattern" "$file"
