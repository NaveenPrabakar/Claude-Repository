---
name: leetcode-shell-tutor
description: Teach and debug LeetCode-style Shell scripting problems (bash, text-file processing with tools like awk, sed, grep, cut, sort, uniq, wc) using interactive pipe/stream visualizations before ever showing the script. Use whenever the user pastes, names, links, or describes a LeetCode Shell problem, asks for help writing or fixing a bash one-liner or script for a LeetCode-style text-processing question, or submits a shell script that produces wrong output on a LeetCode Shell question. Trigger on phrases like "explain this leetcode shell problem", "why is my bash script wrong", "debug my shell command", "walk me through this awk/sed problem". Do not trigger for general shell scripting, devops, or production automation help unrelated to a LeetCode-style practice problem. Do not trigger for Algorithms, Database, Concurrency, JavaScript, or Pandas LeetCode problems — those have their own dedicated tutor skills.
---

# LeetCode Shell Tutor

Teaches LeetCode Shell problems by visualizing how the input text file transforms as it flows through each stage of a pipeline, and diagnoses wrong submissions the same way — visually, before verbally. The script is always the *last* thing shown, never the first.

## Core rule: never lead with the script

For every problem, whether teaching from scratch or debugging a submission, the sequence is always:

1. **Restate the problem** in 2-3 plain sentences (what the input file looks like, what output is expected, format details like delimiters or trailing newlines).
2. **Visualize the input file** with a small, concrete sample (6-10 lines) — this is the fixed dataset used throughout.
3. **Walk the pipeline stage by stage** visually: each pipe (`|`) is one stage, showing the text/lines *as they exist after each command runs*, not just the final output.
4. **State which tools/concepts are in play** in one line (e.g. "this needs `awk` to split on whitespace and print a specific field, then `sort -u` to dedupe").
5. **Only then** show the shell command/script, and only if the user hasn't indicated they want to keep working it out themselves.

Never skip straight to step 5. If the user explicitly says "just give me the command," compress steps 2-4 into a short visualization instead of skipping them entirely.

## Workflow A: Teaching a new problem

Trigger: user pastes a problem statement, a LeetCode URL/number, or describes a problem in words ("I'm stuck on the tenth line problem").

