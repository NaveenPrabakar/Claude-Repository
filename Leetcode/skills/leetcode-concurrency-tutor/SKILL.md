---
name: leetcode-concurrency-tutor
description: Teach and debug LeetCode-style Concurrency problems (multithreading with locks, semaphores, condition variables, producer-consumer, print-in-order style problems) using interactive thread-timeline/interleaving visualizations before ever showing the code. Use whenever the user pastes, names, links, or describes a LeetCode Concurrency problem, asks for help with thread synchronization for a LeetCode-style question, mentions semaphores/mutexes/locks/condition variables/deadlock/race conditions in the context of a practice problem, or submits concurrent code that deadlocks, races, or prints in the wrong order on a LeetCode Concurrency question. Ask which language they want (Java, Python, C++, and Go are the common LeetCode choices) if not obvious from context or pasted code. 
---

# LeetCode Concurrency Tutor

Teaches LeetCode Concurrency problems by visualizing thread timelines and interleavings — showing which thread is running, blocked, or waiting at each point in time — and diagnoses wrong submissions (deadlocks, races, wrong ordering) the same way — visually, before verbally. Code is always the *last* thing shown, never the first.

## Choosing a language

This skill is language-agnostic but concurrency primitives differ meaningfully by language. Before teaching or writing any code:

- If the user pasted code, infer the language (and its concurrency primitives — `synchronized`/`Lock`/`Semaphore` in Java, `threading.Lock`/`Condition` in Python, `std::mutex`/`std::condition_variable` in C++, channels/`sync.WaitGroup`/`sync.Mutex` in Go) from it.
- If the user named a language, use it.
- If neither is clear, ask once. Default to Java if the user has used it earlier, since it's the most common LeetCode Concurrency choice.
- Keep the chosen language and its idiomatic primitives consistent for the session unless the user asks to switch.

## Core rule: never lead with code

For every problem, whether teaching from scratch or debugging a submission, the sequence is always:

1. **Restate the problem** in 2-3 plain sentences (how many threads, what each thread must do, what ordering/synchronization constraint must hold).
2. **Visualize the threads and the constraint** using an interactive step-through widget — a timeline or lane view, no code yet.
3. **Walk a naive/unsynchronized attempt** visually, showing how it *can* interleave badly (e.g. threads racing, wrong print order) even if it sometimes looks right.
4. **Reveal the correct synchronization approach** with its own visualization, showing exactly what's blocking which thread and why, and how that forces the correct interleaving.
5. **Name the primitive(s) used** in one line (e.g. "two semaphores, one signaling 'foo done' and one signaling 'bar done'").
6. **Only then** show the code in the chosen language, and only if the user hasn't indicated they want to keep working it out themselves.

Never skip straight to step 6. If the user explicitly says "just give me the code," compress steps 2-5 into a short visualization instead of skipping them entirely.

## Workflow A: Teaching a new problem

Trigger: user pastes a problem statement, a LeetCode URL/number, or describes a problem in words ("I'm stuck on print in order").

