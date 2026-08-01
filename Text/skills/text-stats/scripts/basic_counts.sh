#!/usr/bin/env bash
# Line, word, character, and byte counts.
# Usage: basic_counts.sh <file>
set -euo pipefail
file="${1:?Usage: basic_counts.sh <file>}"
[[ -f "$file" ]] || { echo "Error: file not found: $file" >&2; exit 1; }
echo "Lines:      $(wc -l < "$file")"
echo "Words:      $(wc -w < "$file")"
echo "Characters: $(wc -m < "$file")"
echo "Bytes:      $(wc -c < "$file")"
