#!/usr/bin/env python3
"""Round-58 C1 mutation battery driver.

  python3 drive.py --checker PATH --base TREE --out DIR [--wrapper PATH] [--ids i1,...]

Mutants are fresh rsync copies of TREE under <out>/muts/<id>. Every run records
the checker's last line (and exit code) plus, when a wrapper is given, the
wrapper's last line. Plain and relocation-parity environments are both probed
for the I8 item (scope-gate resolves sibling lanes from the lane's parent).
"""
import argparse
import json
import os
import re
import shutil
import subprocess
import sys

BIG = ["--exclude=.git"]


def rsync(src, dst):
    if os.path.exists(dst):
        shutil.rmtree(dst)
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    subprocess.run(["rsync", "-a", *BIG, src.rstrip("/") + "/", dst.rstrip("/") + "/"],
                   check=True)


def readp(tree, rel):
    with open(os.path.join(tree, rel), encoding="utf-8") as f:
        return f.read()


def writep(tree, rel, s):
    with open(os.path.join(tree, rel), "w", encoding="utf-8") as f:
        f.write(s)


def sub_once(tree, rel, old, new, what):
    s = readp(tree, rel)
    n = s.count(old)
    if n != 1:
        raise SystemExit(f"SETUP {what}: {rel}: expected 1 occurrence of {old[:60]!r}, found {n}")
    writep(tree, rel, s.replace(old, new, 1))


def section(text, start_re):
    m = re.search(start_re, text, re.M)
    if not m:
        return None
    m2 = re.compile(r"^## ", re.M).search(text, m.end())
    return (m.start(), m2.start() if m2 else len(text))


def edit_section(tree, rel, start_re, fn, what):
    s = readp(tree, rel)
    sp = section(s, start_re)
    if not sp:
        raise SystemExit(f"SETUP {what}: section {start_re!r} not found in {rel}")
    a, b = sp
    sec = fn(s[a:b])
    writep(tree, rel, s[:a] + sec + s[b:])


# ------------------------------------------------------------------ mutations
def _r57_surface(log_text):
    out, inside = [], False
    for ln in log_text.splitlines(keepends=True):
        is_h = ln.startswith("## ")
        is_r57 = bool(re.match(r"^## Round 57\b", ln))
        if not inside and is_r57:
            inside = True
            out.append(ln)
            continue
        if inside:
            if is_h and not is_r57:
                break
            out.append(ln)
    return "".join(out)


def m_i1(tree):
    """LOG round-57 record: name a plausible receipt that is not an epoch-C receipt."""
    s = readp(tree, "LOG.md")
    surf = _r57_surface(s)
    new, npaths = re.subn(r"controls-prefreeze-epochC([^`\s]*\.txt)",
                          r"controls-prefreeze-epochD\1", surf)
    if npaths == 0:
        m = None
    m = None
    if npaths == 0:
        m = re.search(r"epoch C", surf)
        if not m:
            raise SystemExit("SETUP i1: no epoch-C receipt path or epoch-C token in the LOG record")
        new = surf[:m.start()] + "epoch D" + surf[m.end():]
    writep(tree, "LOG.md", s.replace(surf, new, 1))


def m_i2(tree):
    """epoch-C receipt: corrupt only the plans/round-57.md INSTRUMENT pin."""
    rel = None
    d = os.path.join(tree, ".ufo/waves/round-57/controls")
    cands = sorted(x for x in os.listdir(d) if x.startswith("controls-prefreeze-epochC"))
    for c in cands:
        s = readp(tree, os.path.join(".ufo/waves/round-57/controls", c))
        m = re.search(r"^INSTRUMENT ([0-9a-f]{64}) plans/round-57\.md$", s, re.M)
        if m and re.search(r"^CONTROLS: match=(\d+) mismatch=0$", s, re.M):
            rel = os.path.join(".ufo/waves/round-57/controls", c)
            h = m.group(1)
            new = h[:-1] + ("0" if h[-1] != "0" else "1")
            sub_once(tree, rel, f"INSTRUMENT {h} plans/round-57.md",
                     f"INSTRUMENT {new} plans/round-57.md", "i2")
            return
    raise SystemExit("SETUP i2: no epochC receipt carrying both a plan pin and a CONTROLS line")


def m_i3(tree):
    """S117 Gate quote: paraphrase one word so the quote no longer occurs in the body."""
    try:
        sub_once(tree, "corpus/lessons/round-57.md",
                 "specified audit device's hash function",
                 "specified audit backend's hash function", "i3")
    except SystemExit:
        raise


def m_i4(tree):
    """lesson §Sources registry count: stale 116 for the measured 117."""
    s = readp(tree, "corpus/lessons/round-57.md")
    m = re.search(r"Registry 114 → (\d+) \(", s)
    if not m:
        raise SystemExit("SETUP i4: no 'Registry 114 → N (' statement in the lesson")
    n = m.group(1)
    writep(tree, "corpus/lessons/round-57.md",
           s.replace(m.group(0), "Registry 114 → 116 (", 1) if n != "116"
           else s.replace(m.group(0), "Registry 114 → 118 (", 1))


