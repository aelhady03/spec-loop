# Plan: 2026-07-04-1 — Remember-me checkbox on login

Spec: docs/product-specs/2026-07-04-1-remember-me-login.md

## Approach
Add a `rememberMe: boolean` field to the login form and its submit payload.
On the server, when `rememberMe` is true, pass `ttlOverride: 30 * 24h` into
the existing `session-config.ts` issuance call instead of the default TTL.
Logout continues to call the existing session-invalidation path unchanged —
criterion 4 falls out of that for free rather than needing new logic, since
invalidation doesn't check TTL.

No new alternatives were seriously considered — this is a straightforward
extension of an existing, already-supported parameter (`ttlOverride`), not a
new design.

## Architecture / data flow
```
LoginForm (+ rememberMe checkbox)
  -> POST /api/login { username, password, rememberMe }
    -> auth-service.login()
      -> session-config.issue({ ttlOverride: rememberMe ? THIRTY_DAYS : undefined })
```

## Dependency graph
T1 (backend: accept + apply `rememberMe`) has no dependency. T2 (frontend:
checkbox + wire into submit payload) depends on T1's API contract (the
`rememberMe` field name) being settled, but not on T1 being merged first —
both can be built in parallel against the agreed contract, with T2's PR
simply landing after T1's in the same day.

## Checkpoints
Default: spec approval (already done, above) and PR review for both T1 and
T2. No additional checkpoint needed — this is a low-risk, additive change.

## Rollback plan
Revert both PRs; `ttlOverride` was already an existing, unused parameter, so
rollback returns to exactly today's behavior with no data migration
involved.
