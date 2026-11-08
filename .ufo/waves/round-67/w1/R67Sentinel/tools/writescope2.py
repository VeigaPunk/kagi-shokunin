#!/usr/bin/env python3
"""Write-scope auditor v2 for round-67.

Categorises every path modified under the fleet root since the wave launch:
  - KAGI-LANE-ALLOWED : under the kagi lane's allowed write set
  - KAGI-LANE-OTHER   : under the kagi lane but NOT allowed (a kagi seat wrote out of scope)
  - OTHER-LANE        : under a sibling lane (concurrent rounds; not attributable to kagi
                        unless the bytes name kagi/round-67)
  - FLEET-ROOT        : directly under the fleet root (never-edit fleet paths)
"""
import os, sys, time

LANE = "/home/vgpnk/Projects/shokunin/kagi-shokunin"
FLEET = "/home/vgpnk/Projects/shokunin"
ALLOWED_PREFIXES = [
    LANE + "/.ufo/waves/round-67",
    LANE + "/plans",
    LANE + "/corpus",
]
ALLOWED_EXACT = [
    LANE + "/SCORECARD.md", LANE + "/SKILL.md",
    LANE + "/PROVINCE.md", LANE + "/LOG.md",
]
SKIP_DIRS = {".git", ".jj", "node_modules", "__pycache__", ".venv", "target", "dist"}

def allowed(p):
    if p in ALLOWED_EXACT: return True
    return any(p.startswith(pre + "/") or p == pre for pre in ALLOWED_PREFIXES)

def main():
    since = float(sys.argv[1])
    cats = {"KAGI-LANE-ALLOWED": [], "KAGI-LANE-OTHER": [], "OTHER-LANE": [], "FLEET-ROOT": []}
    for dp, dn, fn in os.walk(FLEET):
        dn[:] = [d for d in dn if d not in SKIP_DIRS]
        for f in fn:
            p = os.path.join(dp, f)
            try: st = os.stat(p)
            except OSError: continue
            if st.st_mtime < since: continue
            rel = os.path.relpath(p, FLEET)
            top = rel.split(os.sep)[0]
            if p.startswith(LANE + "/"):
                k = "KAGI-LANE-ALLOWED" if allowed(p) else "KAGI-LANE-OTHER"
            elif top.endswith("-shokunin"):
                k = "OTHER-LANE"
            else:
                k = "FLEET-ROOT"
            cats[k].append((st.st_mtime, p, st.st_size))
    for k in ("KAGI-LANE-ALLOWED", "KAGI-LANE-OTHER", "FLEET-ROOT"):
        print(f"=== {k} ({len(cats[k])}) ===")
        for m, p, s in sorted(cats[k]):
            print(f"  {p}")
    print(f"=== OTHER-LANE ({len(cats['OTHER-LANE'])}) — concurrent rounds, summarised by lane ===")
    bylane = {}
    for m, p, s in cats["OTHER-LANE"]:
        bylane.setdefault(p.split("/")[4], []).append(p)
    for lane in sorted(bylane):
        print(f"  {lane}: {len(bylane[lane])} files")
    return 0

if __name__ == "__main__":
    sys.exit(main())
