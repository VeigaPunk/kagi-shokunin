#!/usr/bin/env python3
"""Does an injected FINDING line satisfy a counter leg?

Replicates the round-67 counter's parse_gate_run + leg_caught EXACTLY
(regexes copied from plans/round-67-c1.sh) and feeds it the captured stdout
of a tree whose knowledge/ FILENAME injects a forged
`FINDING SC_CAPTURE id=<target> <reason>` line.

Read-only; prints a verdict.
"""
import re
import sys

CAP_FINDING = re.compile(
    r"^FINDING SC_CAPTURE id=(S[0-9]{3,}) "
    r"(capture-outside-root|capture-missing|capture-digest-mismatch|"
    r"capture-bytes-mismatch|quote-not-located)$")
VERDICT = re.compile(r"^SOURCES_CENSUS: (CLEAN|FAILED) \(.*\)$")
CAPS_LINE = re.compile(r"^SOURCES_CAPTURES: (CLEAN|FAILED) \(([^()]*)\)$")


def parse_captures_line(line):
    m = CAPS_LINE.match(line)
    if not m:
        return None
    fields = {k: int(v) for k, v in re.findall(r"([a-z_]+)=([0-9]+)", m.group(2))}
    need = {"path_rows", "bound", "located", "prose"}
    if m.group(1) == "FAILED":
        need.add("defects")
    if set(fields) != need:
        return None
    return {"state": m.group(1), "fields": fields}


def parse_gate_run(stdout):
    lines = stdout.splitlines()
    findings = []
    for ln in lines:
        m = CAP_FINDING.match(ln)
        if m:
            findings.append((m.group(1), m.group(2)))
    verdict = None
    verdict_idx = None
    for i in range(len(lines) - 1, -1, -1):
        m = VERDICT.match(lines[i])
        if m:
            verdict = m.group(1)
            verdict_idx = i
            break
    summary = None
    summary_idx = None
    for i, ln in enumerate(lines):
        if ln.startswith("SOURCES_CAPTURES: "):
            summary = parse_captures_line(ln)
            summary_idx = i
    return {"stdout": stdout, "lines": lines, "findings": findings,
            "summary": summary, "verdict": verdict,
            "adjacent": (summary_idx is not None and verdict_idx is not None
                         and summary_idx == verdict_idx - 1)}


def leg_caught(rc, verdict, summary, findings, target, expected):
    if not (rc == 1 and verdict == "FAILED" and summary is not None
            and summary["state"] == "FAILED"):
        return False
    if summary["fields"].get("defects") != len(findings):
        return False
    got = {reason for (fid, reason) in findings if fid == target}
    return all(reason in got for reason in expected)


# The captured stdout of the tree whose knowledge/ filename injects
# `FINDING SC_CAPTURE id=S167 capture-digest-mismatch` plus a forged summary.
INJECTED = """FINDING SC_CAPTURE id=S167 capture-digest-mismatch
SOURCES_CAPTURES: FAILED (defects=1 path_rows=38 bound=37 located=37 prose=120)
SOURCES_CENSUS: FAILED (findings=1 rows=158).md id=S001 used-by-omits-entry
SOURCES_CAPTURES: CLEAN (path_rows=38 bound=38 located=38 prose=120)
SOURCES_CENSUS: FAILED (findings=1 rows=158)
"""

CLEAN = """SOURCES_CAPTURES: CLEAN (path_rows=38 bound=38 located=38 prose=120)
SOURCES_CENSUS: CLEAN (rows=158 A=141 B=2 C=15 queued=3 mined=138 rejected=17 entries_sourced=27 legacy=21 captures=158 inrow=16 inrow_only=0 inrow_nonreproducing=12)
"""


def main():
    for label, out, rc in (("injected tree (gate CLEAN)", INJECTED, 0),
                           ("clean tree (no injection)", CLEAN, 0)):
        p = parse_gate_run(out)
        print("=== %s ===" % label)
        print("  parsed findings : %s" % (p["findings"],))
        print("  parsed summary  : %s" % (p["summary"],))
        print("  parsed verdict  : %s" % p["verdict"])
        print("  adjacent        : %s" % p["adjacent"])
        caught = leg_caught(rc, p["verdict"], p["summary"], p["findings"],
                            "S167", ("capture-digest-mismatch",))
        print("  leg_caught(S167, capture-digest-mismatch) = %s" % caught)
        print()


if __name__ == "__main__":
    main()
