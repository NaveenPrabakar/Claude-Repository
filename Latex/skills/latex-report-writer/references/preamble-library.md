# Preamble Library

Reusable, tested preamble blocks. Copy only what's needed.

## Font Stacks

**Latin Modern (default, clean, safe everywhere):**
```latex
\usepackage[T1]{fontenc}
\usepackage{lmodern}
```

**Libertine (warmer serif, good for business reports):**
```latex
\usepackage{libertine}
\usepackage[libertine]{newtxmath}
```

**Palatino (classic academic look):**
```latex
\usepackage{mathpazo}
```

## Headers and Footers (fancyhdr)

```latex
\usepackage{fancyhdr}
\pagestyle{fancy}
\fancyhf{}
\fancyhead[L]{\small\leftmark}
\fancyhead[R]{\small\thepage}
\fancyfoot[C]{\small Confidential}
\renewcommand{\headrulewidth}{0.4pt}
```

For `article` class, `\leftmark` is empty unless `\section` sets it; use `\markboth{}{}` manually if needed, or switch to `report`/`book` for automatic chapter marks.

## Section Heading Styling (titlesec)

```latex
\usepackage{titlesec}
\usepackage{xcolor}
\definecolor{accent}{HTML}{1F4E79}
\titleformat{\section}{\large\bfseries\color{accent}}{\thesection}{1em}{}
\titleformat{\subsection}{\normalsize\bfseries}{\thesubsection}{1em}{}
```

## Hyperlinks (hyperref — load last, after most other packages)

```latex
\usepackage{hyperref}
\hypersetup{
  colorlinks=true,
  linkcolor=accent,
  citecolor=accent,
  urlcolor=accent,
  pdftitle={Report Title},
  pdfauthor={Author Name}
}
```

## Lists (enumitem — tighter, more controllable lists)

```latex
\usepackage{enumitem}
\setlist[itemize]{leftmargin=*, itemsep=2pt}
\setlist[enumerate]{leftmargin=*, itemsep=2pt}
```

## Code Listings (if the report includes code snippets)

```latex
\usepackage{listings}
\usepackage{xcolor}
\lstset{
  basicstyle=\ttfamily\small,
  breaklines=true,
  frame=single,
  numbers=left,
  numberstyle=\tiny,
  commentstyle=\color{gray},
  keywordstyle=\color{blue}
}
```

Prefer `minted` only if the user confirms `-shell-escape` compilation is available (it requires Pygments and shell-escape, which many build environments block by default).

## Common Pitfalls

- Loading `hyperref` too early causes broken links with some packages — load it last, before only `cleveref`/`glossaries`.
- Mixing `babel` languages without setting `\usepackage[main=english]{babel}` explicitly can silently break hyphenation.
- `geometry` and `fullpage` conflict — never load both.
