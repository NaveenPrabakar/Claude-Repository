---
name: text-sort-dedup
description: >
  This skill should be used when the user wants to "sort a file", "sort lines alphabetically or
  numerically", "remove duplicate lines", "find duplicate lines", "dedupe a list", "shuffle lines",
  or "sort by a specific column/field". Covers sort and uniq based operations on plain text and
  delimited files.
metadata:
  version: "0.1.0"
---

# Text Sort & Dedup

Wraps `sort`, `uniq`, and `shuf` for ordering and deduplicating lines.

## Scripts

Run with `bash ${CLAUDE_PLUGIN_ROOT}/skills/text-sort-dedup/scripts/<script>.sh <args>`.

| Script | Purpose | Usage |
|---|---|---|
| `sort_lines.sh` | Sort lines alphabetically (ascending) | `sort_lines.sh <file> [output_file]` |
| `sort_numeric.sh` | Sort lines numerically | `sort_numeric.sh <file> [output_file]` |
| `sort_reverse.sh` | Sort lines in descending order | `sort_reverse.sh <file> [output_file]` |
| `sort_by_column.sh` | Sort by a specific delimited column | `sort_by_column.sh <file> <column_num> [delimiter] [output_file]` |
| `dedup.sh` | Remove duplicate lines, keep first occurrence, preserve order | `dedup.sh <file> [output_file]` |
| `dedup_sorted.sh` | Remove duplicate lines after sorting (classic `sort \| uniq`) | `dedup_sorted.sh <file> [output_file]` |
| `find_duplicates.sh` | Print only lines that appear more than once | `find_duplicates.sh <file>` |
| `count_occurrences.sh` | Count how many times each unique line appears, most frequent first | `count_occurrences.sh <file>` |
| `shuffle_lines.sh` | Randomly shuffle line order | `shuffle_lines.sh <file> [output_file]` |

## Workflow

1. Ask which sense of "duplicate" the user means: exact whole-line duplicates (`dedup.sh`) vs. duplicates only visible after sorting adjacent lines — usually the same result but `dedup.sh` preserves original order while `dedup_sorted.sh` does not.
2. For `sort_by_column.sh`, default delimiter is whitespace; pass a delimiter like `,` explicitly for CSV/TSV data. Column numbers are 1-indexed.
3. Confirm whether output should overwrite the source or go to a new file — same convention as `text-transform`: omit `output_file` to preview on stdout first.
4. `count_occurrences.sh` is useful before deduping to show the user what will be removed.

## Notes

- These scripts assume line-oriented text. For structured CSV with many columns, consider `text-fields` for column-aware operations, then feed the result here for sorting.
