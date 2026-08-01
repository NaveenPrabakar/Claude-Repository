#!/usr/bin/env bash
# Convert all text to uppercase.
# Usage: to_upper.sh <file> [output_file]
set -euo pipefail
file="${1:?Usage: to_upper.sh <file> [output_file]}"
outfile="${2:-}"
[[ -f "$file" ]] || { echo "Error: file not found: $file" >&2; exit 1; }
if [[ -n "$outfile" ]]; then
  tr '[:lower:]' '[:upper:]' < "$file" > "${outfile}.tmp" && mv "${outfile}.tmp" "$outfile"
  echo "Wrote: $outfile" >&2
else
  tr '[:lower:]' '[:upper:]' < "$file"
fi
