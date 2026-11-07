#!/usr/bin/env python3
"""Follow-up probes for R56MutCounter: corrected normaliser-isolation mutant,
gate-substitution discrimination probe, and printer-mechanism evidence."""
import hashlib
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

S = Path("/fast/scratch/hyaku/kagi-r56/R56MutCounter")
sys.path.insert(0, str(S))
import mutate as m  # noqa: E402

REF, M, LANE, C1 = m.REF, m.M, m.LANE, m.C1
B070 = m.B070
NORM = m.NORM
GATE = m.GATE
OUT = S / "followups.json"


def sha(p):
    return hashlib.sha256(Path(p).read_bytes()).hexdigest()


def run_counter(tree):
    env = dict(os.environ)
    env["HYAKU_SCRATCH"] = str(S)
    p = subprocess.run(["bash", str(C1), "--tree", str(tree)], capture_output=True, text=True,
                       env=env, timeout=900)
    lines = [l for l in p.stdout.splitlines() if l.strip()]
    return lines[0] if lines else "", p.returncode


def fresh(mid):
    d = M / mid
    if d.exists():
        shutil.rmtree(d)
    shutil.copytree(REF, d, symlinks=True)
    return d


def mut_r4b2(r):
    """Doctor the S070 body (quote no longer present) and fake the TREE normaliser;
    leave the BASE normaliser (which r4 uses) untouched."""
    d = Path(r) / B070
    data = d.read_bytes()
    old = b"The client authenticates using your OIDC token"
    assert old in data, "quote absent"
    data = data.replace(old, b"The client authenticates using a variant OIDC token", 1)
    d.write_bytes(data)
    m.fixdigest(r, B070, "S070")
    m.sub(r, NORM, "        return cmd_locate(argv[1], argv[2])",
          '        print("RENDERED_TEXT_V1_LOCATE: count=1")\n        return 0')
    return [B070, m.MAN, NORM]


def main():
    out = {}
    # 0. BASE normaliser count on the doctored body (the value r4 must see)
    d = fresh("R4b2-fake-tree-normaliser-body-only")
    ch = mut_r4b2(d)
    base_norm = S / "base-norm.py"
    if not base_norm.exists():
        subprocess.run("git -C %s show 832ba6a53d6a76706b5c80bce2278683dea33d42:corpus/rendered-text-v1.py > %s"
                       % (LANE, base_norm), shell=True, check=True)
    q = "The client authenticates using your OIDC token, workload ID, and the integration key configured by your administrator"
    bp = subprocess.run([sys.executable, "-I", "-B", str(base_norm), "locate", str(d / B070), q],
                        capture_output=True, text=True)
    tp = subprocess.run([sys.executable, "-I", "-B", str(d / NORM), "locate", str(d / B070), q],
                        capture_output=True, text=True)
    out["R4b2"] = {"changed": {k: sha(d / k) if (d / k).is_file() else "?" for k in ch},
                   "base_normaliser": bp.stdout.strip(), "tree_normaliser": tp.stdout.strip()}
    first, rc = run_counter(d)
    out["R4b2"]["first"], out["R4b2"]["rc"] = first, rc
    print("R4b2 expected=9 got=%s %s" % (first.split("value=")[1].split()[0], first), flush=True)

    # 1. gate-substitution discrimination probe: run each tree's gate on a doctored
    #    copy of itself (append one byte to S054.body) and require rc!=0 + BAD-CAPTURE.
    probe = {}
    for name, tree in (("ref-real-gate", REF),
                       ("R5b-full-printer", M / "R5b-full-printer-gate"),
                       ("R5c-printer-rc1", M / "R5c-printer-gate-rc1"),
                       ("R5g-symlink-printer", M / "R5g-gate-symlink-outside-tree"),
                       ("G3-gutted-selftest", M / "G3-selftest-gutted-passes")):
        if not (tree / "corpus/recheck-replay.py").exists():
            continue
        dd = S / "probe" / name
        if dd.exists():
            shutil.rmtree(dd)
        shutil.copytree(tree, dd, symlinks=True)
        with open(dd / ".ufo/waves/round-56/capture/S054.body", "ab") as f:
            f.write(b"x")
        p = subprocess.run([sys.executable, "-I", "-B", str(dd / "corpus/recheck-replay.py"),
                            "--root", str(dd)], capture_output=True, text=True)
        last = [l for l in p.stdout.splitlines() if l.strip()]
        probe[name] = {"rc": p.returncode, "last": last[-1] if last else "",
                       "bad_capture": "BAD-CAPTURE" in p.stdout}
        print("probe %-22s rc=%d bad_capture=%s last=%s" % (
            name, p.returncode, probe[name]["bad_capture"], probe[name]["last"]), flush=True)
    out["discrimination_probe"] = probe

    # 2. printer mechanism: python3 on the bash CLEAN printer (R5a)
    bashp = M / "R5a-clean-printer-gate" / "corpus/recheck-replay.py"
    p = subprocess.run([sys.executable, "-I", "-B", str(bashp), "--selftest"], capture_output=True, text=True)
    out["R5a_mechanism"] = {"rc": p.returncode, "stderr_tail": p.stderr.strip().splitlines()[-1] if p.stderr.strip() else ""}
    print("R5a via python3 rc=%d %s" % (p.returncode, out["R5a_mechanism"]["stderr_tail"]), flush=True)

    # 3. exact gate stdout of R5b (proves the printer reproduces the real lines)
    g = M / "R5b-full-printer-gate" / "corpus/recheck-replay.py"
    p = subprocess.run([sys.executable, "-I", "-B", str(g), "--root", str(REF)], capture_output=True, text=True)
    out["R5b_output_equals_real"] = (
        p.stdout == subprocess.run([sys.executable, "-I", "-B", str(REF / "corpus/recheck-replay.py"),
                                    "--root", str(REF)], capture_output=True, text=True).stdout)
    print("R5b stdout identical to real gate:", out["R5b_output_equals_real"], flush=True)

    # 4. body-path uniqueness across the real manifest (proposed extra conjunct)
    rows = m.manifest_rows(REF)[2]
    paths = [r["body_path"] for _, r in rows]
    out["manifest_body_paths_unique"] = len(paths) == len(set(paths)) == 10
    out["pairs"] = [(r["id"], r["body_path"]) for _, r in rows]
    print("real manifest body_paths unique:", out["manifest_body_paths_unique"], flush=True)

    OUT.write_text(json.dumps(out, indent=1))
    print("wrote", OUT)


if __name__ == "__main__":
    main()
