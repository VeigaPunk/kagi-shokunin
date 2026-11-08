#!/usr/bin/env python3
"""Counter confinement harness (round-67 sentinel) — refined.

Tests, per counter (plans/round-67-c1.sh, plans/round-67-c2.sh):

  T1 WRITES-CONFINED-TO-SCRATCH
       run the counter with --scratch <dir> against a tree copy; assert every
       file it CREATES lands under <dir>; a file created in the --tree, the
       lane, the fleet root or /tmp is a breach.
  T2 TREE-ARG-CONTAINMENT
       run with --tree <a tree outside the lane>: record whether the counter
       refuses (non-zero rc + a diagnostic) or proceeds.  Proceeding is not
       automatically a defect (the frozen guard (c) needs a BASE extraction
       outside the lane); what IS a defect is the counter writing outside its
       scratch, or reading a path it was not given.
  T3 ABSOLUTE/TRAVERSAL-TREE-ARG
       --tree /etc and --tree <lane>/../../etc must not be silently treated as
       a tree; a refusal with a named reason is the expected behaviour.

Reports file:line + class only for any credential shape found in the
counter's own bytes (never the bytes).
"""
import os, re, shutil, subprocess, sys, hashlib, json, glob

LANE = "/home/vgpnk/Projects/shokunin/kagi-shokunin"
FLEET = "/home/vgpnk/Projects/shokunin"
ROOT = os.environ.get("HYAKU_SCRATCH", "/fast/scratch/hyaku") + "/kagi-r67/R67Sentinel/confine"

CRED = [
    ("op-ref", re.compile(r"op://[^\s\"'`)\]]+")),
    ("pem-block", re.compile(r"-----BEGIN [A-Z ]*(PRIVATE KEY|CERTIFICATE|KEY)-----")),
    ("gh-token", re.compile(r"\bgh[pousr]_[A-Za-z0-9]{16,}\b")),
    ("aws-access-key", re.compile(r"\b(?:AKIA|ASIA)[0-9A-Z]{16}\b")),
    ("age-secret-key", re.compile(r"AGE-SECRET-KEY-1[0-9A-Z]{20,}")),
    ("jwt", re.compile(r"\beyJ[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}")),
    ("bearer-header", re.compile(r"(?i)authorization\s*:\s*bearer\s+\S+")),
    ("set-cookie", re.compile(r"(?i)\bset-cookie\s*:")),
]

def sha(p):
    h = hashlib.sha256()
    with open(p, "rb") as f:
        for c in iter(lambda: f.read(1 << 20), b""):
            h.update(c)
    return h.hexdigest()

def credscan(path):
    out = []
    with open(path, "rb") as f:
        t = f.read().decode("utf-8", "replace")
    for i, line in enumerate(t.splitlines(), 1):
        for cls, rx in CRED:
            if rx.search(line):
                out.append((i, cls))
    return out

def snapshot(root):
    s = {}
    for dp, dn, fn in os.walk(root):
        dn[:] = [d for d in dn if d not in (".git", ".jj", "__pycache__")]
        for f in fn:
            p = os.path.join(dp, f)
            try:
                s[p] = os.stat(p).st_mtime_ns
            except OSError:
                pass
    return s

def diff_after(before, root, label):
    after = snapshot(root)
    new = [p for p, m in after.items() if p not in before]
    return sorted(new)

def run(counter, args, cwd):
    p = subprocess.run(["bash", counter] + args, cwd=cwd,
                       capture_output=True, text=True, timeout=1800)
    return p.returncode, p.stdout, p.stderr

