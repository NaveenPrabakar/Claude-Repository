---
name: latex-beamer-presentation
description: >
  This skill should be used when the user asks to "make slides in LaTeX",
  "create a Beamer presentation", "build a .tex slide deck", "convert this
  report into slides", or wants a conference/lecture/business presentation
  produced with the Beamer document class.
metadata:
  version: "0.1.0"
---

# LaTeX Beamer Presentations

Build slide decks with the `beamer` class. Slides are not reports — favor sparse text, one idea per slide, and visual hierarchy over dense prose.

## Workflow

1. Determine the context: academic talk, conference presentation, or business/internal deck. This affects theme choice and tone.
2. Choose a theme from `references/beamer-themes.md` — don't default to Berkeley/Warsaw (overused, busy); prefer `metropolis` or a plain theme with a custom color unless the user has an institutional theme to match.
3. Draft an outline first (one line per slide title) and confirm it covers the right scope before writing full slide content — restructuring an outline is much cheaper than restructuring finished slides.
4. Write slides: title slide, agenda/outline slide (for talks >10 slides), content slides, summary/conclusion slide, optional backup/appendix slides.
5. Compile-check. Beamer errors are often about mismatched `\begin{frame}`/`\end{frame}` or fragile frames containing verbatim/code needing the `[fragile]` option.

## Slide Content Rules

- **Text density**: max ~6 bullet lines per slide, each bullet a fragment not a sentence where possible. If content doesn't fit, split into two slides rather than shrinking font.
- **One idea per slide**: a slide title should be answerable by the slide's content alone.
- **Visuals over walls of text**: prefer a diagram, chart, or table (see `latex-tables-figures-tikz` skill) over a bulleted paraphrase of the same information.
- **Speaker notes**: use `\note{}` (requires `\setbeameroption{show notes}` or `\setbeameroption{show notes on second screen}`) for delivery reminders rather than cramming them onto the visible slide.

## Base Preamble

```latex
\documentclass[11pt, aspectratio=169]{beamer}
\usetheme{metropolis}   % or a plain fallback below
\usepackage[utf8]{inputenc}
\usepackage{graphicx}
\usepackage{booktabs}

\title{Presentation Title}
\subtitle{Optional Subtitle}
\author{Author Name}
\institute{Organization}
\date{\today}

\begin{document}

\begin{frame}
  \titlepage
\end{frame}

\begin{frame}{Agenda}
  \tableofcontents
\end{frame}

\section{Section One}
\begin{frame}{Slide Title}
  \begin{itemize}
    \item Point one
    \item Point two
  \end{itemize}
\end{frame}

\end{document}
```

If `metropolis` isn't available in the target environment, fall back to a plain theme with a manual accent color (see `references/beamer-themes.md`) rather than a heavy legacy theme.

## Fragile Frames (code listings, verbatim)

Any frame containing `\begin{verbatim}`, `lstlisting`, or `minted` content must be marked fragile:

```latex
\begin{frame}[fragile]{Code Example}
\begin{lstlisting}[language=Python]
def hello():
    print("hello")
\end{lstlisting}
\end{frame}
```

## Overlays / Reveals (use sparingly)

```latex
\begin{itemize}
  \item<1-> Always visible from slide 1
  \item<2-> Appears on slide 2
  \item<3-> Appears on slide 3
\end{itemize}
```

Overlays are useful for build-up during a live talk; avoid overusing them in decks meant to be read standalone (e.g. shared as a PDF afterward), since the flattened PDF becomes cluttered with repeated near-duplicate slides.

## Handout Version

For a version without overlay animations (useful for printing/distribution):

```latex
\documentclass[11pt, aspectratio=169, handout]{beamer}
```

## Output

Deliver the `.tex` source. Compile to PDF when a compiler is available — Beamer decks are meant to be viewed as PDF, not read as source.
