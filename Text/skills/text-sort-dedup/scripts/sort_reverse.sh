#!/usr/bin/env bash
# Sort lines in descending order.
# Usage: sort_reverse.sh <file> [output_file]
set -euo pipefail
file="${1:?Usage: sort_reverse.sh <file> [output_file]}"
outfile="${2:-}"
[[ -f "$file" ]] || { echo "Error: file not found: $file" >&2; exit 1; }
if [[ -n "$outfile" ]]; then
  sort -r "$file" > "${outfile}.tmp" && mv "${outfile}.tmp" "$outfile"
  echo "Wrote: $outfile" >&2
else
  sort -r "$file"
fi
