# text-toolkit

A Claude plugin that turns everyday Linux text-manipulation commands into reusable, safe shell scripts organized as skills. Built for anyone who regularly needs to search, transform, sort, extract, diff, split, or clean up plain text/CSV/log files without hand-writing `grep`/`sed`/`awk` one-liners each time.

## Components

8 skills, 42 scripts total, all pure bash wrapping standard POSIX/GNU tools (`grep`, `sed`, `awk`, `sort`, `uniq`, `cut`, `tr`, `diff`, `comm`, `paste`, `join`, `split`, `cat`, `head`, `tail`, `wc`, `nl`, `tac`, `shuf`):

| Skill | What it covers |
|---|---|
| `text-search` | Find/filter lines by pattern, exclude, count, multi-pattern, between-patterns, case-insensitive |
| `text-transform` | Find & replace, upper/lowercase, line numbering, reverse lines, CRLF/LF conversion |
| `text-sort-dedup` | Sort (alpha/numeric/reverse/by column), dedupe, find duplicates, count occurrences, shuffle |
| `text-fields` | Extract/reorder columns, extract by header, CSV↔TSV conversion, sum/average a column |
| `text-stats` | Line/word/char/byte counts, word frequency, longest/shortest line, line length stats, blank line count |
| `text-diff-merge` | Unified/side-by-side diff, common/unique lines (comm), paste side-by-side, join on key |
| `text-split-join` | Split by line count or into N pieces, concatenate files, extract line range, head/tail |
| `text-cleanup` | Trim whitespace, remove/collapse blank lines, trailing-space removal, collapse spaces, strip non-ASCII |

## Setup

No external dependencies — every script relies on tools already present on any standard Linux/macOS system with bash and GNU/BSD coreutils. Nothing to configure.

## Usage

Ask Claude naturally, e.g.:
- "Find all lines with 'ERROR' in server.log"
- "Sort this CSV by the 3rd column"
- "Remove duplicate lines from list.txt but keep the original order"
- "Give me word frequency stats for this file"
- "Diff these two config files"
- "Split this 10,000-line file into 5 pieces"
- "Trim trailing whitespace from every line"

Claude will load the matching skill and run the relevant script(s) under `${CLAUDE_PLUGIN_ROOT}/skills/<skill-name>/scripts/`.

## Design conventions (shared across all skills)

- **Non-destructive by default**: every transforming script prints to stdout unless an explicit `output_file` argument is given. Nothing overwrites your source file unless you say so.
- **Fail loudly**: missing files or missing required arguments produce a clear error on stderr and a non-zero exit code, rather than silently doing nothing.
- **1-indexed columns/lines**: matches how most people describe "column 2" or "line 10", not 0-indexed array semantics.
- **Extended regex** (`grep -E` / `sed -E`) is used throughout for pattern matching, which is closer to how most people write patterns than POSIX basic regex.

## Customization

None needed — this plugin has no external service integrations, so there's no `CONNECTORS.md`. All scripts run locally against files you point them at.
