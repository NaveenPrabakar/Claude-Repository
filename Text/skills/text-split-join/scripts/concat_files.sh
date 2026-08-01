#!/usr/bin/env bash
# Concatenate multiple files into one, in the given order.
# Usage: concat_files.sh <output_file> <file1> [file2 ...]
set -euo pipefail
outfile="${1:?Usage: concat_files.sh <output_file> <file1> [file2 ...]}"
shift
[[ $# -ge 1 ]] || { echo "Error: at least one input file required" >&2; exit 1; }
for f in "$@"; do
  [[ -f "$f" ]] || { echo "Error: file not found: $f" >&2; exit 1; }
done
cat "$@" > "$outfile"
echo "Wrote: $outfile ($(wc -l < "$outfile") lines)" >&2
