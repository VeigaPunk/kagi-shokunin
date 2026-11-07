#!/usr/bin/env python3
"""Round-56 C1 counter mutation driver (seat R56MutCounter).

Builds one mutant tree per id from the reference tree, runs the lane's
plans/round-56-c1.sh --tree on it, and records the reading. Read-only on the lane.
"""
import hashlib
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

S = Path("/fast/scratch/hyaku/kagi-r56/R56MutCounter")
REF = S / "ref"
LANE = Path("/home/vgpnk/Projects/shokunin/kagi-shokunin")
C1 = LANE / "plans/round-56-c1.sh"
M = S / "m"

BL = "corpus/knowledge/betterleaks-detection-vs-validation.md"
TH = "corpus/knowledge/trufflehog-verification-lifecycle.md"
ISO = "corpus/knowledge/iso-11770-3-edition-status.md"
CDP = "corpus/knowledge/cdp-bridge-1password-oidc-workflow.md"
MAN = "corpus/recheck-captures.tsv"
REG = "corpus/SOURCES.md"
GATE = "corpus/recheck-replay.py"
NORM = "corpus/rendered-text-v1.py"
B054 = ".ufo/waves/round-56/capture/S054.body"
B055 = ".ufo/waves/round-56/capture/S055.body"
B057 = ".ufo/waves/round-56/capture/S057.body"
B070 = ".ufo/waves/round-56/capture/S070.body"
B074 = ".ufo/waves/round-56/capture/S074.body"
S113_SHA = "d8dfe35408b17b02845dc0cf19f774bc6cc6b8dcbfe1636e22bb6b13dfa64357"
S113_BYTES = "90604"


def sha(p):
    return hashlib.sha256(Path(p).read_bytes()).hexdigest()


def rd(root, rel):
    return (Path(root) / rel).read_text(encoding="utf-8")


def wr(root, rel, t):
    (Path(root) / rel).write_text(t, encoding="utf-8")


def rdb(root, rel):
    return (Path(root) / rel).read_bytes()


def wrb(root, rel, d):
    (Path(root) / rel).write_bytes(d)


def sub(root, rel, old, new, count=-1, must=True):
    s = rd(root, rel)
    t = s.replace(old, new, count)
    if must:
        assert t != s, "inert edit %s :: %r" % (rel, old[:60])
    wr(root, rel, t)


def manifest_rows(root):
    lines = rd(root, MAN).splitlines()
    hdr = None
    out = []
    for i, l in enumerate(lines):
        if not l.strip() or l.startswith("#"):
            continue
        cols = l.split("\t")
        if hdr is None:
            hdr = cols
            continue
        out.append((i, dict(zip(hdr, cols))))
    return lines, hdr, out


def setrow(root, sid, **kw):
    lines, hdr, rows = manifest_rows(root)
    hit = 0
    for i, row in rows:
        if row["id"] == sid:
            hit += 1
            cols = lines[i].split("\t")
            for k, v in kw.items():
                cols[hdr.index(k)] = str(v)
            lines[i] = "\t".join(cols)
    assert hit == 1, "id %s rows=%d" % (sid, hit)
    wr(root, MAN, "\n".join(lines) + "\n")


def fixdigest(root, body_rel, sid):
    d = rdb(root, body_rel)
    setrow(root, sid, bytes=len(d), sha256=hashlib.sha256(d).hexdigest())


def reg_lines(root):
    return rd(root, REG).splitlines()


def set_reg_row(root, sid, fn):
    lines = reg_lines(root)
    hit = 0
    for i, l in enumerate(lines):
        if l.startswith("| %s |" % sid):
            hit += 1
            cells = [c.strip() for c in l.strip().strip("|").split("|")]
            assert len(cells) == 11, (sid, len(cells))
            fn(cells)
            lines[i] = "| " + " | ".join(cells) + " |"
    assert hit == 1, "registry rows %s=%d" % (sid, hit)
    wr(root, REG, "\n".join(lines) + "\n")


