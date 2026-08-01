#!/usr/bin/env bash
# Print the longest line and its length.
# Usage: longest_line.sh <file>
set -euo pipefail
file="${1:?Usage: longest_line.sh <file>}"
[[ -f "$file" ]] || { echo "Error: file not found: $file" >&2; exit 1; }
awk '{ if (length($0) > maxlen) { maxlen = length($0); maxline = $0 } } END { print "Length: " maxlen; print maxline }' "$file"
