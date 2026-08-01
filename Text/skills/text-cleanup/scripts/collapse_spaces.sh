#!/usr/bin/env bash
# Collapse multiple internal spaces into a single space.
# Usage: collapse_spaces.sh <file> [output_file]
set -euo pipefail
file="${1:?Usage: collapse_spaces.sh <file> [output_file]}"
outfile="${2:-}"
[[ -f "$file" ]] || { echo "Error: file not found: $file" >&2; exit 1; }
if [[ -n "$outfile" ]]; then
  sed -E 's/ +/ /g' "$file" > "${outfile}.tmp" && mv "${outfile}.tmp" "$outfile"
  echo "Wrote: $outfile" >&2
else
  sed -E 's/ +/ /g' "$file"
fi
