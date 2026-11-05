#!/usr/bin/env bash
# run-mutants.sh -- seat K41MutGates (round 41): mutation runner for the C1 gate and the C2 paragraph.
#
# Usage: run-mutants.sh <LANE> [c1|c2|both]
#   <LANE>  lane root. Read-only for this runner: nothing is written inside it.
#   C1 gate: <LANE>/corpus/expect-journal.sh   counter: <LANE>/plans/round-41-c1.sh (target 4)
#   C2 file: <LANE>/corpus/rendered-text-v1.py counter: <LANE>/plans/round-41-c2.sh (target 3)
#   For each mutant: EXPECT_JOURNAL=<mutant> (C1) or RTV1=<mutant> (C2) bash <counter>.
#   A mutant is killed when the counter reading is not the target.
# Scratch: ${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r41/K41MutGates/mut-run.<pid>,
#          removed on exit (trap). /tmp is never used. Mutants live under .../K41MutGates/.
# Exit 2 (fail closed) when the gate or the candidate Sources paragraph is missing.
# Baseline discipline: if the unmutated gate/paragraph does not read the target, mutants are
# reported INCONCLUSIVE, never judged.
set -u

SCOPE=${2:-both}
case "$SCOPE" in c1|c2|both) ;; *) echo "run-mutants: scope must be c1, c2 or both" >&2; exit 2 ;; esac
LANE=${1:-}
[ -n "$LANE" ] && [ -d "$LANE" ] || { echo "run-mutants: lane path required" >&2; exit 2; }

C1_SH="$LANE/plans/round-41-c1.sh"
C2_SH="$LANE/plans/round-41-c2.sh"
GATE="$LANE/corpus/expect-journal.sh"
RTV1="$LANE/corpus/rendered-text-v1.py"

fail2() { echo "run-mutants: $*" >&2; exit 2; }

case "$SCOPE" in c1|both)
  [ -r "$C1_SH" ] || fail2 "missing counter: $C1_SH"
  [ -r "$GATE" ]  || fail2 "missing gate: $GATE"
  ;;
esac
case "$SCOPE" in c2|both)
  [ -r "$C2_SH" ] || fail2 "missing counter: $C2_SH"
  [ -r "$RTV1" ]  || fail2 "missing candidate paragraph file: $RTV1"
  grep -q '^Sources (' "$RTV1" 2>/dev/null || fail2 "missing Sources paragraph: $RTV1"
  ;;
esac

ROOT=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r41/K41MutGates/mut-run.$$
mkdir -p "$ROOT/mutants" || fail2 "cannot create scratch root: $ROOT"
trap 'rm -rf -- "$ROOT"' EXIT INT TERM

run_counter() { # $1 env name (EXPECT_JOURNAL|RTV1)  $2 value  $3 counter script  $4 outfile -> rc on stdout
  env "$1=$2" bash "$3" >"$4" 2>"$4.err"
  printf '%s' "$?"
}

reading_of() { # $1 outfile -> last stdout line if a bare integer, else INCONCLUSIVE
  local v
  v=$(tail -n 1 "$1" 2>/dev/null | tr -d '[:space:]')
  case "$v" in '' | *[!0-9]*) printf 'INCONCLUSIVE' ;; *) printf '%s' "$v" ;; esac
}

# ---------------------------------------------------------------- C1 (gate mutants, target 4)
if [ "$SCOPE" = c1 ] || [ "$SCOPE" = both ]; then
  cp "$GATE" "$ROOT/gate-original.sh"
  brc=$(run_counter EXPECT_JOURNAL "$ROOT/gate-original.sh" "$C1_SH" "$ROOT/c1-baseline.out")
  bread=$(reading_of "$ROOT/c1-baseline.out")
  echo "C1 BASELINE rc=$brc reading=$bread target=4"
  if [ "$bread" != "4" ]; then
    echo "C1 INCONCLUSIVE-BASELINE: baseline reading $bread is not 4; no mutant judged"
    echo "MUTANTS C1: killed=0 survived=0 total=0"
  else
    python3 - "$ROOT/gate-original.sh" "$ROOT/mutants" >"$ROOT/c1-gen.tsv" <<'PY'
import os, re, subprocess, sys

gate_path, outdir = sys.argv[1], sys.argv[2]
src = open(gate_path, encoding="utf-8").read()
out = []

def bash_ok(text):
    return subprocess.run(["bash", "-n"], input=text, capture_output=True, text=True).returncode == 0

def python_ok(text):
    for m in re.finditer(r"<<'(\w+)'\n(.*?)\n\1(?=\s*$)", text, re.S | re.M):
        try:
            compile(m.group(2), "<heredoc>", "exec")
        except SyntaxError:
            return False
    return True

def checks_ok(text):
    return bash_ok(text) and python_ok(text)

def record(name, status, info):
    out.append("%s\t%s\t%s" % (name, status, info))

