#!/usr/bin/env bash
# Unified diff between two files.
# Usage: diff_files.sh <file1> <file2>
set -euo pipefail
f1="${1:?Usage: diff_files.sh <file1> <file2>}"
f2="${2:?Usage: diff_files.sh <file1> <file2>}"
[[ -f "$f1" ]] || { echo "Error: file not found: $f1" >&2; exit 1; }
[[ -f "$f2" ]] || { echo "Error: file not found: $f2" >&2; exit 1; }
diff -u "$f1" "$f2" || true
