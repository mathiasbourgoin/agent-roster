#!/usr/bin/env bash
# Backward-compatible wrapper around the TypeScript indexer.
# Preferred: npm run build:index

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

if [ "${1:-}" = "--stdout" ]; then
  TMP_OUT="$(mktemp)"
  npm run -s build:index -- --output "$TMP_OUT" --quiet
  cat "$TMP_OUT"
  rm -f "$TMP_OUT"
  exit 0
fi

npm run -s build:index -- "$@"
