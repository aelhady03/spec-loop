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

As of mid-2026 the field converged on a few separate insights that this
skill combines:

- **Spec-driven development** (GitHub's [spec-kit](https://github.com/github/spec-kit),
  [BMAD-METHOD](https://github.com/bmad-code-org/BMAD-METHOD)) — durable,
  versioned spec/plan/task artifacts instead of prompts, so intent survives
  past one chat session.
- **Loop engineering** — a term that took off in June 2026 (Boris Cherny,
  Anthropic: *"I don't prompt Claude anymore. I have loops that are
  running... My job is to write loops."*) — the idea that the leverage move
  is designing the *loop* an agent runs inside (bounded discover → plan →
  execute → verify → repeat), not hand-crafting each individual prompt.
- **Harness engineering** (OpenAI's Codex team,
  ["Harness engineering: leveraging Codex in an agent-first world"](https://openai.com/index/harness-engineering/),
  2026-02-11) — the concrete lessons from shipping ~1M lines of a real
  product with zero manually-written code: `AGENTS.md` as a short map into a
  structured `docs/` knowledge base rather than a monolithic manual;
  mechanical enforcement of architecture/taste invariants (with remediation
  baked into lint failure messages) instead of relying on review to catch
  drift; and a recurring "garbage collection" loop against a repo's own
  golden principles, because agents faithfully replicate whatever patterns
  — good or bad — already exist.

Most existing skills do one slice of this — a spec template, or a raw
autonomous-loop harness, or a docs convention. spec-loop's opinion is that
they're the same problem: the spec gives the loop a stop condition and a
review rubric, the loop is what makes the spec worth writing instead of
theater, and the knowledge-base structure is what keeps both legible to the
next agent run instead of rotting after the first one.

## What's in here

```
SKILL.md                          — the orchestrating skill, phases 0-8
references/
  grilling-checklist.md           — gap-finding question bank for Phase 1
  spec-template.md                 — Phase 2 artifact
  plan-template.md                 — Phase 3 artifact
  tasks-template.md                — Phase 4 artifact (task = PR-sized slice)
  test-plan-template.md            — Phase 5 artifact, TDD + runtime-verification coverage map
  knowledge-base-structure.md      — AGENTS.md-as-map + docs/ tree this skill scaffolds
  pr-conventions.md                — branch/commit/PR naming, diff-size gate, mechanical enforcement
  review-rubric.md                — adversarial review lenses + multi-reviewer loop
  autonomy-levels.md               — L1-L5 ladder; what has to be true before relaxing checkpoints
  golden-principles.md             — Phase 8's recurring garbage-collection loop
scripts/
  scaffold.sh                      — creates the docs/ knowledge base + this ticket's artifacts
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
- **State lives on disk** (`docs/product-specs/`, `docs/exec-plans/`), not
  in chat history, so the loop survives session boundaries — and so it's
  legible to the *next* agent run, not just this one.
- **`AGENTS.md` is a map, not a manual.** A monolithic instructions file
  rots and crowds out context; a short map into a structured, mechanically
  checkable `docs/` tree doesn't. See `knowledge-base-structure.md`.
- **Separation of duties**: the builder is never the reviewer. Adversarial
  review starts from the diff + spec only, and prefers multiple independent
  reviewers over one.
- **Two checkpoints by default, not twenty**: spec approval and PR review.
  Everything else is autonomous by default, human-in-the-loop by exception
  — and that default is a dial (`autonomy-levels.md`), not a ceiling.
- **Entropy needs its own loop.** Phase 8 exists because agents faithfully
  replicate whatever's already in the repo, including the bad parts — manual
  Friday cleanups don't scale, mechanical golden-principle enforcement does.

Related skills worth composing with this one (not bundled, but philosophically
adjacent): `obra/superpowers`' `writing-plans`, `executing-plans`,
`test-driven-development`, and `dispatching-parallel-agents`; Anthropic's own
`skill-creator`.

## License

MIT — see LICENSE.
