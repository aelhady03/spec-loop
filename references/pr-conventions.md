# PR & branch conventions

Applies to every task produced by spec-loop. The goal: a reviewer should be
able to approve in ~15 minutes because they already saw the spec, not because
the PR description re-explains everything.

## Branch naming
`agent/<ticket-id>-<task-slug>`

The `agent/` prefix exists so agent-authored branches are trivially
filterable (`git branch --list 'agent/*'`) for branch-protection rules,
auto-cleanup, or extra scrutiny — distinct from human-authored `feature/…`
or `fix/…` branches.

## Commit convention
Conventional Commits, scoped to the touched area, referencing the task id:

```
feat(auth): add session refresh endpoint [T3]
test(auth): red tests for session refresh [T3]
fix(auth): handle expired refresh token [T3]
```

Types: `feat`, `fix`, `test`, `docs`, `refactor`, `chore`. One logical change
per commit; the task's red→green→refactor cycle is allowed to be multiple
commits.

## PR title
`[<ticket-id>] <task title>` — e.g. `[PROJ-482] Add session refresh endpoint`

## PR description
Do not re-explain the design. Link instead:
- Spec: `docs/product-specs/<ticket-id>-<slug>.md`
- Plan: `docs/exec-plans/active/<ticket-id>-<slug>/plan.md`
- This task's row in `tasks.md`
- What changed (bullet list, not prose)
- Test evidence (which tests are new/red→green, coverage of the acceptance
  criteria this task closes) — plus runtime verification evidence
  (screenshot/recording/log-query result) per test-plan.md's Runtime
  Verification section, when there's a runtime surface to drive.

## Diff-size gate
Default ceiling: **~400 changed lines** (excluding generated/lockfiles).
If a task's implementation would exceed this, that's a signal the task was
under-split — go back to tasks.md and split it, rather than opening an
oversized PR. Exceptions require a note in the PR explaining why the slice
can't be split further (e.g. an atomic schema migration).

## One task, one PR
Each task in tasks.md maps to exactly one PR, stacked on the previous task's
branch when there's a real dependency, or opened independently when there
isn't (prefer independence — it parallelizes review).

## Merge gate
At spec-loop's default autonomy (L3, see autonomy-levels.md), a PR does not
merge until:
1. All tests for this task are green.
2. The adversarial review loop (see review-rubric.md) reports zero blocking
   findings, or every blocking finding has an explicit human override.
3. A human has looked at it — merge itself is a human (or human-delegated
   bot merge) action.

At L4, step 3 relaxes: merge can happen once every independent reviewer
agent is satisfied, with the human notified async rather than blocking.
Don't relax this because throughput demands it before the L4 prerequisites
in autonomy-levels.md are actually met — relaxing the merge gate ahead of
the mechanical guardrails that justify it is how "AI slop" compounds.

## Mechanical enforcement over prose review
Where a rule is checkable (naming, layering, structured logging, forbidden
patterns), write a linter or structural test for it instead of relying on a
reviewer to remember to mention it — see golden-principles.md. Write the
lint's failure message to include the fix, not just the violation, e.g.
`error: raw fetch() at a domain boundary — use the validated client in
lib/http-client instead`, so a builder agent can self-correct without a
review round-trip.

## Test flakes at higher throughput
At L3, a flaky test blocks merge like any other red test. At L4, once
flake-quarantine tooling exists, a single rerun is acceptable before
treating a flake as a real failure — corrections are cheap and waiting is
expensive once the harness is mature enough to make that trade safely.
