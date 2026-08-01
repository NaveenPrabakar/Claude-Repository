#!/usr/bin/env bash
# Print lines between a start and end pattern (inclusive).
# Usage: between_patterns.sh <file> <start_pattern> <end_pattern>
set -euo pipefail
file="${1:?Usage: between_patterns.sh <file> <start_pattern> <end_pattern>}"
start="${2:?Usage: between_patterns.sh <file> <start_pattern> <end_pattern>}"
end="${3:?Usage: between_patterns.sh <file> <start_pattern> <end_pattern>}"
[[ -f "$file" ]] || { echo "Error: file not found: $file" >&2; exit 1; }
sed -n -E "/${start}/,/${end}/p" "$file"
