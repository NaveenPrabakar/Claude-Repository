#!/usr/bin/env bash
# Extract a column by its header name (first row is treated as header).
# Usage: extract_by_header.sh <file> <header_name> [delimiter]
set -euo pipefail
file="${1:?Usage: extract_by_header.sh <file> <header_name> [delimiter]}"
header="${2:?Usage: extract_by_header.sh <file> <header_name> [delimiter]}"
delim="${3:-,}"
[[ -f "$file" ]] || { echo "Error: file not found: $file" >&2; exit 1; }
awk -F"$delim" -v target="$header" '
  NR==1 {
    for (i=1; i<=NF; i++) if ($i == target) col = i
    if (!col) { print "Error: header not found: " target > "/dev/stderr"; exit 1 }
    next
  }
  { print $col }
' "$file"