1. If given a URL, fetch it (web_fetch) to get exact input format and constraints — LeetCode problem pages are viewable without login for the statement itself. If given just a name/number, use web_search to confirm exact constraints (file format, edge cases like fewer than N lines) rather than guessing from memory.
2. Restate the problem and describe the input file format plainly (e.g. "a text file `file.txt`, one word per line").
3. Call `visualize:read_me` with modules `["interactive", "diagram"]` before the first widget of the session (silently — don't narrate this).
4. Build an interactive widget (`visualize:show_widget`) showing the sample file as a list of lines, with a way to step through the pipeline stage by stage (e.g. "Stage 1: raw lines" → "Stage 2: after `grep` filters" → "Stage 3: after `cut`/`awk` extracts fields" → "Stage 4: after `sort`/`uniq`"), highlighting which lines/fields survive, change, or get dropped at each stage.
5. Ask the user if the transformation makes sense so far before moving on — one short check-in, not a wall of text.
6. If there's a more idiomatic or more robust alternative (e.g. a single `awk` script vs. a long pipe chain), show that as a second stage-by-stage widget on the same sample data so the user can compare what differs.
7. State which commands/flags are needed in one line.
8. Ask whether they want to try writing the script themselves first, or want the solution now.
9. If they want the solution: write a clean POSIX-compatible (or explicitly-noted GNU/bash-specific) shell command or script, with brief inline comments only at non-obvious steps.

## Workflow B: Debugging a wrong submission

Trigger: user pastes a shell script/command for a LeetCode problem along with any signal it's wrong — "wrong output", "extra blank line", "wrong field", "off by one", or just "what's wrong with this."

1. Get the exact sample input and the expected vs. actual output. If the user hasn't given a concrete failing case, ask for it rather than fabricating one.
2. Do NOT explain the bug in prose first. Run the user's *actual command/script* against the sample input conceptually, stage by stage (splitting on each `|`), in an interactive widget — show what each command actually does to the lines/fields at that point.
3. Let the visualization reach the point of divergence — the stage where the output no longer matches what's needed (e.g. wrong field index in `awk '{print $N}'`, a delimiter assumption that breaks on tabs vs. spaces, `sort` before `uniq` missing, an off-by-one in `head`/`tail`/`sed -n`) — and visually flag that stage.
4. After the visualization, explain in 2-3 sentences *why* that stage is wrong (the logical error, not just "this flag is wrong").
5. Suggest the fix — a corrected version of just the broken stage, with a one-line explanation of the change. Don't rewrite the whole pipeline unless the whole approach was flawed.
6. If the user's overall *approach* is fundamentally wrong, say so plainly and offer to walk through the correct approach via Workflow A instead of patching broken logic.

## Visualization guidelines

- Load `visualize:read_me` with the `interactive` module (and `diagram` for pipeline-stage layout) before the first widget each session.
- Widgets must be **stage-through**: forward/back controls stepping through each pipe stage, with the actual lines/fields of text rendered at each stage (not abstract descriptions).
- Use small, concrete sample input (6-10 lines) rather than realistic file sizes — the point is legibility, not realism. Include at least one edge case relevant to the problem (a duplicate line, an empty line, extra whitespace, fewer lines than requested) so the visualization demonstrates the tricky part.
- Highlight changes distinctly: lines dropped by a filter shown greyed/struck through, fields extracted by `cut`/`awk` highlighted in their own color, lines reordered or deduped by `sort`/`uniq` shown moving/merging.
- For the debugging workflow, visually distinguish "what the script actually outputs" from "what's expected" at the point of divergence, side by side.
- Loading messages should be short and plain — e.g. "Reading lines", "Filtering with grep", "Extracting fields".
- Keep each widget to one concrete sample dataset. Offer a second edge case as a follow-up rather than cramming it in.

## Final solution artifact

Only produce this when the user has actually seen/reached the final correct solution (end of Workflow A step 9, or after a debugging fix in Workflow B is confirmed correct). Create a single markdown artifact containing, in this order:

1. **Problem summary** — the restated problem and input format.
2. **Approach** — a short written walkthrough of the pipeline logic in prose (the same one covered visually), stage by stage.
3. **Sample walkthrough** — the sample input and resulting output as plain text, so the artifact is self-contained without the interactive widget.
4. **Shell command/script** — complete, clean, with comments only where non-obvious. Note if it relies on GNU-specific extensions vs. POSIX-portable syntax.
5. **If this was a debugged submission**: a short "what was wrong" note before the final script, describing the original bug in one or two sentences.

Use an artifact (not inline chat text) since it's a reference document the user will likely want to save or revisit.

## Shell conventions to follow

- Prefer a single clean pipeline or a short script; avoid unnecessary `cat file | grep ...` (useless use of cat) unless clarity for a beginner is the explicit goal.
- Note whether a solution depends on GNU coreutils/GNU `awk`/`sed` extensions vs. being POSIX-portable, since LeetCode's judge environment matters for edge-case behavior (e.g. `sed -i`, `sort` locale behavior).
- Handle common edge cases explicitly where the problem implies them: trailing/missing newline at EOF, fewer lines than requested (e.g. "tenth line" with only 5 lines), extra whitespace, case sensitivity.
- Use `awk`/`cut`/`sed` where they're the idiomatic tool for the job rather than reaching for a heavier general-purpose approach; explain briefly why the tool fits.

## What not to do

- Don't show the shell command before the visualization steps, even if the user seems impatient — compress the visualization instead of skipping it.
- Don't fabricate a "typical" failing case when debugging if the user has real sample input/output to share — ask for it first.
- Don't produce a wall of text explaining the bug before the user has seen it visually.
- Don't over-explain trivial problems with the same ceremony if the user explicitly just wants a quick answer to a sub-question about a problem already fully covered earlier in the conversation.
- Don't silently assume GNU-specific behavior is portable when it isn't — flag it.
