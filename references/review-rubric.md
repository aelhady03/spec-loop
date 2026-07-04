# Adversarial review rubric

The reviewer must not be the builder. Whether that's literally a separate
agent/subagent invocation or a separate conversation context, the reviewing
pass starts from the diff + spec.md only — not from the builder's reasoning
trail — so it can't inherit the builder's blind spots.

## Lenses (run independently, not sequentially)
1. **Correctness** — does the diff actually satisfy every acceptance
   criterion in spec.md? Walk each Given/When/Then against the code.
2. **Security** — injection, auth/authz bypass, secrets, unsafe
   deserialization, SSRF — whatever's relevant to the touched surface.
3. **Test coverage** — does test-plan.md's coverage map actually exist in
   the diff, and do the tests fail without the implementation (not
   tautological)?
4. **Simplification / reuse** — unnecessary abstraction, dead code,
   duplicated logic that already exists elsewhere in the repo.

## Verification pass (kill false positives before they reach the human)
For each finding raised by a lens above, a second pass tries to *refute* it:
reproduce it against the actual code/tests, not just re-read the diff and
agree. A finding that can't be reproduced or doesn't hold up under refutation
is dropped silently (not surfaced as a hedge) — only findings that survive
refutation get posted.

## Severity
- **Blocking** — violates an acceptance criterion, a security issue, or a
  test that doesn't actually test anything. Merge gate stays closed.
- **Advisory** — simplification/reuse findings. Reported, doesn't block.

## Output
One comment per surviving finding: file:line, what's wrong, the concrete
failure scenario (input/state → wrong output), severity. No restating what
the diff already makes obvious.

## Bounded iteration
If the builder fixes and re-submits, re-review only the changed hunks plus
anything a fix could have broken — not the whole diff from scratch. Cap at
~2 fix/re-check rounds; a third round of the same blocking finding means
escalate to the human rather than keep looping.

## Multiple independent reviewers when available — single-reviewer fallback otherwise
Prefer more than one independent reviewer over one: have the builder
request review from more than one independent reviewer — locally and, if
available, cloud/async — and keep iterating until **all** reviewer agents
are satisfied, not just the first one. This is the same shape as what's
elsewhere called a [Ralph Wiggum
loop](https://ghuntley.com/ralph/): the same review prompt re-run each
iteration against the current diff, with state (the findings, what's been
fixed) persisted on disk in the PR/tasks.md rather than only in a
conversation. The bounded-iteration cap above still applies per reviewer.

**Degraded mode (no subagent dispatch available):** run the four lenses
above yourself, sequentially, in a fresh pass that only reads the diff +
spec.md (don't carry over the builder's reasoning trail from earlier in the
same conversation) — this is a single reviewer, not zero. It's weaker than
independent parallel reviewers because one pass can share blind spots with
itself across lenses, but it's still a real, separate review step, and
still subject to the verification/refutation pass and bounded-iteration cap
above. Don't skip review entirely just because multi-agent dispatch isn't
available.

At L3 autonomy (spec-loop's default, see autonomy-levels.md) a human still
makes the final call once reviewer agents are satisfied. At L4, "all
reviewer agents satisfied" is itself the merge gate, and the human is
notified rather than blocking — see the merge-gate note in
pr-conventions.md before turning that dial.
