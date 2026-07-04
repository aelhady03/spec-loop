# Knowledge-base structure: AGENTS.md as a map, not a manual

Teams running fully agent-generated codebases at scale have tried one giant
`AGENTS.md` and found it fails in predictable, specific ways — this is why
spec-loop doesn't scaffold a single instructions file:

- **Context is scarce.** A giant instruction file crowds out the task, the
  code, and the relevant docs — the agent either misses key constraints or
  optimizes for the wrong ones.
- **Too much guidance becomes non-guidance.** When everything is
  "important," nothing is — agents pattern-match locally instead of
  navigating intentionally.
- **It rots instantly.** A monolithic manual becomes a graveyard of stale
  rules nobody maintains, and it quietly becomes an attractive nuisance.
- **It's unverifiable.** A single blob doesn't lend itself to mechanical
  checks (coverage, freshness, ownership, cross-links) — drift is
  inevitable.

## The pattern spec-loop scaffolds instead

`AGENTS.md` at repo root is a **table of contents**, not an encyclopedia —
keep it short (roughly 100 lines), and let it point into a structured
`docs/` tree that's the actual system of record:

```
AGENTS.md                        — short map: what this repo is, where to look
ARCHITECTURE.md                  — top-level domain/layer map
docs/
├── design-docs/
│   ├── index.md
│   └── core-beliefs.md          — agent-first operating principles for this repo
├── product-specs/
│   ├── index.md                 — one row per spec, links out
│   └── <ticket-id>-<slug>.md    — spec-loop's spec.md content lives here
├── exec-plans/
│   ├── active/
│   │   └── <ticket-id>-<slug>/  — plan.md, tasks.md, test-plan.md while in flight
│   ├── completed/
│   │   └── <ticket-id>-<slug>/  — moved here once the last task merges
│   └── tech-debt-tracker.md
├── generated/                    — machine-generated docs (db schema, etc.)
└── QUALITY_SCORE.md              — per-domain grade, tracked over time
```

`scripts/scaffold.sh` creates this skeleton idempotently (skips anything
that already exists) the first time it runs in a repo, then always creates
the per-ticket `product-specs/<ticket-id>-<slug>.md` and
`exec-plans/active/<ticket-id>-<slug>/` for each new spec-loop run.

## Why this matters beyond tidiness

**Agent legibility is the actual goal, not documentation for its own sake.**
From the agent's point of view, anything it can't access in-context while
running effectively doesn't exist. A Slack thread that settled an
architectural question, a decision made in a meeting, tribal knowledge in a
senior engineer's head — none of it is real to the agent unless it's a
repository-local, versioned artifact. Every time a human resolves an
ambiguity during Phase 1 (Grill), that resolution belongs in `spec.md`'s
Assumptions table or in `docs/design-docs/`, not just in the chat transcript
that produced it — the chat is not the system of record, the repo is.

## Mechanical enforcement

Treat the knowledge base like code, not prose:
- A linter/CI job checks the docs tree is structured correctly, internally
  cross-linked, and that `product-specs/index.md` /
  `exec-plans/tech-debt-tracker.md` actually match what's in the directories
  (no orphaned or missing entries).
- A recurring "doc-gardening" task (see `golden-principles.md`) scans for
  docs that no longer match real code behavior and opens fix-up PRs — stale
  docs are worse than no docs, because agents will trust and act on them.
