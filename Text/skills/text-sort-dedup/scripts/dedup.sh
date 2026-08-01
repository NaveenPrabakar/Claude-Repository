#!/usr/bin/env bash
# Remove duplicate lines, keep first occurrence, preserve original order.
# Usage: dedup.sh <file> [output_file]
set -euo pipefail
file="${1:?Usage: dedup.sh <file> [output_file]}"
outfile="${2:-}"
[[ -f "$file" ]] || { echo "Error: file not found: $file" >&2; exit 1; }
if [[ -n "$outfile" ]]; then
  awk '!seen[$0]++' "$file" > "${outfile}.tmp" && mv "${outfile}.tmp" "$outfile"
  echo "Wrote: $outfile" >&2
else
  awk '!seen[$0]++' "$file"
fi
