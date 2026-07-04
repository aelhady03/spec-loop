# Grilling checklist — gap-finding question bank

Used in Phase 1 (Grill) of spec-loop. Work down these categories against the raw
story. For each category: first try to answer it yourself from the codebase
(grep, read configs, check existing patterns) — only surface it as a question
to the human if the codebase genuinely doesn't answer it and the answer would
change scope, design, or acceptance criteria. Never ask about things you can
verify by reading.

## Actors & triggers
- Who/what initiates this? (human user, another service, a schedule, an event)
- Are there multiple actor roles with different permissions/views?
- What starts the flow — a UI action, an API call, a webhook, a cron?

## Happy path
- What's the single most common successful path, end to end?
- What does "done" look like from the actor's point of view?

## Edge cases & error states
- What happens on empty/null/zero/duplicate input?
- What happens if a dependency (DB, API, queue) is down or slow?
- What happens on partial failure / retry / concurrent execution?
- Is this idempotent? Does it need to be?

## Non-functional requirements
- Any latency, throughput, or scale expectations?
- Any auth/permission boundaries?
- Any data privacy/compliance constraints (PII, retention, audit logging)?
- Any backwards-compatibility constraint (existing clients, migrations)?

## Boundaries (non-goals)
- What is explicitly OUT of scope for this story, even if adjacent?
- Is there a related feature this must NOT touch or change?

## Dependencies & sequencing
- Does this depend on another in-flight change, flag, or migration?
- Does anything else depend on this shipping first?

## Rollout & reversibility
- Feature-flagged, or does it ship live?
- How would this be rolled back if it's wrong in production?
- Any data migration that's hard to reverse?

## Acceptance / verification
- How will we know this actually works — what's the observable proof?
- What's the minimum test that would catch a regression here?

---

### Loop rule
Run one grilling round, note every gap found and how it was resolved (either
"resolved by reading X" or "resolved by asking human — answer: Y" or
"unresolved — documented as assumption"). Run a second round against the
*updated* understanding. Stop when a round produces zero new gaps, or after 3
rounds — whichever comes first. Anything still unresolved after that gets
written into spec.md under **Assumptions**, flagged for the human to
sign off on at the Phase 2 checkpoint, rather than blocking indefinitely.

When you do need to ask the human, batch questions (≈4 at a time), and only
ask ones where each plausible answer would lead to a genuinely different
plan — not preference-only bikeshedding.
