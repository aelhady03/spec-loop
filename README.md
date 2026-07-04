# spec-loop

A skill for `npx skills add <owner>/spec-loop` (via [skills.sh](https://skills.sh),
Vercel's open agent-skills directory) that turns a raw user story into
shipped, reviewed code through a bounded loop instead of turn-by-turn
prompting.

**Grill it → spec it → plan it → split it into PR-sized tasks with
tests-first → build autonomously → adversarially review → merge.** Two
human checkpoints (spec approval, PR review); everything between is an
agent loop with a hard bound.

## Why

As of mid-2026 the field converged on two separate insights that this skill
combines:

- **Spec-driven development** (GitHub's [spec-kit](https://github.com/github/spec-kit),
  [BMAD-METHOD](https://github.com/bmad-code-org/BMAD-METHOD)) — durable,
  versioned spec/plan/task artifacts instead of prompts, so intent survives
  past one chat session.
- **Loop engineering** — a term that took off in June 2026 (Boris Cherny,
  Anthropic: *"I don't prompt Claude anymore. I have loops that are
  running... My job is to write loops."*) — the idea that the leverage move
  is designing the *loop* an agent runs inside (bounded discover → plan →
  execute → verify → repeat), not hand-crafting each individual prompt.

Most existing skills do one half or the other — a spec template, or a raw
autonomous-loop harness. spec-loop's opinion is that they're the same
problem: the spec is what gives the loop a stop condition and a review
rubric, and the loop is what makes the spec worth writing instead of
theater.

## What's in here

```
SKILL.md                       — the orchestrating skill, phases 0-7
references/
  grilling-checklist.md        — gap-finding question bank for Phase 1
  spec-template.md              — Phase 2 artifact
  plan-template.md              — Phase 3 artifact
  tasks-template.md             — Phase 4 artifact (task = PR-sized slice)
  test-plan-template.md         — Phase 5 artifact, TDD coverage map
  pr-conventions.md             — branch/commit/PR naming, diff-size gate
  review-rubric.md              — adversarial review lenses + verification
scripts/
  scaffold.sh                   — creates docs/specs/<ticket>-<slug>/ in a target repo
```

## Install

```
npx skills add <owner>/spec-loop
```

(or clone this repo and point your agent's skill-discovery path at it,
per your tool's convention — spec-loop is written to be portable across
Claude Code, Cursor, Copilot, and anything else that reads a `SKILL.md`).

## Design notes for anyone extending this

- **Bounded loops only.** Grilling caps at 3 rounds, build attempts cap at
  ~3/task, review fix/re-check caps at ~2 rounds. Hitting a bound means
  escalate to a human, never "keep trying silently."
- **State lives on disk** (`docs/specs/<ticket-id>-<slug>/*.md`), not in
  chat history, so the loop survives session boundaries.
- **Separation of duties**: the builder is never the reviewer. Adversarial
  review starts from the diff + spec only.
- **Two checkpoints, not twenty**: spec approval and PR review. Everything
  else is autonomous by default, human-in-the-loop by exception.

Related skills worth composing with this one (not bundled, but philosophically
adjacent): `obra/superpowers`' `writing-plans`, `executing-plans`,
`test-driven-development`, and `dispatching-parallel-agents`; Anthropic's own
`skill-creator`.

## License

MIT — see LICENSE.
