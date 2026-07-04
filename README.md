# spec-loop

![Version](https://img.shields.io/badge/version-0.3.0-blue)
![License: MIT](https://img.shields.io/badge/license-MIT-green)
![Skill format](https://img.shields.io/badge/format-SKILL.md-lightgrey)

Turn a raw user story into shipped, reviewed code through a bounded loop —
grill it for gaps, write a spec, plan it, split it into small PR-sized
tasks with tests-first, implement autonomously, and adversarially review
before merge. Two human checkpoints (spec approval, PR review); everything
between is an agent loop with a hard bound.

Published for [skills.sh](https://skills.sh) (Vercel's open agent-skills
directory) and written to be portable across any agent that reads a
`SKILL.md`.

## Table of contents

- [Why](#why)
- [Quick start](#quick-start)
- [How it works](#how-it-works)
- [Repository structure](#repository-structure)
- [Design principles](#design-principles)
- [Related skills](#related-skills)
- [Contributing](#contributing)
- [Changelog](#changelog)
- [License](#license)

## Why

As of mid-2026 the field converged on a few separate insights that this
skill combines:

- **Spec-driven development** ([spec-kit](https://github.com/github/spec-kit),
  [BMAD-METHOD](https://github.com/bmad-code-org/BMAD-METHOD)) — durable,
  versioned spec/plan/task artifacts instead of prompts, so intent survives
  past one chat session.
- **Loop engineering** — the idea that the leverage move is designing the
  *loop* an agent runs inside (bounded discover → plan → execute → verify →
  repeat), not hand-crafting each individual prompt. As Anthropic's Boris
  Cherny put it: *"I don't prompt Claude anymore. I have loops that are
  running... My job is to write loops."*
- **Harness engineering** — lessons from teams running fully
  agent-generated codebases at real scale: `AGENTS.md` as a short map into
  a structured `docs/` knowledge base rather than a monolithic manual;
  mechanical enforcement of architecture/taste invariants (with remediation
  baked into lint failure messages) instead of relying on review to catch
  drift; and a recurring "garbage collection" loop against a repo's own
  golden principles, because agents faithfully replicate whatever patterns
  — good or bad — already exist.

Most existing skills cover one slice of this — a spec template, a raw
autonomous-loop harness, or a docs convention. spec-loop's opinion is that
they're the same problem: the spec gives the loop a stop condition and a
review rubric, the loop is what makes the spec worth writing instead of
theater, and the knowledge-base structure is what keeps both legible to the
next agent run instead of rotting after the first one.

## Quick start

### Requirements

- `bash` and `git` (for `scripts/scaffold.sh`)
- `node`/`npx` if installing via skills.sh

### Install

```bash
npx skills add <owner>/spec-loop
```

Or clone this repo and point your agent's skill-discovery path at it, per
your tool's convention.

### See a worked example first

[`examples/2026-07-04-1-remember-me-login/`](examples/) walks one small
story through Phases 0-5 with real, filled-in content — read this before
the blank templates in `references/` if you want to see what the loop
actually produces.

### Scaffold a new spec

```bash
scripts/scaffold.sh <ticket-id> <slug> [target-repo-root]
```

- `<ticket-id>` and `<slug>` must match `[A-Za-z0-9_-]+` (kebab-case, no
  spaces or slashes) — they become path segments, and the script rejects
  anything else rather than silently accepting it. No ticketing system?
  Mint a `YYYY-MM-DD-<n>` id (see `SKILL.md` Phase 0).
- `target-repo-root` defaults to the current repo's root
  (`git rev-parse --show-toplevel`), not the caller's working directory,
  if omitted.
- The script is idempotent: re-running it for the same ticket skips
  anything that already exists instead of overwriting it.

## How it works

`SKILL.md` is the orchestrating skill; everything else in this repo is a
template, rubric, or script it loads on demand.

| Phase | Name | Produces | Checkpoint |
|---|---|---|---|
| 0 | Intake | raw story captured verbatim | |
| 1 | Grill | gaps found and resolved (read code / asked human / assumption) | |
| 2 | Spec | `docs/product-specs/<ticket-id>-<slug>.md` | **Human approval** |
| 3 | Plan | `docs/exec-plans/active/<ticket-id>-<slug>/plan.md` | |
| 4 | Tasks & PR splitting | `tasks.md` — one PR-sized vertical slice per task | |
| 5 | Scaffold | knowledge-base skeleton + this ticket's artifacts on disk | |
| 6 | Autonomous build loop | implementation + tests, bounded to ~3 attempts/task | |
| 7 | Adversarial review | reviewed diff, blocking findings resolved | **Human/PR review** |
| 8 | Maintain | recurring garbage-collection pass (not per-task) | |

The instructions work with a single sequential agent as the baseline
everywhere. An "Enhanced mode" section in `SKILL.md` covers what to prefer
when your environment exposes subagent dispatch or multi-agent
orchestration — `references/review-rubric.md` documents the degraded,
single-reviewer fallback for when it doesn't.

## Repository structure

```text
SKILL.md                           the orchestrating skill, phases 0-8
references/
├── grilling-checklist.md          gap-finding question bank for Phase 1
├── spec-template.md                Phase 2 artifact (includes an Amendments section for brownfield edits)
├── plan-template.md                 Phase 3 artifact
├── tasks-template.md                Phase 4 artifact (task = PR-sized slice)
├── test-plan-template.md            Phase 5 artifact: TDD + runtime-verification coverage map
├── knowledge-base-structure.md    AGENTS.md-as-map + docs/ tree this skill scaffolds
├── pr-conventions.md              branch/commit/PR naming, diff-size gate, conflict/rebase handling
├── review-rubric.md               adversarial review lenses, multi-reviewer loop + single-reviewer fallback
├── autonomy-levels.md             L1-L5 ladder; what has to be true before relaxing checkpoints
└── golden-principles.md           Phase 8's recurring garbage-collection loop
scripts/
└── scaffold.sh                    creates the docs/ knowledge base + this ticket's artifacts
examples/
└── 2026-07-04-1-remember-me-login/  a full worked example (spec/plan/tasks/test-plan)
CONTRIBUTING.md                    how to propose changes to this skill
CHANGELOG.md
LICENSE
```

## Design principles

- **Bounded loops only.** Grilling caps at 3 rounds, build attempts cap at
  ~3/task, review fix/re-check caps at ~2 rounds. Hitting a bound means
  escalate to a human, never "keep trying silently."
- **State lives on disk** (`docs/product-specs/`, `docs/exec-plans/`), not
  in chat history, so the loop survives session boundaries — and so it's
  legible to the *next* agent run, not just this one.
- **`AGENTS.md` is a map, not a manual.** A monolithic instructions file
  rots and crowds out context; a short map into a structured, mechanically
  checkable `docs/` tree doesn't. See `references/knowledge-base-structure.md`.
- **Separation of duties.** The builder is never the reviewer. Adversarial
  review starts from the diff + spec only, and prefers multiple independent
  reviewers over one — with an explicit single-reviewer fallback when
  that's not available, rather than skipping review.
- **Brownfield is a first-class case, not an afterthought.** Extending an
  existing spec appends an Amendments entry and reuses the existing
  ticket-id; it doesn't fork a second, competing spec for the same feature.
- **Two checkpoints by default, not twenty.** Spec approval and PR review.
  Everything else is autonomous by default, human-in-the-loop by exception
  — and that default is a dial (`references/autonomy-levels.md`), not a
  ceiling.
- **Entropy needs its own loop.** Phase 8 exists because agents faithfully
  replicate whatever's already in the repo, including the bad parts —
  manual cleanup passes don't scale, mechanical golden-principle
  enforcement does.

## Related skills

Not bundled, but philosophically adjacent — worth composing with this one:

- `obra/superpowers`'s `writing-plans`, `executing-plans`,
  `test-driven-development`, and `dispatching-parallel-agents`
- Anthropic's own `skill-creator`

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

## License

[MIT](LICENSE)
