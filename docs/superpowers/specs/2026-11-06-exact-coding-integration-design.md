# EXACT Coding integration — design (short)

## Intent

Try EXACT Coding (Predictive TDD v1.2, [marcoemrich/EXACT-Coding](https://github.com/marcoemrich/EXACT-Coding)) on real work to get two things the current brainstorm → plan → subagent-execute flow doesn't give Adam:

1. **Better code quality** — readability and maintainability, as measured in EXACT's own runs (hardest-function cognitive complexity down 2–4×, zero linter smells vs. "just use TDD").
2. **Understanding of what gets produced** — today Adam scans generated code and can't explain it 30 minutes later.

First real use: the implementation PR on the "Python realtime agents in Agent Framework" wayfinder map, which goes upstream to microsoft/agent-framework. Upstream's `AI_CONTRIBUTIONS.md` requires the contributor to understand, explain and own every change, and tests that can detect a broken implementation. Success is judged by feel on real work, not a side-by-side comparison.

## Goals

- EXACT available as opt-in skills in every repo and every Copilot session worktree.
- Checkpoint level (EXACT's Autonomy Level) chosen when a run starts.
- Example Mapping usable two ways: Adam interviewed, or the agent drafts from named sources and Adam corrects.
- Removable in one step if the trial doesn't work out.

## Non-goals

- Editing superpowers or Matt Pocock skills.
- Using EXACT for prototypes or spikes (e.g. the map's prototype ticket).
- Measuring EXACT against the current flow.
- Claude Code, Cursor, OpenCode or pi harnesses.
- Adam making the predictions himself (considered; rejected as too much friction).

## Anti-goals

- EXACT files ending up in an agent-framework PR.
- EXACT starting when it wasn't asked for by name (e.g. on a plain "use TDD").

## Constraints

- Copilot sessions run in git worktrees; untracked files in the main checkout don't appear there (checked: `python/.github/agents/` is absent from both agent-framework worktrees).
- EXACT's Copilot harness (`harness/copilot`, distribution 2026-10-29) hard-codes `.github/skills/...` paths between files, assumes the spec lives in `prompt.md`, and has generic skill names (`red`, `green`, `refactor`, `test-list`).
- Adam's user-level skills are installed with `npx skills` into `~/.agents/skills`, tracked in `~/.agents/.skill-lock.json`.
- EXACT is still evolving upstream; local changes must survive updates.

## Approaches

- **A. Own fork, user-level install (picked).** Fork EXACT, apply the changes below as commits on top of `harness/copilot`, install to `~/.agents/skills`. Works in every worktree; never touches the agent-framework tree; changes rebase onto upstream updates and could be offered back. Cost: small upkeep per upstream update.
- **B. Per-repo, git-excluded.** EXACT's intended install, no edits. Rejected: needs re-copying into every session worktree, and sits beside upstream's own `.github/skills/`, one careless `git add` from a PR.
- **C. Pristine user-level copy + adapter skill.** Vendor files stay identical; a wrapper redirects paths and adds options. Rejected: relies on the agent honouring a path redirect every time.

Adam picked A because it works in worktrees and keeps the trial cleanly reversible.

## Decided

1. **Fork** `marcoemrich/EXACT-Coding` to `adamdougal/EXACT-Coding`; work on a branch cut from `harness/copilot`. This doc is its first commit. Each change below is its own commit so rebasing onto upstream stays tractable.
2. **Skill-relative references.** Replace every `.github/skills/<x>/...` reference so it resolves from the installed skill directories.
3. **`exact-` prefix on every skill** (Adam's call: yes): `exact-predictive-tdd`, `exact-test-list`, `exact-example-mapping`, `exact-red`, `exact-green`, `exact-refactor`, `exact-end-refactor`; `exact-coding` and `exact-coding-isolated-refactor` keep their names. Update all cross-references.
4. **Checkpoint level at invocation.** `/exact-coding <level>` (e.g. `refactor-only`, `every-n-tests 3`) sets the Autonomy Level for that run; with no level, the file default (`full-hitl`) applies. The manual phase skills (`/exact-red`, `/exact-green`, `/exact-refactor`) stay as the "I drive" mode.
5. **Example Mapping draft mode.** Interview stays the default and unchanged. A draft mode (e.g. `/exact-example-mapping draft <tickets, ADR, files>`) has the agent draft story, rules, examples and questions *only* from the named sources, label each item as a draft with its source, then walk Adam through it one rule at a time. Nothing is written to the output file until Adam confirms it. Health checks run as today.
6. **Spec input.** `exact-test-list` reads the spec Adam names, defaulting to the most recent Example Mapping output, instead of `prompt.md`.
7. **Opt-in by name only.** Rewrite skill descriptions so they trigger on "EXACT" / "Predictive TDD" or the slash command, not on a generic request for TDD.
8. **Coexistence with the existing flow** *(my calls, accepted by Adam)*:
   - Brainstorming (or wayfinder/grilling for large work) still settles what and why.
   - For EXACT work, the Example Map and test list replace the superpowers written plan; structure emerges from the tests and the refactor step. Adam agreed.
   - While an EXACT run is active, the agent must not load `superpowers:test-driven-development` or Matt's `tdd`; EXACT governs the loop.
   - Commit after each finished piece of work, not per phase (EXACT forbids phase commits).
   - Each finished piece gets the usual `code-review` skill, run on a model from a different family than the author.
9. **Install and removal.** Install from the fork with `npx skills add` into `~/.agents/skills`; `refactor.agent.md` (isolated-refactor profile) goes to `~/.copilot/agents`. Removal: `npx skills remove` for the `exact-*` skills and delete the agent file. Document both in the fork's README alongside a short "changes from upstream" list.
10. **Language.** Example Mapping output headings in English (upstream mixes in German labels).

## Left to the builder

- Whether `npx skills add` finds skills under the fork's `.github/skills/` on a non-default branch; if not, make the work branch the fork's default or install another reliable way, keeping one-step removal.
- Where the shared `human-in-the-loop.md` lives once installed (it sits in a folder with no `SKILL.md`, which `npx skills` may skip).
- Whether the isolated-refactor subagent resolves from `~/.copilot/agents` in Copilot CLI and the app; if not, note it as a known limitation rather than redesigning.
- Exact wording of the invocation syntax for checkpoint level and draft mode.
- A smoke run of `/exact-coding` on a tiny Python + pytest kata in a scratch directory to prove the installed skills load and cross-reference correctly.
