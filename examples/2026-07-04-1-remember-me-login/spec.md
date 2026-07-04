# Spec: 2026-07-04-1 — Remember-me checkbox on login

Status: approved
Owner: k.elborai
Created: 2026-07-04

## Raw input
> "Add a 'remember me' checkbox to the login form. When checked, the user
> shouldn't have to log in again for a while."

## Objective
Let a user opt into a longer-lived session at login time, so they aren't
forced to re-authenticate on every visit from a trusted device.

## Actors
- End user logging in via the web login form.
- Existing session/auth service (unchanged interface, longer-lived token
  issuance only).

## Acceptance criteria
1. Given the login form, when the user submits credentials with "remember
   me" unchecked, then the session behaves exactly as it does today
   (existing short-lived session duration, no regression).
2. Given the login form, when the user submits credentials with "remember
   me" checked, then the issued session persists for 30 days instead of the
   default session length.
3. Given a "remembered" session, when the user closes and reopens the
   browser within 30 days, then they remain logged in without re-entering
   credentials.
4. Given a "remembered" session, when the user explicitly logs out, then
   the extended session is invalidated immediately (logout always wins over
   "remember me").

## Non-goals / boundaries
- Not building "remember me" for the mobile app in this story — web login
  form only.
- Not changing the auth token format/algorithm — only its expiry.
- Not adding a settings-page toggle to review/revoke remembered devices —
  that's a separate story if wanted.

## Assumptions
| Gap found during grilling | Resolution | Source |
|---|---|---|
| What's the current default session length? | 24 hours | read `lib/auth/session-config.ts:12` |
| Does "a while" have a specific duration requirement? | No number given in the story | asked human, 2026-07-04 — human said "30 days is fine" |
| Should "remember me" survive an explicit logout? | Yes — logout should always end the session | asked human, 2026-07-04 |
| Is there an existing session-length config path to extend, or does this need a new mechanism? | Existing `session-config.ts` already supports a per-login `ttlOverride` param, unused elsewhere | read `lib/auth/session-config.ts:40-58` |

## Risks
Extending session lifetime increases the exposure window if a device is
shared or stolen — mitigated by acceptance criterion 4 (logout always
invalidates) and by this being opt-in (default behavior unchanged, criterion
1).

## Non-functional requirements
No new latency/throughput requirements — this only changes a TTL value
passed into an existing, already-tested session-issuance path.
