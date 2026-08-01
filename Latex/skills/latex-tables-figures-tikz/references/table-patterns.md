# Table Patterns

## Multi-Page Table (longtable)

```latex
\usepackage{longtable}

\begin{longtable}{lrr}
  \caption{Long Table Caption} \label{tab:long} \\
  \toprule
  Category & Metric A & Metric B \\
  \midrule
  \endfirsthead
  \toprule
  Category & Metric A & Metric B \\
  \midrule
  \endhead
  \bottomrule
  \endfoot
  Row One & 12.3 & 45.6 \\
  Row Two & 78.9 & 10.1 \\
  ...
\end{longtable}
```

## Merged Cells (multirow / multicolumn)

```latex
\usepackage{multirow}

\begin{tabular}{llrr}
\toprule
\multirow{2}{*}{Region} & \multirow{2}{*}{Product} & \multicolumn{2}{c}{2025 Sales} \\
 & & Q1 & Q2 \\
\midrule
Midwest & Widget A & 120 & 150 \\
        & Widget B & 90  & 110 \\
\bottomrule
\end{tabular}
```

## Colored Rows (xcolor + colortbl)

```latex
\usepackage[table]{xcolor}

\begin{tabular}{lr}
\toprule
\rowcolor{gray!15} Category & Value \\
\midrule
Row One & 12.3 \\
Row Two & 45.6 \\
\bottomrule
\end{tabular}
```

## Fixed-Width Wrapped Columns (tabularx)

```latex
\usepackage{tabularx}

\begin{tabularx}{\textwidth}{lX}
\toprule
Term & Definition \\
\midrule
API & A set of rules that lets applications communicate with each other. \\
\bottomrule
\end{tabularx}
```

Use `X` columns for any column containing prose that needs to wrap — plain `l`/`p{}` columns don't wrap gracefully to fill available width.

## Landscape Wide Table

```latex
\usepackage{pdflscape}

\begin{landscape}
\begin{table}
  ...
\end{table}
\end{landscape}
```
