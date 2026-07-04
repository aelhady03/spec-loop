# Test plan: {{ticket-id}} — {{title}}

Spec: ./spec.md

Every acceptance criterion in spec.md maps to at least one test here, written
*before* the implementation (TDD red → green → refactor). If a criterion has
no test, it isn't done — full stop.

## Coverage map

| Acceptance criterion (spec.md) | Test file / case | Level (unit/integration/e2e) |
|---|---|---|

## Edge cases from grilling
Pull the edge cases surfaced during Phase 1 that need explicit test coverage
(empty input, dependency-down, concurrent write, etc.) — not just the happy
path.

## Regression guard
What existing behavior must NOT change. Add/point to the tests that already
guard it.