def m_i5(tree):
    """SKILL gate row: drop the --selftest spelling from the row."""
    s = readp(tree, "SKILL.md")
    for old in ("`python3 -I -B corpus/current-claims.py --selftest` prints",
                "`python3 -I -B corpus/current-claims.py --selftest`",
                "--selftest"):
        if s.count(old) >= 1:
            writep(tree, "SKILL.md", s.replace(old, "none of its own", 1))
            return
    raise SystemExit("SETUP i5: no --selftest token in SKILL.md")


def m_i6(tree):
    """current-claims.py: hardcode the lesson surface to a literal round-56 path."""
    rel = "corpus/current-claims.py"
    s = readp(tree, rel)
    m = re.search(r'f"corpus/lessons/round-\{(\w+)\}\.md"', s)
    if m:
        writep(tree, rel, s[:m.start()] + '"corpus/lessons/round-56.md"' + s[m.end():])
        return
    m = re.search(r'os\.path\.join\("corpus", "lessons", f"round-\{(\w+)\}\.md"\)', s)
    if m:
        writep(tree, rel, s[:m.start()] + 'os.path.join("corpus", "lessons", "round-56.md")' + s[m.end():])
        return
    raise SystemExit("SETUP i6: no round-derived lesson surface expression found")


def m_i7(tree):
    """S115 Gate row: use the stale anchor label D12 named."""
    s = readp(tree, "corpus/lessons/round-57.md")
    if "§Enabling/Disabling audit devices" in s:
        writep(tree, "corpus/lessons/round-57.md",
               s.replace("§Enabling/Disabling audit devices",
                         "§Enabling and disabling audit devices"))
        return
    raise SystemExit("SETUP i7: live heading label absent")


def m_i8(tree):
    """adjacency basis: point the opencode row at a line that carries no token."""
    rel = "corpus/adjacency.tsv"
    s = readp(tree, rel)
    lines = s.splitlines(True)
    hits = 0
    for i, ln in enumerate(lines):
        if ln.startswith("$HOME/.config/opencode\t"):
            cells = ln.rstrip("\n").split("\t")
            if len(cells) >= 6:
                cells[4] = "SCORECARD.md:54"
                lines[i] = "\t".join(cells) + "\n"
                hits += 1
    if hits != 1:
        raise SystemExit(f"SETUP i8: opencode adjacency row hits={hits}")
    writep(tree, rel, "".join(lines))


def m_ga(tree):
    """guard (a): remove an item input file (the round-57 lesson)."""
    os.remove(os.path.join(tree, "corpus/lessons/round-57.md"))


MUT = {"i1": m_i1, "i2": m_i2, "i3": m_i3, "i4": m_i4, "i5": m_i5, "i6": m_i6,
       "i7": m_i7, "i8": m_i8, "ga": m_ga}

STUB = '''#!/usr/bin/env python3
import sys
print("C1_ROUTED: value=0 population=8 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 i8=1 guard=1")
sys.exit(0)
'''


def parse(line):
    out = {}
    for k, v in re.findall(r"(\w+)=([^\s]+)", line or ""):
        out[k] = v
    return out


def run(cmd, cwd, env=None):
    e = dict(os.environ)
    e.pop("ADJ_BASIS_ROOT", None)
    e.pop("ADJ_LANE_ROOT", None)
    e.pop("ADJ_HOME", None)
    if env:
        e.update(env)
    r = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, env=e)
    lines = [x for x in (r.stdout or "").splitlines() if x.strip()]
    return {"rc": r.returncode, "last": lines[-1] if lines else "",
            "stdout_tail": lines[-6:], "stderr_tail": (r.stderr or "").splitlines()[-4:]}


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--checker", required=True)
    ap.add_argument("--wrapper", default="")
    ap.add_argument("--base", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--ids", default="")
    ap.add_argument("--lane-root", default="/home/vgpnk/Projects/shokunin")
    args = ap.parse_args()
    ids = args.ids.split(",") if args.ids else ["base"] + list(MUT)
    os.makedirs(args.out, exist_ok=True)
    recs = []
    for mid in ids:
        mu = os.path.join(args.out, "muts", mid)
        rsync(args.base, mu)
        if mid in MUT:
            MUT[mid](mu)
        parity = {"ADJ_BASIS_ROOT": mu, "ADJ_LANE_ROOT": args.lane_root}
        ck = run([sys.executable, "-I", "-B", args.checker, "--root", mu], mu, parity)
        ck_plain = run([sys.executable, "-I", "-B", args.checker, "--root", mu], mu)
        rec = {"id": mid, "checker": ck, "checker_plain": ck_plain,
               "checker_fields": parse(ck["last"]), "plain_fields": parse(ck_plain["last"])}
        if args.wrapper:
            wr = run(["bash", args.wrapper, "--tree", mu], mu, parity)
            rec["wrapper"] = wr
            rec["wrapper_fields"] = parse(wr["last"])
        recs.append(rec)
        print(json.dumps(rec, sort_keys=True))
    with open(os.path.join(args.out, "battery.jsonl"), "w") as f:
        for r in recs:
            f.write(json.dumps(r, sort_keys=True) + "\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
