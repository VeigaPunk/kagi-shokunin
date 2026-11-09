#!/usr/bin/env python3
import sys, re, os, json, subprocess

# Independent leg-checker derived from plans/round-69.md §C1/§C2 (not the counters,
# which for C1 do not exist yet). Evaluates the frozen leg wording with plain
# measurements on a given tree.
# Usage: legcheck.py <tree> <base_tree> [L1|L2|L3|L11|L8|subfloor|ledger]

tree, base = sys.argv[1], sys.argv[2]
leg = sys.argv[3] if len(sys.argv)>3 else 'all'

def read(p):
    try: return open(os.path.join(tree,p)).read()
    except: return None
def exists(p): return os.path.exists(os.path.join(tree,p))
def section(text, header):
    if text is None: return None
    i=text.find(header)
    if i<0: return None
    # to next ## header
    j=text.find("\n## ", i+1)
    return text[i:j if j>=0 else len(text)]

sc = read("SCORECARD.md")
lesson68 = read("corpus/lessons/round-68.md")
qual = read("corpus/QUALITY.md")
ledger = read("corpus/claim-ledger.tsv")

if leg in ('L1','all'):
    sec = section(sc, "## Round 68 — post-move")
    # plan L1: row names unprovable AND receipt AND no mismatches=0 string
    has_unprov = sec is not None and 'unprovable' in sec.lower()
    has_receipt = sec is not None and '.ufo/waves/round-68/w1/R68ScribeLesson/c2-lane-run.txt' in sec
    has_fab = 'mismatches=0' in (sec or '')
    print(f"L1 sec=None={sec is None} unprovable={has_unprov} receipt={has_receipt} fab_present={has_fab}")
    print(f"L1 verdict={'PASS' if (has_unprov and has_receipt and not has_fab) else 'MISMATCH'}")
if leg in ('L2','all'):
    sec = section(sc, "## Round 68 — post-move")
    qual_ids = set(re.findall(r'^\| (QM\d+) \|', qual or '', re.M))
    qual_high = sorted([x for x in qual_ids if int(x[2:])>96])
    qual_68 = [x for x in qual_ids if False]  # derived: rows whose lesson cell names round-68
    # find rows citing round-68
    cited68=set()
    for m in re.finditer(r'^\| (QM\d+) \|.*?(round-68)', qual or '', re.M):
        cited68.add(m.group(1))
    enter = 'enter the bar' in (sec or '')
    print(f"L2 qual_high={qual_high} cited68={sorted(cited68)} enter_phrase={enter}")
    print(f"L2 verdict={'PASS' if (not enter and cited68==set(qual_high) and len(qual_high)>=0) else 'MISMATCH'} (plan requires row names every QM>96 citing round-68; BASE set empty must not claim)")
if leg in ('L3','all'):
    base_text = open(os.path.join(base,"corpus/lessons/round-68.md")).read()
    has_orig = 'C2_RECORD' in (lesson68 or '') and 'mismatches 3' in (lesson68 or '')
    has_corr = 'Correction (round 69)' in (lesson68 or '')
    # does the correction name the superseded sentence and honest-stop receipt?
    corr_idx = (lesson68 or '').find('Correction (round 69)')
    corr = (lesson68 or '')[corr_idx:] if corr_idx>=0 else ''
    names_sentence = 'C2_RECORD' in corr
    names_receipt = 'c2-lane-run.txt' in corr
    print(f"L3 orig_present={has_orig} corr={has_corr} names_sentence={names_sentence} names_receipt={names_receipt}")
    print(f"L3 verdict={'PASS' if (has_orig and has_corr and names_sentence and names_receipt) else 'MISMATCH'}")
if leg in ('L11','all'):
    qual_ids = set(re.findall(r'^\| (QM\d+) \|', qual or '', re.M))
    high = sorted([x for x in qual_ids if int(x[2:])>96])
    cited = set()
    for m in re.finditer(r'^\| (QM\d+) \|', qual or '', re.M):
        row_start = m.start()
        row_end = qual.find('\n', row_start)
        if 'round-68' in qual[row_start:row_end]:
            cited.add(m.group(1))
    # falsifier text: criterion cell non-empty beyond shape?
    print(f"L11 high={high} cited68={sorted(cited)} count_cited={len(cited)}")
    print(f"L11 verdict={'PASS' if len(cited)>=4 else 'MISMATCH'}")
if leg in ('L8','all'):
    p68 = read("plans/round-68-c1.sh") or ''
    m=re.search(r'def predicate_ok\(verified, col15, caught, guard, defects\):(.*?)\n\ndef verdict_line', p68, re.S)
    if m:
        ns={}
        exec("def predicate_ok(verified, col15, caught, guard, defects):"+m.group(1), ns)
        f=ns['predicate_ok']
        tests=[((36,31,6,1,0),False),((37,32,6,1,0),True),((38,33,6,1,0),True),((38,33,5,1,0),False),((38,33,6,0,0),False),((38,33,6,1,1),False)]
        ok=all(f(*a)==w for a,w in tests)
        has_case='predicate-subfloor' in p68
        print(f"L8 predicate_ok 6-behaviors={ok} subfloor_case={has_case}")
        print(f"L8 verdict={'PASS' if ok and has_case else 'MISMATCH'}")
    else:
        print("L8 verdict=SETUP predicate_ok not found")
if leg in ('subfloor','all'):
    p68 = read("plans/round-68-c1.sh") or ''
    p68b = open(os.path.join(base,"plans/round-68-c1.sh")).read()
    def get_pred(src):
        m=re.search(r'def predicate_ok\(verified, col15, caught, guard, defects\):(.*?)\n\ndef verdict_line', src, re.S)
        ns={}; exec("def predicate_ok(verified, col15, caught, guard, defects):"+m.group(1), ns)
        return ns['predicate_ok']
    f=get_pred(p68); fb=get_pred(p68b)
    a1 = (not f(36,31,6,1,0)) and f(37,32,6,1,0) and f(38,33,6,1,0) and (not f(38,33,5,1,0)) and (not f(38,33,6,0,0)) and (not f(38,33,6,1,1))
    c = fb(36,31,6,1,0)
    print(f"subfloor a={a1} c(base accepts 36/31)={c}")
    print(f"subfloor(a,c) verdict={'PASS' if a1 and c else 'MISMATCH'} (b requires running both selftests)")
