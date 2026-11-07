#!/usr/bin/env python3
"""Build the round-60 C1 probe fixtures on top of a BASE tree copy.

Every repair here is deliberately TOKEN-SHAPED: it satisfies the literal text of
plans/round-60.md §C1 item conditions while leaving the underlying defect or an
equally false statement in place.  Nothing in this file is a proposed fix.
"""
import os
import sys

DEST = sys.argv[1]
MODE = sys.argv[2] if len(sys.argv) > 2 else "fix"

I1_BLOCK = """
## Round 59 — correction

- D1 (round 60): the round-59 entry's last line leaves the dead-seat count as a placeholder; the measured count over `.ufo/waves/round-59/w1-results.json` is `results=14 dead=0`.
"""

I2_LINE = """
- Round-60 correction: this supersedes R31 — the committed receipt reads `C1_CHECK_SELFTEST: PASS (33 cases)`.
"""

I3_LESSON = """# Round 60 — lesson (probe fixture)

## Routed dispositions

| id | disposition |
|---|---|
| R20 | closed |
| R21 | closed |
| R22 | closed |

The round-59 routed table used R20, R21, R22 twice each — a duplicate id names two findings.
"""

I4_LINE = """
- Round-60 correction: this supersedes SCORECARD.md:1971 — the controls runner holds 20 controls.
"""

I5_LINE = """
- Round-60 correction: this supersedes the round-59 gate-evidence pointer — `.ufo/waves/round-60/final/release-clock.txt`, `.ufo/waves/round-60/final/doc-audit.txt` and `.ufo/waves/round-60/final/scope.txt` were never written for round 59.
"""

I6_LINE = """
- Round-60 correction: the round-59 measured revision is the one `c1-landed.txt` carries: measured=revision 160caf750dcf15892b78ec066e66bc605ba57a5c.
"""

SELFTEST_STUB = """case " $* " in *" --selftest "*)
  printf 'TRANSIT_SELFTEST: PASS (cases=6)\\n'
  exit 0
  ;;
esac
"""


def rd(rel):
    with open(os.path.join(DEST, rel), encoding="utf-8", errors="surrogateescape") as f:
        return f.read()


def wr(rel, text):
    p = os.path.join(DEST, rel)
    os.makedirs(os.path.dirname(p) or ".", exist_ok=True)
    with open(p, "w", encoding="utf-8", errors="surrogateescape") as f:
        f.write(text)


def app(rel, text):
    wr(rel, rd(rel) + text)


def main():
    app("LOG.md", I1_BLOCK)
    app("corpus/lessons/round-59.md", I2_LINE)
    wr("corpus/lessons/round-60.md", I3_LESSON)
    app("SCORECARD.md", I4_LINE + I5_LINE + I6_LINE)
    for name, line in (("release-clock.txt", "RELEASE_CLOCK: CLEAN\n"),
                       ("doc-audit.txt", "DOC_AUDIT: CLEAN\n"),
                       ("scope.txt", "SCOPE: NOT RUN — stub\n")):
        wr(".ufo/waves/round-60/final/" + name, line)
    # I7: a --selftest that prints PASS and asserts nothing.
    t = rd("corpus/openbao-transit-trial.sh")
    first, rest = t.split("\n", 1)
    wr("corpus/openbao-transit-trial.sh", first + "\n" + SELFTEST_STUB + rest)
    s = rd("SKILL.md")
    old = "none — its own five shims and the clean-room leg are the falsifiers"
    assert old in s, "SKILL.md selftest cell literal not found"
    wr("SKILL.md", s.replace(old, "bash corpus/openbao-transit-trial.sh --selftest", 1))


main()
