#!/usr/bin/env bash
# Reorder columns into a new sequence.
# Usage: reorder_columns.sh <file> <column_order> [delimiter]
set -euo pipefail
file="${1:?Usage: reorder_columns.sh <file> <column_order> [delimiter]}"
order="${2:?Usage: reorder_columns.sh <file> <column_order> [delimiter]}"
delim="${3:-,}"
[[ -f "$file" ]] || { echo "Error: file not found: $file" >&2; exit 1; }
awk -F"$delim" -v OFS="$delim" -v order="$order" '
  BEGIN { n = split(order, idx, ",") }
  {
    out = ""
    for (i=1; i<=n; i++) out = out (i>1 ? OFS : "") $(idx[i])
    print out
  }
' "$file"
