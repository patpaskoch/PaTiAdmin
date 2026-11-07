#!/usr/bin/env python3
"""Read-only cross-addon focus view; never changes INGAME_TESTING.md."""
import argparse
import csv
import os
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
MAPPING = ROOT / "docs" / "INGAME_TEST_FOCUS.tsv"
ADDONS = pathlib.Path(os.environ.get("PATI_ADDONS_DIR") or ROOT.parent / "PaTiAddons")
TEST_RE = re.compile(r"^- \[([ x])\] (PT-[A-Z]+-\d{3}) (.*)$")
DATE_RE = re.compile(r"VERIFIED \d{4}-\d\d-\d\d")


def read_manifest(path):
    # Line endings differ between Git checkouts (autocrlf); the content decides.
    return path.read_bytes().replace(b"\r\n", b"\n")


def parse_tests(path):
    result = {}
    current = None
    for line in path.read_text(encoding="utf-8").splitlines():
        match = TEST_RE.match(line)
        if match:
            current = match.group(2)
            result[current] = {"verified": match.group(1) == "x",
                               "title": match.group(3), "has_verified": False}
        elif line.startswith("  - ") and current:
            if DATE_RE.search(line):
                result[current]["has_verified"] = True
        elif line and not line[0].isspace():
            current = None
    return result


def main():
    parser = argparse.ArgumentParser(description="Prioritized manual in-game checks using verified PaTiShared evidence")
    parser.add_argument("--list", choices=["shared", "smoke", "all"], default="all")
    parser.add_argument("--summary", action="store_true")
    args = parser.parse_args()
    with MAPPING.open(encoding="utf-8", newline="") as source:
        mapping = list(csv.DictReader(
            (line for line in source if not line.startswith("#")),
            fieldnames=["repo", "test_id", "category", "evidence"], delimiter="	"))
    heal_dir = ADDONS / "PaTiHeal"
    if not (heal_dir / "INGAME_TESTING.md").is_file():
        print("Missing PaTiHeal/INGAME_TESTING.md. Checkout all repos alongside PaTiAdmin.", file=sys.stderr)
        return 2
    reference_manifest = read_manifest(heal_dir / "Shared" / ".manifest")
    heal_tests = parse_tests(heal_dir / "INGAME_TESTING.md")
    cache = {}
    items = []
    skipped = 0
    for record in mapping:
        repo = record["repo"]
        addon_dir = ADDONS / repo
        if repo not in cache:
            path = addon_dir / "INGAME_TESTING.md"
            manifest = addon_dir / "Shared" / ".manifest"
            if not path.is_file() or not manifest.is_file():
                print(f"Missing test file or Shared manifest: {repo}", file=sys.stderr)
                return 2
            cache[repo] = (parse_tests(path), read_manifest(manifest) == reference_manifest)
        tests, same_shared = cache[repo]
        test = tests.get(record["test_id"])
        if test is None:
            print(f"Unknown test ID {record['test_id']} in {repo}", file=sys.stderr)
            return 2
        if test["verified"]:
            skipped += 1
            continue  # Already actually confirmed in this addon.
        if record["category"] == "shared":
            evidence = heal_tests.get(record["evidence"])
            if not same_shared or not evidence or not evidence["verified"] or not evidence["has_verified"]:
                coverage = "NOT MATCHED / RETEST"
            else:
                coverage = f"SHARED CODE COVERED (PaTiHeal {record['evidence']}); ADDON UNVERIFIED"
        else:
            coverage = "ADDON SMOKE TEST REQUIRED"
        items.append((record, test, coverage))
    selected = [i for i in items if args.list == "all" or i[0]["category"] == args.list]
    if args.summary:
        shared = sum(1 for i in items if i[0]["category"] == "shared")
        smoke = sum(1 for i in items if i[0]["category"] == "smoke")
        matched = sum(1 for i in items if i[0]["category"] == "shared"
                      and i[2].startswith("SHARED CODE COVERED"))
        print(f"Mapped open tests: {shared} shared candidates ({matched} matched), "
              f"{smoke} individual smoke checks; {skipped} already verified and skipped.")
    for record, test, coverage in selected:
        print(f"{record['repo']:15} {record['test_id']:18} {coverage}")
        print(f"    {test['title']}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
