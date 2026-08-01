---
name: latex-bibliography
description: >
  This skill should be used when the user asks to "add citations to my
  LaTeX document", "set up BibTeX", "use biblatex", "format references in
  APA/IEEE/Chicago", "cite this source in LaTeX", or needs a .bib file and
  proper in-text citation commands wired into a report, thesis, or paper.
metadata:
  version: "0.1.0"
---

# LaTeX Bibliography and Citations

Set up correct, consistently-styled citations. Default to `biblatex` + `biber` for new documents (more flexible, better Unicode/style support); use classic `bibtex` only if the user's existing document already uses it or their target venue requires it.

## Workflow

1. Check whether the document already has a `.bib` file or citation setup — if editing an existing document, match the existing engine (`bibtex` vs `biblatex`) rather than switching mid-project.
2. Determine the citation style needed: IEEE (numeric, common in CS/engineering), APA (author-year, common in social sciences/business), Chicago, or a specific journal's required style.
3. Create or extend the `.bib` file with correctly-typed entries (`@article`, `@inproceedings`, `@book`, `@misc`, etc.) — never leave required fields blank; use placeholder text only when the user hasn't provided the source yet, and flag it clearly.
4. Wire in-text citations using `\cite{}` / `\parencite{}` / `\textcite{}` as appropriate for the style.
5. Compile the full cycle (pdflatex → biber/bibtex → pdflatex → pdflatex) — a single `pdflatex` pass will not resolve citations.

## biblatex Setup (recommended default)

```latex
\usepackage[style=ieee, backend=biber]{biblatex}
\addbibresource{references.bib}

% ... document body with \cite{key}, \textcite{key}, \parencite{key} ...

\printbibliography
```

Common `style=` values: `ieee` (numeric, brackets), `apa` (author-year), `chicago-authordate`, `numeric` (generic numeric), `authoryear`.

Compile sequence:
```bash
pdflatex report.tex
biber report
pdflatex report.tex
pdflatex report.tex
```

## Classic bibtex Setup (legacy, still required by some venues)

```latex
\bibliographystyle{ieeetr}   % or plain, apalike, unsrt, acm
\bibliography{references}
```

Compile sequence:
```bash
pdflatex report.tex
bibtex report
pdflatex report.tex
pdflatex report.tex
```

## .bib Entry Templates

Common entry types and required fields are in `references/bib-entry-templates.md`. Always populate `author`, `title`, `year` at minimum; type-specific required fields (`journal`+`volume` for `@article`, `booktitle` for `@inproceedings`, `publisher` for `@book`) must not be omitted or the reference will render incorrectly or trigger a warning.

## In-Text Citation Commands (biblatex)

| Command | Renders as (author-year style) | Use for |
|---|---|---|
| `\cite{key}` | (Smith, 2023) | generic citation |
| `\textcite{key}` | Smith (2023) argues... | when the author is the subject of the sentence |
| `\parencite{key}` | (Smith, 2023) | parenthetical citation |
| `\citeauthor{key}` | Smith | author name only |
| `\citeyear{key}` | 2023 | year only |
| `\footcite{key}` | superscript footnote | footnote-style citation (Chicago notes style) |

For numeric/IEEE style, `\cite{key}` renders as `[3]` and `\textcite{key}` is rarely used.

## Key Naming Convention

Use a consistent, collision-resistant key scheme: `authorYEARkeyword` (e.g., `smith2023transformers`) rather than short ambiguous keys like `ref1` — makes the `.bib` file maintainable as it grows.

## Common Pitfalls

- Forgetting the `biber`/`bibtex` step entirely — citations show as `[?]` or `(??)` until that intermediate step runs, not just another `pdflatex` pass.
- Mixing `natbib` commands (`\citep`, `\citet`) with `biblatex` — they're different packages with incompatible command sets; pick one.
- Special characters in `.bib` fields (accents, ampersands) need proper escaping (`\'{e}` or Unicode with `biblatex`+`biber`, which handles UTF-8 natively — another reason to prefer biblatex over legacy bibtex).
- URLs in `@misc`/`@online` entries need `\usepackage{url}` or biblatex's built-in URL handling to avoid breaking line width.

## Output

Deliver both the updated `.tex` file and the `.bib` file — citations are useless without the bibliography database alongside the document.
