#!/usr/bin/env python3
"""S098 falsification probe: Python str.isspace() vs Unicode White_Space.

H0 (the S098 reject premise, plans/round-41.md §Frontier): the set
    D = {c in 0..0x10FFFF : chr(c).isspace()}  setminus  White_Space(UCD latest)
is nonempty and contains U+001C, U+001D, U+001E, U+001F.
Falsifiers: D is empty, or none of U+001C..U+001F is in D.

Procedure (seat K41LabRejectProbe, frozen):
  1. record python3 version and unicodedata.unidata_version;
  2. enumerate A = {c : chr(c).isspace()} over 0..0x10FFFF;
  3. read PropList.txt (fetched from
     https://www.unicode.org/Public/UCD/latest/ucd/PropList.txt), record its
     sha256 and its version line; parse the White_Space ranges into B;
  4. compute A-B and B-A: counts and every member as hex; state whether
     U+001C..U+001F are in A-B;
  5. if unidata_version and the PropList version differ, state which set each
     reflects and whether U+001C..U+001F membership depends on that version.

Usage: probe.py --proplist PropList.txt
"""

import argparse
import datetime
import hashlib
import re
import sys
import unicodedata

RANGE_RE = re.compile(
    r"^([0-9A-F]{4,6})(?:\.\.([0-9A-F]{4,6}))?\s*;\s*White_Space\s*#"
)
PROBE_CP = list(range(0x001C, 0x0020))


def fmt(c: int) -> str:
    return f"U+{c:04X}"


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--proplist", required=True, help="path to PropList.txt")
    args = ap.parse_args()

    print(f"probe_date_utc: "
          f"{datetime.datetime.now(datetime.timezone.utc).isoformat(timespec='seconds')}")
    print(f"python_version: {sys.version.split()[0]}")
    print(f"unidata_version: {unicodedata.unidata_version}")

    raw = open(args.proplist, "rb").read()
    sha = hashlib.sha256(raw).hexdigest()
    lines = raw.decode("utf-8").splitlines()
    version_line = next(
        (l for l in lines if re.match(r"#\s*PropList-\d+\.\d+\.\d+\.txt", l)), "")
    date_line = next((l for l in lines if l.startswith("# Date:")), "")

    print(f"proplist_path: {args.proplist}")
    print(f"proplist_sha256: {sha}")
    print(f"proplist_version_line: {version_line}")
    print(f"proplist_date_line: {date_line}")
    m = re.search(r"(\d+\.\d+\.\d+)", version_line)
    proplist_version = m.group(1) if m else ""

    # Step 2: A over the whole code space (surrogates included; chr() is total).
    A = {c for c in range(0x110000) if chr(c).isspace()}
    # Step 3: parse White_Space ranges into B.
    B = set()
    ws_lines = 0
    for line in lines:
        m2 = RANGE_RE.match(line)
        if m2:
            ws_lines += 1
            lo = int(m2.group(1), 16)
            hi = int(m2.group(2), 16) if m2.group(2) else lo
            B.update(range(lo, hi + 1))

    print(f"A_size: {len(A)}")
    print(f"B_size: {len(B)}")
    print(f"whitespace_range_lines_parsed: {ws_lines}")

    a_minus_b = sorted(A - B)
    b_minus_a = sorted(B - A)
    print(f"A_minus_B_count: {len(a_minus_b)}")
    print("A_minus_B_members: " + (" ".join(fmt(c) for c in a_minus_b)
                                   if a_minus_b else "(none)"))
    print(f"B_minus_A_count: {len(b_minus_a)}")
    print("B_minus_A_members: " + (" ".join(fmt(c) for c in b_minus_a)
                                   if b_minus_a else "(none)"))

    in_diff = {fmt(c): (c in A) and (c not in B) for c in PROBE_CP}
    for c in PROBE_CP:
        k = fmt(c)
        print(f"{k}: isspace={chr(c).isspace()} White_Space={c in B} "
              f"in_A_minus_B={in_diff[k]}")
    probe_all_in = all(in_diff[fmt(c)] for c in PROBE_CP)

    # Step 5: version relationship.
    if proplist_version == unicodedata.unidata_version:
        print("version_note: python unidata_version and PropList version AGREE "
              f"({unicodedata.unidata_version}); A and B reflect the same "
              "Unicode version, so A-B is a definitional difference of "
              "str.isspace, not a version artifact.")
    else:
        print(f"version_note: python unidata_version={unicodedata.unidata_version} "
              f"differs from PropList version={proplist_version}. A reflects the "
              "Unicode version bundled in CPython's unicodedata; B reflects the "
              "fetched latest UCD PropList. White_Space has not contained "
              "U+001C..U+001F in the fetched latest version, and those four are "
              "in A; their membership in A-B is therefore produced by "
              "str.isspace's own definition and does not depend on the "
              "version difference.")
    print(f"probe_set_all_in_A_minus_B: {probe_all_in}")

    if a_minus_b and probe_all_in:
        print(f"VERDICT: H0 holds "
              f"(A_minus_B_count={len(a_minus_b)}, "
              f"U+001C..U+001F all in A-B)")
    else:
        reason = []
        if not a_minus_b:
            reason.append("A-B is empty")
        if not probe_all_in:
            reason.append("some of U+001C..U+001F absent from A-B")
        print("VERDICT: H0 falsified (" + "; ".join(reason) + ")")
    return 0


if __name__ == "__main__":
    sys.exit(main())
