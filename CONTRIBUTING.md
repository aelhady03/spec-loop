# Contributing to spec-loop

This repo *is* a skill, not an app — there's no product code to build or
test suite to run. "Contributing" mostly means improving the instructions,
templates, and scripts that other agents/humans will follow.

## Before opening a PR
- If you're changing behavior described in `SKILL.md`, keep it under ~500
  lines (per the Agent Skills convention) — push detail into `references/`
  instead of inlining it.
- If you change a path convention (e.g. where `scripts/scaffold.sh` writes
  files), grep the whole repo for the old path and update every reference —
  `SKILL.md`, `README.md`, every file under `references/`, and the worked
  example under `examples/` all cross-reference each other and will drift
  silently otherwise.
- If you change `scripts/scaffold.sh`, actually run it in a scratch
  directory before submitting — both a normal case and an edge case
  (re-running it for idempotency, an invalid ticket-id/slug to confirm
  validation still rejects it). Don't just read the diff and assume it
  works.
- Keep claims honest: don't describe a capability (e.g. "runs N reviewers in
  parallel") without also describing the degraded/fallback mode for an
  environment that doesn't have it — this skill is meant to be portable
  across agents with very different tool access.

## Reporting a problem
Open a GitHub issue with: what you expected the skill's instructions to
produce, what actually happened when an agent followed them, and which
agent/tool you were running it in.

## Style
Match the existing voice: direct, concrete, no filler. Prefer a table or a
short bullet list over a paragraph of prose when either would work.
