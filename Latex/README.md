# LaTeX Toolkit

A plugin for producing polished `.tex` documents end-to-end — reports, resumes/CVs, presentations, and everything that goes inside them (tables, figures, diagrams, citations) — plus troubleshooting when compilation breaks.

## Components

| Skill | Purpose |
|---|---|
| `latex-report-writer` | Business/academic/technical reports: structure, preambles, title pages, multi-chapter layouts |
| `latex-resume-cv` | ATS-friendly resumes and CVs, one-to-two page, editable and extendable |
| `latex-beamer-presentation` | Beamer slide decks: themes, fragile frames, overlays, handouts |
| `latex-tables-figures-tikz` | booktabs tables, figures/subfigures, TikZ diagrams, pgfplots |
| `latex-bibliography` | biblatex/bibtex setup, `.bib` entry templates, citation commands, style selection |
| `latex-compile-troubleshoot` | Diagnosing and fixing `pdflatex`/`biber` compile errors from the actual log |

Each skill triggers automatically based on what you ask for — no manual invocation needed. They're designed to compose: e.g. a report can pull in the tables/figures skill for a chart and the bibliography skill for citations in the same document.

## Setup

No external services or API keys required. If `pdflatex`/`biber`/`bibtex` are available in the working environment, skills will compile-check output before delivering it; if not, they fall back to careful manual verification (brace balancing, environment pairing) and note that compilation should be verified locally.

## Usage

Just ask naturally, for example:
- "Write a technical report in LaTeX on our Q3 infrastructure migration"
- "Update my LaTeX resume to add the Merrill Manufacturing internship"
- "Build a 10-slide Beamer deck on our RAG pipeline architecture"
- "Add a TikZ flowchart showing the ETL pipeline to my report"
- "Set up IEEE-style citations for this paper and add these three sources"
- "This won't compile — Undefined control sequence at line 42, can you fix it?"

## Customization

This plugin has no external tool connectors — everything runs on local `.tex`/`.bib` files and (optionally) a local LaTeX toolchain, so there's no `CONNECTORS.md`.
