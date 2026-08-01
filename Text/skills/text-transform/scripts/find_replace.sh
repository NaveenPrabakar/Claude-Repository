#!/usr/bin/env bash
# Substitute every occurrence of a pattern with a replacement.
# Usage: find_replace.sh <file> <pattern> <replacement> [output_file]
set -euo pipefail
file="${1:?Usage: find_replace.sh <file> <pattern> <replacement> [output_file]}"
pattern="${2:?Usage: find_replace.sh <file> <pattern> <replacement> [output_file]}"
replacement="${3:?Usage: find_replace.sh <file> <pattern> <replacement> [output_file]}"
outfile="${4:-}"
[[ -f "$file" ]] || { echo "Error: file not found: $file" >&2; exit 1; }

if [[ -n "$outfile" && "$outfile" == "$file" ]]; then
  tmp="$(mktemp)"
  sed -E "s/${pattern}/${replacement}/g" "$file" > "$tmp"
  mv "$tmp" "$outfile"
  echo "Wrote in place: $outfile" >&2
elif [[ -n "$outfile" ]]; then
  sed -E "s/${pattern}/${replacement}/g" "$file" > "$outfile"
  echo "Wrote: $outfile" >&2
else
  sed -E "s/${pattern}/${replacement}/g" "$file"
fi
