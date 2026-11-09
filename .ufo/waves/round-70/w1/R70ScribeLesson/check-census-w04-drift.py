#!/usr/bin/env python3
"""check-census-w04-drift.py — M70-3 check: a census-warning count stated in a
report is bound to the REVISION the report names, not to the round-start
receipt.

Usage:
  python3 check-census-w04-drift.py --lane <lane-repo> --rev <rev> \
      --base-receipt <receipt> [--census <path-to-sources-census.sh>]

The check materialises the lane's tree at <rev> into a scratch directory
(`git archive <rev>`), runs the fleet census against that scratch root, and
compares the W04 population it measures with the W04 count in
<base-receipt>. A drift means the base receipt's count no longer describes the
named revision, so a report that repeats the base receipt's number is stale.

The scratch tree is written under the directory given by --scratch (default:
a mktemp dir), never into the lane or the fleet repo.

Exit 0 when the counts agree; 1 on drift; 2 SETUP.
"""
import argparse
import os
import re
import shutil
import subprocess
import sys
import tempfile


def w04_ids(text):
    ids = []
    for line in text.splitlines():
        cells = line.split("\t")
        if len(cells) >= 3 and cells[1].strip() == "W04":
            m = re.match(r"\s*(S\d+)\b", cells[2])
            ids.append(m.group(1) if m else "?")
    return ids


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--lane", required=True)
    ap.add_argument("--rev", required=True)
    ap.add_argument("--base-receipt", required=True)
    ap.add_argument("--census",
                    default="/home/vgpnk/Projects/shokunin/scripts/sources-census.sh")
    ap.add_argument("--lane-name", default="kagi")
    ap.add_argument("--scratch", default=None)
    ap.add_argument("--keep", action="store_true")
    args = ap.parse_args()

    if not os.path.isdir(args.lane):
        print(f"SETUP lane-missing {args.lane}")
        return 2
    if not os.path.isfile(args.census):
        print(f"SETUP census-missing {args.census}")
        return 2
    try:
        with open(args.base_receipt, encoding="utf-8") as fh:
            base_text = fh.read()
    except OSError as exc:
        print(f"SETUP receipt-unreadable {exc}")
        return 2
    base_ids = w04_ids(base_text)

    scratch = args.scratch or tempfile.mkdtemp(prefix="c1-census-drift.")
    tree = os.path.join(scratch, args.lane_name)
    try:
        os.makedirs(tree, exist_ok=True)
        ar = subprocess.run(
            ["git", "-C", args.lane, "archive", args.rev],
            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        if ar.returncode != 0:
            print(f"SETUP git-archive rc={ar.returncode} "
                  f"{ar.stderr.decode('utf-8', 'replace').strip()}")
            return 2
        tar = subprocess.run(["tar", "-x", "-C", tree], input=ar.stdout,
                             stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        if tar.returncode != 0:
            print(f"SETUP untar rc={tar.returncode} "
                  f"{tar.stderr.decode('utf-8', 'replace').strip()}")
            return 2

        proc = subprocess.run(["bash", args.census, "validate",
                               "--root", scratch, tree],
                              stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        out = proc.stdout.decode("utf-8", "replace")
        err = proc.stderr.decode("utf-8", "replace")
        cur_ids = w04_ids(out)

        print(f"REV     {args.rev}  (tree extracted to {tree})")
        print(f"  MEASURED W04 lines={len(cur_ids)} "
              f"(census rc={proc.returncode}, stderr bytes={len(err)})")
        print(f"RECEIPT {args.base_receipt}")
        print(f"  BASE     W04 lines={len(base_ids)}")

        added = [i for i in cur_ids if i not in base_ids]
        removed = [i for i in base_ids if i not in cur_ids]
        if added:
            print(f"  ADDED    ids={added}")
        if removed:
            print(f"  REMOVED  ids={removed}")

        if len(cur_ids) != len(base_ids) or added or removed:
            print(f"CENSUS_DRIFT: FAIL (base={len(base_ids)} rev={len(cur_ids)} "
                  f"added={added} removed={removed})")
            return 1
        print("CENSUS_DRIFT: CLEAN")
        return 0
    finally:
        if not args.keep and not args.scratch:
            shutil.rmtree(scratch, ignore_errors=True)


if __name__ == "__main__":
    sys.exit(main())
