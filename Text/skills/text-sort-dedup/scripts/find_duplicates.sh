#!/usr/bin/env bash
# Print only lines that appear more than once in the file.
# Usage: find_duplicates.sh <file>
set -euo pipefail
file="${1:?Usage: find_duplicates.sh <file>}"
[[ -f "$file" ]] || { echo "Error: file not found: $file" >&2; exit 1; }
sort "$file" | uniq -d
