#!/usr/bin/env bash
# Search for any of several patterns (one per line in a pattern file).
# Usage: multi_pattern.sh <file> <pattern_file>
set -euo pipefail
file="${1:?Usage: multi_pattern.sh <file> <pattern_file>}"
pattern_file="${2:?Usage: multi_pattern.sh <file> <pattern_file>}"
[[ -f "$file" ]] || { echo "Error: file not found: $file" >&2; exit 1; }
[[ -f "$pattern_file" ]] || { echo "Error: pattern file not found: $pattern_file" >&2; exit 1; }
grep -nEf "$pattern_file" -- "$file"
