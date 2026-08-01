#!/usr/bin/env bash
# Remove non-ASCII/non-printable characters. Destructive for non-English text - confirm with user first.
# Usage: strip_non_ascii.sh <file> [output_file]
set -euo pipefail
file="${1:?Usage: strip_non_ascii.sh <file> [output_file]}"
outfile="${2:-}"
[[ -f "$file" ]] || { echo "Error: file not found: $file" >&2; exit 1; }
if [[ -n "$outfile" ]]; then
  tr -cd '\11\12\15\40-\176' < "$file" > "${outfile}.tmp" && mv "${outfile}.tmp" "$outfile"
  echo "Wrote: $outfile" >&2
else
  tr -cd '\11\12\15\40-\176' < "$file"
fi