1. If given a URL, fetch it (web_fetch) to get exact constraints (number of threads, exact method signatures expected). If given just a name/number, use web_search to confirm exact constraints rather than guessing from memory.
2. Restate the problem back to the user, naming each thread/method involved (e.g. "thread A calls `first()`, thread B calls `second()`, thread C calls `third()`, and they must always print in that order regardless of scheduling").
3. Confirm the target language if not already established.
4. Call `visualize:read_me` with modules `["interactive", "diagram"]` before the first widget of the session (silently — don't narrate this).
5. Build an interactive widget (`visualize:show_widget`) with a timeline/swimlane per thread, letting the user step forward through time and see, at each step, which thread is Running, Blocked/Waiting, or Done — and what shared state (a flag, a counter, a semaphore's permit count) looks like at that instant. Show a naive unsynchronized version first, illustrating at least one bad interleaving.
6. Ask the user if the problem/race makes sense before moving on — one short check-in.
7. Build a second timeline widget for the correctly-synchronized version on the same thread setup, so the user can see exactly where a thread now blocks/waits that didn't before, and why that guarantees correct ordering.
8. Name the synchronization primitive(s) used and why they fit (e.g. semaphore for signaling between specific threads vs. a lock for mutual exclusion vs. a condition variable for "wait until a condition holds").
9. Ask whether they want to try coding it themselves first, or want the solution now.
10. If they want the solution: write idiomatic code in the chosen language matching LeetCode's expected class/method signature, with brief inline comments only at the non-obvious synchronization points.

## Workflow B: Debugging a wrong/deadlocking submission

Trigger: user pastes concurrent code for a LeetCode problem along with any signal it's wrong — "deadlocks", "prints in wrong order sometimes", "flaky", "hangs", or just "what's wrong with this."

1. Get the exact symptom: does it hang (deadlock), print inconsistently (race), or reliably print wrong (logic error)? Ask if unclear, since the diagnosis path differs.
2. Do NOT explain the bug in prose first. Trace the user's *actual code* on a timeline/swimlane widget, step by step, showing each thread's real state (Running/Blocked/Waiting/Done) and the real state of shared variables/locks/semaphores at each step.
3. Let the visualization reach the point of divergence or the deadlock:
   - **Deadlock**: show all involved threads simultaneously Blocked, each waiting on a resource held by another — a visual "wait cycle."
   - **Race/wrong order**: show the specific interleaving that produces the bad result, flagging the exact step where an unsynchronized access lets the wrong thread proceed.
4. After the visualization, explain in 2-3 sentences *why* that's happening (the missing/incorrect synchronization, not just "this line is wrong").
5. Suggest the fix — a corrected version of just the broken synchronization (e.g. releasing the right semaphore, fixing lock acquisition order, adding a missing `notify`/`signal`), with a one-line explanation. Don't rewrite the whole solution unless the whole approach was flawed.
6. If the user's overall *approach* is fundamentally wrong (e.g. tried to enforce ordering with a shared boolean and busy-waiting instead of a proper primitive), say so plainly and offer to walk through the correct approach via Workflow A instead of patching broken logic.

## Visualization guidelines

- Load `visualize:read_me` with the `interactive` module (and `diagram` for a wait-cycle/resource graph when diagnosing deadlocks) before the first widget each session.
- Widgets must be **step-through timelines**: forward/back controls, one lane per thread, each thread's state (Running/Blocked/Waiting/Done) visually distinct at every step, plus a panel showing shared-state values (semaphore permit counts, lock ownership, flags) at that instant.
- Use a small, concrete number of threads (2-4) matching the problem — legibility over realism.
- Highlight the exact instant a thread blocks and the exact instant it's released, and by what/whom.
- For deadlock debugging, make the "wait cycle" visually obvious (e.g. arrows showing thread A waits on resource held by thread B, which waits on a resource held by thread A).
- For race debugging, show at least two possible interleavings side by side if that's what makes the bug clear (the "lucky" ordering that looks fine vs. the "unlucky" one that breaks).
- Loading messages should be short and plain — e.g. "Scheduling threads", "Tracking the semaphore", "Watching for the wait cycle".
- Keep each widget to one concrete scenario. Offer additional interleavings as follow-ups rather than cramming them in.

## Final solution artifact

Only produce this when the user has actually seen/reached the final correct solution (end of Workflow A step 10, or after a debugging fix in Workflow B is confirmed correct). Create a single markdown artifact containing, in this order:

1. **Problem summary** — the restated problem and thread/method setup.
2. **Approach** — a short written walkthrough of the synchronization strategy in prose (the same one covered visually).
3. **Sketch of the approach** — a text-based timeline/swimlane sketch capturing which thread blocks on what, so the artifact is self-contained without the interactive widget.
4. **Primitives used** — named explicitly (e.g. `Semaphore(0)`, `ReentrantLock`, `Condition`) with a one-line reason each was chosen.
5. **Solution code** — complete, idiomatic, in the chosen language, matching LeetCode's exact method signature, with comments only at non-obvious synchronization points.
6. **If this was a debugged submission**: a short "what was wrong" note before the final code, describing the original deadlock/race in one or two sentences.

Use an artifact (not inline chat text) since it's a reference document the user will likely want to save or revisit.

## Concurrency conventions to follow

- Match LeetCode's exact class/method signature for the problem in the chosen language, verified via web_search/web_fetch rather than assumed.
- Prefer the primitive that directly matches the constraint being enforced: a `Semaphore` for "signal N times, wait for signal" patterns; a `Lock`/`synchronized` block for mutual exclusion over shared state; a `Condition`/`wait`-`notify` pair for "wait until a predicate holds." Avoid busy-waiting (`while(!flag){}` spin loops) except to briefly show why it's a bad naive attempt.
- Always initialize semaphore permit counts correctly and explain the initial value's meaning (e.g. `new Semaphore(0)` means "nothing has happened yet, first acquire() will block").
- Note real deadlock-prevention principles when relevant (consistent lock ordering, avoiding nested lock acquisition where possible) without turning it into an unrelated systems-design lecture.
- State correctness in terms of guarantees, not just "it worked when I ran it" — a solution that merely does not exhibit its race in casual testing is not correct.

## What not to do

- Don't show code before the visualization steps, even if the user seems impatient — compress the visualization instead of skipping it.
- Don't fabricate a "typical" failing interleaving when debugging if the user has a real symptom/log to share — ask for it first.
- Don't produce a wall of text explaining the bug before the user has seen it visually.
- Don't over-explain trivial problems with the same ceremony if the user explicitly just wants a quick answer to a sub-question about a problem already fully covered earlier in the conversation.
- Don't claim a race-y solution is "fixed" just because a single visualized run looks correct — call out explicitly what guarantees correctness (e.g. "this works because the semaphore permit count can never go negative here, not because of timing luck").
