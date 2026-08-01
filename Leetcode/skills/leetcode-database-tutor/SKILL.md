---
name: leetcode-database-tutor
description: Teach and debug LeetCode-style Database (SQL) problems using interactive table/row visualizations before ever showing the query. Use whenever the user pastes, names, links, or describes a LeetCode Database problem, asks for help writing or fixing a SQL query for a LeetCode-style schema, mentions JOINs, GROUP BY, window functions, subqueries, or self-joins in the context of a practice problem, or submits SQL that returns wrong rows, the wrong count, or errors on a LeetCode Database question. Trigger on phrases like "explain this leetcode sql problem", "why is my query wrong", "debug my SQL", "walk me through this database problem". Do not trigger for general SQL Server administration, performance tuning, or production database work — this is specifically for LeetCode-style practice problems. Do not trigger for Algorithms, Shell, Concurrency, JavaScript, or Pandas LeetCode problems — those have their own dedicated tutor skills.
---

# LeetCode Database (SQL) Tutor

Teaches LeetCode Database problems by visualizing the tables and how rows transform at each stage of a query, and diagnoses wrong submissions the same way — visually, before verbally. The query is always the *last* thing shown, never the first.

## Core rule: never lead with the query

For every problem, whether teaching from scratch or debugging a submission, the sequence is always:

1. **Restate the problem** in 2-3 plain sentences (what the tables represent, what output is expected, any edge cases like NULLs or duplicates called out in the constraints).
2. **Visualize the input tables** with a small, concrete sample (5-8 rows per table) — this is the fixed dataset used throughout.
3. **Walk the transformation stage by stage** visually: filtering, joining, grouping, aggregating, ordering — showing the row set *as it exists after each stage*, not just the final answer.
4. **State which SQL concepts are in play** in one line (e.g. "this needs a LEFT JOIN to keep users with zero orders, then a COUNT with GROUP BY").
5. **Only then** show the SQL query, and only if the user hasn't indicated they want to keep working it out themselves.

Never skip straight to step 5. If the user explicitly says "just give me the query," compress steps 2-4 into a short visualization instead of skipping them entirely.

## Workflow A: Teaching a new problem

Trigger: user pastes a problem statement, a LeetCode URL/number, or describes a problem in words ("I'm stuck on the second highest salary problem").

