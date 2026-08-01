---
name: text-cleanup
description: >
  This skill should be used when the user wants to "trim whitespace", "remove blank/empty lines",
  "remove trailing spaces", "collapse multiple spaces", "strip non-printable/non-ASCII characters",
  "remove duplicate blank lines", or otherwise clean up messy text file formatting before further
  processing.
metadata:
  version: "0.1.0"
---

# Text Cleanup

Wraps `sed`, `awk`, and `tr` for whitespace and formatting cleanup — usually the first pass before other text-toolkit skills.

## Scripts

Run with `bash ${CLAUDE_PLUGIN_ROOT}/skills/text-cleanup/scripts/<script>.sh <args>`.

| Script | Purpose | Usage |
|---|---|---|
| `trim_whitespace.sh` | Strip leading/trailing whitespace from every line | `trim_whitespace.sh <file> [output_file]` |
| `remove_blank_lines.sh` | Remove all blank/empty lines | `remove_blank_lines.sh <file> [output_file]` |
| `collapse_blank_lines.sh` | Collapse runs of consecutive blank lines into one | `collapse_blank_lines.sh <file> [output_file]` |
| `remove_trailing_spaces.sh` | Remove only trailing whitespace (keep leading indentation) | `remove_trailing_spaces.sh <file> [output_file]` |
| `collapse_spaces.sh` | Collapse multiple internal spaces into a single space | `collapse_spaces.sh <file> [output_file]` |
| `strip_non_ascii.sh` | Remove non-ASCII/non-printable characters | `strip_non_ascii.sh <file> [output_file]` |

## Workflow

1. This skill is commonly a preprocessing step — recommend running `trim_whitespace.sh` or `remove_blank_lines.sh` before search/sort/field scripts if the user's file looks inconsistently formatted (mixed indentation, stray trailing spaces).
2. Same output convention as the rest of the plugin: omit `output_file` to preview on stdout, pass it to save.
3. `strip_non_ascii.sh` is destructive for legitimately non-English text (accents, non-Latin scripts) — confirm with the user before running it on anything but pure-ASCII source data (e.g. logs, code).
4. Chain scripts as needed, e.g. trim whitespace then collapse blank lines, by feeding the output of one into the next.

## Notes

- These scripts do not modify the source file unless `output_file` is explicitly the same path as `file` — always safe by default.
