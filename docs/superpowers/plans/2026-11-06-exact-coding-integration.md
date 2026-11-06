# EXACT Coding Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A fork of EXACT Coding's Copilot harness, adapted per the design, installed as opt-in user-level skills that work in every repo and worktree and can be removed in one step.

**Architecture:** All changes are commits on branch `adamdougal-copilot` of `adamdougal/EXACT-Coding`, cut from upstream `harness/copilot` (distribution `2026-10-29`). Skill files stay under `.github/skills/` so `npx skills` discovers them; cross-file references become relative to each skill's own directory. A guard script (`scripts/check-exact-skills.sh`) encodes every structural rule from the design and is the "test" each task turns green.

**Tech Stack:** Markdown skills (Copilot `SKILL.md` format), bash, `npx skills` (vercel-labs skills CLI), GitHub CLI, Copilot CLI 1.0.105 (`copilot -p`), Python 3.11+ / pytest for the smoke kata.

**Spec:** `docs/superpowers/specs/2026-11-06-exact-coding-integration-design.md` (copied in by Task 1 from `/Users/adamdougal/.copilot/session-state/f265f507-eb70-4b82-a69f-d1e448e79d94/files/2026-11-06-exact-coding-integration-design.md`).

## Prerequisites (done by the coordinator before execution)

1. `adamdougal/EXACT-Coding` exists as a fork of `marcoemrich/EXACT-Coding` (all branches).
2. Branch `adamdougal-copilot` exists on the fork at the same commit as `harness/copilot` (`0dd2789`), and is the fork's default branch. The name must not contain `/`: `npx skills` misparses `tree/harness/copilot` as branch `harness`.
3. The fork is a configured repository in the app and your session runs on branch `adamdougal-copilot` directly (no worktree).

This checkout's own `.github/skills/` will show up as project skills in your session. Don't invoke them: they are the files you're editing.

## Global Constraints

- Every skill directory under `.github/skills/` is named `exact-*` and its frontmatter `name:` equals the directory name.
- Final skill set (9): `exact-coding`, `exact-coding-isolated-refactor`, `exact-predictive-tdd`, `exact-test-list`, `exact-example-mapping`, `exact-red`, `exact-green`, `exact-refactor`, `exact-end-refactor`.
- Custom agent: `.github/agents/exact-isolated-refactor.agent.md`, `name: exact-isolated-refactor`.
- No reference to `.github/skills/` or `.github/agents/` paths inside skill or agent files. References between skills use `../exact-<skill>/...`; references within a skill use bare relative paths.
- Default Autonomy Level stays `full-hitl`.
- Keep upstream's `LICENSE` (MIT, Ferdi Ade & Marco Emrich) and method text unchanged except where a task says otherwise.
- No phase commits inside EXACT runs; this plan's own commits are per task.

## Review Focus

