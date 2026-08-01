#!/usr/bin/env bash
# Count how many times each unique line appears, most frequent first.
# Usage: count_occurrences.sh <file>
set -euo pipefail
file="${1:?Usage: count_occurrences.sh <file>}"
[[ -f "$file" ]] || { echo "Error: file not found: $file" >&2; exit 1; }
sort "$file" | uniq -c | sort -rn
