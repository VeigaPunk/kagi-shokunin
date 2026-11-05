#!/usr/bin/env python3
"""plans/round-46-controls.py -- pre-freeze controls for the round-46 counters.

Builds fixture trees from the claim BASE (git archive, scratch under
$HYAKU_SCRATCH/kagi-r46/controls.<pid>) and scores each with the frozen counter
(C1_TREE / C2_TREE override). Every control names its independent expected value
before it runs; the receipt line records expected, observed and MATCH/DIFF.
No network: the C2 positive control replays the receipt observed live on
2026-11-06 and kept at .ufo/waves/round-46/controls/c2-positive-observe.json.
Exit 0 when every control matches its expectation, 1 when any differs, 2 setup.
"""
import hashlib, json, os, re, shutil, subprocess, sys, tempfile

LANE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BASE = "f5977284a8ce5bab09252be8196ee5dc18489926"
POS_RECEIPT = os.path.join(LANE, ".ufo/waves/round-46/controls/c2-positive-observe.json")
RECEIPT_REL = ".ufo/waves/round-46/final/observe-r46.json"
ROOT = os.path.join(os.environ.get("HYAKU_SCRATCH", "/fast/scratch/hyaku"), "kagi-r46")


def sh(cmd, **kw):
    return subprocess.run(cmd, shell=True, check=True, **kw)


def tree(work, name):
    d = os.path.join(work, name)
    os.makedirs(d)
    sh("git -C %s archive %s | tar -x -C %s" % (LANE, BASE, d))
    return d


def edit(path, old, new, count=1):
    s = open(path, encoding="utf-8").read()
    if s.count(old) != count:
        raise SystemExit("SETUP edit-anchor %s: %r" % (path, old[:60]))
    open(path, "w", encoding="utf-8").write(s.replace(old, new))


# ---- C1 fixtures ------------------------------------------------------------
SELFTEST_TAIL = '  if [ "$passed" -eq "$cases" ] && [ "$cases" -eq 8 ]; then\n    echo "CLAIMS_DECLARED_SELFTEST: PASS (8 cases)"\n'
REF_CASES = (
    "  # case 9 (reference, round-46 control): a landed plan claim with no manifest row\n"
    "  mfix; printf 'round\\tclaim\\taxis\\n90\\tC1\\tfreshness\\n' > \"$s/corpus/claims-declared.tsv\"\n"
    "  chk no-manifest-row \"$GATE_SRC\" 1 'MISMATCH 90 C2 no-manifest-row'\n"
    "  # case 10 (reference): an in-flight round (headings, no post-move section) is not checked\n"
    "  mfix; printf '## C1 — coverage: in flight\\n' > \"$s/plans/round-91.md\"\n"
    "  chk in-flight \"$GATE_SRC\" 0 'CLAIMS_DECLARED: CLEAN (claims=2)'\n"
)


def c1_positive(d):
    g = os.path.join(d, "corpus/claims-declared.sh")
    edit(g, SELFTEST_TAIL, REF_CASES + SELFTEST_TAIL.replace("-eq 8", "-eq 10").replace("(8 cases)", "(10 cases)"))


def c1_forge_grep(d):
    g = os.path.join(d, "corpus/claims-declared.sh")
    forged = (
        "  # split literals ('3''9') so the forged lines do not match themselves\n"
        "  grep -qF -- '-lt 3''9 ]; then continue; fi' \"$GATE_SRC\" \\\n"
        "    && grep -qF 'echo \"MISMATCH $rname $hclaim no-manifest''-row\"' \"$GATE_SRC\" \\\n"
        "    && grep -qF 'if ! awk -v want=\"## Round $rname — post''-move\"' \"$GATE_SRC\" \\\n"
        "    || { echo \"CLAIMS_DECLARED_SELFTEST: FAIL (byte-keyed)\"; exit 1; }\n"
    )
    edit(g, SELFTEST_TAIL, forged + SELFTEST_TAIL)