1. **Installed via symlink into another agent directory:** `../exact-*` references must still resolve from wherever Copilot loads the skills. Task 5 runs the guard against the installed location.
2. **Upstream update reintroduces old names or `.github/skills/` paths after a rebase:** the guard must catch it. Task 5's README tells you to run it after every rebase.
3. **Per-run level ignored:** a run started with `autonomous` stops anyway, or a run with no level never stops. Task 6 covers both.
4. **Draft mode invents an example the sources don't contain.** Task 6's draft smoke run uses a source with a rule that has no example.
5. **Another TDD skill loads during an EXACT run** (superpowers `test-driven-development` or Matt Pocock's `tdd`). Task 6 inspects the run transcript.

---

### Task 1: Docs and guard script

**Files:**
- Create: `docs/superpowers/specs/2026-11-06-exact-coding-integration-design.md` (copy of the design)
- Create: `docs/superpowers/plans/2026-11-06-exact-coding-integration.md` (copy of this plan)
- Create: `scripts/check-exact-skills.sh`

**Interfaces:**
- Produces: `scripts/check-exact-skills.sh`. Env vars `SKILLS_DIR` (default `.github/skills`) and `AGENTS_DIR` (default `.github/agents`). Prints `FAIL <id>: <detail>` per violation, exits 1 if any, else prints `OK` and exits 0. It only inspects `$SKILLS_DIR/exact-*` directories, plus the repo-only check C2b.

- [ ] **Step 1: Copy the design and this plan into `docs/superpowers/`** at the paths above.

- [ ] **Step 2: Write `scripts/check-exact-skills.sh`** (`set -euo pipefail`, executable) with these checks. `<files>` means every file under `$SKILLS_DIR/exact-*/` plus `$AGENTS_DIR/exact-isolated-refactor.agent.md`.
  - **C1 stale paths:** `grep -nE '\.github/(skills|agents)/'` over `<files>` finds nothing.
  - **C2 naming:** each `$SKILLS_DIR/exact-*/` has `SKILL.md` whose `name:` equals the directory name. **C2b** (only when `SKILLS_DIR` is the default): no directory in `.github/skills/` lacks the `exact-` prefix. **C2c:** all 9 skills from Global Constraints are present.
  - **C3 references resolve:** every backticked `../exact-<name>/<path>` in `$SKILLS_DIR/exact-*/SKILL.md` exists relative to that skill's directory (a trailing `/` means a directory). Every backticked `human-in-the-loop.md` in `exact-predictive-tdd/SKILL.md` exists beside it.
  - **C4 old names:** `` grep -nE '`/?(red|green|refactor|test-list|predictive-tdd|example-mapping|end-refactor)`' `` over `<files>` finds nothing, and neither does `grep -nE '(^|[ (`])/(red|green|refactor|test-list|example-mapping)\b'`.
  - **C5 agent:** `$AGENTS_DIR/exact-isolated-refactor.agent.md` exists and contains `name: exact-isolated-refactor`.
  - **C6 spec input:** `grep -n 'prompt\.md'` over `<files>` finds nothing.
  - **C7 English output:** `grep -nE '\((gelb|blau|gruen|rot|ausgelagert)\)|Regel|Keine -|Titel der'` in `exact-example-mapping/SKILL.md` finds nothing.
  - **C8 opt-in:** `grep -nE 'asks for TDD or|prepare a feature for TDD|clarify requirements before coding'` over `<files>` finds nothing.
  - **C9 features:** `Per-run override` appears in `exact-predictive-tdd/human-in-the-loop.md`, `## Other TDD skills` in `exact-predictive-tdd/SKILL.md`, and `## Draft mode` in `exact-example-mapping/SKILL.md`.

- [ ] **Step 3: Run it and confirm it fails**

  Run: `bash scripts/check-exact-skills.sh; echo "exit=$?"`
  Expected: `exit=1` with FAIL lines for C1, C2 or C2b/C2c, C4, C5, C6, C7, C8 and C9. Upstream has no `exact-predictive-tdd` yet, so C9 also reports missing files.

- [ ] **Step 4: Commit**

  ```bash
  git add docs scripts/check-exact-skills.sh
  git commit -m "chore: add integration design, plan and skill guard script"
  ```

### Task 2: Rename skills, relocate shared checkpoint file, make references skill-relative

**Files:**
- Rename (`git mv`): `.github/skills/{predictive-tdd,test-list,example-mapping,red,green,refactor,end-refactor}` → `.github/skills/exact-{same}`
- Move: `.github/skills/exact-coding-shared/human-in-the-loop.md` → `.github/skills/exact-predictive-tdd/human-in-the-loop.md`; remove the empty `exact-coding-shared/`
- Rename: `.github/agents/refactor.agent.md` → `.github/agents/exact-isolated-refactor.agent.md`
- Modify: every `SKILL.md` under `.github/skills/` and the agent file

**Interfaces:**
- Consumes: guard script (Task 1).
- Produces: the 9 skill names and the agent name in Global Constraints. Shared checkpoint file at `exact-predictive-tdd/human-in-the-loop.md`.

- [ ] **Step 1: Do the renames and the move** listed above.

- [ ] **Step 2: Update frontmatter `name:`** in each renamed `SKILL.md` and in the agent file.

- [ ] **Step 3: Rewrite path references** using this mapping:

  | Old | New (from another skill) | New (inside `exact-predictive-tdd/SKILL.md`) |
  |---|---|---|
  | `.github/skills/test-list/SKILL.md` | `../exact-test-list/SKILL.md` | — |
  | `.github/skills/predictive-tdd/SKILL.md` | `../exact-predictive-tdd/SKILL.md` | — |
  | `.github/skills/predictive-tdd/stacks/` | `../exact-predictive-tdd/stacks/` | — |
  | `.github/skills/exact-coding-shared/human-in-the-loop.md` | `../exact-predictive-tdd/human-in-the-loop.md` | `human-in-the-loop.md` |

  In every `SKILL.md` that has such references, add this line directly under the H1: `Paths in this skill are relative to this skill's directory.`

