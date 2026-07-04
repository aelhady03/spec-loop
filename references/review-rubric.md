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
