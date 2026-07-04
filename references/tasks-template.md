# Tasks: {{ticket-id}} — {{title}}

Plan: ./plan.md

Each task = one vertical slice = one PR. Keep each under the diff-size gate
(see pr-conventions.md, default ~400 changed lines). If a task would blow the
gate, split it further here before implementation starts, not after.

## Task list

### T1 — {{short title}}
- Depends on: (none | T#)
- Branch: `agent/{{ticket-id}}-{{slug}}`
- Acceptance criteria: (copy the relevant Given/When/Then from spec.md)
- Test-first: which test(s) get written red before any implementation code
- Estimated diff size: S / M / L (L means split it)
- Status: [ ] not started / [ ] in progress / [ ] implemented / [ ] reviewed / [ ] merged

### T2 — ...

## Ordering rationale
Why the tasks are sequenced this way (usually: dependency graph from plan.md,
plus "land the riskiest/most-uncertain slice first").
