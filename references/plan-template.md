# Plan: {{ticket-id}} — {{title}}

Spec: docs/product-specs/{{ticket-id}}-{{slug}}.md
Lives at: docs/exec-plans/active/{{ticket-id}}-{{slug}}/plan.md (moves to
exec-plans/completed/ once the last task merges)

## Approach
The chosen design, in prose. What it touches, what it doesn't.

## Alternatives considered
| Option | Pros | Cons | Why not chosen |
|---|---|---|---|

Only fill this in for genuinely non-trivial designs (2+ defensible approaches).
For a straightforward task, skip straight to Approach.

## Architecture / data flow
Sketch the pieces that change and how they connect. Prefer a short bullet list
or ASCII sketch over prose.

## Dependency graph
What must land before what. This drives task ordering in tasks.md.

## Checkpoints
The points where a human should look before autonomous work continues past
them. Default: spec approval (before this plan) and PR review (after
implementation) — only add more if the risk/blast-radius warrants it.

## Rollback plan
How this gets undone in production if it's wrong.
