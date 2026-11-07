#!/usr/bin/env python3
"""Round-54 C1 counter mutation driver.

For each single-point mutant: fresh `git clone --shared` lane at ede4373,
install the mutant counter, run plans/round-54-controls.sh, parse the
CONTROL lines, restore pristine bytes, verify the restore hash.
"""
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import time
from concurrent.futures import ThreadPoolExecutor

S = "/fast/scratch/hyaku/kagi-r54/R54MutCounter"
ORIG = "/home/vgpnk/Projects/shokunin/kagi-shokunin"
REV = "ede4373afa07a33e24cbd35e9fd33fc2fddf2f14"
PRISTINE = os.path.join(S, "c1.pristine.sh")
PRISTINE_SHA = "df3d67463c29aaa94d302b4125a70aaa6ad0228aca8f5459394333a571ba82ba"
CTRL_SHA = "5839275f4609abb808b1f2984d3cbc2d5c461c38f29b891a9defeb8dc18d5000"
PY = open(PRISTINE, encoding="utf-8").read()

MUTANTS = [
 ("M01", "s072 recheck conjunct dropped (S072 may keep `180d`)",
  '    if r["recheck"] != "on-release": return "s072-recheck=" + r["recheck"]',
  '    pass  # M01'),
 ("M02", "clock anchor conjunct dropped (anchored != 2.41.1 passes)",
  '    if anch != ANCHOR: return "clock-anchor"',
  '    pass  # M02'),
 ("M03", "clock observed conjunct dropped (observed != 2.42.0 passes)",
  '    if obsv != V: return "clock-observed=" + obsv',
  '    pass  # M03'),
 ("M04", "clock verdict conjunct dropped (verdict != `fired` passes)",
  '    if verdict != "fired": return "clock-verdict=" + verdict',
  '    pass  # M04'),
 ("M05", "feed-url uniqueness conjunct dropped (by_url == [fsid])",
  '    if by_url(reg, OPFEED) != [fsid]: return "feed-url-rows"',
  '    pass  # M05'),
 ("M06", "receipt path pin dropped (only DEFAULT_RECEIPT_SHA256 line required)",
  '    if len(m1) != 1 or len(m2) != 1: return "receipt-unnamed"',
  '    if len(m1) != 1: return "receipt-unnamed"  # M06'),
 ("M07", "receipt sha256-vs-digest check dropped",
  '    if hashlib.sha256(raw).hexdigest() != m1[0]: return "receipt-sha"',
  '    pass  # M07'),
 ("M08", "receipt body link dropped (record sha256 need not equal CAPSHA)",
  '    if o.get("sha256") != CAPSHA: return "receipt-body-link"',
  '    pass  # M08'),
 ("M09", "observed_at window dropped (FLOOR <= t <= ASOF)",
  '    if not FLOOR <= e <= asof: return "receipt-time-window"',
  '    pass  # M09'),
 ("M10", "symlink refusal dropped in plain_file()",
  '        if p.is_symlink():\n            return None',
  '        if False:  # M10\n            return None'),
 ("M11", "gate parse_latest_version result check dropped",
  '    if got != V: return "parse=" + str(got)',
  '    pass  # M11'),
 ("M12", "gate CLEAN line check dropped (gate != 1 passes)",
  '    if gate != "1": return "gate"',
  '    pass  # M12'),
 ("M13", "op receipt `op_version=V` line requirement dropped",
  '("op_version=" + V, "gpg_validsig=" + KEY, "probe_sha256=" + probe_sha,',
  '("gpg_validsig=" + KEY, "probe_sha256=" + probe_sha,'),
 ("M14", "op receipt `gpg_validsig=KEY` line requirement dropped",
  '("op_version=" + V, "gpg_validsig=" + KEY, "probe_sha256=" + probe_sha,',
  '("op_version=" + V, "probe_sha256=" + probe_sha,'),
 ("M15", "op receipt `probe_sha256=` line requirement dropped",
  '("op_version=" + V, "gpg_validsig=" + KEY, "probe_sha256=" + probe_sha,',
  '("op_version=" + V, "gpg_validsig=" + KEY,'),
 ("M16", "exact six DOTENV_BYTES_CASE set check dropped",
  '    if sorted(cases) != sorted(want): return "oprcpt-cases"',
  '    pass  # M16'),
 ("M17", "entry `### 11.2` heading check dropped",
  '    if not re.search(r"^### 11\\.2\\b", s, re.M): return "entry-no-11.2"',
  '    pass  # M17'),
 ("M18", "GUARD probe-byte equality (cmp -s against BASE) dropped",
  'cmp -s "$SCR/b/op-ref-probe.sh" "$T/corpus/op-ref-probe.sh"',
  'true'),
 ("M19", "GUARD selftest PASS requirement dropped (guard=1 if probe equal)",
  '  [ "$src" -eq 0 ] && [[ $slast == "RELEASE_CLOCK_SELFTEST: PASS"* ]] && guard=1',
  '  guard=1  # M19'),
]


