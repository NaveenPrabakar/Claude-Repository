---
name: text-diff-merge
description: >
  This skill should be used when the user wants to "compare two files", "diff two text files",
  "find lines unique to one file", "find lines common to both files", "merge two files
  side by side", or "join two files on a common key". Covers diff, comm, paste, and join.
metadata:
  version: "0.1.0"
---

# Text Diff & Merge

Wraps `diff`, `comm`, `paste`, and `join` for comparing and combining two files.

## Scripts

Run with `bash ${CLAUDE_PLUGIN_ROOT}/skills/text-diff-merge/scripts/<script>.sh <args>`.

| Script | Purpose | Usage |
|---|---|---|
| `diff_files.sh` | Unified diff between two files | `diff_files.sh <file1> <file2>` |
| `diff_side_by_side.sh` | Side-by-side diff | `diff_side_by_side.sh <file1> <file2>` |
| `common_lines.sh` | Lines present in both files (requires both pre-sorted) | `common_lines.sh <file1> <file2>` |
| `unique_to_first.sh` | Lines only in file1 (requires both pre-sorted) | `unique_to_first.sh <file1> <file2>` |
| `unique_to_second.sh` | Lines only in file2 (requires both pre-sorted) | `unique_to_second.sh <file1> <file2>` |
| `merge_side_by_side.sh` | Paste two files column-by-column | `merge_side_by_side.sh <file1> <file2> [delimiter]` |
| `join_on_key.sh` | Join two delimited files on a common key column | `join_on_key.sh <file1> <file2> <key_col> [delimiter]` |

## Workflow

1. `common_lines.sh`, `unique_to_first.sh`, and `unique_to_second.sh` wrap `comm`, which **requires sorted input**. Sort both files first (see `text-sort-dedup/scripts/sort_lines.sh`) or the results will be wrong — check and warn the user if the inputs look unsorted.
2. `join_on_key.sh` also requires both files sorted on the join key; same caveat applies.
3. Use `diff_files.sh` for a compact change summary, `diff_side_by_side.sh` when the user wants to visually eyeball two versions.
4. For merging more than two files, chain `merge_side_by_side.sh` pairwise or use `paste file1 file2 file3` directly.

## Notes

- `join_on_key.sh` defaults to comma delimiter; pass a different delimiter for TSV or whitespace-separated data.