PRINTER = r'''#!/usr/bin/env python3
import sys
LINES = [
"MATCH corpus/knowledge/betterleaks-detection-vs-validation.md:4 id=S055 form=grep stated=1 replayed=1",
"MATCH corpus/knowledge/cdp-bridge-1password-oidc-workflow.md:3 id=S070 form=locate stated=1 replayed=1",
"MATCH corpus/knowledge/iso-11770-3-edition-status.md:3 id=S101 form=grep stated=2 replayed=2",
"MATCH corpus/knowledge/iso-11770-3-edition-status.md:3 id=S113 form=grep stated=3 replayed=3",
"MATCH corpus/knowledge/iso-11770-3-edition-status.md:3 id=S114 form=grep stated=2 replayed=2",
"MATCH corpus/knowledge/nist-key-management-guidance-status.md:3 id=S074 form=grep stated=1 replayed=1",
"MATCH corpus/knowledge/nist-key-management-parts-withdrawal.md:3 id=S078 form=pdf stated=1 replayed=1",
"MATCH corpus/knowledge/oidc-federation-trust-policy.md:3 id=S067 form=grep stated=1 replayed=1",
"MATCH corpus/knowledge/secret-scanning-detection-vs-validation.md:4 id=S054 form=grep stated=1 replayed=1",
"MATCH corpus/knowledge/trufflehog-verification-lifecycle.md:4 id=S057 form=grep stated=1 replayed=1",
]
if sys.argv[1:2] == ["--selftest"]:
    print("RECHECK_REPLAY_SELFTEST: PASS (13 cases)")
    sys.exit(0)
for l in LINES:
    print(l)
print("RECHECK_REPLAY: CLEAN (clocks=10 match=10 mismatch=0 no_capture=0 bad_capture=0 unsupported=0 tool=0)")
sys.exit(RC)
'''


def mut_R1a(r):
    s = rd(r, TH)
    i = s.find("recheck:")
    j = s.find("\n", i)
    assert i >= 0
    wr(r, TH, s[:i] + "recheck: 180d — on-change — reopen the docs page" + s[j:])
    return [TH]


def mut_R1b(r):
    sub(r, BL, "by default'` -> 1", "by default'` -> 2")
    return [BL]


def mut_R1c(r):
    wr(r, BL, rd(r, BL) + "\nrecheck: 90d — on-change — reopen\n")
    return [BL]


def mut_R1d(r):
    sub(r, BL, "'https://raw.githubusercontent.com/betterleaks/betterleaks/main/README.md'",
        '"https://raw.githubusercontent.com/betterleaks/betterleaks/main/README.md"')
    return [BL]


def mut_R1e(r):
    sub(r, BL, "by default'` -> 1", "by default'` -> count=1")
    return [BL]


def mut_R1f(r):
    sub(r, BL, "by default'` -> 1", "by default'` -> 10")
    return [BL]


def mut_R1g(r):
    sub(r, BL, "(ran 2026-10-23)", "(ran 2026-11-06)")
    return [BL]


def mut_R2a(r):
    lines = rd(r, MAN).splitlines()
    t = [l for l in lines if not l.startswith("S054\t")]
    assert len(t) == len(lines) - 1
    wr(r, MAN, "\n".join(t) + "\n")
    return [MAN]


def mut_R2b(r):
    lines = rd(r, MAN).splitlines()
    row = [l for l in lines if l.startswith("S054\t")]
    assert len(row) == 1
    wr(r, MAN, "\n".join(lines + row) + "\n")
    return [MAN]


def mut_R2c(r):
    wr(r, REG, rd(r, REG) + "\n" + [l for l in reg_lines(r) if l.startswith("| S054 |")][0] + "\n")
    return [REG]


def mut_R2d(r):
    def f(cells):
        assert cells[7] == "mined"
        cells[7] = "staged"
    set_reg_row(r, "S113", f)
    return [REG]


