# Changelog

## 0.3.0 — 2026-07-04
- Fixed a path-traversal bug in `scripts/scaffold.sh`: `ticket-id`/`slug`
  are now validated against `[A-Za-z0-9_-]+` and rejected otherwise, since
  they're used unescaped as path segments.
- `scripts/scaffold.sh` now detects the repo root via `git rev-parse
  --show-toplevel` instead of defaulting to the caller's cwd.
- Added explicit ticket-id minting guidance for repos with no existing
  ticketing system (Phase 0).
- Added brownfield guidance for extending an existing spec instead of
  starting a competing one (Phase 0, spec-template.md's new Amendments
  section).
- Added merge-conflict/rebase guidance for parallel tasks and stacked
  branches (`pr-conventions.md`).
- Added an explicit single-reviewer degraded mode for environments without
  subagent dispatch (`review-rubric.md`), instead of only describing the
  multi-reviewer case.
- Added `examples/` with a full worked story run through Phases 0-5.
- Removed unused `TaskCreate`/`TaskUpdate` from `SKILL.md`'s `allowed-tools`
  (dead entries, never referenced in the instructions).
- Added `CONTRIBUTING.md` and this changelog.

## 0.2.0 — 2026-07-04
- Restructured the knowledge base from a flat `docs/specs/<ticket>/` layout
  to `docs/product-specs/` + `docs/exec-plans/{active,completed}/` +
  `docs/design-docs/` + `docs/QUALITY_SCORE.md`.
- Added `references/knowledge-base-structure.md` (`AGENTS.md` as a map, not
  a manual), `references/autonomy-levels.md` (L1-L5 ladder), and
  `references/golden-principles.md` (Phase 8, recurring garbage-collection
  loop).
- Added runtime-verification guidance to the build loop and test plan —
  driving the app for evidence, not just green tests, when there's a
  runtime surface.
- Added multiple-independent-reviewer guidance to the review rubric.

## 0.1.0 — 2026-07-04
- Initial release: Phases 0-7 (Intake, Grill, Spec, Plan, Tasks, Scaffold,
  Build loop, Adversarial review), `references/` templates and rubrics,
  `scripts/scaffold.sh`.