- [ ] **Step 4: Rewrite skill and agent names in the text**
  - `` `red` ``, `` `green` ``, `` `test-list` ``, `` `end-refactor` `` → `exact-` prefixed.
  - `` `refactor` `` as a skill → `` `exact-refactor` ``.
  - "`refactor` custom agent" / "per-cycle `refactor` agent" (in `exact-coding-isolated-refactor`, `exact-refactor`, `exact-end-refactor`) → `` `exact-isolated-refactor` `` custom agent.
  - `/red`, `/green`, `/refactor` in descriptions → `/exact-red`, `/exact-green`, `/exact-refactor`.
  - In `exact-example-mapping`, replace `` (`test-list` skill) converts those examples into `it.todo()` test cases `` with `` (`exact-test-list` skill) converts those examples into inactive test cases ``. `it.todo()` is TypeScript-only.

- [ ] **Step 5: Run the guard**

  Run: `bash scripts/check-exact-skills.sh; echo "exit=$?"`
  Expected: no FAIL lines for C1, C2/C2b/C2c, C3, C4 or C5. C6–C9 still fail.

- [ ] **Step 6: Commit**

  ```bash
  git add -A .github
  git commit -m "refactor: prefix skills with exact- and make references skill-relative"
  ```

### Task 3: Opt-in descriptions, coexistence rules, per-run checkpoint level

**Files:**
- Modify: frontmatter `description:` in all 9 `SKILL.md`
- Modify: `.github/skills/exact-predictive-tdd/SKILL.md` (new section)
- Modify: `.github/skills/exact-predictive-tdd/human-in-the-loop.md`
- Modify: `.github/skills/exact-coding/SKILL.md`, `.github/skills/exact-coding-isolated-refactor/SKILL.md`

**Interfaces:**
- Consumes: names from Task 2.
- Produces: invocation syntax `/exact-coding [<level>]`, where `<level>` is any level from the Autonomy Level table, e.g. `refactor-only` or `every-n-tests 3`.

- [ ] **Step 1: Make descriptions opt-in by name.** Keep each description's "what it does" clause and replace the trigger clause:
  - `exact-coding`, `exact-coding-isolated-refactor`: "Invoke only when the user asks for EXACT Coding or Predictive TDD by name, or runs /exact-coding (/exact-coding-isolated-refactor). Do NOT invoke for a generic request for TDD or test-first work."
  - `exact-predictive-tdd`: "Method reference for EXACT Coding; read by the exact-* skills. Invoke only when the user asks for Predictive TDD by name or to continue an EXACT Coding cycle."
  - `exact-test-list`, `exact-red`, `exact-green`, `exact-refactor`: "Part of EXACT Coding. Invoke only when the user runs /exact-<name> or an EXACT Coding run reaches this phase."
  - `exact-example-mapping`: "Invoke only when the user asks for Example Mapping by name or runs /exact-example-mapping." Delete the "clarify requirements before coding" and "prepare a feature for TDD" triggers, which overlap brainstorming.
  - `exact-end-refactor`: "Invoke only when the user asks for exact-end-refactor by name."

- [ ] **Step 2: Add `## Other TDD skills` to `exact-predictive-tdd/SKILL.md`**, just before `## Preparation`. It says:
  - While an EXACT Coding run or phase is active, this skill governs the TDD loop.
  - Do not load `test-driven-development` (superpowers) or `tdd` (Matt Pocock), even if they seem to apply.
  - Do not write a separate implementation plan: the example map and the test list are the plan.

- [ ] **Step 3: Add the per-run override to `human-in-the-loop.md`.** Rename `**Current setting:**` to `**Default:**` (value stays `full-hitl`) and add a `**Per-run override:**` paragraph saying:
  - If the user names a level when starting a run (`/exact-coding refactor-only`, `/exact-coding every-n-tests 3`), use it for the whole run.
  - State the active level once in the first message of the run.
  - If the user changes the level mid-run, apply it from the next checkpoint.
  - With no named level, use the default.

- [ ] **Step 4: Finish the piece of work in `exact-coding` and `exact-coding-isolated-refactor`.**
  - In their `## Human-in-the-loop` sections, replace "Its default `full-hitl` level" with "Its default level (`full-hitl`, overridable per run)".
  - Append to `## Sequence`: "6. When every behavior is green and all gates pass, stop. Tell the user the piece is ready for review and commit, and suggest the `code-review` skill. Do not commit unless asked."

- [ ] **Step 5: Run the guard**

  Run: `bash scripts/check-exact-skills.sh; echo "exit=$?"`
  Expected: C8 passes. Of C9, only the `## Draft mode` check still fails, along with C6 and C7.

- [ ] **Step 6: Commit**

  ```bash
  git add -A .github
  git commit -m "feat: opt-in triggers, per-run checkpoint level, coexistence with other TDD skills"
  ```

