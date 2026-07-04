# Worked example

A small, concrete run of spec-loop end to end, so you can see what the
templates actually produce instead of just reading blank placeholders.

**Raw story (Phase 0 input):**
> "Add a 'remember me' checkbox to the login form. When checked, the user
> shouldn't have to log in again for a while."

**What's in `2026-07-04-1-remember-me-login/`:**
- `spec.md` — post-grilling, post-approval spec (Phase 1-2 output). Read
  the Assumptions table to see what grilling actually surfaced for a story
  this small — that's the part that's easy to under-appreciate from the
  blank template alone.
- `plan.md` — Phase 3 output. Deliberately skips "Alternatives considered"
  per SKILL.md's own guidance (straightforward task, no genuinely
  competing designs).
- `tasks.md` — Phase 4 output: two PR-sized tasks, not one.
- `test-plan.md` — Phase 5 output: acceptance-criteria coverage map.

This example stops at Phase 5 (Scaffold) on purpose — Phases 6-8 are about
*how* an agent builds/reviews/maintains, which isn't something a static
example file can demonstrate; run `scripts/scaffold.sh` yourself against a
real repo to see that part.

To regenerate this skeleton yourself and compare:
```
scripts/scaffold.sh 2026-07-04-1 remember-me-login /tmp/some-scratch-repo
```
