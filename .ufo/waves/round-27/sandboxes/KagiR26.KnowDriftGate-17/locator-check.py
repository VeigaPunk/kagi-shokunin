#!/usr/bin/env python3
"""Read-only locator + mutation proof for corpus/knowledge/drift-gate.md (round 27 C1).

Reproduces the report's two measurements without executing any gate:
  A. each candidate locator has exactly one capture group and matches exactly
     one line of the entry;
  B. against the self-counts rows that currently target the entry, a one-digit
     mutation of each in-population number is VISIBLE only if some row's
     capture changes or a previously matching locator stops matching
     (both exit 1 in corpus/self-counts.py:329-361).
"""
import re

DOC = "corpus/knowledge/drift-gate.md"
TABLE = "corpus/self-counts.tsv"

LOCATORS = {
    "DRIFT-PINS-LINES": r"^Sources: .*\(round-9 v2, ([0-9]+) lines,",
    "DRIFT-BASE-ROWS": r"^`corpus/drift-baseline\.tsv` \(([0-9]+) rows\)",
    "DRIFT-SYM-ROWS": r"^`corpus/drift-baseline\.tsv` \([0-9]+ rows\), `corpus/drift-symbols\.tsv` \(([0-9]+) rows\)",
    "DRIFT-HANDOFF-PINS": r"^\| `handoff-status\.json:#1` ×([0-9]+) \|",
    "DRIFT-HASHED-FILES": r"^\| everything else \| ([0-9]+) files, mode 644/755 \|",
    "DRIFT-NOHASH-6": r"^from its hash alone.*for the ([0-9]+)$",
    "DRIFT-OPREF-ZERO": r"^Verified clean: the committed TSVs contain ([0-9]+) `op://` refs and",
    "DRIFT-OPKEY-ZERO": r"^Verified clean: the committed TSVs contain [0-9]+ `op://` refs and ([0-9]+) `op\.env` key",
    "DRIFT-BOUND-NUMERATOR": r"^- \*\*([0-9]+) of [0-9]+ files are content-unhashed",
    "DRIFT-BOUND-DENOM": r"^- \*\*[0-9]+ of ([0-9]+) files are content-unhashed",
    "DRIFT-ROW-LIST": r"^  ([0-9]+)-row list\.",
    "DRIFT-SELFTEST-CASES": r"^Selftest cases \(([0-9]+)\): clean, content drift",
    "DRIFT-FALSIFY-CASES": r"^Run the commands above: clean run, ([0-9]+)-case selftest",
}

MUTATIONS = [
    ("L3 451->452", "round-9 v2, 451 lines", "round-9 v2, 452 lines"),
    ("L4 baseline 15->14", "`corpus/drift-baseline.tsv` (15 rows)", "`corpus/drift-baseline.tsv` (14 rows)"),
    ("L4 symbols 20->19", "`corpus/drift-symbols.tsv` (20 rows)", "`corpus/drift-symbols.tsv` (19 rows)"),
    ("L59 x2->x3", "`handoff-status.json:#1` ×2", "`handoff-status.json:#1` ×3"),
    ("L97 9->8", "| everything else | 9 files,", "| everything else | 8 files,"),
    ("L101 6->7", "explicit: for the 6", "explicit: for the 7"),
    ("L110 opref 0->1", "TSVs contain 0 `op://`", "TSVs contain 1 `op://`"),
    ("L110 opkey 0->1", "refs and 0 `op.env` key", "refs and 1 `op.env` key"),
    ("L143 num 6->7", "**6 of 15 files", "**7 of 15 files"),
    ("L143 den 15->14", "**6 of 15 files", "**6 of 14 files"),
    ("L159 15->16", "  15-row list.", "  16-row list."),
    ("L189 13->14", "Selftest cases (13):", "Selftest cases (14):"),
    ("L197 13->12", "clean run, 13-case", "clean run, 12-case"),
]


def hits(pattern, doc):
    regex = re.compile(pattern)
    return [(num, m.group(1)) for num, line in enumerate(doc, 1) for m in [regex.search(line)] if m]


def after_rows():
    rows = []
    with open(TABLE, encoding="utf-8") as handle:
        for line in handle:
            if not line.strip() or line.lstrip().startswith("#"):
                continue
            fields = line.rstrip("\n").split("\t")
            if fields[1] == DOC:
                rows.append((fields[0], fields[2], fields[3]))
    return rows


def main():
    doc = open(DOC, encoding="utf-8").read().splitlines()
    print(f"doc={DOC} logical_lines={len(doc)}")
    print("\nA. candidate locators")
    for ident, pattern in LOCATORS.items():
        found = hits(pattern, doc)
        groups = re.compile(pattern).groups
        ok = groups == 1 and len(found) == 1
        print(f"{'OK  ' if ok else 'BAD '} {ident} groups={groups} hits={found}")

    rows = after_rows()
    print(f"\nB. draft rows targeting this entry: {[(r[0], r[2]) for r in rows]}")
    visible = 0
    for label, old, new in MUTATIONS:
        mutated = [line.replace(old, new) for line in doc]
        if mutated == doc:
            print(f"{label}: MUTATION DID NOT APPLY")
            continue
        changed, lost = [], []
        for ident, pattern, _source in rows:
            before, now = hits(pattern, doc), hits(pattern, mutated)
            if before and not now:
                lost.append(ident)
            elif before and now and before[0][1] != now[0][1]:
                changed.append(f"{ident}:{before[0][1]}->{now[0][1]}")
        verdict = "VISIBLE" if (changed or lost) else "INVISIBLE"
        visible += verdict == "VISIBLE"
        print(f"{label}: {verdict} changed={changed} lost={lost}")
    print(f"\n{visible}/{len(MUTATIONS)} one-digit mutations reach the draft binder")


if __name__ == "__main__":
    main()
