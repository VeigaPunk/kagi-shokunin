#!/usr/bin/env bash
# plans/round-55-c2.sh -- round 55 C2 counter (freshness: the ISO/IEC 11770-3 entry
# names the amendment now in force on the 2021 edition, and its recheck clock reads
# true on the committed capture it re-fetches).
#
# Frozen predicate (the same sentence appears in plans/round-55.md section C2):
#   C2_ISO_CURRENT: value = AMD + RECHECK when GUARD = 1, else FAIL; target 2 (BASE 0).
#   Constants: ENTRY corpus/knowledge/iso-11770-3-edition-status.md;
#     AMDURL https://www.iso.org/standard/85929.html; AMDQ `ISO/IEC 11770-3:2021/Amd 1:2025`;
#     AMDCAP .ufo/waves/round-55/capture/S114.body, sha256 AMDSHA below.
#   Registry rows: as in plans/round-55-c1.sh (outside ``` fences, 11 cells).
#   AMD = 1 iff all of:
#     (a) exactly one registry row whose source cell contains AMDURL as a
#         whitespace-delimited token; call its id X; status `mined`, tier `A`, opened
#         `2026-11-07`, and its used-by parts include ENTRY;
#     (b) corpus/source-fetches.tsv has exactly one non-comment row with id X; its
#         url (column 4) is AMDURL and its decoded sha256 (column 10) is AMDSHA;
#     (c) corpus/quote-bodies.tsv has exactly one row with id X; its body path is
#         AMDCAP, which is a regular file, not a symlink, on a path with no
#         symlinked component, with sha256 AMDSHA, and its quote occurs at its
#         declared byte offset;
#     (d) ENTRY is a regular non-symlink file whose column-1 `source:` field carries
#         X as a token, and some line of ENTRY outside that field contains AMDQ and
#         the bracketed citation `[X]`.
#   RECHECK = 1 iff ENTRY has exactly one column-1 `recheck:` line, that line holds
#     at least one command of the exact form
#       `curl <args> '<URL>' | grep -c '<Q>'` -> <N>
#     (backticked, N a decimal integer >= 1), and for every such command: URL is the
#     URL of a registry row Y whose id is a token of ENTRY's `source:` field; Y has
#     exactly one corpus/quote-bodies.tsv row whose body path is a regular
#     non-symlink file inside the measured tree whose sha256 equals column 10 of Y's
#     single corpus/source-fetches.tsv row; and the number of lines of that body
#     containing Q as a byte string equals N (what `grep -c` prints on the body).
#   GUARD = 1 iff the measured registry lines for S100, S101 and S102 are
#     byte-identical to BASE's, the S101 capture
#     .ufo/waves/round-45/controls/capture-r45/S101.raw has sha256 S101SHA below, and
#     `bash corpus/sources-census.sh` in the measured tree exits 0 with a last line
#     starting `SOURCES_CENSUS: CLEAN`.
# Fail closed: a bad revision, unreadable BASE, unusable scratch or missing python3
#   is SETUP (exit 2); a missing or unreadable file reads its conjunct as 0.
# Named ceilings: the counter checks committed bytes. A capture and rows forged
#   self-consistently around the frozen AMDSHA cannot be built without that body; a
#   recheck command whose quote is true of the capture but not discriminating
#   (e.g. a common word with its true count) scores RECHECK; the live re-fetch by a
#   non-author is the check of currency on the day.
# Input: a revision, or --tree DIR. Output: one line
#   C2_ISO_CURRENT: value=V amd=A recheck=R guard=G (bad=<reasons>)
set -u
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
BASE=ebe095857a734caf5efdd7bd776feb22b4e23972
AMDSHA=8bb88d88ff21d4488cf2205d9655a7fcbdeb3601616bdf4f5767dce13c449bdf
S101SHA=2e4c1524ec05865536f819db68c56494d97fc67cb490df4f5d4b1ca85b7b0c80
setup() { echo "C2_ISO_CURRENT: SETUP $1"; exit 2; }
command -v python3 >/dev/null 2>&1 || setup no-python3
SCR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r55/c2.$$
mkdir -p -- "$SCR/t" "$SCR/b" "$SCR/tmp" || setup scratch
trap 'rm -rf -- "$SCR"' EXIT
export TMPDIR=$SCR/tmp
T=$SCR/t
if [ "${1:-}" = --tree ]; then
  [ -n "${2:-}" ] && [ -d "$2" ] || setup tree
  cp -a "$2"/. "$T"/ || setup tree-copy
