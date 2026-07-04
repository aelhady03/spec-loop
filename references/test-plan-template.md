# Test plan: {{ticket-id}} — {{title}}

Spec: docs/product-specs/{{ticket-id}}-{{slug}}.md

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

## Runtime verification (when there's a runtime surface)
For anything with a UI, API, or observable running behavior, "tests pass"
isn't sufficient evidence on its own — drive it. If the environment supports
it: boot an isolated instance (e.g. per-worktree), actually exercise the
acceptance criteria against it, and attach evidence to the PR (screenshot,
short recording, or a log/metric query result — e.g. "p95 latency for this
endpoint stayed under 800ms" via the observability stack). Skip this section
for pure logic/library changes with no runtime surface to drive.
