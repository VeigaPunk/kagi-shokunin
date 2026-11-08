#!/usr/bin/env python3
"""Round-delta credential scanner for round-67.

Scans only the files this round CREATES or MODIFIES relative to BASE
(076701a11a58e3eb58d996b4c76c5e18071fb179) inside the kagi lane, plus every
file under .ufo/waves/round-67/ (all untracked at BASE).

Reports file:line and CLASS only. Never the matched bytes.
Also classifies a match as NEW-CLASS if the class had zero occurrences at BASE.
"""
import os, subprocess, sys, json

LANE = "/home/vgpnk/Projects/shokunin/kagi-shokunin"
BASE = "076701a11a58e3eb58d996b4c76c5e18071fb179"
SCRATCH = os.environ.get("SCRATCH", "/fast/scratch/hyaku/kagi-r67/R67Sentinel")
sys.path.insert(0, os.path.join(SCRATCH, "bin"))

from credscan import scan_file  # noqa: E402

def classify_text(text, path):
    return scan_file(path)

def scan_path(p):
    try:
        with open(p, "rb") as f:
            data = f.read()
    except OSError:
        return []
    try:
        text = data.decode("utf-8")
    except UnicodeDecodeError:
        text = data.decode("utf-8", "replace")
    return classify_text(text, p)

def git(*args):
    return subprocess.run(["git", "-C", LANE] + list(args),
                          capture_output=True, text=True).stdout

def main():
    # 1. files tracked at BASE
    base_files = set(git("ls-tree", "-r", "--name-only", BASE).splitlines())
    # 2. files changed now (tracked modified + untracked, excluding .git)
    st = git("status", "--porcelain", "--untracked-files=all")
    changed = set()
    for line in st.splitlines():
        if len(line) < 4:
            continue
        p = line[3:].strip()
        if " -> " in p:
            p = p.split(" -> ")[-1]
        p = p.strip('"')
        changed.add(p)
    new_or_changed = sorted(p for p in changed if p)
    # 3. everything under .ufo/waves/round-67/ (untracked at BASE by definition)
    wave = []
    for dp, dn, fn in os.walk(os.path.join(LANE, ".ufo/waves/round-67")):
        dn[:] = [d for d in dn if d not in (".git", "__pycache__")]
        for f in fn:
            wave.append(os.path.relpath(os.path.join(dp, f), LANE))
    targets = sorted(set(new_or_changed) | set(wave))
    print(f"BASE_FILES={len(base_files)}")
    print(f"CHANGED_OR_NEW={len(new_or_changed)}")
    print(f"WAVE_FILES={len(wave)}")
    print(f"SCAN_TARGETS={len(targets)}")
    total = 0
    per_class = {}
    rows = []
    for rel in targets:
        ap = os.path.join(LANE, rel)
        if not os.path.isfile(ap):
            continue
        for cls, line, _ in scan_path(ap):
            total += 1
            per_class[cls] = per_class.get(cls, 0) + 1
            rows.append((rel, line, cls, rel in base_files))
    print(f"SHAPE_MATCHES={total}")
    for cls in sorted(per_class):
        print(f"CLASS {cls} {per_class[cls]}")
    print("--- per-match (relpath:line class) ---")
    for rel, line, cls, was_tracked in rows:
        tag = "BASE-TRACKED" if was_tracked else "NEW-FILE"
        print(f"{rel}:{line} {cls} [{tag}]")
    # save machine-readable
    with open(os.path.join(SCRATCH, "out", "credscan-delta.json"), "w") as f:
        json.dump({"targets": targets, "matches": [
            {"file": r, "line": l, "class": c, "base_tracked": b} for r, l, c, b in rows]}, f, indent=1)
    return 0

if __name__ == "__main__":
    sys.exit(main())
