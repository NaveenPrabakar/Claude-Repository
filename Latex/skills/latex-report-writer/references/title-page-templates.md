# Title Page Templates

## Simple Academic (maketitle)

```latex
\title{Report Title}
\author{Author Name \\ Affiliation}
\date{\today}
\maketitle
```

## Business Report with Logo and Confidentiality Line

```latex
\begin{titlepage}
\centering
\includegraphics[width=0.3\textwidth]{logo.png}\par\vspace{2cm}
{\Huge\bfseries Report Title \par}
\vspace{0.5cm}
{\Large Subtitle or Tagline \par}
\vspace{2cm}
{\large Prepared by: Author Name \par}
{\large Department / Team \par}
\vspace{1cm}
{\large \today \par}
\vfill
{\small This document is confidential and intended solely for internal use.\par}
\end{titlepage}
```

## Thesis-Style Title Page

```latex
\begin{titlepage}
\centering
{\scshape\LARGE University Name \par}
\vspace{1.5cm}
{\huge\bfseries Thesis Title \par}
\vspace{2cm}
{\Large\itshape Author Name \par}
\vfill
supervised by\par
Supervisor Name
\vfill
{\large \today \par}
\end{titlepage}
```

## Two-Column Author/Affiliation Block (multiple authors)

```latex
\author{
  Author One\thanks{Affiliation One} \and
  Author Two\thanks{Affiliation Two}
}
```
