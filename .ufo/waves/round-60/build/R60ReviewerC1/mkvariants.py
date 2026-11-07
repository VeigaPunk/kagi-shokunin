#!/usr/bin/env python3
"""Build the round-60 C1 attack variants from the token-satisfying `fix` tree."""
import os
import shutil
import subprocess
import sys

S = "/fast/scratch/hyaku/kagi-r60/R60ReviewerC1"
T = os.path.join(S, "trees")
FIX = os.path.join(T, "fix")


def rd(d, rel):
    with open(os.path.join(d, rel), encoding="utf-8", errors="surrogateescape") as f:
        return f.read()


def wr(d, rel, text):
    p = os.path.join(d, rel)
    os.makedirs(os.path.dirname(p) or ".", exist_ok=True)
    with open(p, "w", encoding="utf-8", errors="surrogateescape") as f:
        f.write(text)


def app(d, rel, text):
    wr(d, rel, rd(d, rel) + text)


def mk(name):
    d = os.path.join(T, name)
    if os.path.isdir(d):
        shutil.rmtree(d)
    subprocess.run(["cp", "-a", FIX, d], check=True)
    return d


def sub(d, rel, old, new, count=1):
    t = rd(d, rel)
    assert old in t, f"{rel}: literal not found: {old!r}"
    wr(d, rel, t.replace(old, new, count))


# 1. I1 states the right token and the wrong fact in the same block.
d = mk("v_wrongfact")
app(d, "LOG.md", "\n- The round had `dead seats=14`; every seat died.\n")

# 2. I2: the receipt is edited to agree with a false statement (32 cases).
d = mk("v_receipt32")
sub(d, ".ufo/waves/round-59/build/R59ExecCounterC1/selftest.txt",
    "PASS (33 cases)", "PASS (32 cases)")
sub(d, "corpus/lessons/round-59.md", "PASS (33 cases)", "PASS (32 cases)")

# 3. I4: the controls receipt loses a line so a false count becomes "right".
d = mk("v_ctrl19")
p = os.path.join(d, ".ufo/waves/round-59/controls/controls-prefreeze.txt")
lines = open(p, encoding="utf-8").read().splitlines(True)
idx = [i for i, ln in enumerate(lines) if ln.startswith("CONTROL ")]
del lines[idx[-1]]
open(p, "w", encoding="utf-8").writelines(lines)
sub(d, "SCORECARD.md", "holds 20 controls", "holds 19 controls")

# 4. I6: the receipt's measured revision is edited, and the correction cites it.
d = mk("v_hash")
sub(d, ".ufo/waves/round-59/final/c1-landed.txt",
    "measured=revision 160caf750dcf15892b78ec066e66bc605ba57a5c",
    "measured=revision 75165a07b1b55a96ddf03fc71449211455d968ee")
sub(d, "SCORECARD.md", "measured=revision 160caf750dcf15892b78ec066e66bc605ba57a5c",
    "measured=revision 75165a07b1b55a96ddf03fc71449211455d968ee")

# 5. I6: an unrelated line naming the tip is inserted, then the correction after it.
d = mk("v_anchor")
t = rd(d, "SCORECARD.md")
anchor = "\n- (probe) the round-59 spot-check cites the tip 75165a07 for the report only.\n"
wr(d, "SCORECARD.md", t + anchor)
app(d, "SCORECARD.md",
    "\n- Round-60 correction: `c1-landed.txt` measured=revision "
    "160caf750dcf15892b78ec066e66bc605ba57a5c.\n")

# 6. I2: a decoy `R31` line before the real R31 line, correction placed before it.
d = mk("v_decoyR31")
t = rd(d, "corpus/lessons/round-59.md")
lines = t.splitlines(True)
# strip the appended correction, re-insert it after an early decoy
corr = ("- Round-60 correction: this supersedes R31 — the committed receipt reads `C1_CHECK_SELFTEST: PASS (33 cases)`.\n")
assert corr in t
t = t.replace(corr, "")
lines = t.splitlines(True)
decoy_at = 2
lines.insert(decoy_at, "See R31 below for the selftest count.\n")
corr_at = decoy_at + 1
lines.insert(corr_at, corr)
wr(d, "corpus/lessons/round-59.md", "".join(lines))

