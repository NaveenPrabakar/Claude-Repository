---
name: latex-resume-cv
description: >
  This skill should be used when the user asks to "build a resume in LaTeX",
  "make a CV", "update my LaTeX resume", "add a project to my resume", "fix
  my resume formatting", or wants a one-to-two page resume/CV as a .tex
  file with sections for education, experience, projects, and skills.
metadata:
  version: "0.1.0"
---

# LaTeX Resume / CV

Build and edit tight, ATS-friendly resumes as `.tex` files. A resume is a space-constrained document — every layout decision should be about density and scan-ability, not decoration.

## Workflow

1. If editing an existing resume, read the current `.tex` file first and match its existing style (don't rewrite the whole document unless asked).
2. If building new, ask only what's essential and not inferable: target role/industry (affects section order and emphasis) and page limit (1 page is standard for <10 years experience, 2 pages otherwise). Don't ask about things you can reasonably default (margins, font) — just pick sane defaults and say so.
3. Use one of the structures in `references/resume-templates.md` as the base rather than inventing a layout from scratch — these are tested for consistent spacing and ATS-parseable text (no `tikzpicture`-based text, no icon fonts required to render body content).
4. Keep bullet points as `\item` inside `itemize`, one line each where possible, action-verb-first, quantified impact where the user has provided numbers.
5. Compile-check before delivering. Resumes tolerate zero broken layout — verify no overfull `\hbox` warnings that visibly overflow the page margin.

## Core Structure

```
Header (name, phone, email, LinkedIn, GitHub, location — one line, small font)
Education
Experience (reverse chronological)
Projects
Skills (categorized: Languages / Frameworks / Tools)
```

Order Projects above or below Experience based on which is stronger for the target role — for students/new grads with strong project work (as opposed to limited internship history), Projects often belongs directly under Education.

## Section Writing Rules

- **Bullets**: start with a strong verb (Built, Designed, Automated, Reduced, Led), state the action, then the measurable outcome. Avoid "Responsible for."
- **Length**: 3–5 bullets per experience entry, 2–3 per project. Cut anything that doesn't differentiate the candidate.
- **Consistency**: same tense throughout (past tense for past roles, present for current role), same date format, same bolding pattern for company/title.
- **No paragraphs**: resumes are bulleted, not prose, except for a one-line summary if the user wants one (optional, often skippable).

## Density Control

Common tools to fit content without shrinking font below 10pt:
- Reduce `\baselineskip` / use `\vspace{-Xpt}` sparingly between sections (prefer `titlesec` spacing controls over manual `\vspace` hacks — cleaner to maintain).
- Use `enumitem`'s `topsep`, `itemsep`, `parsep` to compress bullet spacing rather than shrinking the font.
- Tighten margins to 0.5–0.75in via `geometry` before shrinking font size — font below 10pt hurts ATS parsing and readability.

Full spacing-control preamble and a compact section-heading macro are in `references/resume-templates.md`.

## ATS Compatibility

- Never put contact info, section headers, or bullet content inside a `tikzpicture`, `tabular` with graphics, or as an image — ATS parsers read text order, and images/positioned text can scramble.
- Avoid multi-column layouts with `\parbox`/`minipage` side-by-side sections for content that needs to parse linearly, unless the user explicitly wants a two-column *visual* resume and accepts the ATS tradeoff (flag this tradeoff explicitly if they ask for a heavily designed two-column resume).
- Keep the font embeddable/standard (Latin Modern, Charter, or similar) — avoid obscure OTF fonts that don't extract text cleanly from PDF.

## Editing Existing Resumes

When the user asks to add/update an entry:
1. Locate the right section via the existing `\section{}` markers.
2. Match existing bullet style, verb tense, and macro usage (many resumes define custom commands like `\resumeItem{}` — reuse them, don't introduce a parallel raw `\item` alongside a custom macro system).
3. Recompile mentally (or actually, if a compiler is available) to check the addition doesn't push the document past the page limit — if it does, flag it and suggest what to trim rather than silently overflowing to a second page.

## Output

Deliver the `.tex` file (and PDF if compilation is available). For a page-limited document, always confirm final page count.
