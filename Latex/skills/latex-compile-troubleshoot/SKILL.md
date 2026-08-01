---
name: latex-compile-troubleshoot
description: >
  This skill should be used when the user asks to "fix my LaTeX error",
  "why won't this compile", "debug this .tex file", "pdflatex is failing",
  "undefined control sequence", "missing $ inserted", or pastes a LaTeX
  compile log / error message and wants it diagnosed and fixed.
metadata:
  version: "0.1.0"
---

# LaTeX Compile Troubleshooting

Diagnose LaTeX compile failures from the actual error output rather than guessing. LaTeX error messages point at the *symptom* location, which is often a line or more after the real cause (e.g., an unclosed brace reported many lines later) — read backward from the error line when the surface fix doesn't make sense.

## Workflow

1. Get the actual log, not just a description. Run:
   ```bash
   pdflatex -interaction=nonstopmode -halt-on-error document.tex
   ```
   `-interaction=nonstopmode` prevents it from hanging on a prompt; `-halt-on-error` stops at the first real error instead of cascading into dozens of downstream noise errors.
2. Find the first `! ` prefixed line in the output — that's the real error. Ignore warnings (`LaTeX Warning:`, `Overfull \hbox`) unless the user specifically asks about layout/spacing issues; they don't stop compilation.
3. Match the error against `references/common-errors.md` for the fix pattern.
4. Fix the root cause, not just the reported line — for brace/environment mismatches, check the whole file's `\begin{}`/`\end{}` pairing, not just the flagged line.
5. Recompile to confirm the fix, and check for newly-surfaced errors that were previously masked by the first one.

## Reading a LaTeX Error

Example error block:
```
! Undefined control sequence.
l.42 \tabel{results}
              ^
```
- `!` marks the error type.
- `l.42` is the line number where LaTeX detected the problem (not always where the mistake actually is).
- The line snippet with `^` shows where in that line parsing broke.

This example: `\tabel` is a typo for `\table` or more likely `\label` — undefined control sequence almost always means a misspelled command or a missing `\usepackage` for that command.

## Most Common Error Categories

Full patterns and fixes for each are in `references/common-errors.md`. Quick triage:

| Error | Usual Cause |
|---|---|
| `Undefined control sequence` | Typo in command name, or missing package that defines it |
| `Missing $ inserted` | Math-mode character (`_`, `^`, `\alpha`, etc.) used outside `$...$` |
| `Missing } inserted` / `Too many }'s` | Unbalanced braces — often from a `{` inside a command argument that wasn't closed |
| `Environment X undefined` | Missing `\usepackage` for that environment, or typo in `\begin{}`/`\end{}` name |
| `\begin{X} ended by \end{Y}` | Mismatched or improperly nested environments |
| `File 'X' not found` | Wrong filename/path for `\includegraphics`, `\input`, `\bibliography`, or missing package |
| `Overfull \hbox` (warning, not error) | Content too wide for the line/column — not fatal but visually breaks layout |
| Citations show as `[?]` or `(??)` | Forgot to run `bibtex`/`biber` between `pdflatex` passes |

## Package Conflicts

Some packages conflict or must load in a specific order:
- `hyperref` should load near-last (before only `cleveref`, `glossaries`).
- `geometry` and `fullpage` conflict — never both.
- `subfig`/`subfigure` (deprecated) conflict with `caption`/`subcaption` — use `subcaption` only.
- `natbib` citation commands (`\citep`, `\citet`) don't work with `biblatex` loaded — pick one citation package system.

## When halt-on-error Isn't Available

If only a full log dump is available (no live compile access), scan the `.log` file for the first `!` line the same way, ignoring the noise of subsequent cascading errors that stem from the same root cause.

## Verifying the Fix

After a fix, always recompile rather than declaring it solved from inspection alone — LaTeX errors frequently cascade, and a single brace fix can reveal a second, previously-hidden error further down.

## Output

Explain the root cause in plain terms (not just "here's the fix"), so the user can avoid the same mistake next time, then provide the corrected snippet or full file.
