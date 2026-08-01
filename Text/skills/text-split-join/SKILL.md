---
name: text-split-join
description: >
  This skill should be used when the user wants to "split a file into chunks", "split a file by
  line count", "split a file into N pieces", "concatenate files together", "combine multiple text
  files into one", or "extract a range of lines from a file". Covers split, csplit, cat, and head/tail
  based operations.
metadata:
  version: "0.1.0"
---

# Text Split & Join

Wraps `split`, `cat`, `head`, and `tail` for breaking files apart and combining them.

## Scripts

Run with `bash ${CLAUDE_PLUGIN_ROOT}/skills/text-split-join/scripts/<script>.sh <args>`.

| Script | Purpose | Usage |
|---|---|---|
| `split_by_lines.sh` | Split a file into chunks of N lines each | `split_by_lines.sh <file> <lines_per_chunk> [output_prefix]` |
| `split_into_n.sh` | Split a file into N roughly equal pieces | `split_into_n.sh <file> <num_pieces> [output_prefix]` |
| `concat_files.sh` | Concatenate multiple files into one, in the given order | `concat_files.sh <output_file> <file1> [file2 ...]` |
| `extract_line_range.sh` | Extract a specific range of lines | `extract_line_range.sh <file> <start_line> <end_line>` |
| `head_lines.sh` | Print the first N lines | `head_lines.sh <file> <n>` |
| `tail_lines.sh` | Print the last N lines | `tail_lines.sh <file> <n>` |

## Workflow

1. `split_by_lines.sh` and `split_into_n.sh` write chunk files to disk (default prefix `chunk_`, suffixed `aa`, `ab`, ... or numbered). Tell the user where the output files landed.
2. Before splitting, confirm whether the user wants to preserve a header row in every chunk — these scripts do NOT replicate headers by default; flag this so the user can add that step if needed (e.g. `head -1 file > headered_chunk && cat chunk >> headered_chunk`).
3. `concat_files.sh` preserves the exact order of files as given in the argument list — double check the order matches the user's intent before running.
4. For extracting a range, `extract_line_range.sh` is 1-indexed and inclusive on both ends.

## Notes

- Output chunk files use a working directory relative to where the script is invoked; pass an absolute `output_prefix` to control the location precisely.