# 7. I4: a decoy `(21 controls` line early in SCORECARD, correction right after it.
d = mk("v_decoy21")
t = rd(d, "SCORECARD.md")
corr4 = ("\n- Round-60 correction: this supersedes SCORECARD.md:1971 — the controls "
         "runner holds 20 controls.\n")
t = t.replace(corr4, "")
lines = t.splitlines(True)
lines.insert(3, "An early prose line that says (21 controls) for no reason.\n")
lines.insert(4, corr4)
wr(d, "SCORECARD.md", "".join(lines))

# 8. I4: the superseded line is rewritten in place (append-only violated), correction kept.
d = mk("v_inplace")
sub(d, "SCORECARD.md", "(21 controls", "(20 controls")

# 9. I1: the derivation source is deleted, the correction keeps its numbers.
d = mk("v_missingresults")
os.unlink(os.path.join(d, ".ufo/waves/round-59/w1-results.json"))

# 10. I4/I5/I6: SCORECARD.md is absent (must read 0, population must stay 7).
d = mk("v_noscorecard")
os.unlink(os.path.join(d, "SCORECARD.md"))

# 11. I3: an id appears in a condition cell (checker scanning all cells reads 0).
d = mk("v_i3cond")
sub(d, "corpus/lessons/round-60.md", "| R21 | closed |", "| R21 | closed (was R21 twice) |")

# 12. I3: vacuous ids and a negation that carries the word `duplicate`.
d = mk("v_i3vacuous")
wr(d, "corpus/lessons/round-60.md",
    "# Round 60 — lesson (probe fixture)\n\n## Routed dispositions\n\n"
    "| id | disposition |\n|---|---|\n| R20 | - |\n| R21 | - |\n| R22 | - |\n\n"
    "R20, R21 and R22 are not duplicates of anything.\n")

# 13. Two unresolved items (I2, I5) to test the guard's `value+1` on a nonzero tree.
d = mk("v_two_unresolved")
t = rd(d, "corpus/lessons/round-59.md")
t = t.replace("- Round-60 correction: this supersedes R31 — the committed receipt reads `C1_CHECK_SELFTEST: PASS (33 cases)`.\n", "")
wr(d, "corpus/lessons/round-59.md", t)
t = rd(d, "SCORECARD.md")
t = t.replace("- Round-60 correction: this supersedes the round-59 gate-evidence pointer — `.ufo/waves/round-60/final/release-clock.txt`, `.ufo/waves/round-60/final/doc-audit.txt` and `.ufo/waves/round-60/final/scope.txt` were never written for round 59.\n", "")
wr(d, "SCORECARD.md", t)

# 14. LOG.md is a symlink to a file outside the tree carrying the correction.
d = mk("v_symlink")
outside = os.path.join(S, "outside-LOG.md")
open(outside, "w", encoding="utf-8").write(rd(d, "LOG.md"))
os.unlink(os.path.join(d, "LOG.md"))
os.symlink(outside, os.path.join(d, "LOG.md"))

# 15. I5: the three named paths escape the round-60 final dir via `..`
d = mk("v_escape")
os.makedirs(os.path.join(d, ".ufo/waves/round-59/final"), exist_ok=True)
for nm, line in (("release-clock.txt", "RELEASE_CLOCK: CLEAN\n"),
                 ("doc-audit.txt", "DOC_AUDIT: CLEAN\n"),
                 ("scope.txt", "SCOPE: NOT RUN\n")):
    wr(d, ".ufo/waves/round-59/final/" + nm, line)
t = rd(d, "SCORECARD.md")
t = t.replace(".ufo/waves/round-60/final/release-clock.txt",
              ".ufo/waves/round-60/final/../round-59/final/release-clock.txt")
t = t.replace(".ufo/waves/round-60/final/doc-audit.txt",
              ".ufo/waves/round-60/final/../round-59/final/doc-audit.txt")
t = t.replace(".ufo/waves/round-60/final/scope.txt",
              ".ufo/waves/round-60/final/../round-59/final/scope.txt")
wr(d, "SCORECARD.md", t)

print("built:", " ".join(sorted(n for n in os.listdir(T) if n.startswith("v_"))))

