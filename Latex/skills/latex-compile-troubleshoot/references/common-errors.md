# Common LaTeX Errors and Fixes

## Undefined control sequence

**Cause**: typo in a command name, or the command comes from a package that isn't loaded.

```
! Undefined control sequence.
l.12 \citep{smith2020}
```
Fix: `\citep` is from `natbib` — either `\usepackage{natbib}` or switch to the `biblatex` equivalent `\parencite{}` if that's already loaded.

## Missing $ inserted

**Cause**: a math-only character or command used outside math mode.

```
! Missing $ inserted.
l.20 The value of x_1 is...
```
Fix: wrap in math mode: `The value of $x_1$ is...`. Common triggers: `_`, `^`, `\alpha`, `\times`, `\leq`, `\infty` used in plain text.

## Missing } inserted / Too many }'s

**Cause**: unbalanced braces, often from a nested `{` that wasn't closed, or an extra `}` left over from editing.

Fix strategy: count braces in the surrounding block, or use an editor with bracket matching. Common culprits:
- `\textbf{Bold text` (missing closing brace)
- `\section{Title}}` (stray extra closing brace copy-pasted)

## Environment X undefined

```
! LaTeX Error: Environment tikzpicture undefined.
```
Fix: missing `\usepackage{tikz}`. This pattern applies broadly — the environment name usually maps directly to the package that defines it (`tabularx` → `\usepackage{tabularx}`, `align` → `\usepackage{amsmath}`, `frame` → must be inside a `beamer` document class, etc.).

## \begin{X} ended by \end{Y}

```
! LaTeX Error: \begin{itemize} on input line 10 ended by \end{enumerate}.
```
Fix: mismatched environment nesting — find the `\begin{itemize}` at line 10 and make sure its matching `\end{}` says `itemize`, not `enumerate`. Usually caused by copy-pasting a list and forgetting to update both the begin and end tags.

## File 'X' not found

```
! LaTeX Error: File `figure1.png' not found.
```
Fix checklist:
- Confirm the file actually exists at that relative path from the `.tex` file's directory.
- Check the extension matches exactly (case-sensitive on Linux/Mac build environments even if the user's OS isn't).
- If using `\graphicspath{{images/}}`, confirm the path has a trailing slash and matches the actual folder name.

## Citations render as [?] or (??)

**Cause**: the bibliography backend step was skipped or ran before the `.bib` file existed.

Fix: run the full compile cycle in order:
```bash
pdflatex document.tex
biber document        # or: bibtex document
pdflatex document.tex
pdflatex document.tex
```
A single `pdflatex` pass, or even two, will not resolve citations without the `biber`/`bibtex` step in between.

## Overfull \hbox (badness N) — warning, not fatal

**Cause**: a line, word, or table column is too wide to fit and LaTeX had to let it overflow rather than break it.

Fix options depending on cause:
- Long unbreakable word/URL: wrap with `\url{}` (from `hyperref` or `url` package) or add `\usepackage{microtype}` for better default breaking.
- Table too wide: use `tabularx`, `resizebox`, or `landscape` (see table-patterns.md in the tables/figures skill).
- Image too wide: reduce `\includegraphics[width=...]`.

## Runaway argument

```
! Paragraph ended before \textbf was complete.
```
**Cause**: a command argument spans a blank line (paragraph break) without being closed — LaTeX commands' `{}` arguments can't contain a blank line.

Fix: close the brace before the blank line, or remove the accidental blank line inside the argument.

## Dimension too large / Illegal unit of measure

**Cause**: a length value is missing its unit (e.g., `\vspace{2}` instead of `\vspace{2cm}`) or uses an invalid one.

Fix: always specify units (`pt`, `cm`, `in`, `em`, `ex`) on length commands.