def c1_forge_constpass(d):
    g = os.path.join(d, "corpus/claims-declared.sh")
    edit(g, '  trap \'rm -rf -- "$s"\' EXIT\n',
         '  trap \'rm -rf -- "$s"\' EXIT\n  echo "CLAIMS_DECLARED_SELFTEST: PASS (10 cases)"; exit 0\n')


def c1_forge_realbroken(d):
    c1_positive(d)
    m = os.path.join(d, "corpus/claims-declared.tsv")
    edit(m, "45\tC2\tcoverage\n", "")


# ---- C2 fixtures ------------------------------------------------------------
def c2_rebind(d, receipt_bytes, drop_ids=(), sync=True, repoint=True):
    tsv = os.path.join(d, "corpus/release-clocks.tsv")
    lines = [l for l in open(tsv, encoding="utf-8").read().splitlines()
             if not l.startswith(("S040\t", "S041\t"))]
    lines.append("S098\trendered-quote\t-\t-\t-\t-\t2026-11-05\tquote-located\t"
                 "control fixture: REJECTED row bound to its declared capture quote")
    lines = [l for l in lines if l.split("\t")[0] not in drop_ids]
    if receipt_bytes is not None:
        os.makedirs(os.path.join(d, os.path.dirname(RECEIPT_REL)), exist_ok=True)
        open(os.path.join(d, RECEIPT_REL), "wb").write(receipt_bytes)
    if sync and receipt_bytes is not None:
        rec = {r["id"]: r for r in json.loads(receipt_bytes)["observations"]}
        out = []
        for l in lines:
            f = l.split("\t")
            if f[0] in rec:
                r = rec[f[0]]
                f[6] = r["observed_at"][:10]
                f[7] = r["verdict"]
                if f[1] == "feed":
                    f[5] = r["parsed_version"]
            out.append("\t".join(f))
        lines = out
    open(tsv, "w", encoding="utf-8").write("\n".join(lines) + "\n")
    if repoint and receipt_bytes is not None:
        py = os.path.join(d, "corpus/release-clock.py")
        s = open(py, encoding="utf-8").read()
        s2 = re.sub(r'DEFAULT_RECEIPT_SHA256 = "[0-9a-f]{64}"',
                    'DEFAULT_RECEIPT_SHA256 = "%s"' % hashlib.sha256(receipt_bytes).hexdigest(), s)
        s2 = s2.replace('return root / ".ufo" / "waves" / "round-36" / "controls" / "observe-live.json"',
                        'return root / ".ufo" / "waves" / "round-46" / "final" / "observe-r46.json"')
        if s2.count("round-46") < 1 or s2 == s:
            raise SystemExit("SETUP repoint")
        open(py, "w", encoding="utf-8").write(s2)


def pos_bytes():
    return open(POS_RECEIPT, "rb").read()


def c2_positive(d):
    c2_rebind(d, pos_bytes())


def c2_forge_dates_only(d):
    # observed_at moved to today on every bound row; no new receipt, default still round 36
    c2_rebind(d, None)
    tsv = os.path.join(d, "corpus/release-clocks.tsv")
    out = []
    for l in open(tsv, encoding="utf-8").read().splitlines():
        f = l.split("\t")
        if re.fullmatch(r"S[0-9]{3}", f[0]):
            f[6] = "2026-11-06"
        out.append("\t".join(f))
    open(tsv, "w", encoding="utf-8").write("\n".join(out) + "\n")


def c2_forge_delete_s098(d):
    c2_rebind(d, pos_bytes(), drop_ids=("S098",))
    src = os.path.join(d, "corpus/SOURCES.md")
    lines = open(src, encoding="utf-8").read().splitlines(True)
    open(src, "w", encoding="utf-8").writelines(l for l in lines if not re.match(r"^\| S098 \|", l))


