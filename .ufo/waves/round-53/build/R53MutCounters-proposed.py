#!/usr/bin/env python3
"""Proposed-control and equivalence-fixture verification for seat R53MutCounters (C1).

For each case: build BASE + the round-53 C1 reference overlay, apply ONE fixture edit,
then run (a) the gate corpus/release-clock.py, (b) the pristine candidate C1 counter,
(c) the C1 counter carrying the named mutant. Prints one JSON line per case.

Cases starting with `prop-` are candidate killing controls for surviving mutants:
the pristine counter must read E and the mutant must read != E.
Cases starting with `eq-` are the fixtures that would expose a surviving mutant's
dropped conjunct; they show the gate itself fails (GATE = 0), i.e. the conjunct is
unreachable under GATE = 1.
"""
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tarfile
from pathlib import Path

S = Path("/fast/scratch/hyaku/kagi-r53/R53MutCounters")
BASE = "c1953d4afc19a5a336a58685c00ab5260bcfea1c"
LANE = S / "lane"
SLIM = S / "slim"
REF = SLIM / ".ufo/waves/round-53/controls/fixtures/ref/c1"
VERIFY = S / "verify"
ENV = dict(os.environ, HYAKU_SCRATCH="/fast/scratch/hyaku")
FLOOR = int(subprocess.check_output(["date", "-u", "-d", "2026-11-07T00:00:00Z", "+%s"]))
NOW = int(subprocess.check_output(["date", "-u", "+%s"]))


def build(case):
    d = VERIFY / case
    if d.exists():
        shutil.rmtree(d)
    d.mkdir(parents=True)
    with subprocess.Popen(["git", "-C", str(LANE), "archive", BASE], stdout=subprocess.PIPE) as p:
        with tarfile.open(fileobj=p.stdout, mode="r|") as tar:
            tar.extractall(d)
        p.wait()
    shutil.copytree(REF, d, dirs_exist_ok=True)
    return d


def rows(path):
    return path.read_text(encoding="utf-8").split("\n")


def reg_cells(line):
    return [c.strip() for c in line.strip().strip("|").split("|")]


def set_reg(path, sid, idx, value):
    lines = rows(path)
    hits = [i for i, l in enumerate(lines) if re.match(r"^\| %s \|" % sid, l)]
    assert len(hits) == 1, (sid, hits)
    cells = reg_cells(lines[hits[0]])
    assert len(cells) == 11
    cells[idx] = value
    lines[hits[0]] = "| " + " | ".join(cells) + " |"
    path.write_text("\n".join(lines), encoding="utf-8")


def clock_rows(path, sid):
    lines = rows(path)
    return [i for i, l in enumerate(lines) if l.startswith(sid + "\t")]


def redigest(d):
    g = d / "corpus/release-clock.py"
    r = d / ".ufo/waves/round-53/final/observe-r53.json"
    lines = rows(g)
    lines[27] = 'DEFAULT_RECEIPT_SHA256 = "%s"' % hashlib.sha256(r.read_bytes()).hexdigest()
    g.write_text("\n".join(lines), encoding="utf-8")


def edit_receipt(d, mutate, redigest_after):
    r = d / ".ufo/waves/round-53/final/observe-r53.json"
    j = json.loads(r.read_text(encoding="utf-8"))
    for o in j["observations"]:
        if o.get("id") == "S104":
            mutate(o)
    r.write_text(json.dumps(j, indent=2) + "\n", encoding="utf-8")
    if redigest_after:
        redigest(d)


def gate(d):
    p = subprocess.run(["python3", "corpus/release-clock.py"], cwd=d,
                       capture_output=True, text=True)
    last = [l for l in p.stdout.splitlines() if l.strip()][-1] if p.stdout.strip() else ""
    return p.returncode, last


def counter(counter_path, d, asof):
    p = subprocess.run(["bash", str(counter_path), "--tree", str(d)],
                       capture_output=True, text=True, env=dict(ENV, C1_ASOF=str(asof)))
    out = (p.stdout + p.stderr).strip().splitlines()
    line = out[-1] if out else ""
    m = re.search(r"value=(\d+)", line)
    return p.returncode, (m.group(1) if m else "SETUP"), line


CASES = []


def case(name, mutant, mutate, asof):
    CASES.append((name, mutant, mutate, asof))


def m_s103_status(d):
    set_reg(d / "corpus/SOURCES.md", "S103", 7, "queued")


def m_s103_90d(d):
    set_reg(d / "corpus/SOURCES.md", "S103", 9, "90d")


