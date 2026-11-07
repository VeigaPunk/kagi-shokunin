#!/usr/bin/env python3
"""Build the round-60 C1 §A5 positive reference and its attack variants.

Usage: mkA5.py <dest-tree> [variant]

<dest-tree> must be a copy of the claim BASE a677c78e (git archive) with
corpus/openbao-transit-trial.sh and SKILL.md taken from the round-60 tree (the trial
gains --selftest this round). The tree this builds satisfies the §A5-amended item
conditions with true statements; the variants break one condition each. Written by
R60ReviewerC1 so the §A5 re-measurement in findings.md is reproducible.
"""
import os
import sys

DEST = sys.argv[1]
VARIANT = sys.argv[2] if len(sys.argv) > 2 else "fix3"

I1 = """
## Round 59 — correction

- D1 (round 60): the wave line's dead-seat field was left as an unfilled placeholder; measured over `.ufo/waves/round-59/w1-results.json` (14 result records, every final output non-empty): results=14 dead=0 dead seats=0.
"""
I2 = """
- Correction (round 60): this supersedes R31 — the committed receipt reads `C1_CHECK_SELFTEST: PASS (33 cases)`.
"""
I3 = """# Round 60 — lesson

## Routed dispositions

| id | disposition |
|---|---|
| R20 | closed: the duplicate id is retired in this lesson |
| R21 | closed: the duplicate id is retired in this lesson |
| R22 | closed: the duplicate id is retired in this lesson |

The round-59 routed table used R20, R21 and R22 twice each, so a duplicate id named two findings.
"""
I4 = "- Correction: this supersedes SCORECARD.md:1971 — the battery holds 20 controls, derived by `grep -cE '^CONTROL '` over the receipt.\n"
I5 = ("- Correction: this supersedes the round-59 gate-evidence pointer — "
      "`.ufo/waves/round-60/final/release-clock.txt`, `.ufo/waves/round-60/final/doc-audit.txt` "
      "and `.ufo/waves/round-60/final/scope.txt` were never written for round 59.\n")
I6 = ("- Correction: this supersedes the round-59 measured-commit citation — the committed "
      "receipt `.ufo/waves/round-59/final/c1-landed.txt` carries measured=revision "
      "160caf750dcf15892b78ec066e66bc605ba57a5c.\n")
RECEIPTS = {
    "release-clock.txt": "RELEASE_CLOCK: CLEAN (on_release=32 bound=32 unbound=0)\n",
    "doc-audit.txt": "DOC_AUDIT: CLEAN (entries=40 row_linked=37 by_hand=3 unpinned=0)\n",
    "scope.txt": "SCOPE: DEFECT stale_basis=0 breadth_drift=5 breadth_unverified=1\n",
}
STUB = ('case " $* " in *" --selftest "*)\n'
        "  printf 'TRANSIT_SELFTEST: PASS (cases=6)\\n'\n"
        "  exit 0\n"
        "  ;;\n"
        "esac\n")


def rd(rel):
    with open(os.path.join(DEST, rel), encoding="utf-8", errors="surrogateescape") as f:
        return f.read()


def wr(rel, text):
    p = os.path.join(DEST, rel)
    os.makedirs(os.path.dirname(p) or ".", exist_ok=True)
    with open(p, "w", encoding="utf-8", errors="surrogateescape") as f:
        f.write(text)


def main():
    wr("LOG.md", rd("LOG.md") + I1)
    wr("corpus/lessons/round-59.md", rd("corpus/lessons/round-59.md") + I2)
    wr("corpus/lessons/round-60.md", I3)
    wr("SCORECARD.md", rd("SCORECARD.md") + "\n## Errata — round 59 (round 60)\n\n" + I4 + I5 + I6)
    for name, line in RECEIPTS.items():
        wr(".ufo/waves/round-60/final/" + name, line)
    # I7: the real transit trial (with --selftest) and the re-registered SKILL row.
    trial = rd("corpus/openbao-transit-trial.sh")
    if "--selftest" not in trial:
        raise SystemExit("the BASE tree has no transit --selftest; build from the round-60 tree")
    sk = rd("SKILL.md")
    old = "none — its own five shims and the clean-room leg are the falsifiers"
    if old in sk:
        wr("SKILL.md", sk.replace(old, "`bash corpus/openbao-transit-trial.sh --selftest` (fixture-driven, no `bao`)", 1))

    if VARIANT == "hash-edit":
        for rel in (".ufo/waves/round-59/final/c1-landed.txt", "SCORECARD.md"):
            t = rd(rel).replace("measured=revision 160caf750dcf15892b78ec066e66bc605ba57a5c",
                                "measured=revision deadbeefdeadbeefdeadbeefdeadbeefdeadbeef")
            wr(rel, t)
    elif VARIANT == "i5-stub":
        wr(".ufo/waves/round-60/final/release-clock.txt", "RELEASE_CLOCK: CLEAN\n")
    elif VARIANT == "i7-stub":
        first, rest = rd("corpus/openbao-transit-trial.sh").split("\n", 1)
        wr("corpus/openbao-transit-trial.sh", first + "\n" + STUB + rest)
    elif VARIANT == "i1-lastwrong":
        wr("LOG.md", rd("LOG.md") + "- Correction (revised): .ufo/waves/round-59/w1-results.json holds results=15 dead=1 dead seats=1.\n")
    elif VARIANT == "i2-decoy":
        lines = rd("corpus/lessons/round-59.md").splitlines(True)
        corr = ("- Correction (round 60): this supersedes R31 — the committed receipt reads "
                "`C1_CHECK_SELFTEST: PASS (33 cases)`.\n")
        lines = [l for l in lines if l != corr]
        lines.insert(2, corr)
        lines.insert(2, "See R31 below for the selftest count.\n")
        wr("corpus/lessons/round-59.md", "".join(lines))
    elif VARIANT != "fix3":
        raise SystemExit(f"unknown variant {VARIANT}")


main()
