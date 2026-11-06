---
name: exact-coding-isolated-refactor
description: Predictive Test-Driven Development with a complete up-front test list, falsifiable predictions before deterministic checks, one-test Red-Green-Refactor cycles, domain-responsibility review, and configurable human checkpoints. Invoke only when the user asks for EXACT Coding or Predictive TDD by name, or runs /exact-coding-isolated-refactor. Do NOT invoke for a generic request for TDD or test-first work.
---

# EXACT Coding — Predictive TDD v1.2 — Isolated Refactor

Paths in this skill are relative to this skill's directory.

This is the consumer form of the universal EXACT Coding Predictive-TDD line. It runs in
one shared context: Test List once, then one-test Red-Green-Refactor cycles.
Refactoring uses the Four Rules of Simple Design in an isolated subagent. Refactoring also applies a domain-responsibility review and a mandatory concrete boundary trial whenever it finds a credible semantic seam. This profile deliberately has no APP calculation or metric-driven end pass.

## Preparation

1. Read `../exact-test-list/SKILL.md`.
2. Read `../exact-predictive-tdd/SKILL.md`.
3. Determine the project's language and test framework. Read the matching file
   under `../exact-predictive-tdd/stacks/` before changing code.
4. Read the complete specification and establish the applicable baseline gates.

Do not assume TypeScript or Vitest from this orchestration file. Concrete
inactive-test syntax, examples, paths, commands, compiler behavior, and quality
tools belong only to the selected stack profile.

## Sequence

1. Create the complete ordered test list with every future behavior inactive:
   the driving tests first, the verification tests after them in their
   `verification` group. Then predict and verify that the inactive list
   leaves the full suite green.
2. Apply the Test-List checkpoint from `../exact-predictive-tdd/human-in-the-loop.md`.
3. For exactly one driving behavior at a time, follow the Predictive TDD skill:
   - reconsider whether the next driving test will still fail, and move it
     into the `verification` group before activating it if an earlier
     generalization already covers it,
   - activate one behavior and reach behavioral Red,
   - state falsifiable predictions before deterministic checks and compare them
     explicitly with reality,
   - apply the Red checkpoint,
   - reach Green with the smallest production change,
   - after every Green, delegate the Four Rules review through the `exact-isolated-refactor` custom agent; invoke it even when Green changed no production code,
   - perform the mandatory domain-boundary trial and retain or narrowly undo it based on semantic and test evidence,
   - apply the Refactor checkpoint.
4. When every driving test is active and green, activate the verification
   tests one at a time, each predicted to pass, as described under
   "Verification part" in the Predictive TDD skill.
5. Continue until every listed behavior is executable and all applicable gates
   from the active stack profile pass.
6. When every behavior is green and all gates pass, stop. Tell the user the piece
   is ready for review and commit, and suggest the `code-review` skill. Do not
   commit unless asked.

A test already satisfied by an earlier generalization is legitimate evidence,
not a gap. If you foresee it before activation, it belongs in the
`verification` group. If it surprises you after activation, record the missed
prediction. In neither case manufacture a failure or production change.

## Method boundary

This is Predictive TDD, not TCR. Do not create phase commits or use a hard reset
as a phase mechanism. Preserve successful work in the working tree. If a
refactoring trial fails a check or does not improve intent, undo only that trial
before continuing.

The subagent never manages checkpoints or waits for the user. The main context reads its report, verifies Green, and applies the shared Refactor checkpoint.

## Human-in-the-loop

`../exact-predictive-tdd/human-in-the-loop.md` is the single source of truth for checkpoints. Its default level (`full-hitl`, overridable per run) stops after Test List, Red, and Refactor, and whenever a
prediction is wrong. Green has no default stop.

## Provenance

Exported from the promoted `exact-ptdd-v1.2-verification-split-pi` workflow. The methodology was validated
on GPT-5.6 SOL with pi. The driving/verification split of the test list was measured
as non-inferior to that base on GPT-6.1 Sol with pi and on Opus 5.5 with
Claude Code. Other harness trees ship the
same method; they have been tested manually and in workshops, not in lab batches.
