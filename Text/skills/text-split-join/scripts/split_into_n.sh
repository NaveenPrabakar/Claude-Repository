#!/usr/bin/env bash
# Split a file into N roughly equal pieces (by line count).
# Usage: split_into_n.sh <file> <num_pieces> [output_prefix]
set -euo pipefail
file="${1:?Usage: split_into_n.sh <file> <num_pieces> [output_prefix]}"
n="${2:?Usage: split_into_n.sh <file> <num_pieces> [output_prefix]}"
prefix="${3:-chunk_}"
[[ -f "$file" ]] || { echo "Error: file not found: $file" >&2; exit 1; }
split -n "l/${n}" -d -a 3 "$file" "$prefix"
echo "Wrote chunks with prefix: $prefix" >&2
ls -1 "${prefix}"* >&2
