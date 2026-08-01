#!/usr/bin/env bash
# Top N most frequent words (lowercased, punctuation stripped).
# Usage: word_frequency.sh <file> [top_n]
set -euo pipefail
file="${1:?Usage: word_frequency.sh <file> [top_n]}"
top_n="${2:-10}"
[[ -f "$file" ]] || { echo "Error: file not found: $file" >&2; exit 1; }
tr '[:upper:]' '[:lower:]' < "$file" \
  | tr -c '[:alnum:]' '\n' \
  | grep -v '^$' \
  | sort \
  | uniq -c \
  | sort -rn \
  | head -n "$top_n"
