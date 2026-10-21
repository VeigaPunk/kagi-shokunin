#!/usr/bin/env python3
"""CritSeparability-8: hand-split claim-only overlays of candidate 62a33b1's
corpus/release-clock.py over BASE 3553d49. Usage: build_overlays.py LANECLONE OUTDIR

Hunks (candidate diff order): C1 = 3,5,6,7,8,9,14,15,16; C2 = 2,10,11,13;
neutral (both) = 1 (dead VERSION_RE), 12 (run_case try/except);
mixed = 4 (evaluate) and 17 (selftest tail), split by text below.
The only non-candidate byte change is in c2-only hunk 4: the candidate guard
`is_derived and not non_canonical and ...` references the C1 helper, so the
C2-only guard is `is_derived and ...` (recorded as a decoupling edit).
"""
import hashlib, importlib.util, subprocess, sys
from pathlib import Path

lane, out = Path(sys.argv[1]), Path(sys.argv[2])
spec = importlib.util.spec_from_file_location("sep", lane / ".ufo/waves/round-28/tools/separability.py")
sep = importlib.util.module_from_spec(spec); spec.loader.exec_module(sep)
BASE, CAND, REL = sep.BASE_REV, "62a33b1bd15217ed729df2ca40c8a30aba3076c0", "corpus/release-clock.py"
show = lambda rev: subprocess.check_output(["git", "-C", str(lane), "show", "%s:%s" % (rev, REL)]).decode()
diff = subprocess.check_output(["git", "-C", str(lane), "diff", "--no-color", BASE, CAND, "--", REL]).decode()
hunks = sep.parse_unified_diff(diff)[0][REL]
assert len(hunks) == 17, len(hunks)
base_lines, trailing = sep.split_text_lines(show(BASE))
cand_text = show(CAND)

def apply(numbers):
    lines, _ = sep.apply_hunks(base_lines, [hunks[n - 1] for n in sorted(numbers)], "overlay")
    return sep.join_text_lines(lines, trailing)

def once(text, old, new):
    assert text.count(old) == 1, (text.count(old), old[:80])
    return text.replace(old, new)

C2_EVAL = (
    "            if (is_derived and not non_canonical and feed_source is not None\n"
    "                    and not derived_anchor_bound(feed_source[\"anchor\"], anchored)):\n"
    "                # round-28 C2: an author-declared derived anchor holds only while\n"
    "                # its feed row's located anchor cell (S033-S037) names exactly\n"
    "                # that one stable X.Y.Z. Lowering a whole feed group, a second\n"
    "                # version in the cell or a prerelease sibling is a typed\n"
    "                # DERIVATION finding, never a silent not-fired clock.\n"
    "                errors.add((\"DERIVATION\", source_id))\n"
    "                row_valid = False\n")
C1_EVAL_HEAD = ("            non_canonical = non_canonical_version(anchored) or "
                "non_canonical_version(observed_version)\n")
C2_TAIL_MARK = "\n    # round 28 C2: the --observe CLI path shares evaluate with verify and\n"
TAIL_END = "    if failures:\n        for failure in failures:\n"

# c1-only: all C1 + neutral hunks whole, hunk 4 minus its C2 block, hunk 17 minus its C2 case.
c1 = apply({1, 3, 4, 5, 6, 7, 8, 9, 12, 14, 15, 16, 17})
c1 = once(c1, C2_EVAL, "")
start = c1.index(C2_TAIL_MARK); end = c1.index(TAIL_END, start)
c2_tail = c1[start:end]
c1 = c1[:start] + "\n" + c1[end:]
assert "derived_anchor_bound" not in c1 and "DERIVATION" not in c1

# c2-only: all C2 + neutral hunks whole, hunk 4's C2 block alone (decoupled guard), hunk 17's C2 case.
c2 = apply({1, 2, 10, 11, 12, 13})
c2 = once(c2, "            anchor_ok = is_derived or version_is_named(sources[source_id][\"anchor\"], anchored)\n",
          "            anchor_ok = is_derived or version_is_named(sources[source_id][\"anchor\"], anchored)\n"
          + C2_EVAL.replace("is_derived and not non_canonical and ", "is_derived and "))
anchor = c2.index(TAIL_END)
c2 = c2[:anchor].rstrip("\n") + "\n" + c2_tail + c2[anchor:]
assert "non_canonical" not in c2 and "NON-CANONICAL" not in c2

# union check: c1 hunks + c2 hunks with the candidate guard reproduce the candidate blob.
union = apply(set(range(1, 18)))
assert union == cand_text, "full hunk set does not reproduce candidate"
out.mkdir(parents=True, exist_ok=True)
for name, text in (("c1only", c1), ("c2only", c2)):
    (out / ("%s-release-clock.py" % name)).write_text(text, encoding="utf-8")
    print(name, hashlib.sha256(text.encode()).hexdigest(), len(text.splitlines()))
print("candidate", hashlib.sha256(cand_text.encode()).hexdigest(), len(cand_text.splitlines()))
