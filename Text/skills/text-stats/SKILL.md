---
name: text-stats
description: >
  This skill should be used when the user wants to "count lines/words/characters", "get word
  frequency", "find the longest line", "check file size", or otherwise get statistics about a text
  file. Covers wc-based counting and awk-based frequency/length analysis.
metadata:
  version: "0.1.0"
---

# Text Stats

Wraps `wc`, `awk`, and `sort` to report statistics about a text file.

## Scripts

Run with `bash ${CLAUDE_PLUGIN_ROOT}/skills/text-stats/scripts/<script>.sh <args>`.

| Script | Purpose | Usage |
|---|---|---|
| `basic_counts.sh` | Line, word, character, and byte counts | `basic_counts.sh <file>` |
| `word_frequency.sh` | Top N most frequent words | `word_frequency.sh <file> [top_n]` |
| `longest_line.sh` | Print the longest line and its length | `longest_line.sh <file>` |
| `shortest_line.sh` | Print the shortest non-empty line and its length | `shortest_line.sh <file>` |
| `line_length_stats.sh` | Min/max/average line length | `line_length_stats.sh <file>` |
| `blank_line_count.sh` | Count blank lines | `blank_line_count.sh <file>` |

## Workflow

1. Run `basic_counts.sh` first for a quick overview before diving into more specific stats.
2. `word_frequency.sh` lowercases and strips punctuation before counting, so "The" and "the." count as one word — mention this normalization to the user since it changes the raw numbers.
3. Present stats concisely (a short table or a few lines); don't pad with unnecessary explanation unless the user asks what a metric means.

## Notes

- These scripts read the whole file into memory via standard Unix tools; for very large files (multi-GB), warn the user this may be slow and suggest sampling instead.
