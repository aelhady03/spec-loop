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
- Spec: `docs/specs/<ticket-id>/spec.md`
- Plan: `docs/specs/<ticket-id>/plan.md`
- This task's row in `tasks.md`
- What changed (bullet list, not prose)
- Test evidence (which tests are new/red→green, coverage of the acceptance
  criteria this task closes)

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
A PR does not merge until:
1. All tests for this task are green.
2. The adversarial review loop (see review-rubric.md) reports zero blocking
   findings, or every blocking finding has an explicit human override.
3. A human has looked at it — spec-loop's autonomy stops at implementation +
   review; merge itself is always a human (or human-delegated bot merge)
   action, never a fully autonomous step.
