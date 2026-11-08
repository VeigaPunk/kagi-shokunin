#!/usr/bin/env python3
"""Independent recount of the census capture population (own code, not the gate's).

Reads the snapshot's corpus/source-fetches.tsv, classifies each col16 by the
frozen rule, and recomputes raw sha256 / byte count / normalized digest / quote
location with the lane's rendered-text-v1.py. Prints the four-number line the
gate must print, plus per-row diffs.
"""
import os, re, sys, hashlib, subprocess

snap = sys.argv[1]
tsv = os.path.join(snap, "corpus/source-fetches.tsv")
norm = os.path.join(snap, "corpus/rendered-text-v1.py")

def sha256(p):
    h = hashlib.sha256()
    with open(p, "rb") as f:
        for b in iter(lambda: f.read(1 << 20), b""): h.update(b)
    return h.hexdigest()

def classify(loc):
    shaped = bool(loc) and "/" in loc and bool(re.fullmatch(r"[A-Za-z0-9._][A-Za-z0-9._/-]*", loc))
    if loc.startswith("/") or loc.startswith("../"):
        return "path"
    toks = loc.split()
    haspath = any(".ufo/waves/" in t for t in toks)
    hasbad = any(t.startswith("~/") or t.startswith("//") for t in toks)
    if not haspath and not hasbad:
        return "prose"
    if shaped:
        return "path"
    t = loc.strip()
    if t and re.fullmatch(r"[A-Za-z0-9._][A-Za-z0-9._/-]*", t) and loc != t:
        return "whitespace"
    if "\r" in loc and re.fullmatch(r"[A-Za-z0-9._][A-Za-z0-9._/-]*", loc.rstrip("\r")):
        return "whitespace"
    if "," in t and ".ufo/waves/" in t and " " not in t:
        return "whitespace"
    return "token"

def locate_count(body, quote):
    r = subprocess.run(["python3", norm, "locate", body, quote], capture_output=True, text=True)
    if r.returncode != 0:
        return -1
    m = re.search(r"count=(\d+)", r.stdout)
    return int(m.group(1)) if m else -1

def norm_digest(body):
    r = subprocess.run(["python3", norm, "digest", body], capture_output=True, text=True)
    m = re.search(r"normalized_sha256=([0-9a-f]{64})", r.stdout)
    return m.group(1) if m else None

counts = {"path": 0, "prose": 0, "whitespace": 0, "token": 0}
bound = located = col15ok = 0
diffs = []
rows = 0
with open(tsv, "rb") as f:
    data = f.read().decode("utf-8", "surrogateescape")
for line in data.split("\n"):
    if not line or line.startswith("#"):
        continue
    p = line.split("\t")
    if len(p) != 16 or not p[0].startswith("S"):
        continue
    rows += 1
    sid, ssha, sbytes, quote, snorm, snsha, loc = p[0], p[9], p[10], p[12], p[13], p[14], p[15]
    cls = classify(loc)
    counts[cls] += 1
    if cls != "path":
        continue
    path = os.path.join(snap, loc)
    real = os.path.realpath(path)
    root = os.path.realpath(snap)
    if not (real == root or real.startswith(root + os.sep)):
        diffs.append((sid, "outside-root", loc)); continue
    if not (os.path.exists(path) and os.path.isfile(path)):
        diffs.append((sid, "missing", loc)); continue
    size = os.path.getsize(path)
    got = sha256(path)
    if str(size) != sbytes or got != ssha:
        diffs.append((sid, f"bytes/digest size={size} want={sbytes}", loc)); continue
    bound += 1
    if snorm == "rendered-text-v1":
        nd = norm_digest(path)
        if nd == snsha:
            col15ok += 1
        else:
            diffs.append((sid, f"col15 recompute {nd} != {snsha}", loc))
    if locate_count(path, quote) >= 1:
        located += 1
    else:
        diffs.append((sid, "quote-not-located", loc))

print(f"rows={rows} class={counts}")
print(f"path_rows={counts['path']} bound={bound} located={located} prose={counts['prose']}")
print(f"col15(recomputed==declared, rendered rows)={col15ok}")
for d in diffs:
    print("DIFF", *d)