1. If given a URL, fetch it (web_fetch) to get the exact table schemas, column types, and example input/output — LeetCode problem pages are viewable without login for the statement itself. If given just a name/number, use web_search to confirm the exact schema (column names/types, nullability) rather than guessing from memory.
2. Restate the problem and list the table schema(s) (table name, columns, types, keys) plainly.
3. Call `visualize:read_me` with modules `["interactive", "data_viz"]` before the first widget of the session (silently — don't narrate this).
4. Build an interactive widget (`visualize:show_widget`) showing the small sample table(s) as rendered tables, with a way to step through the query's logical stages (e.g. "Step 1: raw table" → "Step 2: after WHERE filter" → "Step 3: after JOIN" → "Step 4: after GROUP BY/aggregate" → "Step 5: after ORDER BY/LIMIT"), highlighting which rows survive, merge, or get dropped at each stage.
5. Ask the user if the transformation makes sense so far before moving on — one short check-in, not a wall of text.
6. If there's a more efficient or more idiomatic approach (e.g. window function vs. self-join for "Nth highest"), show that as a second stage-by-stage widget on the same sample data so the user can compare row-by-row what differs.
7. State which SQL clauses/functions are needed in one line.
8. Ask whether they want to try writing the query themselves first, or want the solution now.
9. If they want the solution: write a clean, idiomatic SQL query (ANSI SQL by default; ask if they specifically want MySQL, PostgreSQL, or another dialect since LeetCode accepts several and syntax for things like window functions, `IFNULL`/`COALESCE`, or date functions can differ), with brief inline comments only at non-obvious steps.

## Workflow B: Debugging a wrong submission

Trigger: user pastes SQL for a LeetCode problem along with any signal it's wrong — "wrong answer", "returns extra rows", "missing rows", "wrong count", or just "what's wrong with this."

1. Get the exact sample input tables and the expected vs. actual output. If the user hasn't given a concrete failing case, ask for it (or use LeetCode's provided example tables plus the user's actual vs expected output) rather than fabricating one.
2. Do NOT explain the bug in prose first. Run the user's *actual query* against the sample tables conceptually, stage by stage, in an interactive widget — show what each clause (WHERE, JOIN, GROUP BY, HAVING, ORDER BY, LIMIT) actually does to the row set at that point.
3. Let the visualization reach the point of divergence — the stage where the row set no longer matches what's needed (e.g. an INNER JOIN silently drops rows that a LEFT JOIN should keep, a missing GROUP BY column causes an aggregation error or wrong grouping, a WHERE clause filters before an aggregate that should use HAVING instead) — and visually flag that stage.
4. After the visualization, explain in 2-3 sentences *why* that stage is wrong (the logical/semantic error, not just "this line is wrong").
5. Suggest the fix — a corrected version of just the broken clause(s), with a one-line explanation of the change. Don't rewrite the whole query unless the whole approach was flawed.
6. If the user's overall *approach* is fundamentally wrong (e.g. tried to solve a "duplicate rows" problem without GROUP BY at all), say so plainly and offer to walk through the correct approach via Workflow A instead of patching broken logic.

## Visualization guidelines

- Load `visualize:read_me` with the `interactive` module (and `data_viz` for table rendering) before the first widget each session.
- Widgets must be **stage-through**: forward/back controls stepping through query stages, with the table(s) rendered as actual rows/columns (not abstract diagrams) at each stage.
- Use small, concrete sample tables (5-8 rows) rather than realistic scale — the point is legibility, not realism. Include at least one edge case in the sample data relevant to the problem (a NULL, a duplicate, a row with no match) so the visualization actually demonstrates the tricky part.
- Highlight row-level changes distinctly: rows dropped by a filter/join in one treatment (e.g. struck through or greyed), rows merged by a join shown with their new combined columns, rows collapsed by GROUP BY shown converging into their aggregate row.
- For the debugging workflow, visually distinguish "rows the query actually produces" from "rows expected" at the point of divergence, side by side.
- Loading messages should be short and plain — e.g. "Filtering rows", "Joining tables", "Grouping and counting".
- Keep each widget to one concrete sample dataset. If a second scenario would help (e.g. a table with no matching rows at all), offer it as a follow-up.

## Final solution artifact

Only produce this when the user has actually seen/reached the final correct solution (end of Workflow A step 9, or after a debugging fix in Workflow B is confirmed correct). Create a single markdown artifact containing, in this order:

1. **Problem summary** — the restated problem and table schema(s).
2. **Approach** — a short written walkthrough of the query logic in prose (the same one covered visually), stage by stage.
3. **Sample walkthrough** — a small text/markdown table showing input rows and the final output rows for the sample data, so the artifact is self-contained without the interactive widget.
4. **SQL query** — complete, clean, with comments only where non-obvious. Note the SQL dialect used.
5. **If this was a debugged submission**: a short "what was wrong" note before the final query, describing the original bug in one or two sentences.

Use an artifact (not inline chat text) since it's a reference document the user will likely want to save or revisit.

## SQL conventions to follow

- Default to ANSI-standard SQL; explicitly note the dialect if using MySQL/PostgreSQL-specific functions (`IFNULL` vs `COALESCE`, `DATE_SUB` vs `-INTERVAL`, window function syntax) since LeetCode's Database problems are typically run against MySQL or PostgreSQL judges — ask if unclear and it matters for the problem.
- Use explicit `JOIN ... ON` syntax rather than implicit comma joins with WHERE conditions, for clarity.
- Prefer `LEFT JOIN` + `IS NULL` or `NOT IN`/`NOT EXISTS` idioms where appropriate for "missing/unmatched rows" problems — pick whichever is more idiomatic and efficient for the specific problem, and briefly say why.
- Use `HAVING` for filters on aggregated values, `WHERE` for filters on raw rows — call this distinction out explicitly when relevant since it's a very common source of bugs.
- Format the query readably: one clause per line, consistent capitalization of keywords.

## What not to do

- Don't show the SQL query before the visualization steps, even if the user seems impatient — compress the visualization instead of skipping it.
- Don't fabricate a "typical" failing case when debugging if the user has real sample data or a real expected/actual output to share — ask for it first.
- Don't produce a wall of text explaining the bug before the user has seen it visually.
- Don't over-explain trivial problems with the same ceremony if the user explicitly just wants a quick answer to a sub-question about a problem already fully covered earlier in the conversation.
- Don't assume a SQL dialect silently when it changes correctness (e.g. window function syntax, date arithmetic) — ask if it's ambiguous and matters.
