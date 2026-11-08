#!/usr/bin/env python3
"""Write-scope auditor for round-67.

Lists every path modified under the fleet root and every sibling lane since
the wave launch timestamp, and flags anything outside the lane's allowed
write set.
"""
import os, sys, time, json, subprocess

LANE = "/home/vgpnk/Projects/shokunin/kagi-shokunin"
FLEET = "/home/vgpnk/Projects/shokunin"
ALLOWED_PREFIXES = [
    LANE + "/.ufo/waves/round-67",
    LANE + "/plans",
    LANE + "/corpus",
]
ALLOWED_EXACT = [
    LANE + "/SCORECARD.md",
    LANE + "/SKILL.md",
    LANE + "/PROVINCE.md",
    LANE + "/LOG.md",
]
SKIP_DIRS = {".git", ".jj", "node_modules", "__pycache__", ".venv", "target", "dist"}

def scan(root, since, out):
    for dp, dn, fn in os.walk(root):
        dn[:] = [d for d in dn if d not in SKIP_DIRS]
        for f in fn:
            p = os.path.join(dp, f)
            try:
                st = os.stat(p)
            except OSError:
                continue
            if st.st_mtime >= since:
                out.append((st.st_mtime, p, st.st_size))

def allowed(p):
    if p in ALLOWED_EXACT:
        return True
    for pre in ALLOWED_PREFIXES:
        if p.startswith(pre + "/") or p == pre:
            return True
    return False

def main():
    since = float(sys.argv[1])
    out = []
    scan(FLEET, since, out)
    out.sort()
    print(f"WINDOW_SINCE={time.strftime('%Y-%m-%dT%H:%M:%S', time.localtime(since))}")
    print(f"TOTAL_MODIFIED={len(out)}")
    print("--- lane-allowed ---")
    for m, p, s in out:
        if allowed(p):
            print(f"OK      {p}")
    print("--- OUTSIDE lane-allowed ---")
    n = 0
    for m, p, s in out:
        if not allowed(p):
            n += 1
            print(f"OUTSIDE {p}")
    print(f"OUTSIDE_COUNT={n}")
    return 0

if __name__ == "__main__":
    sys.exit(main())