def mut_R2e(r):
    def f(cells):
        u = "https://www.1password.dev/brokered-access/custom-workflow"
        assert u in cells[1].split(), cells[1]
        cells[1] = cells[1].replace(" — " + u, "")
        cells[6] = cells[6] + " " + u
    set_reg_row(r, "S070", f)
    return [REG]


def mut_R2f(r):
    lines = reg_lines(r)
    row = [l for l in lines if l.startswith("| S074 |")]
    assert len(row) == 1
    lines = [l for l in lines if not l.startswith("| S074 |")]
    wr(r, REG, "\n".join(lines + ["```", row[0], "```"]) + "\n")
    return [REG]


def mut_R2g(r):
    sub(r, MAN, "http_status\tbytes\tsha256", "http_status\tsha256\tbytes")
    return [MAN]


def mut_R2h(r):
    setrow(r, "S054", id="S055")
    return [MAN]


def mut_R2i(r):
    setrow(r, "S054", http_status="404", fetched="1999-01-01")
    return [MAN]


def mut_R2j(r):
    setrow(r, "S101", body_path=".ufo/waves/round-55/capture/S113.body",
           bytes=S113_BYTES, sha256=S113_SHA)
    return [MAN]


def mut_R2k(r):
    setrow(r, "S114", body_path=".ufo/waves/round-55/capture/S113.body",
           bytes=S113_BYTES, sha256=S113_SHA)
    return [MAN]


def mut_R3a(r):
    wrb(r, B054, rdb(r, B054) + b"x")
    return [B054]


def mut_R3b(r):
    setrow(r, "S054", body_path=str(Path(r) / B054))
    return [MAN]


def mut_R3c(r):
    setrow(r, "S054", body_path="../../S054.body")
    return [MAN]


def mut_R3d(r):
    src = Path(r) / B055
    dst = Path(r) / "s055.body"
    os.rename(src, dst)
    os.symlink("../../../../s055.body", src)
    return [B055]


def mut_R3e(r):
    wrb(r, B057, b"HTTP/2 200\r\nset-cookie: x=1\r\n\r\n" + rdb(r, B057))
    fixdigest(r, B057, "S057")
    return [B057, MAN]


def mut_R3f(r):
    d = rdb(r, B074)
    h = len(d) // 2
    wrb(r, B074, d[:h] + b"\nSet-Cookie: y=2\n" + d[h:])
    fixdigest(r, B074, "S074")
    return [B074, MAN]


def mut_R3g(r):
    wrb(r, B054, b"it can also log in to confirm if that secret is live or not\n")
    fixdigest(r, B054, "S054")
    return [B054, MAN]


def mut_R4a(r):
    wrb(r, B054, rdb(r, B054) + b"\nit can also log in to confirm if that secret is live or not\n")
    fixdigest(r, B054, "S054")
    return [B054, MAN]


def mut_R4b(r):
    sub(r, CDP, b"The client authenticates using your OIDC token".decode(),
        "The client authenticates using a variant OIDC token")
    fixdigest(r, B070, "S070")
    sub(r, NORM, '        return cmd_locate(argv[1], argv[2])',
        '        print("RENDERED_TEXT_V1_LOCATE: count=1")\n        return 0')
    return [CDP, B070, MAN, NORM]


def mut_R4c(r):
    os.remove(Path(r) / NORM)
    return [NORM]


def mut_R5a(r):
    wr(r, GATE, '#!/usr/bin/env bash\ncase "${1:-}" in --selftest) echo "RECHECK_REPLAY_SELFTEST: PASS (13 cases)";; '
                '*) echo "RECHECK_REPLAY: CLEAN (clocks=10 match=10 mismatch=0 no_capture=0 bad_capture=0 unsupported=0 tool=0)";; esac\nexit 0\n')
    return [GATE]


def _printer(root, rc):
    wr(root, GATE, PRINTER.replace("sys.exit(RC)", "sys.exit(%d)" % rc))


def mut_R5b(r):
    _printer(r, 0)
    return [GATE]


def mut_R5c(r):
    _printer(r, 1)
    return [GATE]


