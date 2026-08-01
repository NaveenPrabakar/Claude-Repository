#!/usr/bin/env bash
# Print the shortest non-empty line and its length.
# Usage: shortest_line.sh <file>
set -euo pipefail
file="${1:?Usage: shortest_line.sh <file>}"
[[ -f "$file" ]] || { echo "Error: file not found: $file" >&2; exit 1; }
awk 'length($0) > 0 && (minlen == 0 || length($0) < minlen) { minlen = length($0); minline = $0 } END { print "Length: " minlen; print minline }' "$file"
