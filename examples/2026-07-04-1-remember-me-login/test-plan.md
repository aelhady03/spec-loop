# Test plan: 2026-07-04-1 — Remember-me checkbox on login

Spec: docs/product-specs/2026-07-04-1-remember-me-login.md

## Coverage map

| Acceptance criterion (spec.md) | Test file / case | Level (unit/integration/e2e) |
|---|---|---|
| 1. Unchecked = unchanged behavior | `session-config.test.ts: "default TTL unchanged when rememberMe omitted"` | unit |
| 2. Checked = 30-day session | `session-config.test.ts: "rememberMe true issues 30-day TTL"` | unit |
| 3. Session survives browser restart within 30 days | `login.e2e.ts: "remembered session persists across a simulated restart"` | e2e |
| 4. Logout always invalidates, even when remembered | `session-config.test.ts: "logout invalidates a remembered session"` | unit |
| (frontend) checkbox wiring | `login-form.test.tsx: "submit payload reflects checkbox state"` | unit |

## Edge cases from grilling
- Double-submitting the login form with the checkbox toggled between
  submits — the *last* submitted value should be what's sent, not a stale
  one (covered by the frontend test's payload assertion).
- Server receiving a request with no `rememberMe` field at all (older
  client) — must behave as `false`/default, not error (covered by criterion
  1's test).

## Regression guard
Existing session-issuance and logout tests (`session-config.test.ts`'s
pre-existing suite) must stay green unmodified — this change only adds a
new optional parameter path, it doesn't touch the default path's logic.

## Runtime verification
Log in via the real login form with the checkbox checked, close the
browser process entirely, reopen, and confirm the session persists —
attach a short screen recording to the PR. Then log out and confirm a
manual retry of the old session token is rejected.
