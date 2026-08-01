#!/usr/bin/env bash
# Split a file into chunks of N lines each.
# Usage: split_by_lines.sh <file> <lines_per_chunk> [output_prefix]
set -euo pipefail
file="${1:?Usage: split_by_lines.sh <file> <lines_per_chunk> [output_prefix]}"
n="${2:?Usage: split_by_lines.sh <file> <lines_per_chunk> [output_prefix]}"
prefix="${3:-chunk_}"
[[ -f "$file" ]] || { echo "Error: file not found: $file" >&2; exit 1; }
split -l "$n" -d -a 3 "$file" "$prefix"
echo "Wrote chunks with prefix: $prefix" >&2
ls -1 "${prefix}"* >&2