def try_one(name, label, fn):
    new = fn(src)
    if new is None or new == src:
        return False
    if not checks_ok(new):
        return False
    with open(os.path.join(outdir, name), "w", encoding="utf-8") as fh:
        fh.write(new)
    record(name, "GEN", label)
    return True

def try_many(name, variants):
    for label, fn in variants:
        if try_one(name, label, fn):
            return
    record(name, "NGEN", variants[-1][0])

def sub_all(pattern, repl):
    def fn(text, pattern=pattern, repl=repl):
        new, n = re.subn(pattern, repl, text)
        return new if n else None
    return fn

def comment_emit_lines(token):
    rx = re.compile(r"\b(echo|printf|print)\b")
    def fn(text, token=token, rx=rx):
        hit = 0
        res = []
        for ln in text.split("\n"):
            if token in ln and not ln.lstrip().startswith("#") and rx.search(ln):
                ln = "#" + ln
                hit += 1
            res.append(ln)
        return "\n".join(res) if hit else None
    return fn

def first_violation_only(text):
    for m in re.finditer(r"(?m)^([A-Za-z_][A-Za-z0-9_]*)\s*\(\)\s*\{[ \t]*(?:#.*)?$", text):
        close = re.compile(r"(?m)^}\s*$").search(text, m.end())
        if not close:
            continue
        body = text[m.end():close.start()]
        if "EXPECT_JOURNAL: REFUSE" not in body:
            continue
        guard = '\n[ -n "${_fv_done:-}" ] && return 0\n_fv_done=1'
        return text[:m.end()] + guard + text[m.end():]
    return None

def unknown_id_ignore(text):
    m = re.search(r"(?m)^\s*(\w+)\s*=\s*rows\([^\n]*ledger[^\n]*\)\s*$", text)
    cand = m.group(1) if m else None
    if cand is None:
        m2 = re.search(r"(?m)^\s*(\w+)\s*,\s*(\w+)\s*=\s*rows\(", text)
        cand = m2.group(2) if m2 else None
    if cand is None:
        return None
    m3 = re.search(r'(?m)^(\s*)(\w+)\[m\["id"\]\]\s*=\s*m\s*$', text)
    if not m3:
        return None
    indent, old = m3.group(1), m3.group(0)
    line = old[len(indent):]
    new = '%sif m["id"] not in %s: continue\n%s%s' % (indent, cand, indent, line)
    newtext, n = re.subn(re.escape(old), new.replace("\\", "\\\\"), text, count=1)
    return newtext if n else None

try_many("drop_R1", [("comment UNJOURNALED emit", comment_emit_lines("UNJOURNALED"))])
try_many("drop_R2_OLD", [("comment OLD_MISMATCH emit", comment_emit_lines("OLD_MISMATCH"))])
try_many("drop_R2_CMD", [("comment COMMAND_MISMATCH emit", comment_emit_lines("COMMAND_MISMATCH"))])
try_many("drop_R2_NEW", [("comment NEW_MISMATCH emit", comment_emit_lines("NEW_MISMATCH"))])
try_many("drop_R3", [("comment NOT_LITERAL emit", comment_emit_lines("NOT_LITERAL"))])
try_many("r4_downgrade", [("WARN ORPHAN -> REFUSE ORPHAN", sub_all(r"WARN ORPHAN", "REFUSE ORPHAN"))])
try_many("refuse_exit0", [("exit 1 -> exit 0", sub_all(r"\bexit 1\b", "exit 0")),
                          ("exit $violations -> exit 0", sub_all(r"\bexit\s+\$\{?violations\}?", "exit 0"))])
try_many("clean_on_violation", [("final REFUSED -> CLEAN", sub_all(r"EXPECT_JOURNAL: REFUSED", "EXPECT_JOURNAL: CLEAN")),
                                ("REFUSED -> CLEAN", sub_all(r"\bREFUSED\b", "CLEAN"))])
try_many("first_violation_only", [("first-refuse guard in emitter fn", first_violation_only)])
try_many("non_json_accept", [("*.json glob -> *", sub_all(r"\*\.json", "*")),
                             ("endswith('.json') -> endswith('')", sub_all(r"endswith\((['\"])\.json\1\)", r"endswith(\1\1)"))])
try_many("unknown_id_ignore", [("skip journal ids absent from candidate rows", unknown_id_ignore)])

