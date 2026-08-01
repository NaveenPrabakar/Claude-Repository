---
name: latex-report-writer
description: >
  This skill should be used when the user asks to "write a report in LaTeX",
  "create a .tex report", "make a technical report", "write a whitepaper
  in LaTeX", "structure a LaTeX document", or needs a business, academic,
  or technical report built as a .tex file with title page, table of
  contents, sections, headers/footers, and consistent styling.
metadata:
  version: "0.1.0"
---

# LaTeX Report Writer

Produce complete, compilable `.tex` reports with professional structure and typography. Default to `article` for short/medium reports and `report` for long multi-chapter documents. Always deliver a working `.tex` file, not a fragment.

## Workflow

1. Clarify only what's ambiguous and can't be reasonably assumed: document length, audience (academic/business/technical), whether a title page and TOC are wanted, and whether the user has a specific institutional/company template to match. If the user already gave enough detail, skip straight to drafting — don't stall on questions.
2. Pick a document class and package set from `references/preamble-library.md`.
3. Draft content section by section. Never leave `\lipsum` or placeholder Latin text in a final deliverable — write real content based on what the user provided, or clearly marked `% TODO:` comments only for content the user must supply (e.g., specific figures they haven't given yet).
4. Compile-check the file (see Compilation below) before handing it off.
5. Save the final `.tex` (and any assets) and, when appropriate, a compiled PDF.

## Document Structure Defaults

For a standard report, use this section order unless the user specifies otherwise:

```
Title page (title, author, date, optional logo/affiliation)
Abstract or Executive Summary (if requested)
Table of Contents
1. Introduction
2. Body sections (numbered, use \section / \subsection)
N. Conclusion / Recommendations
Appendix (optional)
Bibliography (delegate formatting details to the latex-bibliography skill)
```

Use `\tableofcontents`, `\newpage` after the title page, and consistent heading depth (rarely go past `\subsubsection`).

## Preamble Essentials

Load only the packages actually used — a bloated preamble slows compilation and looks unpolished. Common baseline for reports:

```latex
\documentclass[11pt]{article}
\usepackage[margin=1in]{geometry}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage{lmodern}
\usepackage{graphicx}
\usepackage{booktabs}
\usepackage{hyperref}
\usepackage{fancyhdr}
\usepackage{titlesec}
\usepackage{enumitem}
```

Full package rationale, font stack options (Latin Modern vs Libertine vs Palatino), and header/footer recipes are in `references/preamble-library.md`.

## Title Page

Prefer a clean `\maketitle` for simple reports. For business-style title pages with a logo, subtitle, and confidentiality line, use the manual title-page template in `references/title-page-templates.md` rather than the `titlepage` package unless the user wants that package specifically.

## Business vs Academic Tone

- **Academic reports**: use `\section`/`\subsection` numbering, formal abstract, citations via the bibliography skill, minimal color.
- **Business reports**: favor an Executive Summary over an Abstract, use `\paragraph{}` for bolded lead-ins, consider a light accent color for headings via `\usepackage{xcolor}` and `\titleformat`, and keep prose in short paragraphs with bullet-heavy recommendations sections.

## Cross-References and Labels

Use `\label{sec:...}`, `\label{fig:...}`, `\label{tab:...}` consistently and reference with `\ref{}` or `\cref{}` (if `cleveref` is loaded). Never hardcode section numbers in prose.

## Long Reports (report/book class)

For multi-chapter reports, switch to `\documentclass{report}`, use `\chapter{}` as the top level, and consider `\usepackage{tocbibind}` to include the bibliography in the TOC. See `references/long-report-structure.md` for a full multi-chapter skeleton with front matter (title, TOC, list of figures/tables) and back matter (appendices, glossary).

## Compilation

After drafting, verify the document compiles:

```bash
pdflatex -interaction=nonstopmode -halt-on-error report.tex
```

If `pdflatex` is unavailable in the environment, at minimum visually check brace/environment balance (`\begin{}`/`\end{}` pairs) and package compatibility before handing off. If compilation errors occur, use the `latex-compile-troubleshoot` skill to diagnose the log rather than guessing.

## Output

Always produce the final `.tex` file. If a compiler is available, also produce the `.pdf`. Place both in the user's output/deliverables location, not just printed inline — reports are meant to be saved and shared.
