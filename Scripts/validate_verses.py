#!/usr/bin/env python3
"""Validate verses.json and mood verse ID references."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
VERSES_PATH = ROOT / "GitaApp" / "verses.json"
MOOD_PATH = ROOT / "GitaApp" / "Mood.swift"


def load_verses() -> list[dict]:
    return json.loads(VERSES_PATH.read_text())


def load_mood_ids() -> dict[str, list[int]]:
    text = MOOD_PATH.read_text()
    moods: dict[str, list[int]] = {}
    current = None
    for line in text.splitlines():
        m = re.search(r'id:\s*"([^"]+)"', line)
        if m:
            current = m.group(1)
        m = re.search(r"verseIDs:\s*\[([^\]]+)\]", line)
        if m and current:
            ids = [int(x.strip()) for x in m.group(1).split(",") if x.strip()]
            moods[current] = ids
    return moods


def main() -> int:
    verses = load_verses()
    valid_ids = {v["id"] for v in verses}
    issues: list[str] = []

    seen: set[int] = set()
    for v in verses:
        vid = v["id"]
        if vid in seen:
            issues.append(f"Duplicate id {vid}")
        seen.add(vid)
        for field in ("quote", "takeaway", "scene", "shlok"):
            if not str(v.get(field, "")).strip():
                issues.append(f"Verse {vid} missing {field}")

    moods = load_mood_ids()
    for mood, ids in moods.items():
        missing = [i for i in ids if i not in valid_ids]
        if missing:
            issues.append(f"Mood {mood} missing ids: {missing}")
        if len(ids) != 8:
            issues.append(f"Mood {mood} has {len(ids)} ids (expected 8)")

    chapters = sorted({v["chapter"] for v in verses})
    print(f"Loaded {len(verses)} verses, chapters {chapters[0]}-{chapters[-1]}")

    if issues:
        print("FAILED:")
        for issue in issues:
            print(f"  - {issue}")
        return 1

    print("OK: verse data and mood references look valid.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
