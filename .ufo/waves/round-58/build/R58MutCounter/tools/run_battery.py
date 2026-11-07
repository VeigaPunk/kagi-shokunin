#!/usr/bin/env python3
"""Run the C1 mutation battery over a checker-green base tree.

  python3 run_battery.py --base wit02 --checker <path> --out batt01

Each id gets a fresh rsync copy; the checker runs with relocation-parity env
(ADJ_BASIS_ROOT=<mutant>, ADJ_LANE_ROOT=<fleet>) so the I8 leg resolves sibling
lanes as it does at the lane path. `basepl` is the same copy without that env.
"""
import concurrent.futures as cf
import json
import os
import re
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import drive  # noqa: E402

LANE_ROOT = "/home/vgpnk/Projects/shokunin"


def parse(line):
    return dict(re.findall(r"(\w+)=([^\s]+)", line or ""))


def one(args):
    mid, base, checker, out = args
    mu = os.path.join(out, "muts", mid)
    drive.rsync(base, mu)
    if mid in drive.MUT:
        drive.MUT[mid](mu)
    env = dict(os.environ)
    env.pop("ADJ_BASIS_ROOT", None)
    env.pop("ADJ_HOME", None)
    if mid != "basepl":
        env["ADJ_LANE_ROOT"] = LANE_ROOT
        env["ADJ_BASIS_ROOT"] = mu
    env["C1_CHALLENGE_PARENT"] = os.path.join(out, "chal")
    os.makedirs(env["C1_CHALLENGE_PARENT"], exist_ok=True)
    r = subprocess.run([sys.executable, "-I", "-B", checker, "--root", mu, "--verbose"],
                       capture_output=True, text=True, env=env, timeout=1800)
    lines = [x for x in (r.stdout or "").splitlines() if x.strip()]
    last = next((x for x in reversed(lines) if x.startswith("C1_ROUTED:")), "")
    chal = [x for x in lines if x.startswith("CHALLENGE")]
    items = [x for x in lines if x.startswith("ITEM ")]
    rec = {"id": mid, "rc": r.returncode, "line": last, "fields": parse(last),
           "challenge": chal[-1] if chal else "", "items": items,
           "stderr": (r.stderr or "").splitlines()[-3:]}
    with open(os.path.join(out, mid + ".json"), "w") as f:
        json.dump(rec, f, indent=1, sort_keys=True)
    print(json.dumps({k: rec[k] for k in ("id", "rc", "line", "challenge")}, sort_keys=True))
    return rec


def main():
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument("--base", required=True)
    ap.add_argument("--checker", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--ids", default="base,basepl,i1,i2,i3,i4,i5,i6,i7,i8,ga")
    ap.add_argument("--jobs", type=int, default=5)
    a = ap.parse_args()
    os.makedirs(a.out, exist_ok=True)
    ids = a.ids.split(",")
    with cf.ThreadPoolExecutor(max_workers=a.jobs) as ex:
        futs = [ex.submit(one, (i, os.path.abspath(a.base), os.path.abspath(a.checker),
                                os.path.abspath(a.out))) for i in ids]
        for f in cf.as_completed(futs):
            f.result()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
