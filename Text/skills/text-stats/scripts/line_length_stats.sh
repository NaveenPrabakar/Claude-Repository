#!/usr/bin/env bash
# Min/max/average line length.
# Usage: line_length_stats.sh <file>
set -euo pipefail
file="${1:?Usage: line_length_stats.sh <file>}"
[[ -f "$file" ]] || { echo "Error: file not found: $file" >&2; exit 1; }
awk '
  { len = length($0); sum += len; n++
    if (n == 1 || len < min) min = len
    if (len > max) max = len }
  END {
    printf "Min: %d\nMax: %d\nAverage: %.2f\n", min, max, (n>0 ? sum/n : 0)
  }
' "$file"