else
  REV=${1:-}
  [ -n "$REV" ] || setup no-revision
  git -C "$REPO" cat-file -e "$REV^{commit}" 2>/dev/null || setup bad-revision
  git -C "$REPO" archive "$REV" | tar -x -C "$T" || setup archive
fi
git -C "$REPO" show "$BASE:corpus/SOURCES.md" > "$SCR/b/SOURCES.md" 2>/dev/null || setup base-sources
[ -s "$SCR/b/SOURCES.md" ] || setup base-empty
CEN=0
if out=$(cd "$T" && bash corpus/sources-census.sh 2>&1); then
  case ${out##*$'\n'} in "SOURCES_CENSUS: CLEAN"*) CEN=1 ;; esac
fi
cd "$SCR" || setup cd
python3 -I -B - "$T" "$SCR/b/SOURCES.md" "$CEN" "$AMDSHA" "$S101SHA" <<'PY'
import hashlib, os, re, sys
T, BSRC, CEN, AMDSHA, S101SHA = sys.argv[1], sys.argv[2], int(sys.argv[3]), sys.argv[4], sys.argv[5]
ENTRY = 'corpus/knowledge/iso-11770-3-edition-status.md'
AMDURL = 'https://www.iso.org/standard/85929.html'
AMDQ = 'ISO/IEC 11770-3:2021/Amd 1:2025'
AMDCAP = '.ufo/waves/round-55/capture/S114.body'
S101CAP = '.ufo/waves/round-45/controls/capture-r45/S101.raw'
ROW = re.compile(r'^ {0,3}\|\s*(S\d{3,})\s*\|')
TOK = re.compile(r'(?<![A-Za-z0-9_])S\d{3,}(?!\d)')
CMD = re.compile(r"`curl [^`]*?'(https?://[^'\s]+)' \| grep -c '([^'`]+)'` -> (\d+)")
bad = []
def sha(p):
    with open(p, 'rb') as fh: return hashlib.sha256(fh.read()).hexdigest()
def safe(rel):
    p = os.path.join(T, rel)
    if not os.path.isfile(p): return None
    cur = T
    for part in rel.split('/'):
        cur = os.path.join(cur, part)
        if os.path.islink(cur): return None
    if not os.path.realpath(p).startswith(os.path.realpath(T) + os.sep): return None
    return p
def reglines(path):
    out, fence = [], False
    with open(path, encoding='utf-8', errors='replace') as fh:
        for line in fh:
            line = line.rstrip('\n')
            if line.lstrip().startswith('```'):
                fence = not fence; continue
            if not fence and ROW.match(line) and len(line.split('|')) == 13: out.append(line)
    return out
def tsv(rel):
    p = safe(rel)
    if not p: return []
    with open(p, encoding='utf-8', errors='replace') as fh:
        return [l.rstrip('\n').split('\t') for l in fh if l.strip() and not l.startswith('#')]
def field(txt, key):
    out, on = [], False
    for line in txt.split('\n'):
        if on and line[:1] in (' ', '\t'):
            out.append(line); continue
        if on: break
        if line.startswith(key):
            on = True; out.append(line)
    return '\n'.join(out)
try:
    rl = reglines(os.path.join(T, 'corpus', 'SOURCES.md'))
except Exception:
    rl = []; bad.append('registry-unreadable')
rows = {}
for l in rl:
    c = l.split('|'); rows.setdefault(ROW.match(l).group(1), []).append(c)
fetch = tsv('corpus/source-fetches.tsv'); qb = tsv('corpus/quote-bodies.tsv')
ep = safe(ENTRY)
etxt = open(ep, encoding='utf-8', errors='replace').read() if ep else ''
if not ep: bad.append('entry-missing')
srcf = field(etxt, 'source:')
srcids = set(TOK.findall(srcf))
def body_of(sid):
    q = [r for r in qb if r and r[0] == sid]
    if len(q) != 1 or len(q[0]) < 4: return None, None
    return safe(q[0][1]), q[0]
# AMD
amd = 0
cand = [sid for sid, cs in rows.items() for c in cs if AMDURL in c[2].split()]
if len(cand) != 1: bad.append('amd:a-rows=%d' % len(cand))
else:
    X = cand[0]; c = rows[X][0]
    ub = [x.strip() for x in re.split('[,;]', c[11])]
    a = (len(rows[X]) == 1 and c[8].strip() == 'mined' and c[4].strip() == 'A' and c[9].strip() == '2026-11-07' and ENTRY in ub)
    f = [r for r in fetch if r and r[0] == X]
    b = len(f) == 1 and len(f[0]) >= 10 and f[0][3] == AMDURL and f[0][9] == AMDSHA
    bp, qrow = body_of(X)
    cc = False
    if bp and qrow[1] == AMDCAP and sha(bp) == AMDSHA:
        data = open(bp, 'rb').read(); q = qrow[3].encode('utf-8')
        cc = qrow[2].isdigit() and data[int(qrow[2]):int(qrow[2]) + len(q)] == q
    lines = etxt.split('\n'); fl = set(srcf.split('\n'))
    d = X in srcids and any(AMDQ in l and ('[%s]' % X) in l for l in lines if l not in fl)
    if not d:
        # the quote and the bracket may wrap: accept them within one paragraph
        paras = re.split(r'\n\s*\n', etxt)
        d = X in srcids and any(AMDQ.split()[0] in p and AMDQ in ' '.join(p.split()) and ('[%s]' % X) in p for p in paras if not p.startswith('source:'))
    for k, v in (('a', a), ('b', b), ('c', cc), ('d', d)):
        if not v: bad.append('amd:' + k)
    amd = int(a and b and cc and d)
# RECHECK
rc = 0
rlines = [l for l in etxt.split('\n') if l.startswith('recheck:')]
if len(rlines) != 1: bad.append('recheck:lines=%d' % len(rlines))
else:
    cmds = CMD.findall(rlines[0])
    ok = bool(cmds)
    if not cmds: bad.append('recheck:no-command')
    url2id = {}
    for sid, cs in rows.items():
        for c in cs:
            for tokn in c[2].split():
                if tokn.startswith('http'): url2id.setdefault(tokn, set()).add(sid)
    for url, q, n in cmds:
        ys = [y for y in url2id.get(url, ()) if y in srcids]
        if len(ys) != 1 or int(n) < 1: ok = False; bad.append('recheck:url-or-n'); continue
        Y = ys[0]; f = [r for r in fetch if r and r[0] == Y]
        bp, qrow = body_of(Y)
        if len(f) != 1 or len(f[0]) < 10 or not bp or sha(bp) != f[0][9]:
            ok = False; bad.append('recheck:capture-%s' % Y); continue
        cnt = sum(1 for l in open(bp, 'rb').read().split(b'\n') if q.encode('utf-8') in l)
        if cnt != int(n): ok = False; bad.append('recheck:%s-count-%d-stated-%s' % (Y, cnt, n))
    rc = int(ok)
# GUARD
g = []
try:
    bl = {ROW.match(l).group(1): l for l in reglines(BSRC)}
    for sid in ('S100', 'S101', 'S102'):
        if [ '|'.join(c) for c in rows.get(sid, []) ] != [bl.get(sid)]: g.append('row-' + sid)
except Exception:
    g.append('base-registry')
p = safe(S101CAP)
if not p or sha(p) != S101SHA: g.append('s101-capture')
if CEN != 1: g.append('census')
guard = 0 if g else 1
bad += ['guard:' + x for x in g]
val = str(amd + rc) if guard else 'FAIL'
print('C2_ISO_CURRENT: value=%s amd=%d recheck=%d guard=%d (bad=%s)' % (val, amd, rc, guard, ','.join(bad) or 'none'))
PY