### Task 4: Example Mapping draft mode, English output, spec input

**Files:**
- Modify: `.github/skills/exact-example-mapping/SKILL.md`
- Modify: `.github/skills/exact-test-list/SKILL.md:13`

**Interfaces:**
- Produces: invocation `/exact-example-mapping draft <sources>`, where sources are tickets, an ADR or files. The output file format that `exact-test-list` reads.

- [ ] **Step 1: Add `## Modes` and `## Draft mode`** after "What is Example Mapping?":
  - **Interview** is the default and unchanged.
  - **Draft** is selected by `draft` in the invocation or by "draft it from …", with named sources.
  - Draft rules:
    - Draft story, rules, examples and questions only from the named sources.
    - Tag each card `(draft — <source>)`.
    - Where the sources are silent on a rule, a boundary or the four mandatory question categories, write a question, never an example.
    - Then walk the user through one rule at a time, showing the rule and its examples. The user confirms, corrects or drops each card.
    - Write nothing to the output file until every card is confirmed.
    - Steps 5–7 (new stories, review, evaluate) run as in interview mode.
  - Add one sentence to "CRITICAL: You are a FACILITATOR": in draft mode the named sources stand in for the user's first answer, and the user's confirmation is still required for every card.

- [ ] **Step 2: Translate the output template to English:**
  - `Story (yellow)`, `Rules (blue)`, `Rule N:`, `Examples (green)`, `For Rule N:`, `Questions (red)`, `New Stories (sliced out)`.
  - Placeholder `<Title of the sliced-out story>`.
  - Empty marker `(or: "None - the scope held.")`.

- [ ] **Step 3: Change the default output location** from `src/<feature-name>-example-mapping.md` to "the location the user specifies; if none, ask". A default under `src/` would put map files into PRs, such as an agent-framework upstream PR.

- [ ] **Step 4: Replace `exact-test-list` line 13** with: "Read the specification the user names, or else the most recent Example Mapping output from this conversation; if neither exists, ask for it. Read it thoroughly: every rule, every example, every clarifying question (?)."

- [ ] **Step 5: Run the guard**

  Run: `bash scripts/check-exact-skills.sh; echo "exit=$?"`
  Expected: `OK`, `exit=0`.

- [ ] **Step 6: Commit**

  ```bash
  git add -A .github
  git commit -m "feat(example-mapping): draft mode, English output, ask for output location; test-list reads named spec"
  ```

### Task 5: README, publish, install

**Files:**
- Modify: `README.md` (new top section)

**Interfaces:**
- Consumes: everything above.
- Produces: the installed skills, at `~/.agents/skills/exact-*` or wherever `npx skills` puts Copilot's global skills (record the actual path). The agent at `~/.copilot/agents/exact-isolated-refactor.agent.md`.

- [ ] **Step 1: Add a `## This fork` section at the top of `README.md`:**
  - **Purpose:** one line.
  - **Changes from upstream:** one bullet per Task 2–4 change.
  - **Install:**
    ```bash
    npx skills add adamdougal/EXACT-Coding -g -a github-copilot -s '*' -y
    cp .github/agents/exact-isolated-refactor.agent.md ~/.copilot/agents/
    ```
  - **Remove:**
    ```bash
    npx skills remove -g -s exact-coding exact-coding-isolated-refactor exact-predictive-tdd exact-test-list exact-example-mapping exact-red exact-green exact-refactor exact-end-refactor -y
    rm ~/.copilot/agents/exact-isolated-refactor.agent.md
    ```
  - **Update from upstream:** fetch `upstream harness/copilot`, rebase, run `scripts/check-exact-skills.sh`, `git push --force-with-lease`, then `npx skills update -g -y`.
  - **Usage:** `/exact-example-mapping [draft <sources>]`, then `/exact-coding [<level>]`, or `/exact-red`, `/exact-green`, `/exact-refactor` to drive manually.
  - **Install the whole set:** the skills reference each other, so a partial install breaks.

- [ ] **Step 2: Commit and push**

  ```bash
  git add README.md && git commit -m "docs: describe this fork, install, removal and upstream updates"
  git push origin adamdougal-copilot
  ```

- [ ] **Step 3: Verify discovery from GitHub**

  Run: `npx -y skills add adamdougal/EXACT-Coding --list`
  Expected: exactly the 9 `exact-*` names, no others.

- [ ] **Step 4: Check for collisions, then install**

  Run: `npx -y skills list -g` and confirm no `exact-*` exists yet. Then run the two install commands from Step 1.
  Expected: the CLI reports 9 installed. `~/.agents/.skill-lock.json` has 9 `exact-*` entries with `"source": "adamdougal/EXACT-Coding"`, and the agent file exists in `~/.copilot/agents/`.