def m_s114_anch(d):
    p = d / "corpus/release-clocks.tsv"
    lines = rows(p)
    i = clock_rows(p, "S104")[0]
    f = lines[i].split("\t")
    f[4] = "1.3.3"
    lines[i] = "\t".join(f)
    p.write_text("\n".join(lines), encoding="utf-8")


def m_clock_kind(d):
    p = d / "corpus/release-clocks.tsv"
    lines = rows(p)
    i = clock_rows(p, "S104")[0]
    f = lines[i].split("\t")
    f[1] = "rendered-quote"
    lines[i] = "\t".join(f)
    p.write_text("\n".join(lines), encoding="utf-8")


def m_clock_field(d):
    p = d / "corpus/release-clocks.tsv"
    lines = rows(p)
    i = clock_rows(p, "S104")[0]
    lines[i] = lines[i] + "\textra"
    p.write_text("\n".join(lines), encoding="utf-8")


def m_clock_dup(d):
    p = d / "corpus/release-clocks.tsv"
    lines = rows(p)
    i = clock_rows(p, "S104")[0]
    lines.insert(i + 1, lines[i])
    p.write_text("\n".join(lines), encoding="utf-8")


def m_s104_fsid_s033(d):
    p = d / "corpus/release-clocks.tsv"
    lines = rows(p)
    i = clock_rows(p, "S104")[0]
    f = lines[i].split("\t")
    f[2] = "S033"
    lines[i] = "\t".join(f)
    p.write_text("\n".join(lines), encoding="utf-8")


def m_s111_onrelease(d):
    set_reg(d / "corpus/SOURCES.md", "S111", 9, "on-release")


def m_receipt_204(d):
    edit_receipt(d, lambda o: o.__setitem__("http_status", 204), True)


def m_receipt_204_nodigest(d):
    edit_receipt(d, lambda o: o.__setitem__("http_status", 204), False)


def m_receipt_fired(d):
    edit_receipt(d, lambda o: o.__setitem__("verdict", "fired"), True)


def m_gate_comment(d):
    g = d / "corpus/release-clock.py"
    lines = rows(g)
    assert "Check and observe" in lines[1], lines[1]
    lines[1] = lines[1].replace("Check and observe", "Verify and observe", 1)
    g.write_text("\n".join(lines), encoding="utf-8")


def m_gate_append(d):
    g = d / "corpus/release-clock.py"
    g.write_text(g.read_text(encoding="utf-8") + "# appended by control\n", encoding="utf-8")


def m_none(d):
    pass


case("prop-M03-guard-bytes", "C1M03", m_gate_comment, NOW)
case("prop-M06-asof-clamp", "C1M06", m_none, FLOOR)
case("prop-M10-http204", "C1M10", m_receipt_204, NOW)
case("prop-M18-s103-queued", "C1M18", m_s103_status, NOW)
case("eq-M01-s103-90d", "C1M01", m_s103_90d, NOW)
case("eq-M07-anchored", "C1M07", m_s114_anch, NOW)
case("eq-M08-clock-kind", "C1M08", m_clock_kind, NOW)
case("eq-M09-extra-field", "C1M09", m_clock_field, NOW)
case("eq-M11-verdict", "C1M11", m_receipt_fired, NOW)
case("eq-M13-no-digest", "C1M13", m_receipt_204_nodigest, NOW)
case("eq-M14-dup-row", "C1M14", m_clock_dup, NOW)
case("eq-M19-s111-onrelease", "C1M19", m_s111_onrelease, NOW)
case("eq-M20-fsid-s033", "C1M20", m_s104_fsid_s033, NOW)
case("eq-M04-append-line", "C1M04", m_gate_append, NOW)


def main():
    VERIFY.mkdir(exist_ok=True)
    pristine = SLIM / "plans/round-53-c1.sh"
    baseline = None
    for name, mutant, mutate, asof in CASES:
        d = build(name)
        mutate(d)
        grc, glast = gate(d)
        prc, pval, pline = counter(pristine, d, asof)
        mcounter = S / "mut" / mutant / "plans/round-53-c1.sh"
        mrc, mval, mline = counter(mcounter, d, asof)
        rec = {
            "case": name, "mutant": mutant, "asof": asof,
            "gate_rc": grc, "gate_last": glast,
            "pristine_rc": prc, "pristine_value": pval,
            "mutant_rc": mrc, "mutant_value": mval,
            "differ": pval != mval,
            "pristine_line": pline, "mutant_line": mline,
        }
        print(json.dumps(rec), flush=True)
        shutil.rmtree(d)


if __name__ == "__main__":
    main()
