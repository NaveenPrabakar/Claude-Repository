#!/usr/bin/env bash
# Convert tab-delimited to comma-delimited.
# Usage: tsv_to_csv.sh <file> [output_file]
set -euo pipefail
file="${1:?Usage: tsv_to_csv.sh <file> [output_file]}"
outfile="${2:-}"
[[ -f "$file" ]] || { echo "Error: file not found: $file" >&2; exit 1; }
if [[ -n "$outfile" ]]; then
  awk -F'\t' -v OFS=',' '{$1=$1; print}' "$file" > "${outfile}.tmp" && mv "${outfile}.tmp" "$outfile"
  echo "Wrote: $outfile" >&2
else
  awk -F'\t' -v OFS=',' '{$1=$1; print}' "$file"
fi
