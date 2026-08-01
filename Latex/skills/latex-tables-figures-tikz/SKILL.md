---
name: latex-tables-figures-tikz
description: >
  This skill should be used when the user asks to "make a table in LaTeX",
  "add a figure", "draw a diagram with TikZ", "create a flowchart in
  LaTeX", "plot data with pgfplots", or needs professional tables,
  positioned figures, or vector diagrams embedded in a .tex document.
metadata:
  version: "0.1.0"
---

# LaTeX Tables, Figures, and TikZ Diagrams

Produce clean, publication-quality tables and diagrams natively in LaTeX rather than embedding low-resolution screenshots or spreadsheet exports where possible.

## Tables

**Always use `booktabs`** for horizontal-rule tables instead of default `hline`-heavy tables — it's the standard for professional/academic tables and looks far cleaner.

```latex
\usepackage{booktabs}

\begin{table}[htbp]
  \centering
  \caption{Table Caption}
  \label{tab:example}
  \begin{tabular}{lrr}
    \toprule
    Category & Metric A & Metric B \\
    \midrule
    Row One  & 12.3     & 45.6     \\
    Row Two  & 78.9     & 10.1     \\
    \bottomrule
  \end{tabular}
\end{table}
```

Rules:
- Never use vertical rules (`|`) in a booktabs-style table — horizontal rules only (`\toprule`, `\midrule`, `\bottomrule`).
- Right-align numeric columns (`r`), left-align text columns (`l`).
- For wide tables, use `\resizebox{\textwidth}{!}{...}` or switch to `landscape` (via the `pdflscape` package) rather than shrinking the font below readable size.
- For tables needing multi-row cells, use the `multirow` package; for tables wider than the page with many columns, consider `tabularx` or `longtable` (the latter for tables that span multiple pages).

Full patterns (multi-page tables, merged cells, colored rows) are in `references/table-patterns.md`.

## Figures

```latex
\usepackage{graphicx}

\begin{figure}[htbp]
  \centering
  \includegraphics[width=0.8\textwidth]{filename.pdf}
  \caption{Figure Caption}
  \label{fig:example}
\end{figure}
```

Rules:
- Prefer vector formats (`.pdf`, `.eps`, `.svg` via `svg` package) over raster (`.png`, `.jpg`) for diagrams and plots — they scale without pixelation. Raster is fine for photographs.
- Use `[htbp]` placement (not just `[h]`) to give LaTeX flexibility; avoid `[H]` (from `float` package) unless exact placement is critical, since it can create awkward whitespace.
- For side-by-side figures, use `subcaption` (not the deprecated `subfig`/`subfigure`):

```latex
\usepackage{subcaption}
\begin{figure}[htbp]
  \centering
  \begin{subfigure}{0.48\textwidth}
    \includegraphics[width=\textwidth]{left.pdf}
    \caption{Left}
  \end{subfigure}
  \hfill
  \begin{subfigure}{0.48\textwidth}
    \includegraphics[width=\textwidth]{right.pdf}
    \caption{Right}
  \end{subfigure}
  \caption{Overall caption}
\end{figure}
```

## TikZ Diagrams

Use TikZ for flowcharts, architecture diagrams, and simple schematics drawn natively (no external image dependency, scales perfectly).

```latex
\usepackage{tikz}
\usetikzlibrary{shapes.geometric, arrows.meta, positioning}
```

Basic flowchart pattern, node styles, and a reusable style library are in `references/tikz-patterns.md`. Start from those patterns rather than writing raw coordinate-based TikZ from scratch — the `positioning` library (`right=of`, `below=of`) is far less error-prone than manual `\draw (0,0) -- (2,1)` coordinates for diagrams with more than a few nodes.

For anything more complex than a moderate flowchart (e.g., a detailed system architecture with many components), consider whether an external tool (draw.io, Mermaid rendered separately) and image import might be more maintainable than hand-coded TikZ — flag this tradeoff to the user rather than producing an unwieldy 200-line TikZ block by default.

## Plots (pgfplots)

For data plots, prefer `pgfplots` over manual TikZ coordinate plotting:

```latex
\usepackage{pgfplots}
\pgfplotsset{compat=1.18}

\begin{figure}[htbp]
\centering
\begin{tikzpicture}
\begin{axis}[
  xlabel={X Axis Label},
  ylabel={Y Axis Label},
  grid=major,
  legend pos=north west,
]
\addplot coordinates {(1,2) (2,4) (3,3) (4,6)};
\addlegendentry{Series A}
\end{axis}
\end{tikzpicture}
\caption{Plot Caption}
\end{figure}
```

For complex/large datasets, it's often more practical to generate the plot externally (matplotlib) and import as a PDF, rather than hand-writing many `\addplot coordinates`.

## Output

Keep table/figure source readable — align columns in the source with spaces for maintainability even though whitespace doesn't affect compiled output.
