#!/usr/bin/env bash
# Sort by a specific delimited column.
# Usage: sort_by_column.sh <file> <column_num> [delimiter] [output_file]
set -euo pipefail
file="${1:?Usage: sort_by_column.sh <file> <column_num> [delimiter] [output_file]}"
col="${2:?Usage: sort_by_column.sh <file> <column_num> [delimiter] [output_file]}"
delim="${3:- }"
outfile="${4:-}"
[[ -f "$file" ]] || { echo "Error: file not found: $file" >&2; exit 1; }
if [[ -n "$outfile" ]]; then
  sort -t"$delim" -k"${col},${col}" "$file" > "${outfile}.tmp" && mv "${outfile}.tmp" "$outfile"
  echo "Wrote: $outfile" >&2
else
  sort -t"$delim" -k"${col},${col}" "$file"
fi
