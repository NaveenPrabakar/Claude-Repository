# TikZ Patterns

## Reusable Style Library (put in preamble)

```latex
\usetikzlibrary{shapes.geometric, arrows.meta, positioning}

\tikzset{
  process/.style={rectangle, rounded corners, minimum width=2.5cm, minimum height=1cm,
                  text centered, draw=black, fill=blue!10},
  decision/.style={diamond, minimum width=2.5cm, minimum height=1cm,
                    text centered, draw=black, fill=orange!15, aspect=2},
  startstop/.style={rectangle, rounded corners, minimum width=2.5cm, minimum height=1cm,
                     text centered, draw=black, fill=green!15},
  arrow/.style={thick, -{Stealth}},
}
```

## Basic Flowchart (positioning library — preferred over raw coordinates)

```latex
\begin{tikzpicture}[node distance=1.5cm]
  \node (start) [startstop] {Start};
  \node (input) [process, below=of start] {Input Data};
  \node (check) [decision, below=of input] {Valid?};
  \node (process) [process, below=of check] {Process};
  \node (stop) [startstop, below=of process] {End};

  \draw [arrow] (start) -- (input);
  \draw [arrow] (input) -- (check);
  \draw [arrow] (check) -- node[anchor=west] {yes} (process);
  \draw [arrow] (process) -- (stop);
  \draw [arrow] (check.east) -- ++(2,0) node[anchor=south] {no} |- (input.east);
\end{tikzpicture}
```

## Horizontal Pipeline Diagram

```latex
\begin{tikzpicture}[node distance=2cm]
  \node (a) [process] {Extract};
  \node (b) [process, right=of a] {Transform};
  \node (c) [process, right=of b] {Load};
  \draw [arrow] (a) -- (b);
  \draw [arrow] (b) -- (c);
\end{tikzpicture}
```

## Simple Architecture Diagram (boxes + labeled arrows)

```latex
\begin{tikzpicture}[node distance=2.5cm]
  \node (client) [process] {Client};
  \node (api) [process, right=of client] {API Server};
  \node (db) [process, right=of api] {Database};

  \draw [arrow] (client) -- node[above, font=\small] {HTTP} (api);
  \draw [arrow] (api) -- node[above, font=\small] {SQL} (db);
\end{tikzpicture}
```

## Common Pitfalls

- Forgetting `\usetikzlibrary{positioning}` before using `right=of`/`below=of` syntax — it silently falls back to an error.
- Node names must be unique within a `tikzpicture`; reusing a name silently overwrites the reference.
- For diagrams with more than ~10 nodes, define node styles once via `\tikzset` (as above) rather than repeating inline styling — much easier to maintain and keep visually consistent.
- Diagrams inside a `figure` environment need `\centering` and a `\caption`/`\label` like any other figure — don't float a bare `tikzpicture` without one if it's meant to be referenced from the text.