- [ ] **Step 5: Run the guard against the installed location** (Review Focus 1)

  Run: `SKILLS_DIR=<installed skills dir> AGENTS_DIR=~/.copilot/agents bash scripts/check-exact-skills.sh`
  Expected: `OK`. If the CLI also symlinked into another directory Copilot reads, for example `~/.copilot/skills`, run it against that directory too.

### Task 6: Smoke runs

Use a scratch directory outside any repo, so only user-level skills load.

**Files (scratch, not committed):** `/tmp/exact-smoke/{pyproject.toml,wrap_up_example_map.md,wrap_up_notes.md}`

- [ ] **Step 1: Set up the kata**
  - `pyproject.toml`: project `wrap_up`, Python `>=3.11`, `[tool.pytest.ini_options] testpaths = ["tests"]`, `pythonpath = ["src"]`.
  - `python3 -m venv .venv && .venv/bin/pip install -q pytest`.
  - `wrap_up_example_map.md` in the Task 4 English format:
    - Story: "As a contact-centre supervisor I want each finished call given a wrap-up code so that I can report on call outcomes."
    - Rule 1: a call shorter than 30 seconds is `SHORT`. Examples: 12 s, no hang-up on hold → `SHORT`; 30 s, no hang-up → `COMPLETED`.
    - Rule 2: a caller who hung up while on hold is `ABANDONED`, whatever the duration. Examples: 45 s, hung up on hold → `ABANDONED`; 10 s, hung up on hold → `ABANDONED`.
    - Rule 3: otherwise `COMPLETED`. Example: 120 s, no hang-up → `COMPLETED`.
    - Questions: "None - all ambiguities were resolved."
  - `wrap_up_notes.md`, the draft-mode source: the same three rules with their examples, plus "Rule 4: calls transferred to a person get `TRANSFERRED`" with **no** example and no precedence against Rule 2.

- [ ] **Step 2: Autonomous run** (Review Focus 3, 5)

  Run in `/tmp/exact-smoke/run-a` (copy of the kata):
  ```bash
  copilot -p "Run EXACT Coding (the exact-coding skill) at Autonomy Level autonomous on the spec in wrap_up_example_map.md. Use .venv for Python." --allow-all-tools --allow-all-paths > run.log 2>&1
  ```
  Expected:
  - `run.log` contains `## Test List`, `Test List Created:`, `## Red`, `Red Phase Complete:`, `**Compilation Prediction**`, `**Runtime Prediction**`, `## Green` and `## Refactor`.
  - No "not found" or "no such file" errors for any `../exact-` path.
  - No load of the `test-driven-development` or `tdd` skill.
  - `.venv/bin/pytest -q` exits 0 with ≥5 passed and 0 skipped.

- [ ] **Step 3: Default-level run** (Review Focus 3)

  Run in a fresh copy `run-b`:
  ```bash
  copilot -p "Run EXACT Coding (the exact-coding skill) on the spec in wrap_up_example_map.md. Use .venv for Python." --allow-all-tools --allow-all-paths > run.log 2>&1
  ```
  Expected: `run.log` contains `Test List Created:` and does **not** contain `## Red`, because `full-hitl` stops after the test list.

- [ ] **Step 4: Draft-mode run** (Review Focus 4)

  Run in a fresh copy `run-c`:
  ```bash
  copilot -p "/exact-example-mapping draft wrap_up_notes.md" --allow-all-tools --allow-all-paths > run.log 2>&1
  ```
  If `-p` doesn't expand slash commands, use "Run the exact-example-mapping skill in draft mode from wrap_up_notes.md."
  Expected:
  - The output presents cards tagged `(draft — wrap_up_notes.md)` and asks about Rule 4, either for an example or about precedence against Rule 2.
  - No example for `TRANSFERRED` appears.
  - No example-map file has been written.

- [ ] **Step 5: Custom agent visible**

  Run: `copilot -p "List the names of your available custom agents. Do nothing else." --allow-all-tools > agents.log 2>&1`
  Expected: `agents.log` names `exact-isolated-refactor`. If it doesn't, add it to README's `## This fork` as a known limitation; don't redesign.

- [ ] **Step 6: Report.** Summarise each run's pass or fail against these expectations, and quote any failing excerpt from `run.log`. If anything failed, fix it in the fork as its own commit, push, run `npx skills update -g -y`, and rerun only the failed smoke run. Delete `/tmp/exact-smoke` when done.
