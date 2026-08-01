#!/usr/bin/env bash
# Strip leading/trailing whitespace from every line.
# Usage: trim_whitespace.sh <file> [output_file]
set -euo pipefail
file="${1:?Usage: trim_whitespace.sh <file> [output_file]}"
outfile="${2:-}"
[[ -f "$file" ]] || { echo "Error: file not found: $file" >&2; exit 1; }
if [[ -n "$outfile" ]]; then
  sed -E 's/^[[:space:]]+|[[:space:]]+$//g' "$file" > "${outfile}.tmp" && mv "${outfile}.tmp" "$outfile"
  echo "Wrote: $outfile" >&2
else
  sed -E 's/^[[:space:]]+|[[:space:]]+$//g' "$file"
fi
