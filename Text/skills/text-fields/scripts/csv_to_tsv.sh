#!/usr/bin/env bash
# Convert comma-delimited to tab-delimited.
# Usage: csv_to_tsv.sh <file> [output_file]
set -euo pipefail
file="${1:?Usage: csv_to_tsv.sh <file> [output_file]}"
outfile="${2:-}"
[[ -f "$file" ]] || { echo "Error: file not found: $file" >&2; exit 1; }
if [[ -n "$outfile" ]]; then
  awk -F',' -v OFS='\t' '{$1=$1; print}' "$file" > "${outfile}.tmp" && mv "${outfile}.tmp" "$outfile"
  echo "Wrote: $outfile" >&2
else
  awk -F',' -v OFS='\t' '{$1=$1; print}' "$file"
fi
