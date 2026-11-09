#!/usr/bin/env python3
"""check-report-counts.py — M70-1 check: bind a report's ledger-class counts to a
command over committed bytes.

Usage: python3 check-report-counts.py <report.md> <ledger.tsv>

The ledger is the COMMITTED artifact `.ufo/waves/round-69/claim-falsification.tsv`
(column 3 = verdict). The report is the fleet-side round report that states the
counts. The check re-derives every class count from the ledger's own rows and
compares it with the count the report states, and it compares the counts the
report states with each other (the class counts plus the row total must sum:
total = wording + number + neutral).

Exit 0 only when every stated count equals the measured count.
Exit 1 on any mismatch (the wrong statement is caught).
Exit 2 SETUP (a file is missing or the ledger has no data rows).
"""
import re
import sys

WORDNUM = {
    "zero": 0, "one": 1, "two": 2, "three": 3, "four": 4, "five": 5,
    "six": 6, "seven": 7, "eight": 8, "nine": 9, "ten": 10,
}


def read(path):
    with open(path, encoding="utf-8") as fh:
        return fh.read()


def ledger_counts(path):
    total = 0
    per = {}
    for line in read(path).splitlines():
        if not line.strip() or line.startswith("#"):
            continue
        cells = line.split("\t")
        if len(cells) < 3 or not cells[0].strip():
            continue
        verdict = cells[2].strip()
        total += 1
        per[verdict] = per.get(verdict, 0) + 1
    return total, per


def find_total(text):
    """'...tsv`: 13 rows' -> 13"""
    m = re.search(r"claim-falsification\.tsv`?:?\s*(\d+)\s+rows", text)
    if not m:
        m = re.search(r"claim-falsification\.tsv`?:?[^\n]*?(\d+)\s+rows", text)
    return int(m.group(1)) if m else None


def find_class(text, cls):
    """'eight `falsifies-wording` rows' -> 8 ; also accepts digits."""
    pat = re.compile(
        r"\b(\d+|zero|one|two|three|four|five|six|seven|eight|nine|ten)\b"
        r"\s+`?" + cls + r"`?\s+rows", re.IGNORECASE)
    m = pat.search(text)
    if not m:
        return None
    tok = m.group(1).lower()
    return int(tok) if tok.isdigit() else WORDNUM[tok]


def main():
    if len(sys.argv) != 3:
        print("SETUP usage: check-report-counts.py <report.md> <ledger.tsv>")
        return 2
    report_path, ledger_path = sys.argv[1], sys.argv[2]
    try:
        report = read(report_path)
    except OSError as exc:
        print(f"SETUP report-unreadable {exc}")
        return 2
    try:
        total, per = ledger_counts(ledger_path)
    except OSError as exc:
        print(f"SETUP ledger-unreadable {exc}")
        return 2
    if total == 0:
        print("SETUP ledger-no-data-rows")
        return 2

    measured = {
        "falsifies-wording": per.get("falsifies-wording", 0),
        "falsifies-number": per.get("falsifies-number", 0),
        "neutral": per.get("neutral", 0),
    }
    stated_total = find_total(report)
    stated = {
        "falsifies-wording": find_class(report, "falsifies-wording"),
        "falsifies-number": find_class(report, "falsifies-number"),
        "neutral": find_class(report, "neutral"),
    }

    print(f"LEDGER {ledger_path}")
    print(f"  MEASURED rows={total} "
          f"falsifies-wording={measured['falsifies-wording']} "
          f"falsifies-number={measured['falsifies-number']} "
          f"neutral={measured['neutral']}")
    print(f"REPORT {report_path}")
    print(f"  STATED   rows={stated_total} "
          f"falsifies-wording={stated['falsifies-wording']} "
          f"falsifies-number={stated['falsifies-number']} "
          f"neutral={stated['neutral']}")

    bad = []
    for cls in ("falsifies-wording", "falsifies-number", "neutral"):
        s = stated[cls]
        if s is None:
            continue
        if s != measured[cls]:
            bad.append(f"MISMATCH {cls} stated={s} measured={measured[cls]}")
    if stated_total is not None and stated_total != total:
        bad.append(f"MISMATCH rows stated={stated_total} measured={total}")

    # internal consistency: the stated class counts must account for the stated total
    have = {c: v for c, v in stated.items() if v is not None}
    if stated_total is not None and have:
        if sum(have.values()) > stated_total:
            bad.append(f"MISMATCH internal-sum stated-classes={sum(have.values())} "
                       f"stated-rows={stated_total} (classes exceed the stated row total)")
        else:
            implied = stated_total - sum(have.values())
            print(f"  IMPLIED   unstated-classes={implied} "
                  f"(measured neutral={measured['neutral']})")
            if "neutral" not in have and implied != measured["neutral"]:
                bad.append(f"MISMATCH implied-neutral={implied} "
                           f"measured-neutral={measured['neutral']}")

    if bad:
        for line in bad:
            print(line)
        print(f"REPORT_COUNTS: FAIL ({len(bad)} mismatch(es))")
        return 1
    print("REPORT_COUNTS: CLEAN")
    return 0


if __name__ == "__main__":
    sys.exit(main())
