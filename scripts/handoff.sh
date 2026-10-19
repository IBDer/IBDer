#!/usr/bin/env bash
# One screen of state, generated so it cannot rot.
# A handoff document would be stale the moment it was written; this reads the repo and the board.
set -uo pipefail
cd "$(dirname "$0")/.."

printf 'branch      %s\n' "$(git branch --show-current)"
printf 'uncommitted %s file(s)\n' "$(git status --porcelain | wc -l | tr -d ' ')"

echo
echo "milestones"
gh api repos/IBDer/IBDer/milestones --jq '.[] | "  \(.title)  \(.open_issues) open"' 2>/dev/null || echo "  (gh unavailable)"

echo
echo "waiting on the maintainer"
gh issue list --repo IBDer/IBDer --label needs-decision --json number,title --jq '.[] | "  #\(.number)  \(.title)"' 2>/dev/null
gh issue list --repo IBDer/IBDer --label needs-review --json number,title --jq '.[] | "  #\(.number)  \(.title)"' 2>/dev/null

echo
echo "open issues"
gh issue list --repo IBDer/IBDer --state open --json number,title,milestone --jq '.[] | "  #\(.number) [\(.milestone.title // "decision")] \(.title)"' 2>/dev/null | head -12

echo
echo "openspec"
printf '  tasks: %s done, %s open\n' \
  "$(grep -c '^- \[x\]' openspec/changes/add-v1-recording-core/tasks.md)" \
  "$(grep -c '^- \[ \]' openspec/changes/add-v1-recording-core/tasks.md)"
openspec validate --all --strict 2>&1 | tail -1 | sed 's/^/  /'

echo
echo "checks"
python3 scripts/check-docs.py 2>&1 | sed 's/^/  /'
