#!/usr/bin/env python3
"""Insert the six round-28 draft selftest cases into a COPY of the BASE
release-clock.py and run the selftest there.

Nothing in the lane checkout is written. The inserted block is the draft the
report hands to the implementing seats; the copy exists only to show that each
draft case fails on BASE and that the failure is a FAIL line (not a traceback
that would abort the whole selftest).
"""
import shutil
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
TARGET = HERE / "base" / "corpus" / "release-clock.py"
DRAFT_TREE = HERE / "drafttree"
DRAFT = DRAFT_TREE / "corpus" / "release-clock.py"

BLOCK = '''
    # --- round 28 C1/C2 draft cases (proposed; category names to be aligned
    # with the implementing seats) -------------------------------------------
    CANON_NOTE = "derived: newest stable release on the feed when the row was opened"
    CANON_FEED = fixture_source("S004", "Release feed", "code",
                                "Entry titled v1.2.3, tag link /releases/tag/v1.2.3",
                                "Release Atom feed.", "90d",
                                "https://example.test/other.atom")
    run_case("C1 leading-zero observation is not a fired release",
             fixture_row(anchored="1.2.3", observed="1.2.03", verdict="fired",
                         note=CANON_NOTE) + "\\n",
             [("NONCANONICAL", "S001")], {"observed": 0, "fired": 0, "derived": 0})
    run_case("C1 leading-zero anchor is refused",
             fixture_row(anchored="1.2.03", observed="1.2.4", verdict="fired",
                         note=CANON_NOTE) + "\\n",
             [("NONCANONICAL", "S001")], {"observed": 0, "fired": 0, "derived": 0})
    try:
        run_case("C1 oversize component is a typed finding, not a traceback",
                 fixture_row(anchored="1.2." + "1" * 4301, observed="1.2.3",
                             verdict="not-fired", note=CANON_NOTE) + "\\n",
                 [("NONCANONICAL", "S001")], {"observed": 0})
    except ValueError as exc:
        failures.append("C1 oversize component raised %s instead of a typed finding"
                        % exc.__class__.__name__)
    run_case("C2 derived anchor lowered below its feed row is refused",
             fixture_row(feed_source_id="S004",
                         feed_url="https://example.test/other.atom",
                         anchored="1.1.0", observed="1.1.0", verdict="not-fired",
                         note=CANON_NOTE) + "\\n",
             [("DERIVED-MISMATCH", "S001")], {"observed": 0, "derived": 0},
             extra_sources=[CANON_FEED])
    run_case("C2 derived anchor raised above its feed row is not a fired release",
             fixture_row(feed_source_id="S004",
                         feed_url="https://example.test/other.atom",
                         anchored="1.2.4", observed="1.2.5", verdict="fired",
                         note=CANON_NOTE) + "\\n",
             [("DERIVED-MISMATCH", "S001")],
             {"observed": 0, "fired": 0, "derived": 0},
             extra_sources=[CANON_FEED])
    run_case("C2 derived anchor raised above its feed row is refused",
             fixture_row(feed_source_id="S004",
                         feed_url="https://example.test/other.atom",
                         anchored="1.2.4", observed="1.2.4", verdict="not-fired",
                         note=CANON_NOTE) + "\\n",
             [("DERIVED-MISMATCH", "S001")], {"observed": 0, "derived": 0},
             extra_sources=[CANON_FEED])
'''

text = TARGET.read_text(encoding="utf-8")
anchor = "    atom = b'<feed xmlns=\"http://www.w3.org/2005/Atom\">%s</feed>'"
if anchor not in text:
    sys.exit("insertion anchor not found")
patched = text.replace(anchor, BLOCK.lstrip("\n") + anchor, 1)
(DRAFT.parent).mkdir(parents=True, exist_ok=True)
shutil.copy2(TARGET.parent / "rendered-text-v1.py", DRAFT.parent / "rendered-text-v1.py")
DRAFT.write_text(patched, encoding="utf-8")
print("draft written:", DRAFT)
proc = subprocess.run([sys.executable, "-I", "-B", str(DRAFT), "--selftest"],
                      capture_output=True, text=True)
print("EXIT", proc.returncode)
print(proc.stdout)
if proc.stderr:
    print("STDERR:", proc.stderr[-2000:])
