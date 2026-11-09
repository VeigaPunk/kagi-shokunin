#!/usr/bin/env python3
"""check-census-w04.py — M70-2 check: bind a report's census-warning count to a
command over committed bytes.

Usage: python3 check-census-w04.py <report.md> <census-receipt>

The census receipt is a COMMITTED capture of the census run (stdout). The check
re-derives the W04 population with `grep -c W04` semantics (a line carrying the
W04 code), compares it with the count the report states, and detects the
tail-read mechanism: when the report names exactly the LAST n W04 row ids of the
receipt and n < the population, the count was read off the end of the file
rather than counted over it.

Exit 0 only when the stated count equals the measured count and the named ids
are not a tail-only subset of the population.
Exit 1 on any mismatch or on a detected tail-read.
Exit 2 SETUP (a file is missing).
"""
import re
import sys

WORDNUM = {
    "zero": 0, "one": 1, "two": 2, "three": 3, "four": 4, "five": 5,
    "six": 6, "seven": 7, "eight": 8, "nine": 9, "ten": 10,
    "eleven": 11, "twelve": 12, "thirteen": 13, "fourteen": 14, "fifteen": 15,
    "sixteen": 16, "seventeen": 17, "eighteen": 18, "nineteen": 19,
    "twenty": 20, "twentyfive": 25,
}


def read(path):
    with open(path, encoding="utf-8") as fh:
        return fh.read()


def w04_rows(receipt_text):
    rows = []
    for line in receipt_text.splitlines():
        cells = line.split("\t")
        if len(cells) >= 2 and cells[1].strip() == "W04":
            m = re.match(r"\s*(S\d+)\b", cells[2] if len(cells) > 2 else "")
            rows.append((m.group(1) if m else "?", line))
    return rows


NUM = (r"\d+|zero|one|two|three|four|five|six|seven|eight|nine|ten|"
       r"eleven|twelve|thirteen|fourteen|fifteen|sixteen|seventeen|eighteen|"
       r"nineteen|twenty|twentyfive")


def find_claim(text):
    """'two pre-existing W04 warnings on S156/S164' -> (2, ['S156','S164'])

    The number must be ADJACENT to the W04 phrase (optionally through a short
    adjective run), so that an unrelated number earlier in the sentence
    ("exit 0 (two pre-existing W04 warnings ...)") cannot be mistaken for the
    claimed count.
    """
    m = re.search(
        r"\b(" + NUM + r")\b\s+(?:[A-Za-z][A-Za-z-]*\s+){0,3}W0?4\s+warnings?",
        text, re.IGNORECASE)
    if not m:
        return None, []
    tok = m.group(1).lower()
    n = int(tok) if tok.isdigit() else WORDNUM.get(tok)
    tail = text[m.end():m.end() + 200]
    ids = re.findall(r"\bS\d+\b", tail.split(")")[0])
    # 'S019…S164' is a RANGE over the population, not two named rows
    rng = re.search(r"\b(S\d+)\s*(?:…|\.\.|--|—)\s*(S\d+)\b", tail.split(")")[0])
    if rng:
        return n, ids, (rng.group(1), rng.group(2))
    return n, ids, None


def main():
    if len(sys.argv) != 3:
        print("SETUP usage: check-census-w04.py <report.md> <census-receipt>")
        return 2
    report_path, receipt_path = sys.argv[1], sys.argv[2]
    try:
        report = read(report_path)
    except OSError as exc:
        print(f"SETUP report-unreadable {exc}")
        return 2
    try:
        receipt = read(receipt_path)
    except OSError as exc:
        print(f"SETUP receipt-unreadable {exc}")
        return 2

    rows = w04_rows(receipt)
    measured = len(rows)
    stated, ids, rng = find_claim(report)

    print(f"RECEIPT {receipt_path}")
    print(f"  MEASURED W04 lines={measured} "
          f"(grep -c W04 == {receipt.count('W04')})")
    print(f"REPORT  {report_path}")
    print(f"  STATED   count={stated} named_ids={ids}"
          + (f" range={rng[0]}..{rng[1]}" if rng else ""))

    bad = []
    if stated is None:
        bad.append("MISMATCH no W04 count found in the report")
    elif stated != measured:
        bad.append(f"MISMATCH W04 stated={stated} measured={measured}")

    pop_ids = [r[0] for r in rows]
    if measured > 0:
        if rng:
            if (rng[0], rng[1]) != (pop_ids[0], pop_ids[-1]):
                bad.append(f"MISMATCH range {rng[0]}..{rng[1]} does not span the "
                           f"W04 population ({pop_ids[0]}..{pop_ids[-1]}, "
                           f"{measured} rows)")
        elif ids:
            tail = pop_ids[-len(ids):] if len(ids) <= measured else []
            if len(ids) < measured and ids == tail:
                bad.append(f"MISMATCH tail-read named_ids={ids} are the LAST "
                           f"{len(ids)} of {measured} W04 rows (population not counted)")
            elif set(ids) != set(pop_ids):
                bad.append(f"MISMATCH named_ids={ids} are not the W04 population "
                           f"(measured ids={pop_ids[0]}..{pop_ids[-1]}, "
                           f"{measured} rows)")

    if bad:
        for line in bad:
            print(line)
        print("CENSUS_W04: FAIL")
        return 1
    print("CENSUS_W04: CLEAN")
    return 0


if __name__ == "__main__":
    sys.exit(main())
