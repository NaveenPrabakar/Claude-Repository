#!/usr/bin/env bash
# Convert all text to lowercase.
# Usage: to_lower.sh <file> [output_file]
set -euo pipefail
file="${1:?Usage: to_lower.sh <file> [output_file]}"
outfile="${2:-}"
[[ -f "$file" ]] || { echo "Error: file not found: $file" >&2; exit 1; }
if [[ -n "$outfile" ]]; then
  tr '[:upper:]' '[:lower:]' < "$file" > "${outfile}.tmp" && mv "${outfile}.tmp" "$outfile"
  echo "Wrote: $outfile" >&2
else
  tr '[:upper:]' '[:lower:]' < "$file"
fi
