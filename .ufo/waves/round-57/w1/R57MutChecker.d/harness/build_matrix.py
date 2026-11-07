#!/usr/bin/env python3
"""Build the 10x11 expectation-vs-reading matrix from the battery logs."""
from __future__ import annotations

import os
import re
import sys

S = "/fast/scratch/hyaku/kagi-r57/R57MutChecker"
OUT = os.path.join(S, "out")
CONTROLS = ["K1-BASE", "K1-F1", "K1-F2", "K1-F3", "K1-F4", "K1-F5", "K1-F6",
            "K1-F7", "K2-BASE", "K2-STUB", "K2-MOCK"]

# Predeclared per-mutant predictions (EXPECTATIONS.md, sha256 recorded before any run)
PRED = {
    "M1":  ["0", "0", "0", "0", "0", "FAIL", "0", "0", "0", "0", "5"],
    "M2":  ["3", "2", "2", "2", "0", "FAIL", "6", "3", "0", "0", "5"],
    "M3":  ["3", "2", "2", "2", "0", "FAIL", "4", "3", "0", "0", "5"],
    "M4":  ["1", "0", "1", "1", "0", "FAIL", "4", "1", "0", "0", "5"],
    "M5":  ["3", "2", "2", "2", "0", "FAIL", "6", "3", "0", "0", "5"],
    "M6":  ["8", "7", "7", "7", "5", "FAIL", "10", "8", "0", "0", "5"],
    "M7":  ["3", "2", "2", "2", "0", "FAIL", "6", "3", "0", "0", "5"],
    "M8":  ["3", "2", "2", "2", "0", "FAIL", "6", "3", "0", "0", "5"],
    "M9":  ["3", "2", "2", "2", "0", "FAIL", "6", "3", "0", "0", "5"],
    "M10": ["0", "0", "0", "0", "0", "FAIL", "0", "0", "0", "0", "5"],
}
POS_CLS = ["KILLED", "SURVIVED", "KILLED", "KILLED", "SURVIVED",
           "KILLED", "SURVIVED", "SURVIVED", "SURVIVED", "KILLED"]

LINE = re.compile(r"^CONTROL (\S+) expect=(\S+) got=(\S+) (MATCH|MISMATCH) :: (.*)$")


def main() -> int:
    rows = []
    problems = []
    for m in [f"M{i}" for i in range(1, 11)]:
        path = os.path.join(OUT, f"battery-{m}.log")
        got = {}
        exp = {}
        verdicts = {}
        pops = {}
        detail = {}
        for ln in open(path, encoding="utf-8", errors="replace"):
            r = LINE.match(ln)
            if not r:
                continue
            cid, e, g, v, det = r.groups()
            got[cid] = g
            exp[cid] = e
            verdicts[cid] = v
            detail[cid] = det
            pm = re.search(r"^C1_CURRENT: value=\S+ population=(\S+)", det)
            pops[cid] = pm.group(1) if pm else "-"
        if list(got) != CONTROLS:
            problems.append(f"{m}: control order/coverage {list(got)}")
        kills = [c for c in CONTROLS if verdicts.get(c) == "MISMATCH"]
        rows.append((m, exp, got, pops, verdicts, kills, detail))

    with open(os.path.join(OUT, "matrix.tsv"), "w", encoding="utf-8") as f:
        f.write("mutant\t" + "\t".join(CONTROLS) + "\tkilled_by\tverdict\n")
        for m, exp, got, pops, verdicts, kills, _ in rows:
            f.write(m + "\t" + "\t".join(got[c] for c in CONTROLS) + "\t"
                    + (",".join(kills) if kills else "-") + "\t"
                    + ("KILLED" if kills else "SURVIVED") + "\n")

    with open(os.path.join(OUT, "matrix-expectation-vs-reading.tsv"), "w", encoding="utf-8") as f:
        f.write("mutant\t" + "\t".join(CONTROLS) + "\n")
        for m, exp, got, pops, verdicts, kills, _ in rows:
            f.write(f"{m}.expect\t" + "\t".join(exp[c] for c in CONTROLS) + "\n")
            f.write(f"{m}.got\t" + "\t".join(got[c] for c in CONTROLS) + "\n")
            f.write(f"{m}.verdict\t" + "\t".join(verdicts[c] for c in CONTROLS) + "\n")
            f.write(f"{m}.population\t" + "\t".join(pops[c] for c in CONTROLS) + "\n")

    with open(os.path.join(OUT, "matrix-prediction-vs-reading.tsv"), "w", encoding="utf-8") as f:
        f.write("mutant\t" + "\t".join(CONTROLS) + "\tpredicted\tobserved\n")
        for (m, exp, got, pops, verdicts, kills, _), pc in zip(rows, POS_CLS):
            agree = all(PRED[m][i] == got[c] for i, c in enumerate(CONTROLS))
            f.write(m + "\t" + "\t".join(
                f"{PRED[m][i]}|{got[c]}" for i, c in enumerate(CONTROLS)) + "\t"
                + pc + "\t" + ("AGREE" if agree else "DISAGREE") + "\n")

    with open(os.path.join(OUT, "checker-raw-base.tsv"), "w", encoding="utf-8") as f:
        f.write("mutant\tchecker_line_at_K1-BASE\n")
        for m, exp, got, pops, verdicts, kills, detail in rows:
            f.write(f"{m}\t{detail['K1-BASE']}\n")

    print("rows", len(rows), "problems", problems)
    for m, exp, got, pops, verdicts, kills, _ in rows:
        print(m, "killed_by=" + (",".join(kills) if kills else "-"),
              "| pops", " ".join(f"{c}:{pops[c]}" for c in CONTROLS[:8]))
    return 0 if not problems else 1


if __name__ == "__main__":
    sys.exit(main())
