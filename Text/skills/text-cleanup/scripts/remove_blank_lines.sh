#!/usr/bin/env bash
# Remove all blank/empty lines.
# Usage: remove_blank_lines.sh <file> [output_file]
set -euo pipefail
file="${1:?Usage: remove_blank_lines.sh <file> [output_file]}"
outfile="${2:-}"
[[ -f "$file" ]] || { echo "Error: file not found: $file" >&2; exit 1; }
if [[ -n "$outfile" ]]; then
  sed '/^[[:space:]]*$/d' "$file" > "${outfile}.tmp" && mv "${outfile}.tmp" "$outfile"
  echo "Wrote: $outfile" >&2
else
  sed '/^[[:space:]]*$/d' "$file"
fi
