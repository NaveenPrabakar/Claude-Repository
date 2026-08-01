#!/usr/bin/env bash
# Remove duplicate lines after sorting (classic sort | uniq). Output order is sorted, not original.
# Usage: dedup_sorted.sh <file> [output_file]
set -euo pipefail
file="${1:?Usage: dedup_sorted.sh <file> [output_file]}"
outfile="${2:-}"
[[ -f "$file" ]] || { echo "Error: file not found: $file" >&2; exit 1; }
if [[ -n "$outfile" ]]; then
  sort "$file" | uniq > "${outfile}.tmp" && mv "${outfile}.tmp" "$outfile"
  echo "Wrote: $outfile" >&2
else
  sort "$file" | uniq
fi
