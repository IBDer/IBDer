#!/usr/bin/env bash
# One screen of state, generated so it cannot rot.
# A handoff document would be stale the moment it is written; this reads the repo instead.
set -uo pipefail
cd "$(dirname "$0")/.."

printf 'branch      %s\n' "$(git branch --show-current)"
printf 'uncommitted %s file(s)\n' "$(git status --porcelain | wc -l | tr -d ' ')"

echo
echo "open pull requests"
gh pr list --state open --json number,title --jq '.[] | "  #\(.number)  \(.title)"' 2>/dev/null || echo "  (gh not available)"

TASKS=openspec/changes/add-v1-recording-core/tasks.md
echo
printf 'tasks       %s done, %s open\n' "$(grep -c '^- \[x\]' "$TASKS")" "$(grep -c '^- \[ \]' "$TASKS")"
echo "slices (visual first; see the table at the top of tasks.md)"
awk -F'|' '/^\| [0-9]\./ {gsub(/^ +| +$/, "", $2); gsub(/^ +| +$/, "", $4); print "  " $2 "  ->  " $4}' "$TASKS"

echo
echo "checks"
python3 scripts/check-docs.py 2>&1 | sed 's/^/  /'

echo
echo "waiting on the maintainer"
grep '^|' docs/pending.md | grep -v '^| ---' | tail -n +2 | cut -d'|' -f2 | sed 's/^ *//; s/ *$//; s/^/  - /'
