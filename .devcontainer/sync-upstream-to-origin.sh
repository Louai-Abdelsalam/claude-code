#!/usr/bin/env bash
set -euo pipefail

UPSTREAM_REMOTE="${1:-upstream}"
ORIGIN_REMOTE="${2:-origin}"
BRANCH="${3:-main}"

git fetch "$UPSTREAM_REMOTE"
git rebase "$UPSTREAM_REMOTE/$BRANCH"
git push "$ORIGIN_REMOTE" "$BRANCH" --force-with-lease