def mut_R5d(r):
    sub(r, GATE,
        '        print("%s %s id=%s form=%s stated=%d replayed=%d" % (verdict, where, row["id"], flt[0], stated, got))',
        '        idv = "S999" if where.startswith("corpus/knowledge/betterleaks") else row["id"]\n'
        '        print("%s %s id=%s form=%s stated=%d replayed=%d" % (verdict, where, idv, flt[0], stated, got))')
    return [GATE]


def mut_R5e(r):
    sub(r, GATE,
        '        print("%s %s id=%s form=%s stated=%d replayed=%d" % (verdict, where, row["id"], flt[0], stated, got))',
        '        formv = "grep" if where.startswith("corpus/knowledge/cdp-bridge") else flt[0]\n'
        '        print("%s %s id=%s form=%s stated=%d replayed=%d" % (verdict, where, row["id"], formv, stated, got))')
    return [GATE]


def mut_R5f(r):
    sub(r, GATE, "        rel = path.relative_to(root).as_posix()",
        "        if path.name.startswith('betterleaks'):\n            continue\n        rel = path.relative_to(root).as_posix()")
    return [GATE]


def mut_R5g(r):
    p = S / "printer-abs.py"
    p.write_text(PRINTER.replace("sys.exit(RC)", "sys.exit(0)"))
    os.remove(Path(r) / GATE)
    os.symlink(str(p), Path(r) / GATE)
    return [GATE, "../printer-abs.py"]


def mut_R5h(r):
    sub(r, GATE, "    return run(root)", "    rc = run(root)\n    return rc if rc else 1")
    return [GATE]


def mut_G1(r):
    sub(r, GATE, '    print("RECHECK_REPLAY_SELFTEST: PASS (%d cases)" % total)\n    return 0',
        '    print("RECHECK_REPLAY_SELFTEST: PASS (%d cases)" % total)\n    return 1')
    return [GATE]


def mut_G2(r):
    sub(r, GATE, '    print("RECHECK_REPLAY_SELFTEST: PASS (%d cases)" % total)',
        '    print("RECHECK_REPLAY_SELFTEST: PASS (%d cases)" % total)\n    print("trailing noise line")')
    return [GATE]


def mut_G3(r):
    sub(r, GATE, "def selftest():\n    cases = []",
        'def selftest():\n    print("RECHECK_REPLAY_SELFTEST: PASS (0 cases)")\n    return 0\n    cases = []')
    return [GATE]


def mut_G4(r):
    os.remove(Path(r) / GATE)
    os.mkdir(Path(r) / GATE)
    return [GATE]


def mut_N2(r):
    os.remove(Path(r) / GATE)
    return [GATE]