# 16. I5: the named paths escape the round-60 final dir via `../../` (string prefix ok).
d = mk("v_escape2")
for nm, line in (("release-clock.txt", "RELEASE_CLOCK: CLEAN\n"),
                 ("doc-audit.txt", "DOC_AUDIT: CLEAN\n"),
                 ("scope.txt", "SCOPE: NOT RUN\n")):
    wr(d, ".ufo/waves/round-59/final/" + nm, line)
t = rd(d, "SCORECARD.md")
for nm in ("release-clock.txt", "doc-audit.txt", "scope.txt"):
    t = t.replace(".ufo/waves/round-60/final/" + nm,
                  ".ufo/waves/round-60/final/../../round-59/final/" + nm)
wr(d, "SCORECARD.md", t)

# 17. I6: an anchor line exists AND the receipt is edited to that hash.
d = mk("v_hash_anchor")
sub(d, ".ufo/waves/round-59/final/c1-landed.txt",
    "measured=revision 160caf750dcf15892b78ec066e66bc605ba57a5c",
    "measured=revision deadbeefdeadbeefdeadbeefdeadbeefdeadbeef")
app(d, "SCORECARD.md",
    "\n- (probe) the spot-check cites the tip 75165a07 for the report only.\n"
    "\n- Round-60 correction: `c1-landed.txt` measured=revision "
    "deadbeefdeadbeefdeadbeefdeadbeefdeadbeef.\n")

# 18. I1: the correction quotes the placeholder literal it corrects.
d = mk("v_quoteDEAD")
t = rd(d, "LOG.md")
t = t.replace("leaves the dead-seat count as a placeholder",
              "ends `dead seats __DEAD__`")
wr(d, "LOG.md", t)
print("built extra variants")

# 19. I2: right token, wrong fact in the same line.
d = mk("v_wrongfact2")
sub(d, "corpus/lessons/round-59.md",
    "the committed receipt reads `C1_CHECK_SELFTEST: PASS (33 cases)`.",
    "the committed receipt reads `C1_CHECK_SELFTEST: PASS (33 cases)`; the checker actually runs 12 cases.")

# 20. I4: right token, wrong fact in the same line.
d = mk("v_wrongfact4")
sub(d, "SCORECARD.md", "the controls runner holds 20 controls.",
    "the controls runner holds 21 controls, not 20; the receipt holds 20 controls.")

# 21/22. I4 correction appended twice: bad-last and bad-first.
d = mk("v_dup_bad_last")
app(d, "SCORECARD.md",
    "\n- Round-60 correction (duplicate): supersedes SCORECARD.md:1971 — the runner holds 21 controls.\n")
d = mk("v_dup_bad_first")
t = rd(d, "SCORECARD.md")
t = t.replace("- Round-60 correction: this supersedes SCORECARD.md:1971 — the controls runner holds 20 controls.",
              "- Round-60 correction (duplicate): supersedes SCORECARD.md:1971 — the runner holds 21 controls.\n"
              "- Round-60 correction: this supersedes SCORECARD.md:1971 — the controls runner holds 20 controls.")
wr(d, "SCORECARD.md", t)

# 23. I7: the trial's real verdict mapping is broken, the stub selftest still says PASS.
d = mk("v_i7broken")
sub(d, "corpus/openbao-transit-trial.sh", 'echo "TRIAL T1 HOLDS', 'echo "TRIAL T1 BROKEN', 1) if False else None
t = rd(d, "corpus/openbao-transit-trial.sh")
t = t.replace('HOLDS holds=$holds', 'BROKEN holds=$holds', 1)
wr(d, "corpus/openbao-transit-trial.sh", t)

# 24. I1: the heading is right after the anchor but the numbers live in a later section.
d = mk("v_i1loose")
t = rd(d, "LOG.md")
t = t.replace("- D1 (round 60): the round-59 entry's last line leaves the dead-seat count as a placeholder; the measured count over `.ufo/waves/round-59/w1-results.json` is `results=14 dead=0`.",
              "- D1 (round 60): see the round-60 section below.")
t += "\n## Round 60 — notes\n\nresults=14 dead=0 over `.ufo/waves/round-59/w1-results.json`.\n"
wr(d, "LOG.md", t)
print("built second batch")
