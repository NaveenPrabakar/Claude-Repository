#!/usr/bin/env bash
# Side-by-side diff.
# Usage: diff_side_by_side.sh <file1> <file2>
set -euo pipefail
f1="${1:?Usage: diff_side_by_side.sh <file1> <file2>}"
f2="${2:?Usage: diff_side_by_side.sh <file1> <file2>}"
[[ -f "$f1" ]] || { echo "Error: file not found: $f1" >&2; exit 1; }
[[ -f "$f2" ]] || { echo "Error: file not found: $f2" >&2; exit 1; }
diff -y "$f1" "$f2" || true