MUTS = [
    ("R1a-clock-deleted", mut_R1a, "FAIL"),
    ("R1b-N-restated", mut_R1b, "FAIL"),
    ("R1c-second-recheck-line", mut_R1c, "FAIL"),
    ("R1d-command-bytes-changed", mut_R1d, "FAIL"),
    ("R1e-count-form-allowed", mut_R1e, "10"),
    ("R1f-N-prefix-10", mut_R1f, "FAIL"),
    ("R1g-date-prose-only", mut_R1g, "10"),
    ("R2a-manifest-row-dropped", mut_R2a, "0"),
    ("R2b-manifest-url-duplicated", mut_R2b, "0"),
    ("R2c-registry-row-duplicated", mut_R2c, "9"),
    ("R2d-registry-status-staged", mut_R2d, "9"),
    ("R2e-url-moved-out-of-source", mut_R2e, "9"),
    ("R2f-registry-row-only-fenced", mut_R2f, "9"),
    ("R2g-manifest-header-swapped", mut_R2g, "0"),
    ("R2h-manifest-id-swapped", mut_R2h, "0"),
    ("R2i-forged-http-status", mut_R2i, "10"),
    ("R2j-crosswire-S101-to-S113", mut_R2j, "10"),
    ("R2k-crosswire-S114-to-S113", mut_R2k, "10"),
    ("R3a-body-byte-appended", mut_R3a, "0"),
    ("R3b-body-path-absolute", mut_R3b, "0"),
    ("R3c-body-path-dotdot", mut_R3c, "0"),
    ("R3d-body-symlinked", mut_R3d, "0"),
    ("R3e-http-prefix-digest-fixed", mut_R3e, "0"),
    ("R3f-midfile-setcookie", mut_R3f, "0"),
    ("R3g-handwritten-body", mut_R3g, "10"),
    ("R4a-count-one-too-high", mut_R4a, "0"),
    ("R4b-fake-tree-normaliser", mut_R4b, "9"),
    ("R4c-tree-normaliser-deleted", mut_R4c, "0"),
    ("R5a-clean-printer-gate", mut_R5a, "0"),
    ("R5b-full-printer-gate", mut_R5b, "10"),
    ("R5c-printer-gate-rc1", mut_R5c, "10"),
    ("R5d-gate-id-mutated", mut_R5d, "9"),
    ("R5e-gate-form-mutated", mut_R5e, "9"),
    ("R5f-gate-narrowed-population", mut_R5f, "9"),
    ("R5g-gate-symlink-outside-tree", mut_R5g, "10"),
    ("R5h-gate-rc1-real-source", mut_R5h, "10"),
    ("G1-selftest-rc1", mut_G1, "FAIL"),
    ("G2-selftest-trailing-line", mut_G2, "FAIL"),
    ("G3-selftest-gutted-passes", mut_G3, "10"),
    ("G4-gate-is-directory", mut_G4, "FAIL"),
    ("N2-gate-absent", mut_N2, "0"),
]


def run_counter(tree):
    env = dict(os.environ)
    env["HYAKU_SCRATCH"] = str(S)
    p = subprocess.run(["bash", str(C1), "--tree", str(tree)], capture_output=True,
                       text=True, env=env, timeout=900)
    lines = [l for l in p.stdout.splitlines() if l.strip()]
    return (lines[0] if lines else ""), p.returncode, p.stdout, p.stderr


def main():
    only = sys.argv[1:]
    S.mkdir(parents=True, exist_ok=True)
    M.mkdir(exist_ok=True)
    out = []
    # baselines
    if not only:
        for name, tree in (("P0-ref", REF), ("N0-no-work", None)):
            if tree is None:
                b = S / "base"
                if not b.is_dir():
                    b.mkdir()
                    subprocess.run("git -C %s archive 832ba6a53d6a76706b5c80bce2278683dea33d42 | tar -x -C %s"
                                   % (LANE, b), shell=True, check=True)
                tree = b
            first, rc, stdout, stderr = run_counter(tree)
            out.append({"id": name, "expect": "10" if name.startswith("P") else "0",
                        "first": first, "rc": rc, "changed": []})
            print("%-34s expect=%-4s rc=%d %s" % (name, out[-1]["expect"], rc, first), flush=True)
    for mid, fn, expect in MUTS:
        if only and mid not in only:
            continue
        d = M / mid
        if d.exists():
            shutil.rmtree(d)
        shutil.copytree(REF, d, symlinks=True)
        changed = fn(d)
        hashes = {}
        for rel in changed:
            p = Path(d) / rel
            hashes[rel] = sha(p) if p.is_file() and not p.is_symlink() else (
                "symlink->" + os.readlink(p) if p.is_symlink() else "dir")
        first, rc, stdout, stderr = run_counter(d)
        got = first.split("value=")[1].split()[0] if "value=" in first else "none"
        rec = {"id": mid, "expect": expect, "got": got, "first": first, "rc": rc,
               "changed": hashes, "stderr": stderr[-400:]}
        out.append(rec)
        print("%-34s expect=%-4s got=%-4s rc=%d %s" % (mid, expect, got, rc, first), flush=True)
        with open(S / "results.json", "w") as f:
            json.dump(out, f, indent=1)
    print("pristine ref hashes:", sha(REF / GATE), sha(REF / MAN), sha(C1))


if __name__ == "__main__":
    main()
