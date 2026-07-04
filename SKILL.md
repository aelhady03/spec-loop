---
name: spec-loop
description: Turns a raw user story into shipped, reviewed code through a bounded loop — grill it for gaps, write a spec, plan it, split it into small PR-sized tasks with tests-first, implement autonomously, and adversarially review before merge. Use when a user hands you a feature request, ticket, or user story and no spec/plan exists yet, or when they ask to "plan this properly," "spec this out," or want autonomous implementation with review gates instead of ad-hoc prompting.
when_to_use: Trigger on a new feature/story/ticket with no existing spec, on "spec this out" / "plan this" / "grill this story" requests, or when the user wants an autonomous build+review loop rather than turn-by-turn prompting. Also trigger when a user wants to extend/amend an existing spec-loop spec (see Phase 0's brownfield note). Do not trigger on trivial one-line fixes or pure Q&A.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, AskUserQuestion, Agent, Workflow
version: 0.3.0
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
- **State on disk, not in conversation.** The knowledge base under
  `docs/` (see `references/knowledge-base-structure.md`) is the source of
  truth. Any agent, any session, should be able to pick up mid-loop by
  reading it — don't rely on chat history surviving.
- **Agent legibility is the goal.** If it isn't a repository-local, versioned
  artifact, it doesn't exist to the agent — a Slack thread that resolved an
  ambiguity is invisible unless it gets written into the spec or a design
  doc. Push decisions into the repo as they're made, not after the fact.
- **Separation of duties.** The agent that builds a task is never the one
  that approves it. Adversarial review runs from the diff + spec, not from
  the builder's reasoning trail, so it can't inherit the builder's blind
  spots.
- **Enforce invariants mechanically, don't micromanage implementation.**
  Encode the rules that must always hold (layering, naming, structured
  logging, "parse at the boundary") as linters/structural tests with
  remediation baked into the failure message. Leave everything else to the
  agent's judgment.
- **Two human checkpoints by default, not twenty.** Spec approval (end of
  Phase 2) and PR review (end of Phase 7). Autonomy in between; ask the
  human by exception (genuine ambiguity that changes scope), not by default.
  This default is Level 3 autonomy — see `references/autonomy-levels.md` for
  when and how to deliberately move off it.

## Phase 0 — Intake

Capture the raw story verbatim. Do not paraphrase or "clean it up" yet — that
happens in Phase 2.

**Ticket id.** If there's a real ticket (Jira, Linear, GitHub issue), use its
id. If there isn't one, don't reuse the slug as the id — mint a
`YYYY-MM-DD-<n>` id (e.g. `2026-07-04-1`) so `<ticket-id>-<slug>` doesn't
collapse into a duplicated string. Both `<ticket-id>` and `<slug>` must be
`[A-Za-z0-9_-]` only (kebab-case, no spaces/slashes) — `scripts/scaffold.sh`
enforces this and will refuse anything else, since these values become path
segments.

**Brownfield: extending an existing spec.** If `docs/product-specs/` already
has a spec that this story extends or amends rather than a clean new
feature, don't start a parallel/competing spec. Read the existing
`spec.md` and its `exec-plans/active/` (or `completed/`) plan/tasks first,
run Phase 1's grilling against *the delta only* (what's changing, not the
whole feature again), then update the existing spec.md in place — add a
new dated entry under a `## Amendments` section (append one if it doesn't
exist yet) rather than rewriting history — and add new tasks to the
existing tasks.md rather than minting a second ticket-id for the same
feature.

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

Fill in `references/spec-template.md` → `docs/product-specs/<ticket-id>-<slug>.md`.
This is the first mandatory human checkpoint: get explicit approval on the
spec (including the Assumptions table) before Phase 3. Do not proceed past
this point on an unapproved spec.

## Phase 3 — Plan

Fill in `references/plan-template.md` →
`docs/exec-plans/active/<ticket-id>-<slug>/plan.md`. For a straightforward
task, go straight to Approach. For a genuinely non-trivial design (2+
defensible approaches with real tradeoffs), if you have access to parallel
subagents, generate 2-3 candidate approaches independently and have a
separate pass score them before committing — a judge panel beats iterating
on one attempt when the solution space is wide. Otherwise just reason
through Alternatives Considered yourself.

## Phase 4 — Tasks & PR splitting

Fill in `references/tasks-template.md` →
`docs/exec-plans/active/<ticket-id>-<slug>/tasks.md`. Each task is one
vertical slice = one PR. Apply the diff-size gate from
`references/pr-conventions.md` (~400 changed lines default) at planning
time, not after implementation — if a task looks too big, split it here.

