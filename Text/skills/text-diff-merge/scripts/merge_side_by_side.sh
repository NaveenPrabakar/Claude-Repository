#!/usr/bin/env bash
# Paste two files column-by-column.
# Usage: merge_side_by_side.sh <file1> <file2> [delimiter]
set -euo pipefail
f1="${1:?Usage: merge_side_by_side.sh <file1> <file2> [delimiter]}"
f2="${2:?Usage: merge_side_by_side.sh <file1> <file2> [delimiter]}"
delim="${3:-\t}"
[[ -f "$f1" ]] || { echo "Error: file not found: $f1" >&2; exit 1; }
[[ -f "$f2" ]] || { echo "Error: file not found: $f2" >&2; exit 1; }
paste -d"$delim" "$f1" "$f2"
