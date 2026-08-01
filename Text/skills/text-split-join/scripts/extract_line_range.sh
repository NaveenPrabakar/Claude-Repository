#!/usr/bin/env bash
# Extract a specific 1-indexed, inclusive range of lines.
# Usage: extract_line_range.sh <file> <start_line> <end_line>
set -euo pipefail
file="${1:?Usage: extract_line_range.sh <file> <start_line> <end_line>}"
start="${2:?Usage: extract_line_range.sh <file> <start_line> <end_line>}"
end="${3:?Usage: extract_line_range.sh <file> <start_line> <end_line>}"
[[ -f "$file" ]] || { echo "Error: file not found: $file" >&2; exit 1; }
sed -n "${start},${end}p" "$file"
