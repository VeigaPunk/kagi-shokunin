#!/usr/bin/env python3
"""Counter-mutant builder for the R68 mutation probe (scratch only).

usage: mkcounters.py SRC VARIANT OUT
  SRC is plans/round-68-c2.sh (C2 variants) or plans/round-68-c1.sh (C1 variants).
Every substitution asserts it matched; an inert mutation is a build error.
"""
import os
import sys

src, variant, out = sys.argv[1], sys.argv[2], sys.argv[3]
s = open(src, "r", encoding="utf-8", newline="").read()


def sub(old, new, count=1):
    global s
    n = s.count(old)
    assert n == count, (variant, n, old[:100])
    s = s.replace(old, new)


if variant == "c2-l1-literals":
    # L1 discards the live measured count and compares the pinned count to
    # itself: the two numbers are literals of the same source.
    old = "    detail.append(\"measured=%d\" % m)\n    if m != n:\n"
    sub(old, "    detail.append(\"measured=%d\" % m)\n    m = n  # mutant: live count discarded\n    if m != n:\n")
elif variant == "c2-l3-setup-skip":
    # L3 accepts ANY non-zero cells exit as a tolerated skip.
    old = ('    if rc != 0:\n'
           '        if "unrecognised round heading" in combined:\n'
           '            return False, "cells SETUP planned-heading rc=%s" % rc\n'
           '        return False, "cells rc=%s tail=%r" % (rc, last_nonempty(combined)[:160])\n')
    sub(old, '    if rc != 0:\n        return True, "cells=SKIP rc=%s" % rc\n')
elif variant == "c2-l2-rowtext":
    # L2 is satisfied by the ledger rows' text; neither counter is executed.
    start = '    # Both counters must EXECUTE on the measured tree (rows alone are text).\n'
    end = '        detail.append("c2-executed rc=%s" % c2_rc)\n'
    i = s.index(start)
    j = s.index(end) + len(end)
    s = s[:i] + '    # mutant: row text alone satisfies L2 (no counter execution)\n' + s[j:]
elif variant == "c1-leg-any":
    # (a) the expected-reason filter is removed: any SC_CAPTURE finding for
    # the anchor id counts as a caught leg.
    sub('    return any(fid == anchor_id and why == reason\n'
        '               for (fid, why) in parsed["cap_findings"])',
        '    return any(fid == anchor_id\n'
        '               for (fid, why) in parsed["cap_findings"])')
elif variant == "c1-leg-prefix":
    # (b) the expected reason is accepted loosely: any `capture-` reason.
    sub('    return any(fid == anchor_id and why == reason\n'
        '               for (fid, why) in parsed["cap_findings"])',
        '    return any(fid == anchor_id and why.startswith("capture-")\n'
        '               for (fid, why) in parsed["cap_findings"])')
elif variant == "c1-guardb-zero":
    # (c) guard (b) threshold lowered to 0.
    sub('    ok = 1 if (r.returncode == 0 and m and cases >= 89) else 0',
        '    ok = 1 if (r.returncode == 0 and m and cases >= 0) else 0')
elif variant == "c1-guarde-removed":
    # (d) guard (e) removed from the conjunction.
    sub('    ge = guard_e(clean, derived)',
        '    ge = 1  # mutant: guard (e) removed')
elif variant == "c1-cand-normalizer":
    # (e) the derivation prefers the measured tree's own normalizer.
    sub('    candidates = []\n    if BASE_TREE:',
        '    candidates = [os.path.join(TREE, "corpus/rendered-text-v1.py")]\n    if BASE_TREE:')
elif variant == "c1-anchor-hardcoded":
    # (i) the anchor id is hardcoded instead of derived.
    sub('    if anchor is None:\n        setup("no-binding-token-row")',
        '    if anchor is None:\n        setup("no-binding-token-row")\n'
        '    anchor["id"] = "S166"  # mutant: anchor id hardcoded')
else:
    raise SystemExit("unknown variant " + variant)


open(out, "w", encoding="utf-8", newline="").write(s)
os.chmod(out, 0o755)
print("MKCOUNT: %s -> %s ok" % (variant, out))
