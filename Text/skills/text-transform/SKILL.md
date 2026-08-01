---
name: text-transform
description: >
  This skill should be used when the user wants to "find and replace", "substitute text",
  "convert to uppercase/lowercase", "change line endings", "number the lines", "reverse a file",
  "translate characters", or otherwise rewrite the content of a text file in place or to a new file.
  Covers sed-based substitution, case conversion, line numbering, and character translation.
metadata:
  version: "0.1.0"
---

# Text Transform

Wraps `sed`, `awk`, `tr`, and `rev` for rewriting text content.

## Scripts

Run with `bash ${CLAUDE_PLUGIN_ROOT}/skills/text-transform/scripts/<script>.sh <args>`.

| Script | Purpose | Usage |
|---|---|---|
| `find_replace.sh` | Substitute every occurrence of a pattern with a replacement | `find_replace.sh <file> <pattern> <replacement> [output_file]` |
| `to_upper.sh` | Convert all text to uppercase | `to_upper.sh <file> [output_file]` |
| `to_lower.sh` | Convert all text to lowercase | `to_lower.sh <file> [output_file]` |
| `number_lines.sh` | Prefix each line with its line number | `number_lines.sh <file> [output_file]` |
| `reverse_lines.sh` | Reverse the order of lines (like `tac`) | `reverse_lines.sh <file> [output_file]` |
| `crlf_to_lf.sh` | Convert Windows line endings to Unix | `crlf_to_lf.sh <file> [output_file]` |
| `lf_to_crlf.sh` | Convert Unix line endings to Windows | `lf_to_crlf.sh <file> [output_file]` |

## Workflow

1. Default behavior: **never overwrite the original file silently**. If `output_file` is omitted, scripts print to stdout so the user (or Claude) can review before committing.
2. If the user explicitly wants an in-place edit, pass the same path as both `<file>` and `[output_file]`, or ask to confirm before overwriting — in-place edits are destructive and the original can't be recovered without a backup.
3. For `find_replace.sh`, remind the user that `pattern` is treated as an extended regex; escape special characters (`. * [ ] ( ) + ? ^ $`) if they mean them literally.
4. Chain scripts by piping intermediate files, or extend a script's `sed`/`awk` core if the user needs a one-off transform not covered here — don't force a mismatched script to do the job.

## Notes

- All scripts operate on UTF-8 text; binary files will produce garbled or rejected output — check `file <path>` first if unsure.
- `find_replace.sh` replaces **all** occurrences per line and across the whole file by default (`sed`'s global flag `g`).
