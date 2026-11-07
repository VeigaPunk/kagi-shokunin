#!/usr/bin/env python3
"""Build C2 forgery fixtures from the scratch BASE tree. Scratch only."""
import shutil, subprocess, sys, os
from pathlib import Path

S = Path(os.environ["S"])
BASE = S / "base-tree"

def fresh(name):
    dst = S / ("fx-" + name)
    if dst.exists():
        shutil.rmtree(dst)
    subprocess.run(["cp", "-a", str(BASE), str(dst)], check=True)
    return dst

def edit_lines(root, rel, fn):
    p = root / rel
    text = p.read_text(encoding="utf-8")
    lines = text.split("\n")
    out = fn(lines)
    p.write_text("\n".join(out), encoding="utf-8")

SKILL_PREFIX = "| Re-run a claim this corpus makes / name the revision you read / cite an artifact / audit a score | "

def skill_decoys(root, phantom_cr=False):
    def fn(lines):
        i = 45
        orig = lines[i]
        assert orig.startswith("| Re-run a claim this corpus makes"), orig[:60]
        assert "(124 stamps + " in orig
        if phantom_cr:
            head, tail = orig.split("`bash corpus/claim-ledger.sh verify` ", 1)
            lines[i] = (head + "`bash corpus/claim-ledger.sh verify` "
                        + "\r| Re-run a claim this corpus makes (125 stamps + 86 claims, observed live 2026-11-07) "
                        + tail)
        else:
            lines[i] = orig.replace(
                "| Re-run a claim this corpus makes ",
                "| Re-run a claim this corpus makes (125 stamps + 86 claims, observed live 2026-11-07) ", 1)
        assert lines[i] != orig
        return lines
    edit_lines(root, "SKILL.md", fn)

def province_decoy(root):
    def fn(lines):
        i = 72
        orig = lines[i]
        assert orig.startswith("- `corpus/claim-ledger.sh` — calibration gate: `verify` (124 revision stamps"), orig[:80]
        lines[i] = orig.replace(
            "calibration gate: `verify` (124 revision stamps",
            "calibration gate: `verify` (125 revision stamps, observed live 2026-11-07); "
            "the landed sentence still reads `verify` (124 revision stamps", 1)
        assert lines[i] != orig
        return lines
    edit_lines(root, "PROVINCE.md", fn)

def readme_decoys(root, by_hand=3, row_linked=34):
    def fn(lines):
        i = 64
        orig = lines[i]
        assert orig.startswith("| Revision stamps (data) | `corpus/stamps.tsv` | 124 rows ("), orig[:70]
        lines[i] = orig.replace(
            "`corpus/stamps.tsv` | 124 rows (",
            "`corpus/stamps.tsv` | 125 rows (observed live 2026-11-07); "
            "the landed sentence still reads 124 rows (", 1)
        assert lines[i] != orig
        j = 66
        orig2 = lines[j]
        assert "per entry: 33 row-linked / 3 by-hand / 36 pinned (" in orig2, orig2[:120]
        lines[j] = orig2.replace(
            "per entry: 33 row-linked / 3 by-hand / 36 pinned (",
            ("per entry: %d row-linked / %d by-hand / 37 pinned (observed live 2026-11-07); "
             "the landed sentence still reads 33 row-linked / 3 by-hand / 36 pinned ("
             % (row_linked, by_hand)), 1)
        assert lines[j] != orig2
        return lines
    edit_lines(root, "corpus/README.md", fn)

def decoys_all(root, phantom_cr=False, by_hand=3, row_linked=34):
    skill_decoys(root, phantom_cr=phantom_cr)
    province_decoy(root)
    readme_decoys(root, by_hand=by_hand, row_linked=row_linked)

def ledger_cell(root, rid, col, value):
    p = root / "corpus/claim-ledger.tsv"
    lines = p.read_text(encoding="utf-8").split("\n")
    hits = 0
    for k, line in enumerate(lines):
        if not line or line.startswith("#"):
            continue
        f = line.split("\t")
        if f[0] == rid:
            f[col] = value
            lines[k] = "\t".join(f)
            hits += 1
    assert hits == 1, (rid, hits)
    p.write_text("\n".join(lines), encoding="utf-8")

def knowledge_reverify(root, rel, value):
    p = root / rel
    lines = p.read_text(encoding="utf-8").split("\n")
    hits = 0
    for k, line in enumerate(lines):
        if line.startswith("Reverify: "):
            lines[k] = "Reverify: " + value
            hits += 1
    assert hits == 1, (rel, hits)
    p.write_text("\n".join(lines), encoding="utf-8")

