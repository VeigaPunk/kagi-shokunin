#!/usr/bin/env bash
# plans/round-55-c1.sh -- round 55 C1 counter (calibration: the registry's used-by
# cells, the lane's own statement of which entries cite a row, against the entries
# that actually name the row).
#
# Frozen predicate (the same sentence appears in plans/round-55.md section C1):
#   C1_USEDBY_GAP: value = GAP when GUARD = 1, else FAIL; target 0 (BASE 25).
#   Registry rows: lines of the measured corpus/SOURCES.md outside ``` fences that
#     match `^ {0,3}| *S<3+ digits> *|` and split into exactly 11 cells; id -> used-by
#     cell split on `,` and `;`, each part trimmed, `—`/`-`/empty dropped.
#   Entries: the regular, non-symlink files corpus/knowledge/*.md (top level).
#   CITATION: a pair (id, entry) where the entry's bytes (UTF-8, errors replaced)
#     contain the id as a token `S` + 3 or more digits not preceded by a letter,
#     digit or `_` and not followed by a digit, and id is a registry row.
#   GAP = number of CITATION pairs whose row's used-by parts do not include the
#     exact path `corpus/knowledge/<name>.md`.
#   GUARD = 1 iff all of:
#     (g1) every BASE CITATION pair is a CITATION pair of the measured tree (no
#          mention removed or rewritten to escape the count);
#     (g2) every BASE entry name is a measured entry (regular, non-symlink);
#     (g3) every BASE registry id is a measured registry row, and no id has two rows;
#     (g4) independent NOCITE: for every measured row with status `mined`, every
#          used-by part is a path `corpus/(knowledge|lessons)/<name>.md` naming a
#          regular non-symlink file whose column-1 `source:` field or column-1
#          `cites:` field (first such line plus whitespace-led continuation lines)
#          carries the id as a token (so a used-by cell cannot be padded with an
#          entry that does not record the row);
#     (g5) `bash corpus/sources-census.sh` in the measured tree exits 0 with a last
#          line starting `SOURCES_CENSUS: CLEAN`, and
#          `bash corpus/sources-census.sh --selftest` exits 0 with a last line
#          starting `SOURCES_CENSUS_SELFTEST: PASS`.
# Fail closed: a bad revision, an unreadable BASE, unusable scratch or a missing
# python3 is SETUP (exit 2, no value); a guard conjunct that cannot be evaluated
# reads 0 with a reason.
# Named ceilings: lessons are outside the population (they are not entries); an id
# written in a form the token rule does not match (`S 047`, `S47`, a range `S055-S060`
# counts S055 and S060 only) is not a CITATION; g5 runs the measured tree's own gate,
# so a census replaced by a printer passes g5 (g4 is the independent check).
# Input: a revision, or --tree DIR. Output: one line
#   C1_USEDBY_GAP: value=V gap=G citations=C entries=E guard=0|1 (bad=<reasons>)
set -u
REPO=${REPO_OVERRIDE:-$(cd "$(dirname "$0")/.." && pwd -P)}
BASE=ebe095857a734caf5efdd7bd776feb22b4e23972
setup() { echo "C1_USEDBY_GAP: SETUP $1"; exit 2; }
command -v python3 >/dev/null 2>&1 || setup no-python3
SCR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r55/c1.$$
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
git -C "$REPO" archive "$BASE" corpus/SOURCES.md corpus/knowledge | tar -x -C "$SCR/b" 2>/dev/null || setup base-archive
[ -s "$SCR/b/corpus/SOURCES.md" ] || setup base-empty
G5=0; G5WHY=census
if out=$(cd "$T" && bash corpus/sources-census.sh 2>&1); then
  case ${out##*$'\n'} in "SOURCES_CENSUS: CLEAN"*)
    if out2=$(cd "$T" && bash corpus/sources-census.sh --selftest 2>&1); then
      case ${out2##*$'\n'} in "SOURCES_CENSUS_SELFTEST: PASS"*) G5=1; G5WHY=OK ;; *) G5WHY=selftest-line ;; esac
    else G5WHY=selftest-exit; fi ;;
    *) G5WHY=census-line ;; esac
else G5WHY=census-exit; fi
cd "$SCR" || setup cd
python3 -I -B - "$T" "$SCR/b" "$G5" "$G5WHY" <<'PY'
import os, re, sys
T, B, G5, G5WHY = sys.argv[1], sys.argv[2], int(sys.argv[3]), sys.argv[4]
ROW = re.compile(r'^ {0,3}\|\s*(S\d{3,})\s*\|')
TOK = re.compile(r'(?<![A-Za-z0-9_])S\d{3,}(?!\d)')
UBP = re.compile(r'^corpus/(knowledge|lessons)/[A-Za-z0-9._-]+\.md$')
def rows(root):
    p = os.path.join(root, 'corpus', 'SOURCES.md')
    out, dup, fence = {}, False, False
    with open(p, encoding='utf-8', errors='replace') as fh:
        for line in fh:
            line = line.rstrip('\n')
            if line.lstrip().startswith('```'):
                fence = not fence; continue
            if fence: continue
            m = ROW.match(line)
            if not m: continue
            cells = line.split('|')
            if len(cells) != 13: continue
            sid = m.group(1)
            if sid in out: dup = True
            ub = [x.strip() for x in re.split('[,;]', cells[11])]
            out[sid] = (cells[8].strip(), [x for x in ub if x not in ('', '—', '-')])
    return out, dup
def entries(root):
    d = os.path.join(root, 'corpus', 'knowledge')
    res = {}
    for n in sorted(os.listdir(d)) if os.path.isdir(d) else []:
        p = os.path.join(d, n)
        if n.endswith('.md') and os.path.isfile(p) and not os.path.islink(p):
            with open(p, encoding='utf-8', errors='replace') as fh: res[n] = fh.read()
    return res
def cites(rws, ents):
    return {(t, n) for n, txt in ents.items() for t in set(TOK.findall(txt)) if t in rws}
def field(txt, key):
    out, on = [], False
    for line in txt.split('\n'):
        if on and line[:1] in (' ', '\t'):
            out.append(line); continue
        if on: break
        if line.startswith(key):
            on = True; out.append(line)
    return '\n'.join(out)
bad = []
try:
    rb, _ = rows(B); eb = entries(B); cb = cites(rb, eb)
    bsrc = {n: set(TOK.findall(field(t, 'source:'))) for n, t in eb.items()}
except Exception as e:
    print('C1_USEDBY_GAP: SETUP base-parse %s' % type(e).__name__); sys.exit(2)
try:
    rm, dup = rows(T); em = entries(T); cm = cites(rm, em)
except Exception as e:
    print('C1_USEDBY_GAP: value=FAIL gap=- citations=- entries=- guard=0 (bad=measured-parse:%s)' % type(e).__name__); sys.exit(1)
gap = sorted((t, n) for (t, n) in cm if 'corpus/knowledge/' + n not in rm[t][1])
if not cb <= cm: bad.append('g1:%d-base-citations-gone' % len(cb - cm))
if not set(eb) <= set(em): bad.append('g2:%d-base-entries-gone' % len(set(eb) - set(em)))
if not set(rb) <= set(rm): bad.append('g3:%d-base-rows-gone' % len(set(rb) - set(rm)))
if dup: bad.append('g3:duplicate-id')
nocite = 0
for sid, (st, ub) in rm.items():
    if st != 'mined': continue
    for p in ub:
        fp = os.path.join(T, p)
        if not UBP.match(p) or not os.path.isfile(fp) or os.path.islink(fp):
            nocite += 1; continue
        with open(fp, encoding='utf-8', errors='replace') as fh: txt = fh.read()
        f = field(txt, 'source:') + '\n' + field(txt, 'cites:')
        if sid not in TOK.findall(f): nocite += 1; continue
        bn = os.path.basename(p)
        if p.startswith('corpus/knowledge/') and bn in bsrc and sid not in bsrc[bn]:
            if sid not in TOK.findall(field(txt, 'cites:')): nocite += 1
if nocite: bad.append('g4:%d-used-by-parts-without-record' % nocite)
if G5 != 1: bad.append('g5:' + G5WHY)
guard = 0 if bad else 1
val = str(len(gap)) if guard else 'FAIL'
print('C1_USEDBY_GAP: value=%s gap=%d citations=%d entries=%d guard=%d (bad=%s)' % (val, len(gap), len(cm), len(em), guard, ','.join(bad) or 'none'))
for t, n in gap: print('GAP %s corpus/knowledge/%s' % (t, n))
PY
