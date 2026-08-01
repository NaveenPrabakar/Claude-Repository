#!/usr/bin/env bash
# Extract one or more columns by number.
# Usage: extract_columns.sh <file> <column_list> [delimiter]
set -euo pipefail
file="${1:?Usage: extract_columns.sh <file> <column_list> [delimiter]}"
cols="${2:?Usage: extract_columns.sh <file> <column_list> [delimiter]}"
delim="${3:-,}"
[[ -f "$file" ]] || { echo "Error: file not found: $file" >&2; exit 1; }
cut -d"$delim" -f"$cols" "$file"
