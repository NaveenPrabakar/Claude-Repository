---
name: text-search
description: >
  This skill should be used when the user wants to "search a text file", "find lines matching",
  "grep for", "filter lines containing/excluding", "find and count matches", "search with regex",
  or "find lines between two patterns" in one or more text files. Covers pattern search, inverse
  filtering, context lines, case-insensitive search, multi-pattern search, and counting matches.
metadata:
  version: "0.1.0"
---

# Text Search

Wraps `grep` and friends to search and filter plain text files without writing raw commands from scratch.

## Scripts

All scripts live in `scripts/` and are plain POSIX-ish bash. Run with `bash ${CLAUDE_PLUGIN_ROOT}/skills/text-search/scripts/<script>.sh <args>`.

| Script | Purpose | Usage |
|---|---|---|
| `find_matches.sh` | Print lines matching a pattern, with optional context | `find_matches.sh <file> <pattern> [context_lines]` |
| `find_exclude.sh` | Print lines NOT matching a pattern | `find_exclude.sh <file> <pattern>` |
| `count_matches.sh` | Count how many lines match a pattern | `count_matches.sh <file> <pattern>` |
| `multi_pattern.sh` | Search for any of several patterns (one per line in a pattern file) | `multi_pattern.sh <file> <pattern_file>` |
| `between_patterns.sh` | Print lines between a start and end pattern (inclusive) | `between_patterns.sh <file> <start_pattern> <end_pattern>` |
| `search_ci.sh` | Case-insensitive search with line numbers | `search_ci.sh <file> <pattern>` |

## Workflow

1. Confirm the target file exists and is plain text before running anything (`file <path>` if unsure).
2. Pick the narrowest script for the job rather than reaching for raw `grep -E` inline — the scripts already handle quoting and common flags safely.
3. For regex patterns, prefer extended regex (`-E`) semantics, which these scripts use by default. Tell the user if their pattern needs to be adjusted for that.
4. Pipe output back to the user directly, or redirect to a new file if the user wants the filtered result saved (e.g. `find_matches.sh input.txt ERROR > errors.txt`).
5. If the user wants to search inside multiple files or a directory, extend the pattern with a glob and pass it as `$1`, or ask whether they want recursive search (`grep -R`) added.

## Notes

- All scripts fail loudly (non-zero exit + message to stderr) if the file is missing, unreadable, or the pattern arg is empty — surface that message to the user rather than swallowing it.
- Line numbers are included by default in most scripts (`grep -n`) since users manipulating text files usually want to locate the match, not just see it.
