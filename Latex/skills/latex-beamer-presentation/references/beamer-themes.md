# Beamer Themes

## Recommended Defaults

**metropolis** (modern, minimal, flat design — best general default):
```latex
\usetheme{metropolis}
\metroset{block=fill}
```
Note: requires the `metropolis` package (via `mtheme` on CTAN). If unavailable in the compilation environment, use the plain fallback below.

**Plain theme + custom accent (guaranteed available, no extra packages):**
```latex
\usetheme{default}
\usecolortheme{default}
\definecolor{accent}{HTML}{2C5F8A}
\setbeamercolor{title}{fg=accent}
\setbeamercolor{frametitle}{fg=white, bg=accent}
\setbeamercolor{structure}{fg=accent}
\setbeamertemplate{navigation symbols}{}  % remove navigation icons
```

## Themes to Avoid by Default

`Berkeley`, `Warsaw`, `Madrid` with default color themes look dated and are overused in academic slide decks. Only use them if the user explicitly asks for a "classic academic" look or needs to match an institutional template that specifies one.

## Color Theme Pairing

```latex
\usetheme{Boadilla}       % clean sidebar-free layout
\usecolortheme{seahorse}  % muted, professional
```

## Business/Corporate Look

```latex
\usetheme{default}
\definecolor{corpblue}{HTML}{003057}
\definecolor{corpgray}{HTML}{53565A}
\setbeamercolor{frametitle}{bg=corpblue, fg=white}
\setbeamercolor{title}{fg=corpblue}
\setbeamerfont{frametitle}{series=\bfseries}
\setbeamertemplate{footline}{
  \leavevmode
  \hbox{\begin{beamercolorbox}[wd=\paperwidth, ht=2.5ex, dp=1ex, right]{corpgray}
    \small \insertshorttitle \hspace{1em} \insertframenumber/\inserttotalframenumber \hspace{1em}
  \end{beamercolorbox}}
}
```

## Removing Navigation Clutter

Always strip the default navigation symbol bar for a cleaner look unless the user needs slide-jump navigation during a live talk:

```latex
\setbeamertemplate{navigation symbols}{}
```

## Aspect Ratio

Default to widescreen for modern displays:
```latex
\documentclass[aspectratio=169]{beamer}
```
Use `aspectratio=43` only if the user specifies an older projector/4:3 requirement.
