# Human-in-the-Loop (HITL)

This file is the single source of truth for Predictive TDD checkpoints.

## Autonomy Level

**Default:** `full-hitl`

**Per-run override:** If the user names a level when starting a run
(`/exact-coding refactor-only`, `/exact-coding every-n-tests 3`), use it for the
whole run. State the active level once in the first message of the run. If the
user changes the level mid-run, apply it from the next checkpoint. With no named
level, use the default.

| Level | Stops after |
|---|---|
| `full-hitl` | Test List, Red, Refactor, and prediction mismatch |
| `refactor-only` | Refactor and prediction mismatch |
| `red-only` | Red and prediction mismatch |
| `every-n-tests N` | Every N completed cycles and prediction mismatch |
| `task-end` | End of task; prediction mismatches are reported but do not stop |
| `autonomous` | Never |

Green has no default checkpoint because it is the most mechanical phase.

At a required checkpoint, summarize the evidence and wait for explicit human
approval. After Test List, show the ordered inactive behaviors. After Red, show
the active behavior, prediction, actual result, and why the failure is the
intended behavioral Red. After Refactor, name the Four Rules decision, any
change made, and the passing gates.

When a prediction is wrong, preserve predicted and actual outcomes, stop feature
implementation, and ask whether to investigate or continue. Only `autonomous`
may investigate and resume without waiting.