sys.stdout.write("".join(l + "\n" for l in out))
PY
    k=0; s=0; t=0; ngen=""
    while IFS=$'\t' read -r name status info; do
      [ -n "${name:-}" ] || continue
      if [ "$status" != "GEN" ]; then
        ngen="$ngen $name($info)"
        continue
      fi
      t=$((t + 1))
      mrc=$(run_counter EXPECT_JOURNAL "$ROOT/mutants/$name" "$C1_SH" "$ROOT/c1-$name.out")
      mr=$(reading_of "$ROOT/c1-$name.out")
      if [ "$mr" = "INCONCLUSIVE" ]; then
        echo "C1 MUTANT $name rc=$mrc reading=INCONCLUSIVE verdict=inconclusive gen=$info"
      elif [ "$mr" -ne 4 ]; then
        k=$((k + 1))
        echo "C1 MUTANT $name rc=$mrc reading=$mr verdict=killed gen=$info"
      else
        s=$((s + 1))
        echo "C1 MUTANT $name rc=$mrc reading=$mr verdict=survived gen=$info"
      fi
    done <"$ROOT/c1-gen.tsv"
    echo "MUTANTS C1: killed=$k survived=$s total=$t"
    [ -n "$ngen" ] && echo "C1 NOT-GENERATED:$ngen"
  fi
fi

# ------------------------------------------------- C2 (Sources paragraph mutants, target 3)
if [ "$SCOPE" = c2 ] || [ "$SCOPE" = both ]; then
  brc=$(run_counter RTV1 "$RTV1" "$C2_SH" "$ROOT/c2-baseline.out")
  bread=$(reading_of "$ROOT/c2-baseline.out")
  echo "C2 BASELINE rc=$brc reading=$bread target=3 file=$RTV1"
  if [ "$bread" != "3" ]; then
    echo "C2 INCONCLUSIVE-BASELINE: baseline reading $bread is not 3; no mutant judged"
    echo "MUTANTS C2: killed=0 survived=0 total=0"
  else
    python3 - "$RTV1" "$ROOT/mutants" >"$ROOT/c2-gen.tsv" <<'PY'
import os, re, sys

rtv1, outdir = sys.argv[1], sys.argv[2]
src = open(rtv1, encoding="utf-8").read()
QUOTE = "Matches Unicode whitespace characters (as defined by"
out = []

def record(name, status, info):
    out.append("%s\t%s\t%s" % (name, status, info))

lines = src.split("\n")
start = next((i for i, l in enumerate(lines) if l.startswith("Sources (")), None)
if start is None:
    sys.exit("run-mutants: no Sources paragraph")
end = len(lines)
for i in range(start + 1, len(lines)):
    if lines[i].strip() == "":
        end = i
        break
off = sum(len(l) + 1 for l in lines[:start])
endoff = sum(len(l) + 1 for l in lines[:end])
para = src[off:endoff]

def with_para(newpara):
    return src[:off] + newpara + src[endoff:]

def put(name, text, status, info):
    with open(os.path.join(outdir, name), "w", encoding="utf-8") as fh:
        fh.write(text)
    record(name, status, info)

ids = sorted(set(re.findall(r"S[0-9]{3}", para)))
for iid in ids:
    put("drop_%s" % iid, with_para(para.replace(iid, "")), "GEN", "drop id %s" % iid)
if ids:
    tgt = "S095" if "S095" in ids else ids[0]
    put("cite_S027", with_para(para.replace(tgt, "S027", 1)), "GEN", "cite S027 via %s" % tgt)
else:
    record("cite_S027", "NGEN", "no S### id in paragraph")

if QUOTE in para:
    cut = QUOTE.index("whitespace") + len("whitespace")
    split = QUOTE[:cut] + "\n" + QUOTE[cut:]
    put("split_quote", with_para(para.replace(QUOTE, split, 1)), "GEN", "newline inside quote")
    put("drop_quote", with_para(para.replace(QUOTE, "", 1)), "GEN", "quote removed")
else:
    record("split_quote", "NGEN", "quote absent from paragraph")
    record("drop_quote", "NGEN", "quote absent from paragraph")

put("syntax_break", src + "\n\nif:\n", "GEN", "module-level syntax break (selftest path dead)")
sys.stdout.write("".join(l + "\n" for l in out))
PY
    k=0; s=0; t=0; ngen=""
    while IFS=$'\t' read -r name status info; do
      [ -n "${name:-}" ] || continue
      if [ "$status" != "GEN" ]; then
        ngen="$ngen $name($info)"
        continue
      fi
      t=$((t + 1))
      mrc=$(run_counter RTV1 "$ROOT/mutants/$name" "$C2_SH" "$ROOT/c2-$name.out")
      mr=$(reading_of "$ROOT/c2-$name.out")
      if [ "$mr" = "INCONCLUSIVE" ]; then
        echo "C2 MUTANT $name rc=$mrc reading=INCONCLUSIVE verdict=inconclusive gen=$info"
      elif [ "$mr" -ne 3 ]; then
        k=$((k + 1))
        echo "C2 MUTANT $name rc=$mrc reading=$mr verdict=killed gen=$info"
      else
        s=$((s + 1))
        echo "C2 MUTANT $name rc=$mrc reading=$mr verdict=survived gen=$info"
      fi
    done <"$ROOT/c2-gen.tsv"
    echo "MUTANTS C2: killed=$k survived=$s total=$t"
    [ -n "$ngen" ] && echo "C2 NOT-GENERATED:$ngen"
  fi
fi

exit 0
