#!/usr/bin/env bash
# Scaffold a docs/specs/<ticket-id>-<slug>/ directory from the spec-loop templates.
# Usage: scaffold.sh <ticket-id> <slug> [target-repo-root]
set -euo pipefail

TICKET="${1:?usage: scaffold.sh <ticket-id> <slug> [target-repo-root]}"
SLUG="${2:?usage: scaffold.sh <ticket-id> <slug> [target-repo-root]}"
TARGET_ROOT="${3:-.}"
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

DEST="${TARGET_ROOT}/docs/specs/${TICKET}-${SLUG}"
mkdir -p "$DEST"

for f in spec plan tasks test-plan; do
  if [ -f "$DEST/${f}.md" ]; then
    echo "skip (exists): $DEST/${f}.md"
  else
    cp "$SKILL_DIR/references/${f}-template.md" "$DEST/${f}.md"
    echo "created: $DEST/${f}.md"
  fi
done

if [ ! -f "${TARGET_ROOT}/AGENTS.md" ]; then
  cat > "${TARGET_ROOT}/AGENTS.md" <<'EOF'
# Agent context

This project uses spec-loop. Before implementing any feature, check
docs/specs/<ticket-id>-<slug>/ for the spec, plan, tasks, and test plan —
the spec is the source of truth, not the PR description.

PR/branch conventions: docs/specs/../pr-conventions.md (see the spec-loop
skill's references/pr-conventions.md for the canonical copy).
EOF
  echo "created: ${TARGET_ROOT}/AGENTS.md"
fi

echo "done. next: fill in $DEST/spec.md (Phase 1-2 of spec-loop)."
