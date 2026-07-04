# Tasks: 2026-07-04-1 — Remember-me checkbox on login

Plan: ./plan.md

## Task list

### T1 — Accept and apply `rememberMe` server-side
- Depends on: (none)
- Branch: `agent/2026-07-04-1-backend-remember-me`
- Acceptance criteria: spec.md criteria 1, 2, 4
- Test-first: `session-config.test.ts` — issuing a session with
  `rememberMe: true` yields a 30-day expiry; `rememberMe: false`/omitted
  yields today's default; logout invalidates a remembered session
  regardless of remaining TTL
- Estimated diff size: S
- Status: [x] not started / [ ] in progress / [ ] implemented / [ ] reviewed / [ ] merged

### T2 — Add checkbox to login form and wire into submit payload
- Depends on: T1 (API contract: the `rememberMe` field name)
- Branch: `agent/2026-07-04-1-frontend-remember-me`
- Acceptance criteria: spec.md criterion 3 (and end-to-end criterion 2)
- Test-first: `login-form.test.tsx` — checkbox renders, unchecked by
  default, submit payload includes `rememberMe` matching checkbox state
- Estimated diff size: S
- Status: [x] not started / [ ] in progress / [ ] implemented / [ ] reviewed / [ ] merged

## Ordering rationale
Both are independent slices against an agreed contract (the `rememberMe`
field name from plan.md), so they're built in parallel rather than strictly
sequenced — T1 doesn't block T2 starting, only T2's PR merging after T1's
contract is confirmed stable.
