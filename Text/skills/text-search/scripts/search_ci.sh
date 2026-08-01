#!/usr/bin/env bash
# Case-insensitive search with line numbers.
# Usage: search_ci.sh <file> <pattern>
set -euo pipefail
file="${1:?Usage: search_ci.sh <file> <pattern>}"
pattern="${2:?Usage: search_ci.sh <file> <pattern>}"
[[ -f "$file" ]] || { echo "Error: file not found: $file" >&2; exit 1; }
grep -inE -- "$pattern" "$file"
