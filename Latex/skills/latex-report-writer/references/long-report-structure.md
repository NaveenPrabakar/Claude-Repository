# Long / Multi-Chapter Report Structure

For reports beyond ~15 pages or with distinct chapters, use `report` (or `book` for two-sided binding).

```latex
\documentclass[11pt, oneside]{report}
\usepackage[margin=1in]{geometry}
\usepackage{tocbibind}   % include bib/TOC itself in the TOC
\usepackage{graphicx}
\usepackage{booktabs}
\usepackage{hyperref}

\title{Report Title}
\author{Author Name}
\date{\today}

\begin{document}

\frontmatter
\maketitle
\tableofcontents
\listoffigures
\listoftables

\mainmatter
\chapter{Introduction}
...

\chapter{Methodology}
...

\chapter{Results}
...

\chapter{Conclusion}
...

\appendix
\chapter{Supplementary Material}
...

\backmatter
\bibliography{references}
\bibliographystyle{plain}

\end{document}
```

Notes:
- `\frontmatter`/`\mainmatter`/`\backmatter` (from the `book`/`report` class extensions, requires `\documentclass{book}` for full roman-numeral front matter, or manually manage `\pagenumbering{roman}` / `\pagenumbering{arabic}` under `report`).
- Use `\chapter*{}` with `\addcontentsline{toc}{chapter}{Name}` for unnumbered front-matter sections like a Preface.
- Split very long reports into multiple `.tex` files with `\input{chapters/introduction}` per chapter for easier editing and version control.
