#!/usr/bin/env bash
# Sort lines numerically.
# Usage: sort_numeric.sh <file> [output_file]
set -euo pipefail
file="${1:?Usage: sort_numeric.sh <file> [output_file]}"
outfile="${2:-}"
[[ -f "$file" ]] || { echo "Error: file not found: $file" >&2; exit 1; }
if [[ -n "$outfile" ]]; then
  sort -n "$file" > "${outfile}.tmp" && mv "${outfile}.tmp" "$outfile"
  echo "Wrote: $outfile" >&2
else
  sort -n "$file"
fi
