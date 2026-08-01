#!/usr/bin/env bash
# Average a numeric column. Assumes no header row unless told otherwise.
# Usage: avg_column.sh <file> <column_num> [delimiter]
set -euo pipefail
file="${1:?Usage: avg_column.sh <file> <column_num> [delimiter]}"
col="${2:?Usage: avg_column.sh <file> <column_num> [delimiter]}"
delim="${3:-,}"
[[ -f "$file" ]] || { echo "Error: file not found: $file" >&2; exit 1; }
awk -F"$delim" -v c="$col" '{ sum += $c; n++ } END { if (n>0) print sum/n; else print 0 }' "$file"
