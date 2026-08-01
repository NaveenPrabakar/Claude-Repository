# Resume Templates

## Minimal One-Page Template (no external .cls needed, ATS-safe)

```latex
\documentclass[10.5pt, letterpaper]{article}
\usepackage[margin=0.6in]{geometry}
\usepackage[T1]{fontenc}
\usepackage{lmodern}
\usepackage{enumitem}
\usepackage{titlesec}
\usepackage{hyperref}
\usepackage{xcolor}

\pagestyle{empty}

\titleformat{\section}{\large\bfseries}{}{0em}{}[\titlerule]
\titlespacing{\section}{0pt}{8pt}{4pt}

\setlist[itemize]{leftmargin=1.1em, itemsep=1pt, topsep=2pt, parsep=0pt}

\newcommand{\resumeEntry}[4]{
  \textbf{#1} \hfill #2 \\
  \textit{#3} \hfill \textit{#4} \\[2pt]
}

\begin{document}

\begin{center}
{\Large\textbf{Full Name}} \\[2pt]
City, State \quad | \quad (555) 555-5555 \quad | \quad email@example.com \quad | \quad
\href{https://linkedin.com/in/username}{linkedin.com/in/username} \quad | \quad
\href{https://github.com/username}{github.com/username}
\end{center}

\section*{Education}
\resumeEntry{University Name}{City, State}{B.S. in Computer Science, Minor in Data Science}{Graduation Month Year}

\section*{Experience}
\resumeEntry{Company Name}{City, State}{Job Title}{Month Year -- Month Year}
\begin{itemize}
  \item Built/designed/automated \textbf{X}, resulting in measurable outcome \textbf{Y}.
  \item Action verb + what you did + tools used + impact.
\end{itemize}

\section*{Projects}
\textbf{Project Name} \hfill \textit{Tech stack} \\
\begin{itemize}
  \item One-line description of what it does and why it matters.
  \item A quantified or technical highlight.
\end{itemize}

\section*{Skills}
\textbf{Languages:} Python, Java, SQL, JavaScript/TypeScript \\
\textbf{Frameworks/Tools:} React, Flask, FastAPI, PostgreSQL, Docker, Git

\end{document}
```

## Compact Section-Spacing Macro (drop into any resume preamble to tighten fit)

```latex
\titlespacing{\section}{0pt}{6pt}{2pt}
\setlength{\parskip}{0pt}
\setlength{\baselineskip}{12pt}
```

## Two-Column Visual Resume (design-forward, flag ATS tradeoff to user)

```latex
\documentclass[10pt]{article}
\usepackage[margin=0.5in]{geometry}
\usepackage{multicol}
\usepackage{xcolor}
\definecolor{accent}{HTML}{2C3E50}

\begin{document}
\begin{center}
{\huge\bfseries\color{accent} Full Name}\\
Role Title
\end{center}

\begin{multicols}{2}
[\section*{Sidebar: Contact, Skills, Education}]
% left column: contact, skills, education
\columnbreak
% right column: experience, projects
\end{multicols}
\end{document}
```

Use `multicols` (flows dynamically) rather than two fixed `minipage`s if content length is uncertain — `minipage`s require manual height balancing.

## Cover Letter Companion (matching style)

```latex
\documentclass[11pt]{letter}
\usepackage[margin=1in]{geometry}
\signature{Full Name}
\address{Address Line \\ City, State}
\begin{document}
\begin{letter}{Hiring Manager \\ Company Name \\ Company Address}
\opening{Dear Hiring Manager,}

Body paragraphs...

\closing{Sincerely,}
\end{letter}
\end{document}
```
