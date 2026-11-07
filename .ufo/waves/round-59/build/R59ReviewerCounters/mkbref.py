#!/usr/bin/env python3
"""Build a tree identical to plans/round-59-controls.sh's fixed_tree(), plus
attack variants on top of it. Text copied verbatim from the battery so the
checker's reading on this tree is comparable with the battery's K1-REF control.
"""
import os
import shutil
import subprocess

S = "/fast/scratch/hyaku/kagi-r59/R59ReviewerCounters"
BASE = os.path.join(S, "trees", "base")
LESSON = "corpus/lessons/round-58.md"

BATTERY_CORRECTION = """
## Correction (round 59) — synthetic control fixture

- Correction D1: Registry 117 → 120 at the candidate (S118, S119, S120).
- Correction D2: `corpus/source-fetches.tsv` added 6 rows between the claim BASE and the landing.
- Correction D3: `.ufo/waves/round-58/controls/controls-prefreeze.txt` holds 20 control lines, 9 C1 and 7 C2; `C1-F10` and `C2-F4` were documented, did not ship, and ship now in `plans/round-58-controls-supplement.sh`.
- Correction D4: `.ufo/waves/round-59/final/citation-gate-r59.txt` reads unresolved=0, which closes the round-58 "fixed" claim.
- stale-lane: the round-58 mission ran 101 min (11:54:48 → 13:36:19) and reads progressing, not silent.
"""

SUP = "C1-F10 and C2-F4\n"
GATE = "CITATION_GATE: CLEAN (cites=1 docs=1 unresolved=0 ephemeral=0 labeled=0)\n"
SUPR = ("CONTROL C1-F10 expect=FAIL got=FAIL MATCH :: stub\n"
        "CONTROL C2-F4 expect=4 got=4 MATCH :: single-run\n"
        "SUPPLEMENT: match=2 mismatch=0\n")

BATTERY_EDITS = {
    LESSON: ("append", BATTERY_CORRECTION),
    "plans/round-58-controls-supplement.sh": SUP,
    ".ufo/waves/round-59/final/citation-gate-r59.txt": GATE,
    ".ufo/waves/round-59/final/supplement-receipt.txt": SUPR,
}


def getfile(root, rel):
    with open(os.path.join(root, rel), encoding="utf-8") as f:
        return f.read()


def setfile(root, rel, text):
    p = os.path.join(root, rel)
    os.makedirs(os.path.dirname(p), exist_ok=True)
    tmp = p + ".mkfix-tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        f.write(text)
    os.replace(tmp, p)


def mktree(name, edits, base=BASE):
    dst = os.path.join(S, "trees", name)
    if os.path.isdir(dst):
        shutil.rmtree(dst)
    subprocess.run(["cp", "-al", base, dst], check=True)
    for rel, text in edits.items():
        if text is None:
            p = os.path.join(dst, rel)
            if os.path.exists(p):
                os.unlink(p)
            continue
        if isinstance(text, tuple) and text[0] == "append":
            setfile(dst, rel, getfile(dst, rel) + text[1])
        else:
            setfile(dst, rel, text)
    return dst


def main():
    e = dict(BATTERY_EDITS)
    mktree("bref", e)
    print("bref built")
    # attacks are layered on bref below, each appending one last statement
    L = getfile(BASE, LESSON) + BATTERY_CORRECTION

    def var(name, extra=None, edits=None):
        ee = dict(BATTERY_EDITS)
        if extra is not None:
            ee[LESSON] = ("append", BATTERY_CORRECTION + extra)
        if edits:
            ee.update(edits)
        mktree(name, ee)
        print(name, "built")

    # G1 family: the last Registry claim stays wrong in notation variants
    var("g1_lower", "- registry 119 → 120 at the candidate.\n")
    var("g1_ascii", "- Registry 119 -> 120 at the candidate.\n")
    var("g1_nothe", "- Registry 119 → 120 at candidate.\n")
    var("g1_wrong", "- Registry 119 → 120 at the candidate.\n")
    var("g1_table", "| Registry 118 → 120 at the candidate |\n")
    # G2 family: last source-fetches statement wrong / unparsable
    var("g2_bare", "- `source-fetches.tsv`: 4 rows added.\n")
    var("g2_wrong", "- `corpus/source-fetches.tsv`: 4 rows added.\n")
    var("g2_nofile", "- source-fetches.tsv gained rows (`corpus/` prefix omitted), 4 added.\n")
    # G3 family: controls counts
    var("g3_wrong", "- `.ufo/waves/round-58/controls/controls-prefreeze.txt`: 20 lines, 10 C1 and 7 C2.\n")
    var("g3_roles", "- `.ufo/waves/round-58/controls/controls-prefreeze.txt`: 9 total, 20 C1 and 7 C2.\n")
    var("g3_plain", "- `.ufo/waves/round-58/controls/controls-prefreeze.txt`: 20 control lines, 9 C1 and 7 C2.\n")
    var("g3_noline", "- nothing about controls here.\n",
        edits={"plans/round-58-controls-supplement.sh": None})
    # G4 family: gate receipt
    var("g4_missing", edits={".ufo/waves/round-59/final/citation-gate-r59.txt": None})
    var("g4_badform", "- Citation gate: `.ufo/waves/round-59/final/citation-gate-r59.txt` reads unresolved=0.\n",
        edits={".ufo/waves/round-59/final/citation-gate-r59.txt":
               "# gate\nCITATION_GATE unresolved=0 no-colon-form\n"})
    var("g4_wrong_u", "- Citation gate: `.ufo/waves/round-59/final/citation-gate-r59.txt` reads unresolved=3.\n")
    var("g4_mismatch_receipt", "- Citation gate: `.ufo/waves/round-59/final/citation-gate-r59.txt` reads unresolved=2.\n",
        edits={".ufo/waves/round-59/final/citation-gate-r59.txt":
               "CITATION_GATE: CHECKED unresolved=3 stale=0\n"})
    # G5 family: stale-lane
    var("g5_silent", "- stale-lane: the mission ran 101 min and the row is silent.\n")
    var("g5_wrongmin", "- stale-lane: the mission ran 100 min; the row is progressing.\n")
    var("g5_dup", "- stale-lane: irrelevant line without numbers.\n")
    # supplement receipt
    var("g3d_supbad", edits={".ufo/waves/round-59/final/supplement-receipt.txt":
                             "SUPPLEMENT: match=1 mismatch=1\n"})
    var("g3c_supnoids", edits={"plans/round-58-controls-supplement.sh": "#!/usr/bin/env bash\necho none\n"})
    # structure
    mktree("s1_nolesson", {LESSON: None})
    print("s1_nolesson built")
    mktree("s2_corronly", {LESSON: "# Round 58\n" + BATTERY_CORRECTION})
    print("s2_corronly built")


if __name__ == "__main__":
    main()
