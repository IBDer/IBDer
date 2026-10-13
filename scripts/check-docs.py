#!/usr/bin/env python3
"""Documentation integrity checks.

Mechanical rules are executed, not written down (docs/process/review-gates.md).
Run locally: python3 scripts/check-docs.py
"""

import re
import subprocess
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
AGENTS_LINE_CAP = 120
# The product's own language lives here, and in the review screenshots that show it.
CJK_ALLOWED_PREFIXES = ("IBDer/Resources/Localizable.xcstrings", "docs/review/")
BINARY_SUFFIXES = (".png", ".jpg", ".jpeg", ".webp", ".gif", ".pdf", ".mov")

VERDICT_WORDS = ["remission", "flare", "disease activity", "severity score", "risk prediction"]
VERDICT_IDENTIFIERS = ["diseaseActivity", "remission", "flare", "severityScore", "riskPrediction"]


def tracked_files(suffix=None):
    out = subprocess.run(["git", "ls-files"], cwd=ROOT, capture_output=True, text=True, check=True)
    files = [f for f in out.stdout.splitlines() if not f.endswith(BINARY_SUFFIXES)]
    if suffix:
        files = [f for f in files if f.endswith(suffix)]
    return files


def read(rel):
    return (ROOT / rel).read_text(encoding="utf-8", errors="replace")


def check_links():
    bad = []
    pattern = re.compile(r"\[[^\]]*\]\(([^)\s]+)")
    for rel in tracked_files(".md"):
        for target in pattern.findall(read(rel)):
            if target.startswith(("http://", "https://", "mailto:", "#")):
                continue
            path = target.split("#")[0]
            if path and not ((ROOT / rel).parent / path).exists():
                bad.append(f"{rel} -> {target}")
    return bad


def check_agents_cap():
    lines = len(read("AGENTS.md").splitlines())
    return [f"AGENTS.md is {lines} lines, cap is {AGENTS_LINE_CAP}"] if lines > AGENTS_LINE_CAP else []


def check_cjk():
    cjk = re.compile(r"[\u4e00-\u9fff]")
    return [rel for rel in tracked_files()
            if not rel.startswith(CJK_ALLOWED_PREFIXES) and cjk.search(read(rel))]


def check_verdicts():
    """The rules bind where a patient could read the result: UI strings and identifiers."""
    bad = []
    for rel in tracked_files():
        if not rel.endswith(".swift"):
            continue
        text = read(rel)
        for literal in re.findall(r'"([^"\n]*)"', text):
            for word in VERDICT_WORDS:
                if word in literal.lower():
                    bad.append(f"{rel}: UI literal contains '{word}'")
        for ident in VERDICT_IDENTIFIERS:
            if re.search(rf"\b{ident}\b", text):
                bad.append(f"{rel}: identifier '{ident}' is reserved")
    catalog = "IBDer/Resources/Localizable.xcstrings"
    if (ROOT / catalog).exists() and any(w in read(catalog).lower() for w in VERDICT_WORDS):
        bad.append(f"{catalog}: a UI string uses a verdict word")
    return bad


def check_no_second_entry_point():
    """One entry point. Every tool reads AGENTS.md, so copies only drift."""
    copies = [f for f in ("CLAUDE.md", ".cursorrules", "GEMINI.md") if (ROOT / f).exists()]
    return [f"second instruction file: {f}" for f in copies]


def check_duplicate_rules():
    """A rule stated twice is a rule that will disagree with itself."""
    seen = defaultdict(set)
    for rel in tracked_files(".md"):
        if rel.startswith(("docs/archive/", "openspec/changes/")) or rel.endswith("SKILL.md"):
            continue
        for sentence in re.split(r"(?<=[.;])\s+", read(rel)):
            flat = " ".join(sentence.split()).lower().strip("-*|# ")
            if len(flat.split()) < 8 or flat.startswith(("http", "`", "co-authored")):
                continue
            seen[flat].add(rel)
    return [f"stated in {', '.join(sorted(f))}: {s[:90]}" for s, f in seen.items() if len(f) > 1]


CHECKS = [
    ("links resolve", check_links, True),
    ("AGENTS.md within its cap", check_agents_cap, True),
    ("Chinese only in the String Catalog and review captures", check_cjk, True),
    ("no verdict words in UI text or identifiers", check_verdicts, True),
    ("one instruction entry point", check_no_second_entry_point, True),
    ("no rule stated twice", check_duplicate_rules, False),
]


def main():
    failed = False
    for name, check, blocking in CHECKS:
        findings = check()
        if not findings:
            print(f"ok    {name}")
            continue
        failed = failed or blocking
        print(f"{'FAIL' if blocking else 'warn'}  {name}: {len(findings)} finding(s)")
        for finding in findings[:40]:
            print(f"        {finding}")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
