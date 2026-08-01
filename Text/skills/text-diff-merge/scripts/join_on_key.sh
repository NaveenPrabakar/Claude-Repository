#!/usr/bin/env bash
# Join two delimited files on a common key column. Both must be sorted on that key.
# Usage: join_on_key.sh <file1> <file2> <key_col> [delimiter]
set -euo pipefail
f1="${1:?Usage: join_on_key.sh <file1> <file2> <key_col> [delimiter]}"
f2="${2:?Usage: join_on_key.sh <file1> <file2> <key_col> [delimiter]}"
key_col="${3:?Usage: join_on_key.sh <file1> <file2> <key_col> [delimiter]}"
delim="${4:-,}"
[[ -f "$f1" ]] || { echo "Error: file not found: $f1" >&2; exit 1; }
[[ -f "$f2" ]] || { echo "Error: file not found: $f2" >&2; exit 1; }
join -t"$delim" -1 "$key_col" -2 "$key_col" "$f1" "$f2"
