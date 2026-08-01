#!/usr/bin/env bash
# Reverse the order of lines (like tac).
# Usage: reverse_lines.sh <file> [output_file]
set -euo pipefail
file="${1:?Usage: reverse_lines.sh <file> [output_file]}"
outfile="${2:-}"
[[ -f "$file" ]] || { echo "Error: file not found: $file" >&2; exit 1; }
if [[ -n "$outfile" ]]; then
  tac "$file" > "${outfile}.tmp" && mv "${outfile}.tmp" "$outfile"
  echo "Wrote: $outfile" >&2
else
  tac "$file"
fi
