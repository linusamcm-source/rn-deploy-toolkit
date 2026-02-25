#!/usr/bin/env bash
# monitor-logs.sh — Scan deploy session logs for errors and warnings
# Usage: bash ${CLAUDE_PLUGIN_ROOT}/scripts/monitor-logs.sh [logs_dir]

set -euo pipefail

LOGS_DIR="${1:-logs}"

if [ ! -d "$LOGS_DIR" ]; then
  echo "No logs directory found at: $LOGS_DIR"
  exit 0
fi

echo "=== Deploy Log Monitor ==="
echo "Directory: $LOGS_DIR"
echo ""

# Count by severity
ERROR_COUNT=$(grep -rch 'ERROR' "$LOGS_DIR"/*.log 2>/dev/null | awk '{s+=$1} END {print s+0}')
WARN_COUNT=$(grep -rch 'WARN' "$LOGS_DIR"/*.log 2>/dev/null | awk '{s+=$1} END {print s+0}')
INFO_COUNT=$(grep -rch 'INFO' "$LOGS_DIR"/*.log 2>/dev/null | awk '{s+=$1} END {print s+0}')

echo "Summary:"
echo "  ERROR: $ERROR_COUNT"
echo "  WARN:  $WARN_COUNT"
echo "  INFO:  $INFO_COUNT"
echo ""

# Show recent errors
if [ "$ERROR_COUNT" -gt 0 ]; then
  echo "=== Recent Errors ==="
  grep -rn 'ERROR' "$LOGS_DIR"/*.log 2>/dev/null | tail -20
  echo ""
fi

# Show recent warnings
if [ "$WARN_COUNT" -gt 0 ]; then
  echo "=== Recent Warnings ==="
  grep -rn 'WARN' "$LOGS_DIR"/*.log 2>/dev/null | tail -10
  echo ""
fi

# Check shared error log
if [ -f "$LOGS_DIR/error.log" ]; then
  SHARED_ERRORS=$(wc -l < "$LOGS_DIR/error.log")
  if [ "$SHARED_ERRORS" -gt 0 ]; then
    echo "=== Shared Error Log ($SHARED_ERRORS entries) ==="
    tail -20 "$LOGS_DIR/error.log"
  fi
fi

echo ""
echo "=== Log Files ==="
ls -la "$LOGS_DIR"/*.log 2>/dev/null || echo "No log files found"