## Phase 5 — Scaffold

Run `scripts/scaffold.sh <ticket-id> <slug> [repo-root]` (or do it by hand).
On first use in a repo it lays down the full knowledge-base skeleton —
`AGENTS.md` (short map, not a manual), `ARCHITECTURE.md`,
`docs/product-specs/`, `docs/exec-plans/{active,completed}`,
`docs/design-docs/core-beliefs.md`, `docs/QUALITY_SCORE.md` — per
`references/knowledge-base-structure.md`; every run after that just adds
this ticket's `spec.md` / `plan.md` / `tasks.md` / `test-plan.md`, skipping
anything that already exists. Fill in `references/test-plan-template.md` →
`test-plan.md`, mapping every acceptance criterion in spec.md to a specific
test — TDD red before any implementation code — including runtime
verification evidence (screenshot/log query/recording) when there's an
actual UI or service to drive, not just unit-level assertions.

## Phase 6 — Autonomous build loop

Per task, bounded loop: implement → run the tests just written (should go
green) → self-check the task's acceptance criteria → stop. Cap at ~3
attempts per task before escalating to the human rather than silently
retrying. If you have access to background/forked subagents, dispatch
independent tasks in parallel rather than serially — they're independent
slices by construction from Phase 4. If two parallel tasks turn out to
conflict anyway (touch the same file in incompatible ways), don't let an
agent silently resolve the merge — see the conflict-handling note in
`references/pr-conventions.md`.

When the task has a runtime surface (UI, API, service), don't stop at green
tests — actually drive it if the environment allows: boot an isolated
instance, exercise the acceptance criteria, and capture evidence (see
test-plan.md's Runtime Verification section). "The tests pass" and "I drove
the feature and confirmed it" are different strengths of evidence; use the
stronger one when it's available.

Update `tasks.md`'s status checkboxes as you go — that's the on-disk loop
state, not something to hold only in conversation.

Branch/commit per `references/pr-conventions.md`
(`agent/<ticket-id>-<task-slug>`, Conventional Commits scoped to the task).

## Phase 7 — Adversarial review (human checkpoint)

Apply `references/review-rubric.md`. The reviewing pass must not reuse the
builder's context — start fresh from diff + spec.md. Run the four lenses
(correctness, security, test coverage, simplification) independently, then a
verification pass that tries to *refute* each finding before it's reported,
so only findings that survive refutation reach the human. Prefer more than
one independent reviewer (local + cloud/async, if available) and iterate
until all of them are satisfied, not just the first — see the "Ralph Wiggum
loop" note in review-rubric.md. If you have subagents available, run lenses
in parallel and verification as a separate pass per finding rather than
sequentially.

Blocking findings keep the merge gate closed. Cap fix/re-review at ~2
rounds; a third round of the same blocking finding escalates to the human
instead of looping again.

This is the second mandatory human checkpoint at the default autonomy
level: a human (or a human-delegated bot merge) makes the actual merge
decision. spec-loop's autonomy covers implementation and review; whether
merge itself requires a blocking human action is the autonomy-level dial in
`references/autonomy-levels.md`, not something to relax ad hoc.

## Phase 8 — Maintain (recurring, not per-task)

Separate from the per-story loop above: on a regular cadence, run the
golden-principles / garbage-collection loop described in
`references/golden-principles.md` — scan for drift from this repo's golden
principles and for docs that no longer match real code behavior, update
`docs/QUALITY_SCORE.md`, open small auto-mergeable fix-up PRs, and log
anything that needs a real decision to `docs/exec-plans/tech-debt-tracker.md`
instead of silently picking a side. Skip this phase for a first-time
spec-loop run in a new repo; start it once there's enough agent-generated
code that drift is a real risk.

## Enhanced mode (when subagent/orchestration tooling is available)

Everything above works with a single sequential agent — that's the fallback
every environment can run. If your environment exposes subagent dispatch or
multi-agent orchestration (in Claude Code, the Agent and Workflow tools),
prefer it for:
- Phase 3's judge panel (parallel candidate plans, independent scoring)
- Phase 6 (parallel task implementation across independent slices)
- Phase 7 (parallel review lenses + parallel adversarial verification of
  each finding, plus genuinely independent reviewer agents rather than one
  reviewer wearing multiple hats)

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
- One giant `AGENTS.md` that tries to be the whole manual instead of a map
  — it crowds out context, rots instantly, and can't be checked mechanically.
- Letting agent-replicated drift accumulate because nobody runs Phase 8 —
  "AI slop" is what happens when garbage collection is manual and humans
  are the bottleneck.
