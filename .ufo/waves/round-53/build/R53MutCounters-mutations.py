#!/usr/bin/env python3
"""Round 53 C1/C2 counter mutants (seat R53MutCounters).

Each mutant is ONE line replacement in a frozen counter. Usage:
    python3 R53MutCounters-mutations.py --list
    python3 R53MutCounters-mutations.py <tree> <id>

<tree> is a scratch copy of the lane (candidate 36d0a86 checked out / extracted).
The script asserts the expected substring is on the named line, replaces the whole
line, and prints the sha256 before/after plus the applied line. It never touches
corpus/, plans/ or the lane itself (the tree must be a scratch copy).
"""
import hashlib
import sys
from pathlib import Path

C1 = "plans/round-53-c1.sh"
C2 = "plans/round-53-c2.sh"

# id: (file, 1-based line, substring that must be present, replacement line)
MUTANTS = {
    # ---------------- C1 (freshness) ----------------
    "C1M01": (C1, 148, 'rrecheck', '  :  # WATCHED (a) recheck conjunct dropped'),
    "C1M02": (C1, 148, 'rrecheck', '  [ "$rrecheck" = 90d ] || { bad="$bad $id:recheck=$rrecheck"; continue; }'),
    "C1M03": (C1, 78, 'guard" -eq 1', '[ "$grc" -eq 0 ] && [[ $glast == "RELEASE_CLOCK: CLEAN"* ]] && gate=1'),
    "C1M04": (C1, 69, 'wc -l', 'if true &&'),
    "C1M05": (C1, 130, 'int(floor)', 'if not e <= int(asof):'),
    "C1M06": (C1, 130, 'int(asof)', 'if not int(floor) <= e:'),
    "C1M07": (C1, 159, 'anch', '  :  # WATCHED (b) anchored_version conjunct dropped'),
    "C1M08": (C1, 157, 'clock', '  :  # WATCHED (b) clock-kind conjunct dropped'),
    "C1M09": (C1, 155, 'nf', '  :  # WATCHED (b) 9-field conjunct dropped'),
    "C1M10": (C1, 122, 'http_status', 'if False and o.get("http_status") != 200: print("receipt-status"); sys.exit()'),
    "C1M11": (C1, 125, 'verdict', 'if False and o.get("verdict") != "not-fired": print("receipt-verdict"); sys.exit()'),
    "C1M12": (C1, 78, 'RELEASE_CLOCK: CLEAN', '[ "$guard" -eq 1 ] && [ "$grc" -eq 0 ] && true && gate=1'),
    "C1M13": (C1, 113, 'sha256', 'if False and hashlib.sha256(raw).hexdigest() != m1.group(1):'),
    "C1M14": (C1, 153, 'clock-rows', '  [ "$c" -ge 1 ] || { bad="$bad $id:clock-rows=$c"; continue; }'),
    "C1M15": (C1, 175, 'value=$n', 'value=$n  # GATE coupling dropped'),
    "C1M16": (C1, 136, 'n=0', 'ok=""; bad=""; n=1'),
    "C1M17": (C1, 167, 'feed-status', '  :  # WATCHED (c) feed status conjunct dropped'),
    "C1M18": (C1, 147, 'rstatus', '  :  # WATCHED (a) registry status conjunct dropped'),
    "C1M19": (C1, 168, 'feed-recheck', '  :  # WATCHED (c) feed recheck conjunct dropped'),
    "C1M20": (C1, 165, 'feed-row-url', '  :  # WATCHED (c) feed URL conjunct dropped'),
    # ---------------- C2 (calibration) ----------------
    "C2M01": (C2, 68, 'mc', '  [ -n "$bc" ] || setup "guard:g1:$id:command"'),
    "C2M02": (C2, 65, 'rows=', '  [ "$c" -ge 1 ] || setup "guard:g1:$id:rows=$c"'),
    "C2M03": (C2, 72, 'expect"', '    :  # expect-cell equality dropped'),
    "C2M04": (C2, 75, 'guard:g2', ':  # g2 dropped'),
    "C2M05": (C2, 76, 'guard:g3', ':  # g3 dropped'),
    "C2M06": (C2, 77, 'guard:g4', ':  # g4 dropped'),
    "C2M07": (C2, 89, 'guard:g5', '[ -n "$pol" ] || setup "guard:g5:$pol"'),
    "C2M08": (C2, 86, 'claims', ':  # claims != 63 check dropped'),
    "C2M09": (C2, 87, 'setup=$st', ':  # setup != 0 check dropped'),
    "C2M10": (C2, 81, 'empty-output',
              '[ -n "$last" ] || { echo "C2_SELF_COUNTS: value=0 (bad=; summary=)"; exit 0; }'),
    "C2M11": (C2, 79, '--table',
              'out=$(cd "$T" && timeout 900 python3 "$SCR/b/self-counts.py" --root "$T" --table "$T/corpus/self-counts.tsv" 2>&1)'),
    "C2M12": (C2, 85, 'summary-count', ':  # single-summary-line check dropped'),
    "C2M13": (C2, 92, 'summary-mismatch', ':  # summary arithmetic check dropped'),
    "C2M14": (C2, 93, 'value=$m', 'echo "C2_SELF_COUNTS: value=$s (bad=${bad% }; summary=$last)"'),
    "C2M15": (C2, 83, 'summary:', ':  # summary shape not enforced'),
    "C2M16": (C2, 79, 's/self-counts.py',
              'out=$(cd "$T" && timeout 900 python3 "$T/corpus/self-counts.py" --root "$T" --table "$SCR/b/self-counts.tsv" 2>&1)'),
}


def main() -> int:
    if len(sys.argv) == 2 and sys.argv[1] == "--list":
        for mid, (f, ln, _, _) in MUTANTS.items():
            print(f"{mid}\t{f}:{ln}")
        return 0
    if len(sys.argv) != 3:
        print(__doc__, file=sys.stderr)
        return 2
    tree = Path(sys.argv[1]).resolve()
    mid = sys.argv[2]
    if mid not in MUTANTS:
        print(f"unknown mutant {mid}", file=sys.stderr)
        return 2
    rel, lineno, expect, new = MUTANTS[mid]
    path = tree / rel
    before = hashlib.sha256(path.read_bytes()).hexdigest()
    lines = path.read_text(encoding="utf-8").split("\n")
    old = lines[lineno - 1]
    if expect not in old:
        print(f"REFUSED {mid}: line {lineno} lacks {expect!r}: {old!r}", file=sys.stderr)
        return 3
    if old == new:
        print(f"REFUSED {mid}: line already equals replacement", file=sys.stderr)
        return 3
    lines[lineno - 1] = new
    path.write_text("\n".join(lines), encoding="utf-8")
    after = hashlib.sha256(path.read_bytes()).hexdigest()
    print(f"APPLIED {mid} {path}")
    print(f"  before={before}")
    print(f"  after ={after}")
    print(f"  old   ={old}")
    print(f"  new   ={new}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
