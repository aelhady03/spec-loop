#!/usr/bin/env bash
# Scaffold spec-loop's knowledge-base skeleton (idempotent) plus a new
# ticket's spec/plan/tasks/test-plan artifacts, per
# references/knowledge-base-structure.md.
# Usage: scaffold.sh <ticket-id> <slug> [target-repo-root]
set -euo pipefail

TICKET="${1:?usage: scaffold.sh <ticket-id> <slug> [target-repo-root]}"
SLUG="${2:?usage: scaffold.sh <ticket-id> <slug> [target-repo-root]}"
TARGET_ROOT="${3:-.}"
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# --- 1. knowledge-base skeleton (created once, left alone after that) ---

mkdir -p \
  "${TARGET_ROOT}/docs/design-docs" \
  "${TARGET_ROOT}/docs/product-specs" \
  "${TARGET_ROOT}/docs/exec-plans/active" \
  "${TARGET_ROOT}/docs/exec-plans/completed" \
  "${TARGET_ROOT}/docs/generated"

if [ ! -f "${TARGET_ROOT}/AGENTS.md" ]; then
  cat > "${TARGET_ROOT}/AGENTS.md" <<'EOF'
# Agent context

This is a map, not a manual — keep it short. Point to docs/, don't inline it.

This project uses spec-loop. Before implementing any feature:
- Check docs/product-specs/index.md for an existing spec.
- Check docs/exec-plans/active/ for in-flight plans/tasks.
- ARCHITECTURE.md is the top-level domain/layer map.
- docs/design-docs/core-beliefs.md has this repo's golden principles.

The spec is the source of truth, not the PR description. See the spec-loop
skill's references/ for templates, PR conventions, and the review rubric.
EOF
  echo "created: ${TARGET_ROOT}/AGENTS.md"
fi

if [ ! -f "${TARGET_ROOT}/ARCHITECTURE.md" ]; then
  cat > "${TARGET_ROOT}/ARCHITECTURE.md" <<'EOF'
# Architecture

Top-level domain/layer map. Fill this in with this repo's actual layering
rule (e.g. Types -> Config -> Repo -> Service -> Runtime -> UI) and which
cross-cutting concerns (auth, telemetry, feature flags) enter through which
shared interface. Enforce it mechanically once it's real (linters/structural
tests), not just as prose.
EOF
  echo "created: ${TARGET_ROOT}/ARCHITECTURE.md"
fi

if [ ! -f "${TARGET_ROOT}/docs/product-specs/index.md" ]; then
  printf '# Product specs\n\n| Ticket | Title | Status |\n|---|---|---|\n' \
    > "${TARGET_ROOT}/docs/product-specs/index.md"
  echo "created: ${TARGET_ROOT}/docs/product-specs/index.md"
fi

if [ ! -f "${TARGET_ROOT}/docs/design-docs/core-beliefs.md" ]; then
  cp "$SKILL_DIR/references/golden-principles.md" \
     "${TARGET_ROOT}/docs/design-docs/core-beliefs.md"
  echo "created: ${TARGET_ROOT}/docs/design-docs/core-beliefs.md (starter copy — edit to reflect this repo's actual principles)"
fi

if [ ! -f "${TARGET_ROOT}/docs/exec-plans/tech-debt-tracker.md" ]; then
  printf '# Tech debt tracker\n\n| Found | Description | Source | Status |\n|---|---|---|---|\n' \
    > "${TARGET_ROOT}/docs/exec-plans/tech-debt-tracker.md"
  echo "created: ${TARGET_ROOT}/docs/exec-plans/tech-debt-tracker.md"
fi

if [ ! -f "${TARGET_ROOT}/docs/QUALITY_SCORE.md" ]; then
  printf '# Quality score\n\nPer-domain/per-layer grade, tracked over time by the golden-principles garbage-collection loop.\n\n| Domain | Grade | Last checked | Notes |\n|---|---|---|---|\n' \
    > "${TARGET_ROOT}/docs/QUALITY_SCORE.md"
  echo "created: ${TARGET_ROOT}/docs/QUALITY_SCORE.md"
fi

# --- 2. this ticket's artifacts ---

SPEC_DEST="${TARGET_ROOT}/docs/product-specs/${TICKET}-${SLUG}.md"
if [ -f "$SPEC_DEST" ]; then
  echo "skip (exists): $SPEC_DEST"
else
  cp "$SKILL_DIR/references/spec-template.md" "$SPEC_DEST"
  echo "created: $SPEC_DEST"
fi

PLAN_DIR="${TARGET_ROOT}/docs/exec-plans/active/${TICKET}-${SLUG}"
mkdir -p "$PLAN_DIR"
for f in plan tasks test-plan; do
  if [ -f "$PLAN_DIR/${f}.md" ]; then
    echo "skip (exists): $PLAN_DIR/${f}.md"
  else
    cp "$SKILL_DIR/references/${f}-template.md" "$PLAN_DIR/${f}.md"
    echo "created: $PLAN_DIR/${f}.md"
  fi
done

echo "done. next: fill in $SPEC_DEST (Phase 1-2 of spec-loop), then add a row to docs/product-specs/index.md."
