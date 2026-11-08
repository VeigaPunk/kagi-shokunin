#!/usr/bin/env python3
"""Independent C1 behavioral detector for the R68 mutation probe (scratch only).

usage: detector.py TREE WORKDIR [--skip-legs]
  TREE      tree whose corpus/source-fetches.tsv + captures + gate are measured
  WORKDIR   scratch dir for the six mutated copies (created/removed here)

Prints one line:
  MUTDET: verified=<n> col15=<n> caught=<k>/6 anchor=<id> legs=<M1:ok,...>

Derivation implements the frozen classification rule of plans/round-68.md:
a col-16 cell is legal (path) iff it is exactly one whitespace-delimited
`.ufo/waves/` token with no other content; a cell with no such token is prose;
every other shape naming one is a defect and is never verified.
The quote/digest instruments are the BASE copies (trusted), not TREE's.
"""
import hashlib
import os
import re
import shutil
import subprocess
import sys
import tempfile

TREE = os.path.abspath(sys.argv[1])
WORK = os.path.abspath(sys.argv[2])
SKIP_LEGS = "--skip-legs" in sys.argv[3:]
BASE = "/fast/scratch/hyaku/kagi-r68/R68MutGate/base"
NORM = os.path.join(BASE, "corpus/rendered-text-v1.py")
TSV_REL = "corpus/source-fetches.tsv"
CAP_TOKEN = ".ufo/waves/"

EXPECT = {
    "M1": ("SC_CAPTURE", "capture-whitespace"),
    "M2": ("SC_CAPTURE", "capture-whitespace"),
    "M3": ("SC_FETCH", "cr-in-tsv"),
    "M4": ("SC_CAPTURE", "capture-digest-mismatch"),
    "M5": ("SC_CAPTURE", "normalized-digest-mismatch"),
    "M6": ("SC_CAPTURE", "capture-bytes-mismatch"),
}


def sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def locate(tree, path, quote, norm):
    if norm == "raw-literal-v1":
        with open(path, "rb") as f:
            return f.read().count(quote.encode())
    r = subprocess.run(["python3", NORM, "locate", path, quote],
                       capture_output=True, text=True)
    m = re.search(r"count=(\d+)", r.stdout)
    return int(m.group(1)) if m else 0


def norm_digest(path):
    r = subprocess.run(["python3", NORM, "digest", path],
                       capture_output=True, text=True)
    m = re.search(r"normalized_sha256=([0-9a-f]{64})", r.stdout)
    return m.group(1) if m else None


def rows():
    with open(os.path.join(TREE, TSV_REL), encoding="utf-8", newline="") as f:
        text = f.read()
    out = []
    if "\r" in text:
        return out, text
    for line in text.split("\n"):
        if not line or line.startswith("#"):
            continue
        c = line.split("\t")
        if len(c) != 16:
            continue
        out.append(c)
    return out, text


def classify(cell):
    toks = cell.split()
    hits = [t for t in toks if CAP_TOKEN in t]
    if not hits:
        return ("prose", None)
    if len(hits) == 1 and cell == hits[0]:
        return ("path", hits[0])
    return ("defect", hits)


def derive():
    verified = 0
    col15 = 0
    bound = []
    rs, _ = rows()
    for c in rs:
        kind, val = classify(c[15])
        if kind != "path":
            continue
        p = os.path.join(TREE, val)
        if not (os.path.isfile(p)):
            continue
        if sha256(p) != c[9] or os.path.getsize(p) != int(c[10] or -1):
            continue
        q = c[12]
        norm = c[13]
        if not q or locate(TREE, p, q, norm) < 1:
            continue
        verified += 1
        bound.append((c[0], val))
        if norm == "rendered-text-v1":
            if norm_digest(p) == c[14]:
                col15 += 1
    return verified, col15, bound


def anchor(bound):
    return bound[-1] if bound else (None, None)


def mutate(src, dst, leg, aid, loc):
    subprocess.run(["cp", "-al", src, dst], check=True)
    tsv = os.path.join(dst, TSV_REL)
    body = os.path.join(dst, loc)
    rs, text = rows()
    idx = None
    for i, line in enumerate(text.split("\n")):
        if line.split("\t", 1)[0] == aid:
            idx = i
            break
    assert idx is not None
    lines = text.split("\n")
    cells = lines[idx].split("\t")
    desc = ""
    if leg == "M1":
        cells[15] = cells[15] + " "
    elif leg == "M2":
        cells[15] = cells[15] + "," + cells[15]
    elif leg == "M3":
        pass
    elif leg == "M4":
        h = list(cells[9])
        h[0] = "0" if h[0] != "0" else "1"
        cells[9] = "".join(h)
    elif leg == "M5":
        cells[14] = "4d966ff9535cdbd8faa00ad925f60e2fb38892bdb07cd48bb587c9da8aac72d5"
    elif leg == "M6":
        pass
    else:
        raise SystemExit(leg)
    if leg == "M3":
        data = text.replace("\n", "\r\n").encode()
        tmp = tsv + ".mut"
        open(tmp, "wb").write(data)
        os.replace(tmp, tsv)
        return
    if leg != "M6":
        lines[idx] = "\t".join(cells)
        tmp = tsv + ".mut"
        open(tmp, "w", newline="").write("\n".join(lines))
        os.replace(tmp, tsv)
    else:
        with open(body, "rb") as f:
            b = f.read()
        tmp = body + ".mut"
        open(tmp, "wb").write(b + b"\x00")
        os.replace(tmp, body)


def run_gate(tree, root, extra=()):
    r = subprocess.run(["bash", os.path.join(tree, "corpus/sources-census.sh"),
                        "verify", "--root", root, *extra],
                       capture_output=True, text=True, timeout=1800)
    return r.returncode, r.stdout + r.stderr


def leg_ok(out, rc, kind, reason, aid):
    if rc != 1:
        return False, "rc"
    if "SOURCES_CENSUS: FAILED" not in out:
        return False, "verdict"
    if kind == "SC_FETCH":
        if f"FINDING SC_FETCH cr-in-tsv" not in out:
            return False, "finding"
        return True, "ok"
    needle = f"FINDING SC_CAPTURE id={aid} {reason}"
    if needle not in out:
        return False, "finding"
    return True, "ok"


def main():
    verified, col15, bound = derive()
    aid, loc = anchor(bound)
    caught = 0
    legs = []
    if not SKIP_LEGS and aid:
        os.makedirs(WORK, exist_ok=True)
        for leg in ["M1", "M2", "M3", "M4", "M5", "M6"]:
            d = os.path.join(WORK, leg)
            if os.path.exists(d):
                shutil.rmtree(d)
            mutate(TREE, d, leg, aid, loc)
            rc, out = run_gate(TREE, d)
            ok, why = leg_ok(out, rc, *EXPECT[leg], aid)
            caught += 1 if ok else 0
            legs.append(f"{leg}:{'ok' if ok else why}")
            shutil.rmtree(d)
    print("MUTDET: verified=%d col15=%d caught=%d/6 anchor=%s legs=%s"
          % (verified, col15, caught, aid, ",".join(legs)))


if __name__ == "__main__":
    main()
