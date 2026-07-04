# Autonomy levels

spec-loop defaults to **Level 3**: two mandatory human checkpoints (spec
approval, PR review), autonomous in between. This file is the dial for
moving that default up or down deliberately, instead of drifting there by
accident.

Levels (adapted from the "Five Levels of AI Coding Agent Autonomy" framing
that emerged in 2026, and consistent with what teams running fully
agent-generated codebases at scale describe reaching in practice):

- **L1 — Assistive.** Agent suggests, human writes/applies every change.
- **L2 — Conversational.** Continuous human steering, turn by turn.
- **L3 — Task agent (spec-loop's default).** Human checkpoints only at spec
  approval (Phase 2) and PR review (Phase 7). Grilling, planning detail,
  implementation, and first-pass review all run autonomously between those
  two gates.
- **L4 — Autonomous teammate.** Checkpoints move to objective-setting
  (a human approves the *backlog item*, not each spec) and async PR review
  (a human can review, but merge doesn't wait on them — "humans may review
  pull requests, but aren't required to"). Review is agent-to-agent by
  default: multiple independent reviewer agents (local + cloud/async) must
  all be satisfied before merge; a human is pulled in only when an agent
  reviewer or the builder itself escalates.
- **L5 — Agentic avalanche.** Experimental. Orchestrator-level oversight
  only; individual PRs are neither authored nor reviewed by a human in the
  loop at all.

## Moving from L3 toward L4 — what has to be true first

Don't skip straight to "humans don't need to review PRs" — earn it. L4 only
holds up once these are actually in place, not just claimed:

1. **Mechanical architecture enforcement** exists (see `pr-conventions.md`'s
   note on custom lints) so agents can't quietly violate the layering/taste
   rules that keep the codebase legible to the *next* agent run.
2. **Golden principles + a garbage-collection loop** are running (see
   `golden-principles.md`), so drift from agent-replicated bad patterns gets
   caught continuously instead of accumulating.
3. **The environment itself is agent-drivable** — the agent can boot/drive
   the app, read logs/metrics/traces, and produce evidence (not just "tests
   passed" but "I drove the feature and here's the screenshot/trace showing
   the acceptance criterion holds").
4. **The review loop has multiple independent reviewer agents**, not one,
   and a track record of catching real issues before humans do.

Until 1-4 hold, stay at L3. Regressing from L4 back to L3 for a specific
repo or task class (e.g. anything touching auth/billing/data-deletion) is
always fine — autonomy level is a per-repo, per-risk-class dial, not a
one-way ratchet, and "higher isn't always better."

## What changes operationally between L3 and L4

| | L3 (default) | L4 |
|---|---|---|
| Spec approval | required, blocking | required, blocking (unchanged) |
| Plan review | optional | optional |
| PR review | required, blocking | agent reviewers required + satisfied; human optional, async |
| Merge action | human or human-delegated bot | agent can merge once all reviewer agents are satisfied |
| Escalation trigger | any blocking review finding | only when an agent judges the decision needs human judgment |
| Test flakes | block until green | rerun once; if it stays flaky, file it, don't block the PR (throughput > waiting, once flake-quarantine tooling exists) |
