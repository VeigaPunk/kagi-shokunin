#!/usr/bin/env python3
"""Build a lean, frozen snapshot of the lane for the R68Revenger battery.

Subset = corpus/ + .ufo/waves/*/capture/ + .ufo/prompts/ (if present).
The census gate reads only: corpus/SOURCES.md, corpus/knowledge/,
corpus/source-fetches.tsv, corpus/inrow-pins.tsv and the capture bodies named
by col16. Everything else in the lane is not an input to the verdict.
"""
import os, shutil, subprocess, sys, hashlib, json

S = os.environ.get("REVENGER_SCRATCH", "/fast/scratch/hyaku/kagi-r68/R68Revenger")
LANE = "/home/vgpnk/Projects/shokunin/kagi-shokunin"
BASE_SHA = "d3b2a4e8eed710277951e430efd3d27b5983033c"

def sha(p):
    h = hashlib.sha256()
    with open(p, "rb") as f:
        for b in iter(lambda: f.read(1 << 20), b""): h.update(b)
    return h.hexdigest()

def build(dest):
    shutil.rmtree(dest, ignore_errors=True)
    os.makedirs(dest)
    shutil.copytree(os.path.join(LANE, "corpus"), os.path.join(dest, "corpus"), symlinks=True)
    waves = os.path.join(LANE, ".ufo/waves")
    n = 0
    for dirpath, dirnames, filenames in os.walk(waves):
        rel = os.path.relpath(dirpath, LANE)
        if "/round-" in rel and any(x in os.path.basename(dirpath) for x in ("capture", "capture-r")):
            # copy every capture-bearing directory wholesale
            out = os.path.join(dest, rel)
            if not os.path.isdir(out):
                shutil.copytree(dirpath, out, symlinks=True)
                n += 1
    # also copy every capture body a registry row names (belt and braces)
    for line in open(os.path.join(LANE, "corpus/source-fetches.tsv"), encoding="utf-8", errors="surrogateescape"):
        parts = line.split("\t")
        if len(parts) < 16: continue
        for tok in parts[15].split():
            if tok.startswith(".ufo/waves/"):
                s = os.path.join(LANE, tok); d = os.path.join(dest, tok)
                if os.path.exists(s) and not os.path.exists(d):
                    os.makedirs(os.path.dirname(d), exist_ok=True)
                    shutil.copy2(s, d)
    for extra in (".ufo/prompts", "AGENTS.md", "SKILL.md"):
        p = os.path.join(LANE, extra)
        if os.path.isdir(p):
            shutil.copytree(p, os.path.join(dest, extra), symlinks=True)
        elif os.path.isfile(p):
            shutil.copy2(p, os.path.join(dest, extra))
    return dest

def extract_base(dest):
    shutil.rmtree(dest, ignore_errors=True); os.makedirs(dest)
    tar = os.path.join(S, "base.tar")
    with open(tar, "wb") as f:
        subprocess.run(["git", "-C", LANE, "archive", BASE_SHA], stdout=f, check=True)
    subprocess.run(["tar", "-x", "-f", tar, "-C", dest], check=True)
    os.remove(tar)

def main():
    name = sys.argv[1] if len(sys.argv) > 1 else "snap"
    dest = os.path.join(S, name)
    build(dest)
    gate = os.path.join(dest, "corpus/sources-census.sh")
    meta = {
        "gate_sha256": sha(gate),
        "tsv_sha256": sha(os.path.join(dest, "corpus/source-fetches.tsv")),
        "sources_md_sha256": sha(os.path.join(dest, "corpus/SOURCES.md")),
        "normalizer_sha256": sha(os.path.join(dest, "corpus/rendered-text-v1.py")),
        "base_sha": BASE_SHA,
    }
    with open(os.path.join(dest, "SNAPSHOT.json"), "w") as f:
        json.dump(meta, f, indent=1)
    print(json.dumps(meta, indent=1))
    # clean run + selftest on the snapshot
    r = subprocess.run(["bash", "corpus/sources-census.sh", "verify", "--root", "."],
                       cwd=dest, capture_output=True, text=True)
    for l in (r.stdout + r.stderr).splitlines():
        if l.startswith(("SOURCES_CAPTURES:", "SOURCES_CENSUS:", "FINDING")):
            print(" ", l)
    print("  rc=", r.returncode)
    st = subprocess.run(["bash", "corpus/sources-census.sh", "--selftest"],
                        cwd=dest, capture_output=True, text=True)
    tail = (st.stdout + st.stderr).strip().splitlines()[-1:]
    print("  selftest:", tail[0] if tail else "<none>", "rc=", st.returncode)

if __name__ == "__main__":
    main()
