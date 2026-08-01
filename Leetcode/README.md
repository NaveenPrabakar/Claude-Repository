# LeetCode Tutor Suite

A plugin bundling six visual, step-through tutors — one per LeetCode question category. Each skill teaches new problems and debugs wrong submissions by showing what's actually happening (data transforming, threads interleaving, the event loop ticking) *before* ever showing code or a query, following the same never-lead-with-code philosophy as the original `leetcode-tutor` skill.

## Skills included

| Skill | Category | What it visualizes |
|---|---|---|
| `leetcode-algorithms-tutor` | Algorithms | Array/pointer/data-structure state, step by step. Works in any language (Java, Python, C++, JS, Go, ...) — asks which one if unclear. |
| `leetcode-database-tutor` | Database (SQL) | Tables transforming stage by stage: filter → join → group → order. |
| `leetcode-shell-tutor` | Shell | A text file transforming through each stage of a pipe (`grep` \| `awk` \| `sort` ...). |
| `leetcode-concurrency-tutor` | Concurrency | Thread timelines/swimlanes: who's Running/Blocked/Waiting, and shared-state values, at each tick. |
| `leetcode-javascript-tutor` | JavaScript | JS-specific mechanics: closures/scope chains, `this` binding at the call site, and the event loop's call stack + microtask/macrotask queues. Hands off to the Algorithms tutor for problems that are just algorithms written in JS. |
| `leetcode-pandas-tutor` | Pandas | DataFrames transforming stage by stage, including shape/column/dtype changes. |

## Shared design

Every skill in this suite follows the same five/six-step shape:

1. Restate the problem.
2. Visualize the input.
3. Walk a naive/brute-force attempt.
4. Reveal the correct/optimal approach, visually contrasted with step 3.
5. Name the key concept/complexity in one line.
6. Only then, show code — and only if the user hasn't said they want to work it out themselves.

Debugging a wrong submission follows the same visual-first order: trace the user's *actual* submission against a concrete failing case, flag the exact point of divergence visually, explain why in a couple sentences, then offer a targeted fix.

## Installing

Copy this folder (`leetcode-tutor-suite/`) into your plugins directory, or install the packaged `.plugin`/skill files individually if your client only supports single skills rather than plugins.
