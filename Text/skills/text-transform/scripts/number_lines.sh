#!/usr/bin/env bash
# Prefix each line with its line number.
# Usage: number_lines.sh <file> [output_file]
set -euo pipefail
file="${1:?Usage: number_lines.sh <file> [output_file]}"
outfile="${2:-}"
[[ -f "$file" ]] || { echo "Error: file not found: $file" >&2; exit 1; }
if [[ -n "$outfile" ]]; then
  nl -ba -w1 -s': ' "$file" > "${outfile}.tmp" && mv "${outfile}.tmp" "$outfile"
  echo "Wrote: $outfile" >&2
else
  nl -ba -w1 -s': ' "$file"
fi
