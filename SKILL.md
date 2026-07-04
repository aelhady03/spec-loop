---
name: spec-loop
description: Turns a raw user story into shipped, reviewed code through a bounded loop — grill it for gaps, write a spec, plan it, split it into small PR-sized tasks with tests-first, implement autonomously, and adversarially review before merge. Use when a user hands you a feature request, ticket, or user story and no spec/plan exists yet, or when they ask to "plan this properly," "spec this out," or want autonomous implementation with review gates instead of ad-hoc prompting.
when_to_use: Trigger on a new feature/story/ticket with no existing spec, on "spec this out" / "plan this" / "grill this story" requests, or when the user wants an autonomous build+review loop rather than turn-by-turn prompting. Do not trigger on trivial one-line fixes, pure Q&A, or when a spec already exists and the user just wants to continue an in-flight task.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, AskUserQuestion, TaskCreate, TaskUpdate, Agent, Workflow
---

# spec-loop

A user story is not a spec, and a spec is not a plan. This skill is the loop
that turns one into the other, then keeps a human at exactly two checkpoints
— spec approval and PR review — while everything in between runs as a
bounded, observable, adversarially-checked loop instead of turn-by-turn
prompting.

Read `references/*.md` for the templates and rubrics this skill fills in —
don't inline their content here, load them when you reach that phase.

## Mental model

Loop engineering, not prompt engineering: you are designing the *loop* an
agent runs inside (discover → plan → execute → verify → repeat with a bound),
not hand-holding each step. Concretely that means:

- **Bounded, never infinite.** Every loop below has a max round count. Hitting
  the bound means escalate to the human, not "try again forever."
- **State on disk, not in conversation.** The spec/plan/tasks files in
  `docs/specs/<ticket-id>-<slug>/` are the source of truth. Any agent, any
  session, should be able to pick up mid-loop by reading them — don't rely on
  chat history surviving.
- **Separation of duties.** The agent that builds a task is never the one
  that approves it. Adversarial review runs from the diff + spec, not from
  the builder's reasoning trail, so it can't inherit the builder's blind
  spots.
- **Two human checkpoints, not twenty.** Spec approval (end of Phase 2) and
  PR review (end of Phase 7). Autonomy in between; ask the human by exception
  (genuine ambiguity that changes scope), not by default.

## Phase 0 — Intake

Capture the raw story verbatim. Do not paraphrase or "clean it up" yet — that
happens in Phase 2. If there's no ticket id, mint a short slug from the
title. Decide the working path: `docs/specs/<ticket-id>-<slug>/`.

## Phase 1 — Grill (find the gaps)

Work through `references/grilling-checklist.md`. For every category: try to
answer it yourself by reading the codebase first. Only surface a question to
the human when the codebase genuinely doesn't resolve it *and* the answer
would change scope, design, or acceptance criteria — not preference
bikeshedding.

Loop rule: run a grilling round, log what was found and how it resolved
(read code / asked human / assumption). Run another round against the
updated understanding. Stop when a round finds nothing new, or after 3
rounds. Anything still open goes into spec.md's Assumptions table, flagged
for human sign-off at the Phase 2 checkpoint — don't block indefinitely on
an answer nobody's given yet.

Batch human questions (~4 at a time via `AskUserQuestion` if available,
otherwise as a numbered list in your reply).

## Phase 2 — Spec (human checkpoint)

Fill in `references/spec-template.md` → `docs/specs/<ticket-id>-<slug>/spec.md`.
This is the first mandatory human checkpoint: get explicit approval on the
spec (including the Assumptions table) before Phase 3. Do not proceed past
this point on an unapproved spec.

## Phase 3 — Plan

Fill in `references/plan-template.md` → `plan.md`. For a straightforward
task, go straight to Approach. For a genuinely non-trivial design (2+
defensible approaches with real tradeoffs), if you have access to parallel
subagents, generate 2-3 candidate approaches independently and have a
separate pass score them before committing — a judge panel beats iterating
on one attempt when the solution space is wide. Otherwise just reason
through Alternatives Considered yourself.

## Phase 4 — Tasks & PR splitting

Fill in `references/tasks-template.md` → `tasks.md`. Each task is one
vertical slice = one PR. Apply the diff-size gate from
`references/pr-conventions.md` (~400 changed lines default) at planning
time, not after implementation — if a task looks too big, split it here.

## Phase 5 — Scaffold

Run `scripts/scaffold.sh <ticket-id> <slug> [repo-root]` (or do it by hand):
creates `docs/specs/<ticket-id>-<slug>/{spec,plan,tasks,test-plan}.md` and an
`AGENTS.md` pointing future agents/sessions at the spec. Fill in
`references/test-plan-template.md` → `test-plan.md`, mapping every
acceptance criterion in spec.md to a specific test — TDD red before any
implementation code.

## Phase 6 — Autonomous build loop

Per task, bounded loop: implement → run the tests just written (should go
green) → self-check the task's acceptance criteria → stop. Cap at ~3
attempts per task before escalating to the human rather than silently
retrying. If you have access to background/forked subagents, dispatch
independent tasks in parallel rather than serially — they're independent
slices by construction from Phase 4.

Update `tasks.md`'s status checkboxes as you go — that's the on-disk loop
state, not something to hold only in conversation.

Branch/commit per `references/pr-conventions.md`
(`agent/<ticket-id>-<task-slug>`, Conventional Commits scoped to the task).

## Phase 7 — Adversarial review (human checkpoint)

Apply `references/review-rubric.md`. The reviewing pass must not reuse the
builder's context — start fresh from diff + spec.md. Run the four lenses
(correctness, security, test coverage, simplification) independently, then a
verification pass that tries to *refute* each finding before it's reported,
so only findings that survive refutation reach the human. If you have
subagents available, run lenses in parallel and verification as a separate
pass per finding rather than sequentially.

Blocking findings keep the merge gate closed. Cap fix/re-review at ~2
rounds; a third round of the same blocking finding escalates to the human
instead of looping again.

This is the second and final mandatory human checkpoint: a human (or a
human-delegated bot merge) makes the actual merge decision. spec-loop's
autonomy covers implementation and review, never the merge action itself.

## Enhanced mode (when Agent/Workflow tools are available)

Everything above works with a single sequential agent. If your environment
exposes subagent dispatch or multi-agent orchestration, prefer it for:
- Phase 3's judge panel (parallel candidate plans, independent scoring)
- Phase 6 (parallel task implementation across independent slices)
- Phase 7 (parallel review lenses + parallel adversarial verification of
  each finding)

Don't force parallelism where there's nothing independent to parallelize —
a single small task doesn't need a fleet of agents.

## Anti-patterns this skill exists to prevent
- Writing code straight from a one-line story with no spec — "vibe coding."
- Asking the human twenty small questions one at a time instead of batching
  the ones that actually matter.
- One giant PR instead of dependency-ordered, independently reviewable
  slices.
- Tests written after the implementation, rubber-stamping whatever the code
  already does.
- The same agent/context both building and approving its own work.
- Loops with no iteration bound — "keep trying" instead of "try N times,
  then ask."
