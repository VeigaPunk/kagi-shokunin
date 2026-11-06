#!/usr/bin/env python3
"""m50-1-fail-count.py — compare every FAIL-count a text asserts with the receipt's own count.

Recognised assertion forms; A2/A3 are read only on lines that also contain the token FAIL:
  A1  with <N> FAIL
  A2  from <M> to <N>          (N is the candidate count)
  A3  went <M> (-> or U+2192) <N>   (N is the candidate count)

Receipt count = number of lines beginning `FAIL` (grep -c '^FAIL' <receipt>).

Exit 0 = at least one assertion, all equal the receipt count.
Exit 1 = at least one assertion differs (a FLAG).
Exit 2 = no assertion found.
The checker is a seat instrument, not a lane gate; it is shown able to fail on the filed
round-49 report and on the same report read against the BASE receipt.
"""
import re
import sys

A1 = re.compile(r"with (\d+) FAIL")
A2 = re.compile(r"from (\d+) to (\d+)")
A3 = re.compile(r"went (\d+)\s*(?:->|\u2192)\s*(\d+)")


def main(argv):
    if len(argv) != 3:
        print("usage: m50-1-fail-count.py TEXT RECEIPT")
        return 2
    text_path, receipt = argv[1], argv[2]
    with open(text_path, encoding="utf-8", errors="replace") as fh:
        lines = fh.read().splitlines()
    with open(receipt, encoding="utf-8", errors="replace") as fh:
        n = sum(1 for line in fh if line.startswith("FAIL"))
    print(f"text={text_path}")
    print(f"receipt={receipt}: FAIL lines = {n}  (command: grep -c '^FAIL' {receipt})")
    asserts = []
    for i, line in enumerate(lines, 1):
        for m in A1.finditer(line):
            asserts.append((i, "A1", int(m.group(1)), m.group(0)))
        if "FAIL" in line:
            for m in A2.finditer(line):
                asserts.append((i, "A2", int(m.group(2)), m.group(0)))
            for m in A3.finditer(line):
                asserts.append((i, "A3", int(m.group(2)), m.group(0)))
    if not asserts:
        print("VERDICT: NONE (no FAIL-count assertion found)")
        return 2
    bad = 0
    for ln, form, val, frag in asserts:
        state = "OK" if val == n else "MISMATCH"
        bad += 0 if val == n else 1
        print(f'line {ln} {form} "{frag}" asserts={val} receipt={n} {state}')
    print(f"VERDICT: {'OK' if bad == 0 else 'FLAG'} assertions={len(asserts)} mismatch={bad} receipt_count={n}")
    return 0 if bad == 0 else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))
