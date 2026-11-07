#!/usr/bin/env python3
"""Mutant specifications for the round-55 frozen counters.

Each mutant is ONE literal replacement in ONE counter script. `apply <tree> <id>`
applies it to <tree>/plans/<file>, asserting the old text occurs exactly once
and the file changed; it prints the file's sha256 before and after.
`list` prints the table: id, counter, conjunct, old -> new.
"""
import hashlib
import json
import os
import sys

C1 = "round-55-c1.sh"
C2 = "round-55-c2.sh"

MUTANTS = {
    # ---- C1: guard conjuncts ----
    "C1-01-g1-off": (C1, "g1 base-citations-subset enforced", 
        "if not cb <= cm: bad.append('g1:%d-base-citations-gone' % len(cb - cm))",
        "if False: bad.append('g1:%d-base-citations-gone' % len(cb - cm))"),
    "C1-02-g2-off": (C1, "g2 base-entries-subset enforced",
        "if not set(eb) <= set(em): bad.append('g2:%d-base-entries-gone' % len(set(eb) - set(em)))",
        "if False: bad.append('g2:%d-base-entries-gone' % len(set(eb) - set(em)))"),
    "C1-03-g3-dup-off": (C1, "g3 duplicate-id detection",
        "            if sid in out: dup = True",
        "            if False: dup = True"),
    "C1-04-g3-rows-off": (C1, "g3 base-rows-subset enforced",
        "if not set(rb) <= set(rm): bad.append('g3:%d-base-rows-gone' % len(set(rb) - set(rm)))",
        "if False: bad.append('g3:%d-base-rows-gone' % len(set(rb) - set(rm)))"),
    "C1-05-g4-off": (C1, "g4 NOCITE independent record check",
        "if nocite: bad.append('g4:%d-used-by-parts-without-record' % nocite)",
        "if False: bad.append('g4:%d-used-by-parts-without-record' % nocite)"),
    "C1-06-g4-cites-ignored": (C1, "g4 reads the column-1 cites: field",
        "        f = field(txt, 'source:') + '\\n' + field(txt, 'cites:')",
        "        f = field(txt, 'source:')"),
    "C1-07-g5-off": (C1, "g5 census CLEAN + selftest PASS",
        "if G5 != 1: bad.append('g5:' + G5WHY)",
        "if False: bad.append('g5:' + G5WHY)"),
    "C1-08-ubp-lessons": (C1, "g4 accepts corpus/lessons used-by parts",
        "UBP = re.compile(r'^corpus/(knowledge|lessons)/[A-Za-z0-9._-]+\\.md$')",
        "UBP = re.compile(r'^corpus/knowledge/[A-Za-z0-9._-]+\\.md$')"),
    "C1-09-fail-mode-off": (C1, "fail-closed value (FAIL when guard=0)",
        "val = str(len(gap)) if guard else 'FAIL'",
        "val = str(len(gap))"),
    "C1-10-g5-selftest-off": (C1, "g5 requires the census selftest PASS line",
        "      case ${out2##*$'\\n'} in \"SOURCES_CENSUS_SELFTEST: PASS\"*) G5=1; G5WHY=OK ;; *) G5WHY=selftest-line ;; esac",
        "      G5=1; G5WHY=OK"),
    "C1-11-g4-islink-off": (C1, "g4 rejects symlinked used-by file",
        "        if not UBP.match(p) or not os.path.isfile(fp) or os.path.islink(fp):",
        "        if not UBP.match(p) or not os.path.isfile(fp):"),
    "C1-12-entries-islink-off": (C1, "entries exclude symlinks",
        "        if n.endswith('.md') and os.path.isfile(p) and not os.path.islink(p):",
        "        if n.endswith('.md') and os.path.isfile(p):"),
    # ---- C2: AMD a-d, RECHECK, GUARD ----
    "C2-01-a-ub-off": (C2, "AMD(a) requires ENTRY in the row used-by cell",
        "    a = (len(rows[X]) == 1 and c[8].strip() == 'mined' and c[4].strip() == 'A' and c[9].strip() == '2026-11-07' and ENTRY in ub)",
        "    a = (len(rows[X]) == 1 and c[8].strip() == 'mined' and c[4].strip() == 'A' and c[9].strip() == '2026-11-07')"),
    "C2-02-a-tier-off": (C2, "AMD(a) requires tier A",
        "    a = (len(rows[X]) == 1 and c[8].strip() == 'mined' and c[4].strip() == 'A' and c[9].strip() == '2026-11-07' and ENTRY in ub)",
        "    a = (len(rows[X]) == 1 and c[8].strip() == 'mined' and c[9].strip() == '2026-11-07' and ENTRY in ub)"),
    "C2-03-a-opened-off": (C2, "AMD(a) requires opened 2026-11-07",
        "    a = (len(rows[X]) == 1 and c[8].strip() == 'mined' and c[4].strip() == 'A' and c[9].strip() == '2026-11-07' and ENTRY in ub)",
        "    a = (len(rows[X]) == 1 and c[8].strip() == 'mined' and c[4].strip() == 'A' and ENTRY in ub)"),
    "C2-04-b-sha-off": (C2, "AMD(b) fetch sha256 == AMDSHA",
        "    b = len(f) == 1 and len(f[0]) >= 10 and f[0][3] == AMDURL and f[0][9] == AMDSHA",
        "    b = len(f) == 1 and len(f[0]) >= 10 and f[0][3] == AMDURL"),
    "C2-05-c-offset-off": (C2, "AMD(c) quote at declared byte offset",
        "        cc = qrow[2].isdigit() and data[int(qrow[2]):int(qrow[2]) + len(q)] == q",
        "        cc = True"),
    "C2-06-c-symlink-off": (C2, "AMD(c) capture path has no symlinked component",
        "        if os.path.islink(cur): return None",
        "        if False: return None"),
    "C2-07-d-bracket-off": (C2, "AMD(d) body line carries [X]",
        "    d = X in srcids and any(AMDQ in l and ('[%s]' % X) in l for l in lines if l not in fl)",
        "    d = X in srcids and any(AMDQ in l for l in lines if l not in fl)"),
    "C2-08-d-srcids-off": (C2, "AMD(d) X is a token of ENTRY source:",
        "    d = X in srcids and any(AMDQ in l and ('[%s]' % X) in l for l in lines if l not in fl)",
        "    d = any(AMDQ in l and ('[%s]' % X) in l for l in lines if l not in fl)"),
    "C2-09-count-off": (C2, "RECHECK body line count equals stated N",
        "        if cnt != int(n): ok = False; bad.append('recheck:%s-count-%d-stated-%s' % (Y, cnt, n))",
        "        if False: ok = False; bad.append('recheck:%s-count-%d-stated-%s' % (Y, cnt, n))"),
    "C2-10-n0-accepted": (C2, "RECHECK N >= 1",
        "        if len(ys) != 1 or int(n) < 1: ok = False; bad.append('recheck:url-or-n'); continue",
        "        if len(ys) != 1: ok = False; bad.append('recheck:url-or-n'); continue"),
    "C2-11-srcids-off": (C2, "RECHECK URL row id is on ENTRY source:",
        "        ys = [y for y in url2id.get(url, ()) if y in srcids]",
        "        ys = list(url2id.get(url, ()))"),
    "C2-12-guard-s101-off": (C2, "GUARD rows S100,S101,S102 byte-identical",
        "    for sid in ('S100', 'S101', 'S102'):",
        "    for sid in ('S100', 'S102'):"),
    "C2-13-guard-census-off": (C2, "GUARD census CLEAN",
        "if CEN != 1: g.append('census')",
        "if False: g.append('census')"),
    "C2-14-recheck-capture-sha-off": (C2, "RECHECK capture sha256 == fetch column 10",
        "        if len(f) != 1 or len(f[0]) < 10 or not bp or sha(bp) != f[0][9]:",
        "        if len(f) != 1 or len(f[0]) < 10 or not bp:"),
    "C2-15-recheck-lines-off": (C2, "RECHECK exactly one recheck: line",
        "if len(rlines) != 1: bad.append('recheck:lines=%d' % len(rlines))",
        "if len(rlines) < 1: bad.append('recheck:lines=%d' % len(rlines))"),
    "C2-16-guard-s101sha-off": (C2, "GUARD S101 capture sha256 == S101SHA",
        "if not p or sha(p) != S101SHA: g.append('s101-capture')",
        "if False: g.append('s101-capture')"),
    "C2-17-fail-mode-off": (C2, "fail-closed value (FAIL when guard=0)",
        "val = str(amd + rc) if guard else 'FAIL'",
        "val = str(amd + rc)"),
}


def sha(p):
    return hashlib.sha256(open(p, "rb").read()).hexdigest()


def main():
    cmd = sys.argv[1]
    if cmd == "list":
        for k, v in MUTANTS.items():
            print(k, "|", v[0], "|", v[1], "|", "replacement" if v[3] else "MISSING")
        return
    tree, mid = sys.argv[2], sys.argv[3]
    fname, conjunct, old, new = MUTANTS[mid]
    assert new is not None, f"{mid} has no replacement"
    p = os.path.join(tree, "plans", fname)
    s = open(p, encoding="utf-8").read()
    n = s.count(old)
    assert n == 1, f"{mid}: old text occurs {n} times in {fname}"
    before = sha(p)
    s2 = s.replace(old, new, 1)
    assert s2 != s
    open(p, "w", encoding="utf-8").write(s2)
    after = sha(p)
    print(json.dumps({"id": mid, "file": fname, "conjunct": conjunct,
                      "sha_before": before, "sha_after": after}))


if __name__ == "__main__":
    main()