def keep_tree_fingerprint(root):
    """record what the reviewer-facing tools see for each edited line"""
    out = []
    for rel, n in (("SKILL.md", 46), ("PROVINCE.md", 73),
                   ("corpus/README.md", 65), ("corpus/README.md", 67)):
        cmd = ["sed", "-n", "%dp" % n, str(root / rel)]
        res = subprocess.run(cmd, capture_output=True, text=True)
        out.append("%s:%d -> %s" % (rel, n, res.stdout.strip()[:300]))
    (S / ("fingerprint-" + root.name + ".txt")).write_text("\n".join(out) + "\n", encoding="utf-8")

def main():
    mode = sys.argv[1]
    root = fresh(mode)
    if mode == "f1":
        decoys_all(root)
    elif mode == "f2":
        decoys_all(root, phantom_cr=True)
    elif mode == "f3":
        decoys_all(root, row_linked=33)
        ledger_cell(root, "R14-01", 3, "1")           # exit column 0 -> 1
        knowledge_reverify(root, "corpus/knowledge/claim-ledger.md", "R99-99")
    elif mode == "f3b":
        decoys_all(root, row_linked=33)
        knowledge_reverify(root, "corpus/knowledge/claim-ledger.md", "R99-99")
    elif mode == "f4":
        decoys_all(root, by_hand=4, row_linked=33)
        knowledge_reverify(root, "corpus/knowledge/claim-ledger.md",
                           "by-hand: interactive-only — the entry's own grammar is only measured by the "
                           "R11-09 selftest inside a scratch tree, so no row command pins its prose")
    elif mode == "f5":
        p = root / "corpus/stamps.tsv"
        lines = p.read_text(encoding="utf-8").split("\n")
        n = 0
        for k, line in enumerate(lines):
            if not line.strip() or line.startswith("#"):
                continue
            f = line.split("\t")
            if len(f) >= 2 and len(f[1]) == 64:
                f[1] = ("0" if f[1][0] != "0" else "1") + f[1][1:]
                lines[k] = "\t".join(f)
                n += 1
            if n == 3:
                break
        assert n == 3
        p.write_text("\n".join(lines), encoding="utf-8")
    elif mode == "f6":
        p = root / "corpus/stamps.tsv"
        lines = p.read_text(encoding="utf-8").split("\n")
        for k, line in enumerate(lines):
            if line.startswith("corpus/adjacency.tsv\t"):
                f = line.split("\t")
                f[0] = "corpus/QUOTE-does-not-exist.md"
                lines[k] = "\t".join(f)
                break
        else:
            raise SystemExit("no adjacency stamp row")
        p.write_text("\n".join(lines), encoding="utf-8")
    elif mode == "f7":
        ledger_cell(root, "R12-03", 2, "^124$")
    elif mode == "f8":
        decoys_all(root)
        p = root / "corpus/feed-token-agree.py"
        t = p.read_text(encoding="utf-8")
        old = '    ("plain", "3.15.1"),\n)'
        assert t.count(old) == 1
        p.write_text(t.replace(old, '    ("plain", "3.15.1"),\n    ("plain-second", "3.15.1"),\n)'), encoding="utf-8")
    elif mode == "f12":
        decoys_all(root)
        # duplicate the whole decoyed row: two matching lines -> AMBIGUOUS
        p3 = root / "SKILL.md"
        lines = p3.read_text(encoding="utf-8").split("\n")
        assert lines[45].startswith("| Re-run a claim this corpus makes")
        lines.insert(46, lines[45])
        p3.write_text("\n".join(lines), encoding="utf-8")
    elif mode == "f11":
        decoys_all(root)
        # count-preserving row swap: the stamp-identity pin row loses its id
        p2 = root / "corpus/claim-ledger.tsv"
        lines = p2.read_text(encoding="utf-8").split("\n")
        hits = 0
        for k, line in enumerate(lines):
            f = line.split("\t")
            if f[0] == "R24-05":
                f[0] = "R99-01"
                lines[k] = "\t".join(f)
                hits += 1
        assert hits == 1
        p2.write_text("\n".join(lines), encoding="utf-8")
    elif mode == "f10":
        decoys_all(root)
        stub = root / "corpus/self-counts.py"
        stub.write_text(
            '#!/usr/bin/env python3\n'
            '"""forged selftest-only stub: the shipped binder is gone"""\n'
            'import sys\n'
            'if "--selftest" not in sys.argv:\n'
            '    print("SELF_COUNTS: CLEAN (claims=63 stale=0)")\n'
            '    raise SystemExit(0)\n'
            'print("SELF_COUNTS_SELFTEST: PASS (48 cases)")\n', encoding="utf-8")
    elif mode == "f9":
        decoys_all(root)
        good = S / "outside-skill.md"                       # outside the measured tree
        good.write_text((root / "SKILL.md").read_text(encoding="utf-8"), encoding="utf-8")
        (root / "SKILL.md").unlink()
        (root / "SKILL.md").symlink_to(str(good))
    else:
        raise SystemExit("unknown mode " + mode)
    keep_tree_fingerprint(root)
    print("built", root)

main()