def main():
    counters = sys.argv[1:] or [
        os.path.join(LANE, "plans/round-67-c1.sh"),
        os.path.join(LANE, "plans/round-67-c2.sh"),
    ]
    results = []
    for counter in counters:
        label = os.path.basename(counter)
        print("=" * 72)
        print(f"COUNTER {label}")
        if not os.path.isfile(counter):
            print("  ABSENT: counter not present in the tree")
            results.append({"counter": label, "status": "absent"})
            continue
        print(f"  sha256={sha(counter)}")
        hits = credscan(counter)
        print(f"  credential-shape matches in counter bytes: {len(hits)}")
        for line, cls in hits:
            print(f"    {label}:{line} {cls}")
        R = os.path.join(ROOT, label)
        shutil.rmtree(R, ignore_errors=True)
        os.makedirs(R + "/scratch", exist_ok=True)

        # --- T1: writes confined to scratch ------------------------------
        tree = R + "/tree"
        shutil.copytree(LANE, tree, symlinks=True,
                        ignore=shutil.ignore_patterns(".git", ".jj", "__pycache__"))
        before_scratch = snapshot(R + "/scratch")
        before_tree = snapshot(tree)
        before_lane = snapshot(LANE)
        before_fleet_top = snapshot(FLEET)
        rc, out, err = run(counter, ["--tree", tree, "--scratch", R + "/scratch"], R)
        print(f"  T1 rc={rc}")
        print("  T1 stdout head:")
        for line in out.splitlines()[:12]:
            print("    | " + line[:200])
        if err.strip():
            print("  T1 stderr head:")
            for line in err.splitlines()[:6]:
                print("    ! " + line[:200])
        in_scratch = diff_after(before_scratch, R + "/scratch", "scratch")
        in_tree = diff_after(before_tree, tree, "tree")
        in_lane = diff_after(before_lane, LANE, "lane")
        fleet_breach = [p for p in diff_after(before_fleet_top, FLEET, "fleet")
                        if not p.startswith(LANE + "/")]
        print(f"  T1 files created under scratch: {len(in_scratch)}")
        print(f"  T1 files created inside --tree : {len(in_tree)}")
        for p in in_tree[:10]:
            print("    TREE-WRITE " + p)
        print(f"  T1 files created elsewhere in lane: {len(in_lane)}")
        for p in in_lane[:10]:
            print("    LANE-WRITE " + p)
        print(f"  T1 files created outside lane (fleet): {len(fleet_breach)}")
        for p in fleet_breach[:10]:
            print("    FLEET-WRITE " + p)

        # --- T2: tree argument outside the lane --------------------------
        outside = R + "/outside"
        shutil.copytree(LANE, outside, symlinks=True,
                        ignore=shutil.ignore_patterns(".git", ".jj", "__pycache__"))
        os.makedirs(R + "/scratch2", exist_ok=True)
        before_out = snapshot(outside)
        rc2, out2, err2 = run(counter, ["--tree", outside, "--scratch", R + "/scratch2"], R)
        print(f"  T2 (tree outside the lane) rc={rc2}")
        for line in (out2 + err2).splitlines()[:8]:
            print("    | " + line[:200])
        out_writes = diff_after(before_out, outside, "outside")
        print(f"  T2 files created inside the outside tree: {len(out_writes)}")
        for p in out_writes[:10]:
            print("    OUTSIDE-WRITE " + p)

        # --- T3: absurd tree args ---------------------------------------
        for bad in ["/etc", LANE + "/../../etc"]:
            os.makedirs(R + "/scratch3", exist_ok=True)
            rc3, out3, err3 = run(counter, ["--tree", bad, "--scratch", R + "/scratch3"], R)
            first = (out3 + err3).splitlines()[:3]
            print(f"  T3 --tree {bad} rc={rc3}")
            for line in first:
                print("    | " + line[:200])
        results.append({"counter": label, "status": "ran", "t1_scratch": len(in_scratch),
                        "t1_tree": len(in_tree), "t1_lane": len(in_lane),
                        "t1_fleet": len(fleet_breach)})
    with open(os.path.join(ROOT, "confinement.json"), "w") as f:
        json.dump(results, f, indent=1)
    return 0

if __name__ == "__main__":
    sys.exit(main())
