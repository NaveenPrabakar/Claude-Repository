#!/usr/bin/env bash
# Convert Windows (CRLF) line endings to Unix (LF).
# Usage: crlf_to_lf.sh <file> [output_file]
set -euo pipefail
file="${1:?Usage: crlf_to_lf.sh <file> [output_file]}"
outfile="${2:-}"
[[ -f "$file" ]] || { echo "Error: file not found: $file" >&2; exit 1; }
if [[ -n "$outfile" ]]; then
  sed 's/\r$//' "$file" > "${outfile}.tmp" && mv "${outfile}.tmp" "$outfile"
  echo "Wrote: $outfile" >&2
else
  sed 's/\r$//' "$file"
fi
