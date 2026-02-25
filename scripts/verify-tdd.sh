#!/usr/bin/env bash
# verify-tdd.sh — Check that code fixes followed TDD (test file references in logs)
# Usage: bash ${CLAUDE_PLUGIN_ROOT}/scripts/verify-tdd.sh [logs_dir]

set -euo pipefail

LOGS_DIR="${1:-logs}"

if [ ! -d "$LOGS_DIR" ]; then
  echo "No logs directory found at: $LOGS_DIR"
  exit 0
fi

echo "=== TDD Compliance Check ==="
echo ""

# Check for RED phase entries
RED_COUNT=$(grep -rc '\[INFO\] RED:' "$LOGS_DIR"/*.log 2>/dev/null | awk -F: '{s+=$2} END {print s+0}')
GREEN_COUNT=$(grep -rc '\[INFO\] GREEN:' "$LOGS_DIR"/*.log 2>/dev/null | awk -F: '{s+=$2} END {print s+0}')
REFACTOR_COUNT=$(grep -rc '\[INFO\] REFACTOR:' "$LOGS_DIR"/*.log 2>/dev/null | awk -F: '{s+=$2} END {print s+0}')

echo "TDD Phase Counts:"
echo "  RED (test written):     $RED_COUNT"
echo "  GREEN (fix applied):    $GREEN_COUNT"
echo "  REFACTOR (cleaned up):  $REFACTOR_COUNT"
echo ""

# Check for violations: GREEN without RED
if [ "$GREEN_COUNT" -gt "$RED_COUNT" ]; then
  VIOLATIONS=$((GREEN_COUNT - RED_COUNT))
  echo "WARNING: $VIOLATIONS GREEN phases without corresponding RED phase!"
  echo "These fixes may not have tests:"
  grep -n '\[INFO\] GREEN:' "$LOGS_DIR"/*.log 2>/dev/null | tail -10
  echo ""
fi

# Check for fix tasks without test references
FIX_ENTRIES=$(grep -rc 'FIX:' "$LOGS_DIR"/*.log 2>/dev/null | awk -F: '{s+=$2} END {print s+0}')
TEST_REFS=$(grep -rc '\.test\.\|\.spec\.\|__tests__' "$LOGS_DIR"/*.log 2>/dev/null | awk -F: '{s+=$2} END {print s+0}')

echo "Fix Tasks: $FIX_ENTRIES"
echo "Test File References: $TEST_REFS"

if [ "$FIX_ENTRIES" -gt 0 ] && [ "$TEST_REFS" -eq 0 ]; then
  echo ""
  echo "WARNING: Fix tasks found but no test file references in logs!"
  echo "This suggests TDD may not have been followed."
fi

echo ""
echo "=== TDD Compliance: $([ "$RED_COUNT" -ge "$GREEN_COUNT" ] && echo 'PASS' || echo 'NEEDS REVIEW') ==="