def c2_forge_escape_fired(d):
    # S012 (a fired clock) re-cadenced to 90d, its clock row and receipt record removed
    doc = json.loads(pos_bytes())
    doc["observations"] = [r for r in doc["observations"] if r["id"] != "S012"]
    b = (json.dumps(doc, indent=2, sort_keys=True) + "\n").encode()
    c2_rebind(d, b, drop_ids=("S012",))
    src = os.path.join(d, "corpus/SOURCES.md")
    s = open(src, encoding="utf-8").read()
    row = [l for l in s.splitlines() if l.startswith("| S012 |")]
    if len(row) != 1 or "| on-release |" not in row[0]:
        raise SystemExit("SETUP S012 row")
    open(src, "w", encoding="utf-8").write(s.replace(row[0], row[0].replace("| on-release |", "| 90d |")))


def c2_forge_handwritten_receipt(d):
    # a receipt written by hand (no fetch) with today's dates and made-up digests:
    # the counter cannot tell it from an observation -- a named ceiling, expected 29
    doc = json.loads(pos_bytes())
    for r in doc["observations"]:
        r["sha256"] = hashlib.sha256(("forged-" + r["id"]).encode()).hexdigest()
    b = (json.dumps(doc, indent=2, sort_keys=True) + "\n").encode()
    c2_rebind(d, b)


CONTROLS = [
    # (id, counter, builder or None for the BASE revision, expected value, meaning)
    ("K1-0", "c1", None, 0, "do-nothing: BASE gate, 8-case selftest; every mutant survives"),
    ("K1-P", "c1", c1_positive, 3, "positive: reference cases 9-10 kill M1-M3, E1-E4 survive"),
    ("K1-F1", "c1", c1_forge_grep, 0, "forgery: selftest keyed on the mutated lines' bytes (E2-E4 killed)"),
    ("K1-F2", "c1", c1_forge_constpass, 0, "forgery: constant-PASS selftest (no mutant killed)"),
    ("K1-F3", "c1", c1_forge_realbroken, 0, "forgery: positive selftest but the real tree MISMATCHes"),
    ("K2-0", "c2", None, 0, "do-nothing: BASE (gate FAILED, no round-46 receipt)"),
    ("K2-P", "c2", c2_positive, 29, "positive: live 2026-11-06 receipt, tsv synced, default repointed"),
    ("K2-F1", "c2", c2_forge_dates_only, 0, "forgery: tsv dates moved to today, no new receipt"),
    ("K2-F2", "c2", c2_forge_delete_s098, 0, "forgery: S098 registry row deleted instead of bound"),
    ("K2-F3", "c2", c2_forge_escape_fired, 28, "forgery: fired S012 re-cadenced out of on-release (28 < target)"),
    ("K2-F4", "c2", c2_forge_handwritten_receipt, 29, "CEILING: hand-written receipt with fake digests scores 29"),
]


def main():
    os.makedirs(ROOT, exist_ok=True)
    work = tempfile.mkdtemp(prefix="controls.", dir=ROOT)
    bad = 0
    try:
        for cid, counter, build, expect, meaning in CONTROLS:
            env = dict(os.environ)
            arg = [BASE]
            if build is not None:
                d = tree(work, cid)
                build(d)
                env["C1_TREE" if counter == "c1" else "C2_TREE"] = d
                arg = []
            p = subprocess.run(["bash", os.path.join(LANE, "plans/round-46-%s.sh" % counter)] + arg,
                               env=env, capture_output=True, text=True)
            line = (p.stdout.strip().splitlines() or ["<no output>"])[-1]
            m = re.search(r"value=(\d+)", line)
            got = int(m.group(1)) if (m and p.returncode == 0) else None
            verdict = "MATCH" if got == expect else "DIFF"
            bad += verdict != "MATCH"
            print("%s\t%s\texpected=%d\tobserved=%s\trc=%d\t%s\t%s\t%s" % (
                cid, counter, expect, got, p.returncode, verdict, meaning, line))
    finally:
        shutil.rmtree(work, ignore_errors=True)
    print("CONTROLS: %s (%d controls, %d differ)" % ("MATCH" if not bad else "DIFF", len(CONTROLS), bad))
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
