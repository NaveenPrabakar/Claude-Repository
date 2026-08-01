#!/usr/bin/env bash
# Lines only in file2. Both inputs must be pre-sorted.
# Usage: unique_to_second.sh <file1> <file2>
set -euo pipefail
f1="${1:?Usage: unique_to_second.sh <file1> <file2>}"
f2="${2:?Usage: unique_to_second.sh <file1> <file2>}"
[[ -f "$f1" ]] || { echo "Error: file not found: $f1" >&2; exit 1; }
[[ -f "$f2" ]] || { echo "Error: file not found: $f2" >&2; exit 1; }
comm -13 "$f1" "$f2"
