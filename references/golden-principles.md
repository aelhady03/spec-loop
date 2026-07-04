# Golden principles & the garbage-collection loop

This is a *separate, recurring* loop from spec-loop's per-task build/review
loop (Phases 6-7) — it doesn't wait for a new story to arrive. Its job is to
stop entropy from compounding, because agents will faithfully replicate
whatever patterns already exist in the repo, including the bad ones.

Source: OpenAI's Codex team found manual cleanup didn't scale ("we used to
spend every Friday — 20% of the week — cleaning up AI slop") and replaced it
with mechanical, continuous enforcement
(["Harness engineering," 2026-02-11](https://openai.com/index/harness-engineering/)).
Treat technical debt like a high-interest loan: pay it down continuously in
small increments, not in painful periodic bursts.

## Golden principles doc

Keep a short, opinionated, mechanically-checkable list at
`docs/design-docs/core-beliefs.md` or a repo-root `GOLDEN_PRINCIPLES.md`.
Examples of the *kind* of rule that belongs here (yours will differ):
- Prefer shared utility packages over hand-rolled equivalents, to keep
  invariants centralized.
- Don't probe data shapes YOLO-style — validate at boundaries or use typed
  SDKs, so the agent can't accidentally build on a guessed shape.
- Structured logging only; no bare `console.log`/`print` in application code.
- File size / function complexity ceilings.

Each principle should be enforceable by a linter or structural test, not
just written down as prose reviewers are supposed to remember. **Write the
lint's failure message to inject the remediation instruction directly** —
"error: raw fetch() at boundary; use the validated client in
`lib/http-client`" teaches the agent the fix in the same breath as the
violation, instead of making it guess.

## The recurring loop

On a regular cadence (not per-task):
1. A background agent scans the repo for deviations from the golden
   principles and for docs that no longer match real code behavior
   ("doc-gardening").
2. It updates `docs/QUALITY_SCORE.md` (per-domain/per-layer grade, tracked
   over time — this is the observability signal for whether entropy is
   winning or losing).
3. It opens small, targeted fix-up PRs — each should be reviewable in under
   a minute. Most of these are safe to auto-merge once the mechanical
   checks pass (see `autonomy-levels.md` and the merge-gate note in
   `pr-conventions.md`), since they're narrow, principle-driven diffs, not
   novel logic.
4. Anything that can't be resolved mechanically (a genuine ambiguity about
   which pattern *should* win) gets logged to
   `docs/exec-plans/tech-debt-tracker.md` instead of silently picked one way
   — that's a backlog item, not a spec-loop task on its own until someone
   prioritizes it.

## Why this isn't optional at higher autonomy

The garbage-collection loop is what makes moving from L3 to L4 autonomy
(see `autonomy-levels.md`) safe rather than reckless: without it, higher
throughput just means bad patterns compound faster. With it, throughput and
coherence both increase, because human taste gets captured once (as a
golden principle) and then enforced on every subsequent line of code an
agent writes — not re-litigated in every review.
