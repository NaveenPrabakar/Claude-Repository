#!/usr/bin/env bash
# Sum a numeric column. Assumes no header row unless told otherwise.
# Usage: sum_column.sh <file> <column_num> [delimiter]
set -euo pipefail
file="${1:?Usage: sum_column.sh <file> <column_num> [delimiter]}"
col="${2:?Usage: sum_column.sh <file> <column_num> [delimiter]}"
delim="${3:-,}"
[[ -f "$file" ]] || { echo "Error: file not found: $file" >&2; exit 1; }
awk -F"$delim" -v c="$col" '{ sum += $c } END { print sum }' "$file"
