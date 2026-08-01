#!/usr/bin/env bash
# Collapse runs of consecutive blank lines into a single blank line.
# Usage: collapse_blank_lines.sh <file> [output_file]
set -euo pipefail
file="${1:?Usage: collapse_blank_lines.sh <file> [output_file]}"
outfile="${2:-}"
[[ -f "$file" ]] || { echo "Error: file not found: $file" >&2; exit 1; }
if [[ -n "$outfile" ]]; then
  cat -s "$file" > "${outfile}.tmp" && mv "${outfile}.tmp" "$outfile"
  echo "Wrote: $outfile" >&2
else
  cat -s "$file"
fi