def sha(b):
    return hashlib.sha256(b).hexdigest()


def shell(*argv, **kw):
    return subprocess.run(argv, capture_output=True, text=True, **kw)


def run_one(m):
    mid, desc, old, new = m
    t0 = time.time()
    src = PY
    if src.count(old) != 1:
        return {"id": mid, "mutation": desc, "error": "anchor count %d" % src.count(old)}
    mut = src.replace(old, new)
    mut_bytes = mut.encode()
    mutfile = os.path.join(S, "mutants", mid + ".sh")
    os.makedirs(os.path.dirname(mutfile), exist_ok=True)
    with open(mutfile, "wb") as f:
        f.write(mut_bytes)
    syn = shell("bash", "-n", mutfile)
    d = os.path.join(S, "w_" + mid)
    shutil.rmtree(d, ignore_errors=True)
    c = shell("git", "clone", "-q", "--shared", ORIG, d)
    if c.returncode != 0:
        return {"id": mid, "mutation": desc, "error": "clone: " + c.stderr.strip()}
    top = shell("git", "-C", d, "rev-parse", "--show-toplevel").stdout.strip()
    if top != d:
        return {"id": mid, "mutation": desc, "error": "toplevel mismatch %r" % top}
    c = shell("git", "-C", d, "checkout", "-q", REV)
    if c.returncode != 0:
        return {"id": mid, "mutation": desc, "error": "checkout: " + c.stderr.strip()}
    ctr = os.path.join(d, "plans/round-54-controls.sh")
    if sha(open(ctr, "rb").read()) != CTRL_SHA:
        return {"id": mid, "mutation": desc, "error": "controls sha differs"}
    with open(os.path.join(d, "plans/round-54-c1.sh"), "wb") as f:
        f.write(mut_bytes)
    env = dict(os.environ, HYAKU_SCRATCH="/fast/scratch/hyaku")
    p = subprocess.run(["bash", ctr], cwd=d, capture_output=True, text=True,
                       env=env, timeout=900)
    out = p.stdout + p.stderr
    # restore exact pristine bytes in the scratch lane and verify
    with open(os.path.join(d, "plans/round-54-c1.sh"), "wb") as f:
        f.write(PY.encode())
    restored_sha = sha(open(os.path.join(d, "plans/round-54-c1.sh"), "rb").read())
    lines = out.splitlines()
    controls = []
    for i, ln in enumerate(lines):
        mctrl = re.match(r"CONTROL (\S+) expect=(\S+) got=(\S+) (MATCH|MISMATCH)", ln)
        if not mctrl:
            continue
        detail = lines[i + 1].strip() if i + 1 < len(lines) and "C1_OP_CLOCK" in lines[i + 1] else ""
        controls.append({"id": mctrl.group(1), "expect": mctrl.group(2),
                         "got": mctrl.group(3), "verdict": mctrl.group(4),
                         "detail": detail})
    mism = [c for c in controls if c["verdict"] != "MATCH"]
    summary = next((l for l in lines if l.startswith("CONTROLS:")), "")
    return {"id": mid, "mutation": desc, "mutfile": mutfile,
            "mut_sha256": sha(mut_bytes), "bash_n_rc": syn.returncode,
            "rc": p.returncode, "controls": controls, "mismatch": mism,
            "n_controls": len(controls), "summary": summary,
            "killed": bool(mism) or len(controls) != 16,
            "restored_sha256": restored_sha,
            "restore_ok": restored_sha == PRISTINE_SHA,
            "elapsed_s": round(time.time() - t0, 1),
            "raw_tail": lines[-1] if lines else ""}


def main():
    results = []
    with ThreadPoolExecutor(max_workers=6) as ex:
        for r in ex.map(run_one, MUTANTS):
            results.append(r)
            print(json.dumps({k: r.get(k) for k in
                              ("id", "killed", "n_controls", "summary",
                               "restore_ok", "elapsed_s", "error")},
                             ensure_ascii=False), flush=True)
    results.sort(key=lambda r: r["id"])
    with open(os.path.join(S, "mutation-results.json"), "w", encoding="utf-8") as f:
        json.dump(results, f, indent=2, ensure_ascii=False, sort_keys=True)
    k = sum(1 for r in results if r.get("killed"))
    print("MUTANTS: %d killed=%d survived=%d" % (len(results), k, len(results) - k))


if __name__ == "__main__":
    main()
