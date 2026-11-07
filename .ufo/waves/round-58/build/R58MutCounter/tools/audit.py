#!/usr/bin/env python3
"""Independent literal-condition audit of the eight C1 items (expectation column).

Not the detector; used only to state what a mutation changes, so that a checker
reading can be labelled kill/survivor against the frozen plan text.
"""
import hashlib
import os
import re
import subprocess
import sys

R57 = ".ufo/waves/round-57"


def sha(p):
    h = hashlib.sha256()
    with open(p, "rb") as f:
        for b in iter(lambda: f.read(1 << 16), b""):
            h.update(b)
    return h.hexdigest()


def sec(text, start_re):
    m = re.search(start_re, text, re.M)
    if not m:
        return ""
    m2 = re.compile(r"^## ", re.M).search(text, m.end())
    return text[m.start(): m2.start() if m2 else len(text)]


def norm(s):
    return re.sub(r"\s+", " ", s).strip()


def main(root):
    root = os.path.abspath(root)
    rd = lambda rel: open(os.path.join(root, rel), encoding="utf-8", errors="replace").read()
    out = {}
    import re as _re
    lg_all = rd("LOG.md")
    parts, inside = [], False
    for ln in lg_all.splitlines(keepends=True):
        is_h = ln.startswith("## "); is_r57 = bool(_re.match(r"^## Round 57\b", ln))
        if not inside and is_r57:
            inside = True; parts.append(ln); continue
        if inside:
            if is_h and not is_r57: break
            parts.append(ln)
    log57 = "".join(parts)
    sc57 = sec(rd("SCORECARD.md"), r"^## Round 57 [—-] post-move")
    # I1
    path_ok = False
    for m in re.finditer(r"(\.ufo/waves/round-57/controls/controls-prefreeze-epochC[-\w]*\.txt)", log57):
        if os.path.isfile(os.path.join(root, m.group(1))):
            path_ok = True
    out["i1"] = bool(re.search(r"epoch C|epoch-C", log57)) and path_ok and bool(
        re.search(r"epoch C|epoch-C", sc57))
    # I2
    i2 = False
    d = os.path.join(root, R57, "controls")
    files = [f for f in sorted(os.listdir(d)) if f.startswith("controls-prefreeze-epochC")] if os.path.isdir(d) else []
    detail = []
    for f in files:
        s = open(os.path.join(d, f), encoding="utf-8", errors="replace").read()
        pins = re.findall(r"^INSTRUMENT ([0-9a-f]{64}) (\S+)$", s, re.M)
        okpins = len(pins) >= 5
        for h, rel in pins:
            p = os.path.join(root, rel)
            if not os.path.isfile(p) or sha(p) != h:
                okpins = False
        ctl = re.findall(r"^CONTROLS: match=(\d+) mismatch=(\d+)$", s, re.M)
        ctlok = bool(ctl) and ctl[-1][1] == "0" and int(ctl[-1][0]) >= 13
        detail.append((f, okpins, ctlok))
        if okpins and ctlok:
            i2 = True
    out["i2"] = i2
    out["i2_detail"] = detail
    # I3
    les = rd("corpus/lessons/round-57.md")
    gate = sec(les, r"^## Gate\s*$")
    i3 = False
    for block in re.split(r"\n(?=- \*\*Admit )", gate):
        if "S117" not in block:
            continue
        urls = re.findall(r"https?://\S+", block)
        dates = re.findall(r"opened (\d{4}-\d{2}-\d{2})", block)
        quotes = re.findall(r"[\"“]([^\"”]{10,300})[\"”]", block)
        bodyp = os.path.join(root, R57, "capture/S117.body")
        body = norm(open(bodyp, encoding="utf-8", errors="replace").read()) if os.path.isfile(bodyp) else ""
        qok = any(len(q.split()) <= 25 and norm(q) in body for q in quotes)
        i3 = bool(urls and dates and qok)
    src = rd("corpus/SOURCES.md")
    m = re.search(r"^\| S117 \|.*$", src, re.M)
    usedby = m.group(0).split("|")[-2] if m else ""
    out["i3"] = i3 and "corpus/lessons/round-57.md" in usedby and any(ln.startswith("source:") and "S117" in ln for ln in les.splitlines())
    out["i3_detail"] = {"gate_ok": i3, "usedby": usedby.strip(), "source_line": les.splitlines()[2][:80]}
    # I4
    n = sum(1 for ln in src.splitlines() if re.match(r"^\|\s*S\d{3,}\s*\|", ln))
    counted = []
    for nm, txt in (("SCORECARD", sc57), ("lesson", les)):
        for mm in re.finditer(r"(?:Registry|registry)\D{0,12}(\d+)(?:\s*(?:→|->)\s*(\d+))?", txt):
            counted.append((nm, mm.group(0)))
    landing = 117
    problems = []
    locs = [("SCORECARD", sc57), ("lesson", les[les.find("## Sources"):] if "## Sources" in les else "")]
    for _, text in locs:
        for _a, b in re.findall(r"Registry\s+(\d+)\s*→\s*(\d+)", text):
            if int(b) != landing:
                problems.append(f"arrow {b} != {landing}")
        for m in re.finditer(r"tip count\b[^;\n]{0,200}?=\s*(\d+)", text):
            if int(m.group(1)) != n:
                problems.append(f"tip {m.group(1)} != {n}")
        for m in re.finditer(r"\bend\b[^.;\n]{0,120}?(\d+)\s+rows", text):
            if int(m.group(1)) != n:
                problems.append(f"end {m.group(1)} != {n}")
        if "gates.txt" in text:
            for m in re.finditer(r"rows=(\d+)", text):
                if int(m.group(1)) != 116:
                    problems.append("gates attribution")
            if not re.search(r"\bpredat|\bafter\b", text):
                problems.append("gates predication")
    out["i4"] = n == 119 and not problems and bool(counted)
    out["i4_detail"] = {"sources_rows": n, "statements": counted[:10]}
    # I5
    sk = rd("SKILL.md")
    row = [ln for ln in sk.splitlines() if "current-claims.py" in ln and ln.strip().startswith("|")]
    out["i5"] = any("--selftest" in r and "corpus/current-claims.py" in r and "corpus/current-claims.py --round" in r or
                    ("--selftest" in r and "entry command" in sk) for r in row) and bool(row)
    out["i5_detail"] = {"rows": len(row), "has_selftest": [("--selftest" in r) for r in row]}
    # I6
    cc = rd("corpus/current-claims.py")
    surface = cc[cc.find("surfaces = ["):cc.find("]", cc.find("surfaces = [")) + 1] if "surfaces = [" in cc else ""
    r57 = subprocess.run([sys.executable, "-I", "-B", os.path.join(root, "corpus/current-claims.py"),
                          "--root", root, "--round", "57"], capture_output=True, text=True)
    sel = subprocess.run([sys.executable, "-I", "-B", os.path.join(root, "corpus/current-claims.py"),
                          "--selftest"], capture_output=True, text=True)
    out["i6"] = (r57.returncode in (0, 1) and "round-56.md" not in surface
                 and "plans/round-<N>.md" in cc and sel.returncode == 0)
    out["i6_detail"] = {"round57_rc": r57.returncode, "selftest_rc": sel.returncode,
                        "lit56_in_surface": "round-56.md" in surface}
    # I7
    out["i7"] = "Enabling/Disabling audit devices" in les
    # I8
    env = dict(os.environ, ADJ_BASIS_ROOT=root, ADJ_LANE_ROOT="/home/vgpnk/Projects/shokunin")
    g = subprocess.run(["bash", os.path.join(root, "corpus/scope-gate.sh")], cwd=root,
                       capture_output=True, text=True, env=env)
    mm = re.search(r"stale_basis=(\d+)", g.stdout)
    out["i8"] = bool(mm) and mm.group(1) == "0"
    out["i8_detail"] = {"stale_basis": mm.group(1) if mm else "?"}
    print(f"AUDIT {os.path.basename(root.rstrip('/'))} " +
          " ".join(f"{k}={'1' if v is True else '0'}" for k, v in out.items() if re.fullmatch(r"i[1-8]", k)))
    for k in sorted(out):
        if k.endswith("_detail"):
            print(f"  {k}: {out[k]}")
    return out


if __name__ == "__main__":
    main(sys.argv[1])
