#!/usr/bin/env bash
# plans/round-61-controls.sh -- pre-freeze control battery for round 61 (kagi).
#   usage: bash plans/round-61-controls.sh [REF_TREE]   (REF_TREE defaults to the lane tree)
#          bash plans/round-61-controls.sh --emit-trees DIR   (materialize the forgery trees)
#
# Declared by plans/round-61.md section "Control plan" (frozen, commit 8595018):
# two no-work controls (both instruments on the claim BASE c940f516: C1 diagnostic
# value=7 population=7 with --no-challenge; C2 value=0 ... (absent)), seven forgery
# controls C1-F1..C1-F7 (each breaks exactly one item's substance in an otherwise
# fixed tree and must read value=1 on its own item and 0 on the others on the
# --no-challenge diagnostic leg), one printer-stub control (a stub that always
# prints value=0 must fail the guard's +1 challenge leg), five shim controls
# C2-SH1..SH5 (each KAGI_SEAL_SHIM=SHn run reads BROKEN holds=4 broken=1 with
# exactly test n moved), plus the two L1-routed vacuity controls C2-STUB and
# C2-FIXTURE-TRUTH (a counter fed fixture text must read value=0, never 5).
# 18 controls total.
#
# Control map (id -> required instrument):
#   C1-NOWORK  checker on a BASE copy: value=7 population=7, i1..i7 all 0  (round-61-c1-check.py)
#   C2-NOWORK  counter on a BASE copy: value=0 ... (absent), no trial at BASE (round-61-c2.sh)
#   C1-F1      R37 correction with the wrong result count -> i1=1 only
#   C1-F2      SKILL.md selftest cell names a script with no --selftest -> i2=1 only
#   C1-F3      A7 amendment that withdraws nothing -> i3=1 only
#   C1-F4      quality-trend correction naming two of three ids -> i4=1 only
#   C1-F5      LOG correction with deletions=2 -> i5=1 only
#   C1-F6      stale-lane correction with an invented launch timestamp -> i6=1 only
#   C1-F7      a round-60-c2.sh whose verdict mapping is inverted -> i2=1 only,
#              and the mutated copy's --selftest must exit non-zero with a named
#              FINDING id (the plan's K4 kill rule); the mutation applied is the
#              one the landed checker defines for its own I2 leg C, extracted at
#              run time from the checker's bytes, never assumed
#   C1-STUB    fixed tree reads 0, the I5 deletions=1 -> 2 challenge copy reads 1,
#              and a stub printing a constant value=0 line cannot satisfy the
#              challenge (delta 0, not +1)
#   C2-SH1..5  real trial runs under KAGI_SEAL_SHIM=SHn: BROKEN holds=4 broken=1
#              with exactly Tn moved (B at position n, H elsewhere)
#   C2-STUB    a copy of the candidate tree whose trial is a ~20-line stub printing
#              the full text contract (five HOLDS lines, the summary, the five shim
#              flips, SEAL_SELFTEST: PASS (cases=8), the no-bao SETUP leg) without
#              calling bao: the counter must read value=0; a 5 means the counter
#              trusts trial text and is vacuous (L1 route, critic-measured gap)
#   C2-FIXTURE-TRUTH  a copy whose trial is the real file but whose binary is
#              substituted through the counter's documented R61_BAO override with
#              a stub printing expected-shaped lines: the counter must refuse the
#              run before any TRIAL line with `SETUP bao-pin-mismatch` rc 2 (the
#              sha-pin gate; a caller-PATH stub is irrelevant - the counter
#              resolves BAO_BIN="${R61_BAO:-$HOME/.local/bin/bao}" and env -i's
#              the trial behind its own logging exec shim). Provenance: the
#              original expectation (value=0 via a caller-PATH stub) predates
#              the pin-gate understanding; the refusal is strictly stronger and
#              the expectation was re-pointed to it, not relaxed.
#   C2-HELPSTUB  a copy whose trial is a stub exercising only `bao <op> --help`
#              (bare-name argvs against the real binary) while printing the T2
#              markers must also read value=0: the counter's argv-shape witness
#              must refuse help-only executions (reviewer vacuity class C2-3).
#              18 controls total.
#
# The fixed tree the forgery controls break is synthesized here from the claim
# BASE plus the seven I1..I7 fixes, with every number derived at run time from
# the BASE bytes (w1-results.json, git numstat, git log stamps, the fleet
# watchdog launch line) or from the frozen condition's own literals -- the
# battery owns none of the claimed work. The I2 fix (a fixture-driven
# --selftest in plans/round-60-c2.sh) is overlaid from REF when it has landed;
# until then the fixed-tree controls print
#   CONTROL <id> SKIP <reason>
# which counts as a mismatch, not a match (the battery is re-run once the
# instruments and the fix land; the committed receipt must be the run against
# the final bytes, CONTROLS: match=<N> mismatch=0 or the honest mismatch list).
#
# Receipt: the battery's full stdout is installed at
#   .ufo/waves/round-61/controls/controls-prefreeze.txt
# every run (last run wins). Instrument pins: one "INSTRUMENT <path> <sha256>"
# line per measured instrument (MISSING when not on disk) plus one "BAO <path>
# <sha256>" line for the OpenBao binary the shim controls resolve; drift is
# re-checked and reported at the end.
#
# Every control works on copies under ${HYAKU_SCRATCH:-/fast/scratch/hyaku}/
# kagi-r61/R61ExecControls/battery.$$ and removes them on exit (trees emitted
# with --emit-trees live in the caller's DIR and are the caller's to clean);
# TMPDIR is pointed at the scratch too. No /tmp evidence, no writes inside a
# measured tree, no git/jj mutation (the BASE tree is materialized read-only
# with git archive), no secret value in the output: every line captured from an
# instrument is redacted to shape before it reaches this receipt.
set -u -o pipefail

REPO=$(cd "$(dirname "$0")/.." && pwd -P)
BASE=c940f51689d702f1786989d56ad4663833c1452e
REF=${1:-$REPO}
if [ "$REF" = "--emit-trees" ]; then EMIT_ONLY=1; REF=$REPO; else EMIT_ONLY=0; fi
REF=$(cd "$REF" && pwd -P)
SCR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r61/R61ExecControls/battery.$$
mkdir -p -- "$SCR" || exit 2
trap 'rm -rf -- "$SCR"' EXIT
export TMPDIR=$SCR
RECEIPT_REL=.ufo/waves/round-61/controls/controls-prefreeze.txt

C1CHECK="$REPO/plans/round-61-c1-check.py"
C2="$REPO/plans/round-61-c2.sh"
C2R60_REL=plans/round-60-c2.sh
TRIAL_REL=corpus/openbao-seal-trial.sh
RESULTS60_REL=.ufo/waves/round-60/w1-results.json
SKILL_REL=SKILL.md
LOG_REL=LOG.md
LESSON60_REL=corpus/lessons/round-60.md
PLAN60_REL=plans/round-60.md
SHIMVAR_DEFAULT=KAGI_SEAL_SHIM
BAO_PIN_SHA=9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788
BAO_FALLBACK=/home/vgpnk/.local/bin/bao
WATCHDOG=/home/vgpnk/Projects/shokunin/.ufo/watchdog.log
DEST=$SCR

M=0; K=0

report() { # ID EXPECT OBSERVED DETAIL  (exact string equality on expect/observed)
  local v=MISMATCH
  if [ "$2" = "$3" ]; then M=$((M + 1)); v=MATCH; else K=$((K + 1)); fi
  printf 'CONTROL %s expect=%s observed=%s %s :: %s\n' "$1" "$2" "$3" "$v" "$4"
}

report_skip() { # ID REASON  (a control that cannot run yet: mismatch, not a match)
  K=$((K + 1))
  printf 'CONTROL %s SKIP %s\n' "$1" "$2"
}

redact() { # secret-shape guard: long token runs become [REDACTED] (QM72: shapes, never values)
  sed -E 's/[A-Za-z0-9+\/_-]{43,}/[REDACTED]/g'
}

copy_tree() { # SRC DST -- worktree copy, VCS internals excluded
  mkdir -p "$2" || return 1
  ( cd "$1" && tar --exclude=./.git --exclude=./.jj -cf - . ) | tar -xf - -C "$2"
}

base_tree() { # DST -- the claim BASE revision, materialized read-only
  mkdir -p "$1" || return 1
  git -C "$REPO" archive "$BASE" | tar -xf - -C "$1"
}

# --- instrument presence -------------------------------------------------------
have_c1check=0; [ -f "$C1CHECK" ] && have_c1check=1
have_c2=0;       [ -f "$C2" ] && have_c2=1
have_trial=0;    [ -f "$REF/$TRIAL_REL" ] && have_trial=1
have_c2self=0
if [ -f "$REF/$C2R60_REL" ] && grep -q -- '--selftest' "$REF/$C2R60_REL" 2>/dev/null \
   && grep -q 'C2_SELFTEST: PASS' "$REF/$C2R60_REL" 2>/dev/null; then
  have_c2self=1
fi

# The shim env var and the trial's summary prefix are derived from the landed
# bytes, with the frozen names as fallback -- never assumed from this file.
SHIMVAR=""
[ "$have_c2" = 1 ] && SHIMVAR=$(grep -oE '[A-Z][A-Z0-9_]+_SHIM' "$C2" 2>/dev/null | sort -u | head -1)
if [ -z "$SHIMVAR" ] && [ "$have_trial" = 1 ]; then
  SHIMVAR=$(grep -oE '[A-Z][A-Z0-9_]+_SHIM' "$REF/$TRIAL_REL" 2>/dev/null | sort -u | head -1)
fi
[ -z "$SHIMVAR" ] && SHIMVAR=$SHIMVAR_DEFAULT
TRIAL_PREFIX=""
[ "$have_trial" = 1 ] && TRIAL_PREFIX=$(grep -oE 'OPENBAO_[A-Z0-9_]+_TRIAL' "$REF/$TRIAL_REL" 2>/dev/null | sort -u | head -1)

# Bao resolution: PATH first, the pinned operator binary as fallback.
BAOBIN=$(command -v bao 2>/dev/null || true)
if [ -z "$BAOBIN" ] && [ -x "$BAO_FALLBACK" ]; then
  BAOBIN=$BAO_FALLBACK
  export PATH="$(dirname "$BAO_FALLBACK"):$PATH"
fi

# --- C1 harness ---------------------------------------------------------------
C1_LAST_GUARD=?
c1diag() { # TREE -> "value=<v> population=<p> i1=.. .. i7=.." (guard kept for the detail)
  local t=$1 out rc line v p g vec iv i
  out=$(timeout 600 python3 -I -B "$C1CHECK" --root "$t" --repo "$REPO" --no-challenge 2>/dev/null)
  rc=$?
  if [ "$rc" = 124 ]; then printf 'timeout'; return 0; fi
  line=$(printf '%s\n' "$out" | grep -E '^C1_ROUTED:' | tail -1)
  if [ -z "$line" ]; then printf 'noline'; return 0; fi
  v=$(sed -n 's/^C1_ROUTED: value=\([^ ]*\).*/\1/p' <<<"$line")
  p=$(sed -n 's/.*[^0-9]population=\([0-9][0-9]*\).*/\1/p' <<<"$line")
  g=$(sed -n 's/.*[^0-9]guard=\([0-9][0-9]*\).*/\1/p' <<<"$line")
  vec=""
  for i in 1 2 3 4 5 6 7; do
    iv=$(sed -n "s/.*[^0-9]i$i=\([01]\).*/\1/p" <<<"$line")
    vec="$vec i$i=${iv:-?}"
  done
  C1_LAST_GUARD=${g:-?}
  printf 'value=%s population=%s%s' "${v:-none}" "${p:-none}" "$vec"
}

want_vec() { # BROKEN_INDEX -> " i1=.. .. i7=.." with exactly that item UNRESOLVED (i=0);
#             the checker prints i<n>=1 for HOLD (resolved) and value = the unresolved count
  local n=$1 vec="" i
  for i in 1 2 3 4 5 6 7; do
    if [ "$i" = "$n" ]; then vec="$vec i$i=0"; else vec="$vec i$i=1"; fi
  done
  printf '%s' "$vec"
}

# --- derived numbers (measured from the BASE bytes, never assumed) ------------
derive_w1() { # BASETREE -> sets W1_TOTAL W1_B W1_A  (records, output bytes, literal attack roles)
  python3 - "$1/$RESULTS60_REL" <<'PY'
import json, sys
d = json.load(open(sys.argv[1], encoding="utf-8"))
rs = d if isinstance(d, list) else [v for v in d.values() if isinstance(v, list)][0]
total = len(rs)
mut = [r for r in rs if "R60MutCounters" in json.dumps(
    {k: r.get(k) for k in ("id", "name", "agent", "seat", "note")}, default=str)]
b = len((mut[0].get("output") or "").encode()) if mut else ""
agents = {r.get("agent") for r in rs}
a = len(agents & {"reviewer", "critic", "mutation-tester", "labrat"})
print(total, b, a)
PY
}

derive_numstat() { # -> "I D" from git diff --numstat 14a6c07d 818d2a82 -- LOG.md
  git -C "$REPO" diff --numstat 14a6c07d 818d2a82 -- LOG.md | awk '{print $1, $2}'
}

derive_stamps() { # -> three "-0300 / -03:00" stamp pairs from the named revision range
  git -C "$REPO" log --format='%ci' a677c78e..818d2a82 | python3 -c '
import sys
stamps = [l.strip() for l in sys.stdin if l.strip()][:3]
out = []
for s in stamps:
    iso = s.replace(" -0300", "").replace(" ", "T", 1) + "-03:00"
    out.append(f"{s} / {iso}")
print("; ".join(out))
'
}

derive_launch() { # -> the driver launch line prefix from the fleet watchdog log (frozen literal as fallback)
  local l=""
  [ -r "$WATCHDOG" ] && l=$(grep -oE '[0-9T:+-]+ launch kagi round=60' "$WATCHDOG" 2>/dev/null | head -1)
  [ -z "$l" ] && l='2026-11-07T15:03:17-03:00 launch kagi round=60'
  printf '%s' "$l"
}

# --- synthetic fixed tree (all seven I1..I7 fixes; numbers derived, not assumed) --
build_fixed_tree() { # NAME [f3-restates] -> $DEST/NAME; fails loudly when a derivation is missing
  local T="$DEST/$1" restates="${2:-}" RD NS
  base_tree "$T" || return 1

  RD=$(derive_w1 "$T") || return 1
  W1_TOTAL=${RD%% *}; RD=${RD#* }
  W1_B=${RD%% *}; RD=${RD#* }
  W1_A=${RD%% *}
  [ -n "$W1_TOTAL" ] && [ -n "$W1_B" ] && [ -n "$W1_A" ] || return 1
  NS=$(derive_numstat) || return 1
  NSI=${NS%% *}; NSD=${NS##* }
  [ -n "$NSI" ] && [ -n "$NSD" ] || return 1
  STAMPS=$(derive_stamps) || return 1
  [ "$(printf '%s' "$STAMPS" | grep -o '/ 2026-' | wc -l)" -eq 3 ] || return 1
  LAUNCH=$(derive_launch)
  [ -n "$LAUNCH" ] || return 1

  # I1 + I4 + I6 + I7 + the I3 lesson line (M60-2, second instance): one appended
  # correction block after the routed-dispositions table (i.e. after the R37 line,
  # which the routed table carries).
  python3 - "$T/$LESSON60_REL" "$W1_TOTAL" "$W1_B" "$W1_A" "$STAMPS" "$LAUNCH" <<'PY'
import sys
path, total, ob, a, stamps, launch = sys.argv[1:7]
pct_a = f"{int(a) * 100 / int(total):g}"
pct_s = f"{(int(a) + 1) * 100 / int(total):g}"
block = [
    f"- Correction (supersedes R37): the mutation-tester seat did produce artifacts and a report; the wave file .ufo/waves/round-60/w1-results.json holds results={total} output={ob} for the R60MutCounters record's final output, and its artifacts are committed under .ufo/waves/round-60/build/R60MutCounters/ (mutants.md).\n",
    "- Correction (supersedes the round-60 quality-trend sentence): the report's sentence \"The round introduced no new record defect that it did not itself route (R32-R43)\" is false; the round introduced three new record defects it did not route: D1, D2 and D3.\n",
    f"- Correction (supersedes the round-60 stale-lane paragraph): the driver launch line is {launch} pgid=134532 driver=hyaku-inline attempt=1, not launch 15:09:28; the lane commits inside the driver window carry stamps that occur in git log --format='%ci' a677c78e..818d2a82: {stamps}.\n",
    f"- Correction (supersedes the round-60 attack-share arithmetic): the report's \"{int(a) + 1}/{total} = {pct_s} % on the addendum's literal list\" miscounts; the literal list holds {a} present seats (reviewer, critic, mutation-tester; no labrat exists), so {a}/{total} = {pct_a} %, and {int(a) + 1}/{total} = {pct_s} % counts the sentinel.\n",
    "- Correction (M60-2, second instance): plans/round-60.md A3 item 2 asserted the form-encoded-body behaviour its cited receipt .ufo/waves/round-60/final/l1-probe.txt does not carry; this is the second instance of M60-2, and the item is handled by Amendment A7 in the round-60 plan.\n",
]
lines = open(path, encoding="utf-8", errors="surrogateescape").readlines()
idx = max(i for i, l in enumerate(lines) if l.startswith("| R") and " R37 " in l)
lines[idx + 1:idx + 1] = block
open(path, "w", encoding="utf-8", errors="surrogateescape").writelines(lines)
PY
  [ $? = 0 ] || return 1

  # I5 (LOG.md): appended after the round-60 wave line (the kagi-r60-w1 line).
  printf -- '- Correction (supersedes the round-60 LOG wave line): the round-60 wave line was rewritten in place at 818d2a82 against 14a6c07d (git diff --numstat 14a6c07d 818d2a82 -- LOG.md reads insertions=%s deletions=%s) instead of an appended correction; the superseded text is recoverable at 14a6c07d.\n' "$NSI" "$NSD" >> "$T/$LOG_REL"

  # I3 (plans/round-60.md): Amendment A7 appended after the A6 block (end of file).
  if [ "$restates" = f3-restates ]; then
    cat >> "$T/$PLAN60_REL" <<'EOF'

## Amendment A7 — 2026-11-07, before the recorded candidate reading (restates A3 item 2)

A3 item 2 is restated: its cited receipt `.ufo/waves/round-60/final/l1-probe.txt` carries
the form-encoded-body leg, and the behaviour the item asserts (role creation returns 204
with defaults and every login reads 400 invalid role or secret ID when the login body is
form-encoded) stands exactly as written. The item's claim basis is unchanged.
EOF
  else
    cat >> "$T/$PLAN60_REL" <<'EOF'

## Amendment A7 — 2026-11-07, before the recorded candidate reading (withdraws A3 item 2)

A3 item 2 is withdrawn: its cited receipt `.ufo/waves/round-60/final/l1-probe.txt` carries
no form-encoded-body leg, so the behaviour the item asserts (role creation returns 204 with
defaults and every login reads 400 invalid role or secret ID when the login body is
form-encoded) was never measured. The item's claim basis is withdrawn; the measured AppRole
setup facts in A3 item 1 are unaffected.
EOF
  fi

  # I2 (SKILL.md): the gate-registry row naming plans/round-60-c2.sh re-registered
  # with --selftest; the "none of its own" text gone. The script itself is the
  # landed REF bytes (gate: have_c2self), overlaid after this edit.
  python3 - "$T/$SKILL_REL" <<'PY'
import sys
path = sys.argv[1]
lines = open(path, encoding="utf-8", errors="surrogateescape").readlines()
out, done = [], 0
for l in lines:
    if not done and l.lstrip().startswith("|") and "plans/round-60-c2.sh" in l \
            and "none of its own" in l:
        cells = l.split("|")
        for i, c in enumerate(cells):
            if "none of its own" in c:
                cells[i] = " `bash plans/round-60-c2.sh --selftest` => `C2_SELFTEST: PASS (cases=N)`, fixture-driven (no `bao`, no network), red witness on a mutated copy "
                done = 1
        l = "|".join(cells)
    out.append(l)
open(path, "w", encoding="utf-8", errors="surrogateescape").writelines(out)
raise SystemExit(0 if done else 3)
PY
  [ $? = 0 ] || return 1

  # I2 leg A/B: the landed counter with its --selftest, overlaid from REF.
  [ "$have_c2self" = 1 ] || return 2
  cp "$REF/$C2R60_REL" "$T/$C2R60_REL" || return 1
  return 0
}

# --- per-control substance breaks (shared by the controls and --emit-trees) ----
apply_verdict_mutation() { # TARGET_SCRIPT -> 0 when the checker-defined mutation was applied
  python3 - "$C1CHECK" "$1" 2>&1 <<'PY'
import re, sys
checker, target = sys.argv[1], sys.argv[2]
src = open(checker, encoding="utf-8", errors="surrogateescape").read()
text = open(target, encoding="utf-8", errors="surrogateescape").read()
needle = mutated = None
m = re.search(r"ST_NEEDLE\s*=\s*'([^']*)'", src) or re.search(r'ST_NEEDLE\s*=\s*"([^"]*)"', src)
n = re.search(r"ST_MUTATED\s*=\s*'([^']*)'", src) or re.search(r'ST_MUTATED\s*=\s*"([^"]*)"', src)
if m and n:
    needle, mutated = m.group(1), n.group(1)
else:
    m = re.search(r'([A-Z0-9_]*NEEDLE[A-Z0-9_]*)\s*=\s*"([^"]+)"', src)
    if m:
        base = m.group(1).replace("NEEDLE", "MUTATED")
        n = re.search(base + r'\s*=\s*"([^"]+)"', src)
        if n:
            needle, mutated = m.group(2), n.group(1)
if not needle or needle == mutated:
    print("no (needle, mutated) pair found in the checker bytes")
    raise SystemExit(3)
cnt = text.count(needle)
if cnt != 1:
    print(f"needle occurs {cnt} times in the counter (exactly 1 required)")
    raise SystemExit(4)
open(target, "w", encoding="utf-8", errors="surrogateescape").write(text.replace(needle, mutated, 1))
print("applied the checker's verdict-mapping mutation")
PY
}

apply_forge() { # CONTROL-ID TREE -> 0 when the substance break was applied
  case "$1" in
    C1-F1) # a R37 correction with the wrong result count (last occurrence wins)
      printf -- '- Correction (supersedes R37; revised): the wave file .ufo/waves/round-60/w1-results.json holds results=%s output=%s for the R60MutCounters record'"'"'s final output, and its artifacts are committed under .ufo/waves/round-60/build/R60MutCounters/ (mutants.md).\n' "$((W1_TOTAL + 1))" "$W1_B" >> "$2/$LESSON60_REL" ;;
    C1-F2) # the registry row names a script with no --selftest (BASE counter restored)
      git -C "$REPO" show "$BASE:$C2R60_REL" > "$2/$C2R60_REL" ;;
    C1-F3) : ;; # the restates variant is applied by the builder at build time
    C1-F4) # a quality-trend correction naming two of three ids
      printf -- '- Correction (supersedes the round-60 quality-trend sentence; revised): the report'"'"'s sentence "The round introduced no new record defect that it did not itself route (R32-R43)" is false; the round introduced three new record defects it did not route: D1 and D2.\n' >> "$2/$LESSON60_REL" ;;
    C1-F5) # a LOG correction with deletions=2 (measured: NSD)
      printf -- '- Correction (supersedes the round-60 LOG wave line; revised): the round-60 wave line was rewritten in place at 818d2a82 against 14a6c07d (git diff --numstat 14a6c07d 818d2a82 -- LOG.md reads insertions=%s deletions=2) instead of an appended correction; the superseded text is recoverable at 14a6c07d.\n' "$NSI" >> "$2/$LOG_REL" ;;
    C1-F6) # a stale-lane correction with an invented launch timestamp
      printf -- '- Correction (supersedes the round-60 stale-lane paragraph; revised): the driver launch line is 2026-11-07T15:09:28-03:00 launch kagi round=60 pgid=134532 driver=hyaku-inline attempt=1; the lane commits inside the driver window carry stamps that occur in git log --format='"'"'%%ci'"'"' a677c78e..818d2a82: %s.\n' "$STAMPS" >> "$2/$LESSON60_REL" ;;
    C1-F7) # an inverted verdict mapping: the checker's own leg-C mutation
      apply_verdict_mutation "$2/$C2R60_REL" >/dev/null ;;
    *) return 3 ;;
  esac
}

apply_stub_challenge() { # SRC DST -- the guard's challenge copy (I5 deletions=1 -> 2)
  cp -a "$1" "$2" || return 1
  python3 - "$2/$LOG_REL" <<'PY'
import sys
path = sys.argv[1]
text = open(path, encoding="utf-8", errors="surrogateescape").read()
i = text.find("deletions=1")
if i < 0:
    raise SystemExit(3)
open(path, "w", encoding="utf-8", errors="surrogateescape").write(
    text[:i] + "deletions=2" + text[i + len("deletions=1"):])
PY
}

# =========================== no-work controls ================================
ctrl_c1_nowork() {
  if [ "$have_c1check" != 1 ]; then
    report_skip C1-NOWORK "no-checker (plans/round-61-c1-check.py is not on disk yet)"
    return 0
  fi
  report C1-NOWORK "value=7 population=7 i1=0 i2=0 i3=0 i4=0 i5=0 i6=0 i7=0" \
    "$(c1diag "$SCR/base")" \
    "C1 diagnostic (--no-challenge) on the claim BASE: all seven routed items unresolved (kill rule K2: any lower reading voids the claim); guard=${C1_LAST_GUARD} (diag leg, challenge not run)"
}

ctrl_c2_nowork() {
  if [ "$have_c2" != 1 ]; then
    report_skip C2-NOWORK "no-counter (plans/round-61-c2.sh is not on disk yet)"
    return 0
  fi
  local out rc line obs
  out=$(timeout 300 bash "$C2" --tree "$SCR/base" 2>/dev/null); rc=$?
  if [ "$rc" = 124 ]; then obs=timeout; else
    line=$(printf '%s\n' "$out" | grep -E '^C2_[A-Z0-9_]+:' | tail -1)
    if printf '%s' "$line" | grep -q 'value=0' && printf '%s' "$line" | grep -q '(absent)'; then
      obs='value=0 (absent)'
    elif [ -n "$line" ]; then
      obs=$(printf '%s' "$line" | grep -oE 'value=[^ ]*|\(absent\)|SETUP[^ ]*' | tr '\n' ' ' | sed 's/ $//')
      [ -n "$obs" ] || obs=noline
    else
      obs="none/rc$rc"
    fi
  fi
  report C2-NOWORK 'value=0 (absent)' "$obs" \
    "C2 on the claim BASE: the seal trial does not exist at BASE (absent line, no server work); command: bash plans/round-61-c2.sh --tree <BASE copy>"
}

# =========================== C1 forgeries ====================================
# Each builds the clean fixed tree, breaks exactly one item's substance while
# leaving satisfied-looking text, and must read value=1 with exactly its own
# item at 1 (the --no-challenge diagnostic leg).

ctrl_c1_f1() {
  if [ "$have_c1check" != 1 ] || [ "$have_c2self" != 1 ]; then
    report_skip C1-F1 "needs the checker and the landed round-60-c2.sh --selftest (I2 fix) to build a fully fixed tree"; return 0
  fi
  build_fixed_tree c1f1 || { report C1-F1 "value=1 population=7$(want_vec 1)" "build-failed(rc$?)" "fixed-tree build failed"; return 0; }
  apply_forge C1-F1 "$SCR/c1f1" || { report C1-F1 "value=1 population=7$(want_vec 1)" "forge-failed" "substance break failed"; return 0; }
  report C1-F1 "value=1 population=7$(want_vec 1)" "$(c1diag "$SCR/c1f1")" \
    "I1 substance broken by a last superseding R37 correction whose result count is wrong (results=$((W1_TOTAL + 1)) vs measured $W1_TOTAL, otherwise satisfied-looking); diagnostic leg, guard=${C1_LAST_GUARD}"
}

ctrl_c1_f2() {
  if [ "$have_c1check" != 1 ] || [ "$have_c2self" != 1 ]; then
    report_skip C1-F2 "needs the checker and the landed round-60-c2.sh --selftest (I2 fix) to build a fully fixed tree"; return 0
  fi
  build_fixed_tree c1f2 || { report C1-F2 "value=1 population=7$(want_vec 2)" "build-failed(rc$?)" "fixed-tree build failed"; return 0; }
  apply_forge C1-F2 "$SCR/c1f2" || { report C1-F2 "value=1 population=7$(want_vec 2)" "forge-failed" "substance break failed"; return 0; }
  report C1-F2 "value=1 population=7$(want_vec 2)" "$(c1diag "$SCR/c1f2")" \
    "I2 substance broken: the registry row looks satisfied (carries --selftest) but the script it names has no --selftest mode (BASE counter restored); diagnostic leg, guard=${C1_LAST_GUARD}"
}

ctrl_c1_f3() {
  if [ "$have_c1check" != 1 ] || [ "$have_c2self" != 1 ]; then
    report_skip C1-F3 "needs the checker and the landed round-60-c2.sh --selftest (I2 fix) to build a fully fixed tree"; return 0
  fi
  build_fixed_tree c1f3 f3-restates || { report C1-F3 "value=1 population=7$(want_vec 3)" "build-failed(rc$?)" "fixed-tree build failed"; return 0; }
  report C1-F3 "value=1 population=7$(want_vec 3)" "$(c1diag "$SCR/c1f3")" \
    "I3 substance broken: the A7 block names A3 item 2, form and l1-probe.txt but restates instead of withdrawing (no 'withdrawn'); diagnostic leg, guard=${C1_LAST_GUARD}"
}

ctrl_c1_f4() {
  if [ "$have_c1check" != 1 ] || [ "$have_c2self" != 1 ]; then
    report_skip C1-F4 "needs the checker and the landed round-60-c2.sh --selftest (I2 fix) to build a fully fixed tree"; return 0
  fi
  build_fixed_tree c1f4 || { report C1-F4 "value=1 population=7$(want_vec 4)" "build-failed(rc$?)" "fixed-tree build failed"; return 0; }
  apply_forge C1-F4 "$SCR/c1f4" || { report C1-F4 "value=1 population=7$(want_vec 4)" "forge-failed" "substance break failed"; return 0; }
  report C1-F4 "value=1 population=7$(want_vec 4)" "$(c1diag "$SCR/c1f4")" \
    "I4 substance broken: the last superseding correction still quotes 'no new record defect' and states three, but names D1 and D2 only; diagnostic leg, guard=${C1_LAST_GUARD}"
}

ctrl_c1_f5() {
  if [ "$have_c1check" != 1 ] || [ "$have_c2self" != 1 ]; then
    report_skip C1-F5 "needs the checker and the landed round-60-c2.sh --selftest (I2 fix) to build a fully fixed tree"; return 0
  fi
  build_fixed_tree c1f5 || { report C1-F5 "value=1 population=7$(want_vec 5)" "build-failed(rc$?)" "fixed-tree build failed"; return 0; }
  apply_forge C1-F5 "$SCR/c1f5" || { report C1-F5 "value=1 population=7$(want_vec 5)" "forge-failed" "substance break failed"; return 0; }
  report C1-F5 "value=1 population=7$(want_vec 5)" "$(c1diag "$SCR/c1f5")" \
    "I5 substance broken: the last LOG correction states deletions=2 where the checker derives insertions=$NSI deletions=$NSD; diagnostic leg, guard=${C1_LAST_GUARD}"
}

ctrl_c1_f6() {
  if [ "$have_c1check" != 1 ] || [ "$have_c2self" != 1 ]; then
    report_skip C1-F6 "needs the checker and the landed round-60-c2.sh --selftest (I2 fix) to build a fully fixed tree"; return 0
  fi
  build_fixed_tree c1f6 || { report C1-F6 "value=1 population=7$(want_vec 6)" "build-failed(rc$?)" "fixed-tree build failed"; return 0; }
  apply_forge C1-F6 "$SCR/c1f6" || { report C1-F6 "value=1 population=7$(want_vec 6)" "forge-failed" "substance break failed"; return 0; }
  report C1-F6 "value=1 population=7$(want_vec 6)" "$(c1diag "$SCR/c1f6")" \
    "I6 substance broken: the last correction names an invented launch timestamp (15:09:28, the routed defect's own wrong value) beside the real commit stamps; diagnostic leg, guard=${C1_LAST_GUARD}"
}

ctrl_c1_f7() {
  if [ "$have_c1check" != 1 ] || [ "$have_c2self" != 1 ]; then
    report_skip C1-F7 "needs the checker and the landed round-60-c2.sh --selftest (I2 fix) to build a fully fixed tree"; return 0
  fi
  build_fixed_tree c1f7 || { report C1-F7 "value=1 population=7$(want_vec 2)" "build-failed(rc$?)" "fixed-tree build failed"; return 0; }
  local mout rc fid
  mout=$(apply_verdict_mutation "$SCR/c1f7/$C2R60_REL"); rc=$?
  if [ "$rc" != 0 ]; then
    report C1-F7 "value=1 population=7$(want_vec 2)" "mutation-failed(rc$rc)" \
      "could not apply the checker-defined verdict-mapping mutation: $(printf '%s' "$mout" | head -1 | cut -c1-160)"
    return 0
  fi
  # K4 witness: the mutated copy's --selftest must exit non-zero with a named FINDING.
  mout=$(timeout 300 bash "$SCR/c1f7/$C2R60_REL" --selftest 2>&1); rc=$?
  fid=$(printf '%s\n' "$mout" | grep -oE 'FINDING[[:space:]]+[A-Za-z0-9._-]+' | head -1)
  if [ "$rc" -eq 0 ] || [ -z "$fid" ] || ! printf '%s\n' "$mout" | grep -q FAIL; then
    report C1-F7 "value=1 population=7$(want_vec 2)" "witness-broken(rc$rc$( [ -n "$fid" ] && printf '/%s' "$fid" || printf '/no-finding' ))" \
      "K4: the inverted-mapping copy's --selftest must exit non-zero printing FAIL with a named FINDING id"
    return 0
  fi
  report C1-F7 "value=1 population=7$(want_vec 2)" "$(c1diag "$SCR/c1f7")" \
    "I2 substance broken by an inverted verdict mapping (the checker's own leg-C mutation; K4 witness: mutated --selftest rc=$rc, finding $fid); diagnostic leg, guard=${C1_LAST_GUARD}"
}

# =========================== printer-stub control ============================
ctrl_c1_stub() {
  if [ "$have_c1check" != 1 ] || [ "$have_c2self" != 1 ]; then
    report_skip C1-STUB "needs the checker and the landed round-60-c2.sh --selftest (I2 fix) to build a fully fixed tree"; return 0
  fi
  build_fixed_tree c1stub || { report C1-STUB stub-fails-challenge "build-failed(rc$?)" "fixed-tree build failed"; return 0; }
  local va vb vc
  va=$(c1diag "$SCR/c1stub")
  apply_stub_challenge "$SCR/c1stub" "$SCR/c1stubc" || { report C1-STUB stub-fails-challenge "flip-failed" "the I5 deletions=1 -> 2 challenge copy failed"; return 0; }
  vb=$(c1diag "$SCR/c1stubc")
  printf '%s\n' 'print("C1_ROUTED: value=0 population=7 i1=0 i2=0 i3=0 i4=0 i5=0 i6=0 i7=0 guard=1")' > "$SCR/stub.py"
  vc=$(python3 -I -B "$SCR/stub.py" --root "$SCR/c1stubc" --repo "$REPO" --no-challenge 2>/dev/null \
       | sed -n 's/^C1_ROUTED: value=\([0-9]*\).*/\1/p' | tail -1)
  if [ "$va" = "value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1" ] \
     && [ "$vb" = "value=1 population=7 i1=1 i2=1 i3=1 i4=1 i5=0 i6=1 i7=1" ] \
     && [ "$vc" = "0" ]; then
    report C1-STUB stub-fails-challenge stub-fails-challenge \
      "fixed tree $va; challenge copy (I5 deletions=1 -> 2) $vb (value+1); the constant value=0 stub reads value=0 on the same copy and cannot satisfy the challenge"
  else
    report C1-STUB stub-fails-challenge "fixed=[$va] challenge=[$vb] stub=[${vc:-none}]" \
      "expected fixed value=0, challenge value=1 (i5 flipped), stub value=0"
  fi
}

# =========================== C2 shim controls ================================
shim_vector() { # trial text on stdin -> five-char H/B vector in T1..T5 order ("" when unparsable)
  python3 -c '
import re, sys
out = sys.stdin.read()
seen = {}
for m in re.finditer(r"^TRIAL\s+T([1-5])\s+(HOLDS|BROKEN)\b", out, re.M):
    seen.setdefault(int(m.group(1)), m.group(2))
if len(seen) != 5:
    print("", end="")
else:
    print("".join("B" if seen[i] == "BROKEN" else "H" for i in (1, 2, 3, 4, 5)), end="")
'
}

ctrl_c2_sh() { # N
  local n=$1
  local id="C2-SH$n" want work out rc sum vec obs
  if [ "$have_c2" != 1 ] || [ "$have_trial" != 1 ] || [ -z "$TRIAL_PREFIX" ]; then
    report_skip "$id" "needs plans/round-61-c2.sh, corpus/openbao-seal-trial.sh, and a derivable trial summary prefix"
    return 0
  fi
  if [ -z "$BAOBIN" ]; then
    report_skip "$id" "no bao on PATH and $BAO_FALLBACK is not executable"
    return 0
  fi
  want=$(python3 -c "print(''.join('B' if i == $n else 'H' for i in range(1, 6)))")
  work="$SCR/sh$n"
  mkdir -p "$work" || { report "$id" "BROKEN holds=4 broken=1 $want" "work-failed" "scratch work dir failed"; return 0; }
  out=$(env "$SHIMVAR=SH$n" timeout 900 bash "$REF/$TRIAL_REL" --work "$work" 2>&1); rc=$?
  if [ "$rc" = 124 ]; then
    report "$id" "BROKEN holds=4 broken=1 $want" "timeout" "SH$n run did not terminate within 900s"
    return 0
  fi
  sum=$(printf '%s\n' "$out" | grep -E "^${TRIAL_PREFIX}:" | tail -1)
  vec=$(shim_vector <<<"$out")
  if [ -z "$sum" ] || [ -z "$vec" ]; then
    obs=$(printf '%s\n' "$out" | grep -E ': (SETUP|ERROR)' | head -1 | cut -c1-160 | redact)
    [ -n "$obs" ] || obs="no-summary/rc$rc"
    report "$id" "BROKEN holds=4 broken=1 $want" "$obs" "SH$n run produced no parsable summary/vector"
    return 0
  fi
  obs=$(printf '%s' "$sum" | grep -oE '(HOLDS|BROKEN) holds=[0-9]+ broken=[0-9]+' | head -1)
  if [ -n "$obs" ]; then obs="$obs $vec"; else obs=$(printf '%s' "$sum" | cut -c1-160 | redact); fi
  report "$id" "BROKEN holds=4 broken=1 $want" "$obs" \
    "SH$n must flip exactly its designated test (vector $want, trial rc=$rc, command: $SHIMVAR=SH$n bash corpus/openbao-seal-trial.sh --work <scratch>); summary redacted to shape"
}

# ====================== C2 vacuity controls (L1 route) =======================
gen_stub_trial() { # DST PREFIX SHIMVAR -- fixture trial printing the full text contract; no bao
  local dst=$1 prefix=$2 shim=$3
  cat > "$dst" <<EOF
#!/usr/bin/env bash
# battery fixture trial (C2-STUB): prints the trial's text contract; calls no bao
set -u
prefix="$prefix"; shim="\${$shim:-}"
command -v bao >/dev/null 2>&1 || { echo "\$prefix: SETUP no bao on PATH"; exit 2; }
if [ "\${1:-}" = "--selftest" ]; then echo "SEAL_SELFTEST: PASS (cases=8)"; exit 0; fi
rc=0
for t in 1 2 3 4 5; do
  v=HOLDS
  if [ -n "\$shim" ] && [ "\$shim" = "SH\$t" ]; then v=BROKEN; rc=1; fi
  echo "TRIAL T\$t \$v ok"
done
if [ "\$rc" = 0 ]; then echo "\$prefix: HOLDS holds=5 broken=0 error=0 bao=v2.7.2"
else echo "\$prefix: BROKEN holds=4 broken=1 error=0 bao=v2.7.2"; fi
exit "\$rc"
EOF
  chmod +x "$dst"
}

c2_value_reading() { # COUNTER TREE TIMEOUT -> value=<v> | none/rc<N> | timeout
  local out rc line v
  out=$(timeout "$3" bash "$C2" --tree "$2" 2>&1); rc=$?
  if [ "$rc" = 124 ]; then printf 'timeout'; return 0; fi
  line=$(printf '%s\n' "$out" | grep -E '^C2_[A-Z0-9_]+:' | tail -1)
  v=$(printf '%s' "$line" | grep -oE 'value=[^ ]*' | head -1)
  if [ -n "$v" ]; then printf '%s' "$v"
  elif [ -n "$line" ]; then printf 'summary-malformed/rc%s' "$rc"
  else printf 'none/rc%s' "$rc"; fi
}

ctrl_c2_stub() {
  if [ "$have_c2" != 1 ]; then
    report_skip C2-STUB "no-counter (plans/round-61-c2.sh is not on disk yet)"; return 0
  fi
  copy_tree "$REF" "$SCR/c2stub" || { report C2-STUB "value=0" "copy-failed" "fixture tree copy failed"; return 0; }
  gen_stub_trial "$SCR/c2stub/$TRIAL_REL" "${TRIAL_PREFIX:-OPENBAO_SEAL_TRIAL}" "$SHIMVAR" \
    || { report C2-STUB "value=0" "stub-gen-failed" "stub trial generation failed"; return 0; }
  report C2-STUB "value=0" "$(c2_value_reading "$C2" "$SCR/c2stub" 600)" \
    "fixture trial prints the full text contract (HOLDS x5, summary, shim flips, SEAL_SELFTEST cases=8, no-bao SETUP) without calling bao; command: bash plans/round-61-c2.sh --tree <fixture copy>; a 5 means the counter trusts trial text and is vacuous"
}

ctrl_c2_fixture_truth() {
  if [ "$have_c2" != 1 ] || [ "$have_trial" != 1 ]; then
    report_skip C2-FIXTURE-TRUTH "needs plans/round-61-c2.sh and the landed corpus/openbao-seal-trial.sh"; return 0
  fi
  copy_tree "$REF" "$SCR/c2truth" || { report C2-FIXTURE-TRUTH "SETUP bao-pin-mismatch/rc2" "copy-failed" "fixture tree copy failed"; return 0; }
  mkdir -p "$SCR/fakebin" || { report C2-FIXTURE-TRUTH "SETUP bao-pin-mismatch/rc2" "fakebin-failed" "fake bin dir failed"; return 0; }
  cat > "$SCR/fakebin/bao" <<'EOF'
#!/usr/bin/env bash
# battery fixture bao (C2-FIXTURE-TRUTH): expected-shaped output, operates nothing
case "${1:-}" in
  version|-v|--version) echo "OpenBao v2.7.2" ;;
  *) echo '{"fixture":true}' ;;
esac
exit 0
EOF
  chmod +x "$SCR/fakebin/bao"
  local out rc line obs
  out=$(R61_BAO="$SCR/fakebin/bao" timeout 600 bash "$C2" --tree "$SCR/c2truth" 2>&1); rc=$?
  line=$(printf '%s\n' "$out" | grep -E '^C2_[A-Z0-9_]+:' | tail -1)
  if [ "$rc" = 2 ] && printf '%s' "$line" | grep -q 'SETUP bao-pin-mismatch'; then
    obs="SETUP bao-pin-mismatch/rc2"
  else
    obs=$(printf '%s' "$line" | grep -oE 'value=[^ ]*|SETUP[^ ]*' | head -1)
    [ -n "$obs" ] && obs="$obs/rc$rc" || obs="none/rc$rc"
  fi
  report C2-FIXTURE-TRUTH "SETUP bao-pin-mismatch/rc2" "$obs" \
    "real trial in the tree, the binary substituted through the counter's documented R61_BAO override with a stub printing expected-shaped lines; command: R61_BAO=<stub> bash plans/round-61-c2.sh --tree <real-trial copy>; PROVENANCE (L1 adjudication): the original expectation (value=0 via a caller-PATH stub) was written before the counter's pin-gate was understood; the measured behaviour is the refusal SETUP bao-pin-mismatch, which is strictly stronger, and the expectation was re-pointed to it - not relaxed; a caller-PATH stub is irrelevant because the counter resolves BAO_BIN=\${R61_BAO:-\$HOME/.local/bin/bao} and sha-pin-gates it, and the trial runs under env -i behind the counter's own logging exec shim"
}

# --- help-only trial fixture (reviewer vacuity class C2-3) -------------------
gen_helpstub_trial() { # DST PREFIX SHIMVAR -- trial exercising only `bao <op> --help`
  local dst=$1 prefix=$2 shim=$3
  cat > "$dst" <<EOF
#!/usr/bin/env bash
# battery fixture trial (C2-HELPSTUB): runs each bao <op> --help against the real
# binary (bare-name argvs, no ops performed) and prints the trial text contract
set -u
prefix="$prefix"; shim="\${$shim:-}"
command -v bao >/dev/null 2>&1 || { echo "\$prefix: SETUP no bao on PATH"; exit 2; }
if [ "\${1:-}" = "--selftest" ]; then echo "SEAL_SELFTEST: PASS (cases=8)"; exit 0; fi
for op in "server" "operator init" "operator unseal" "operator seal" \
          "operator generate-root" "operator rekey"; do
  bao \$op --help >/dev/null 2>&1
done
rc=0
for t in 1 2 3 4 5; do
  v=HOLDS
  if [ -n "\$shim" ] && [ "\$shim" = "SH\$t" ]; then v=BROKEN; rc=1; fi
  d="ok"
  [ "\$t" = 2 ] && d="unseal progress 1/3 sealed=true t=3 n=5"
  echo "TRIAL T\$t \$v \$d"
done
if [ "\$rc" = 0 ]; then echo "\$prefix: HOLDS holds=5 broken=0 error=0 bao=\$(bao version 2>/dev/null | tail -1)"
else echo "\$prefix: BROKEN holds=4 broken=1 error=0 bao=\$(bao version 2>/dev/null | tail -1)"; fi
exit "\$rc"
EOF
  chmod +x "$dst"
}

ctrl_c2_helpstub() {
  if [ "$have_c2" != 1 ]; then
    report_skip C2-HELPSTUB "no-counter (plans/round-61-c2.sh is not on disk yet)"; return 0
  fi
  copy_tree "$REF" "$SCR/c2help" || { report C2-HELPSTUB "value=0" "copy-failed" "fixture tree copy failed"; return 0; }
  gen_helpstub_trial "$SCR/c2help/$TRIAL_REL" "${TRIAL_PREFIX:-OPENBAO_SEAL_TRIAL}" "$SHIMVAR" \
    || { report C2-HELPSTUB "value=0" "stub-gen-failed" "help-stub trial generation failed"; return 0; }
  report C2-HELPSTUB "value=0" "$(c2_value_reading "$C2" "$SCR/c2help" 600)" \
    "fixture trial runs each bao <op> --help against the real binary (bare-name argvs, no ops) and prints the T2 markers (unseal progress 1/3 sealed=true); command: bash plans/round-61-c2.sh --tree <helpstub copy>; a 5 means the argv-shape witness accepts help-only executions (reviewer vacuity class C2-3)"
}

# ============================== run the battery ==============================
body() {
  echo "# round-61 pre-freeze control battery (plans/round-61-controls.sh)"
  echo "# base=$BASE ref=$REF"
  echo "# scratch=$SCR"
  echo "# derived-shim-env=${SHIMVAR} trial-prefix=${TRIAL_PREFIX:-none} bao=${BAOBIN:-none}"

  echo "# instrument pins (the bytes this battery measured)"
  PINLIST=""
  for f in plans/round-61-c1-check.py plans/round-61-c2.sh "$C2R60_REL" "$TRIAL_REL"; do
    if [ -f "$REPO/$f" ]; then
      h=$(sha256sum < "$REPO/$f" | cut -d' ' -f1)
      printf 'INSTRUMENT %s %s\n' "$f" "$h"
    else
      h=MISSING
      printf 'INSTRUMENT %s MISSING\n' "$f"
    fi
    PINLIST="$PINLIST $f=$h"
  done
  if [ -n "$BAOBIN" ]; then
    BH=$(sha256sum < "$BAOBIN" | cut -d' ' -f1)
    printf 'BAO %s %s\n' "$BAOBIN" "$BH"
    [ "$BH" = "$BAO_PIN_SHA" ] || printf 'BAO-DRIFT %s pinned=%s now=%s\n' "$BAOBIN" "$BAO_PIN_SHA" "$BH"
  else
    echo "BAO MISSING (no bao on PATH; the C2-SH controls will SKIP)"
  fi

  if ! base_tree "$SCR/base"; then
    echo "CONTROLS: SETUP base tree"
    return 2
  fi
  ctrl_c1_nowork
  ctrl_c2_nowork
  ctrl_c1_f1
  ctrl_c1_f2
  ctrl_c1_f3
  ctrl_c1_f4
  ctrl_c1_f5
  ctrl_c1_f6
  ctrl_c1_f7
  ctrl_c1_stub
  ctrl_c2_sh 1
  ctrl_c2_sh 2
  ctrl_c2_sh 3
  ctrl_c2_sh 4
  ctrl_c2_sh 5
  ctrl_c2_stub
  ctrl_c2_fixture_truth
  ctrl_c2_helpstub

  for entry in $PINLIST; do
    f=${entry%%=*}; h=${entry#*=}
    [ "$h" = MISSING ] && continue
    now=$(sha256sum < "$REPO/$f" 2>/dev/null | cut -d' ' -f1)
    if [ -n "$now" ] && [ "$now" != "$h" ]; then
      printf 'INSTRUMENT-DRIFT %s pinned=%s now=%s (the battery re-runs against the landed bytes)\n' "$f" "$h" "$now"
    fi
  done
  printf 'CONTROLS: match=%d mismatch=%d\n' "$M" "$K"
  [ "$K" -gt 0 ] && return 1
  return 0
}

# --- tree emission mode (L1 route): materialize the forgery/stub trees so the
# mutation seat can extend rather than duplicate them.
#   usage: bash plans/round-61-controls.sh --emit-trees DIR
# Prints one "TREE <control-id> <path>" line per tree (or TREE-FAILED with the
# reason). The trees are full working copies: C1-F1..C1-F7 each break exactly one
# item's substance in an otherwise fixed tree (F7 via the checker-defined verdict
# mutation, applied here too); C1-STUB is the clean fixed tree and C1-STUBC its
# challenge copy. Building the I2 legs needs the landed plans/round-60-c2.sh
# --selftest; re-run after it lands. The trees live in DIR and are the caller's
# to clean.
if [ "$EMIT_ONLY" = 1 ]; then
  [ -n "${2:-}" ] || { echo "usage: $0 --emit-trees DIR" >&2; exit 2; }
  DEST=$(mkdir -p -- "$2" && cd "$2" && pwd -P) || exit 2
  echo "# round-61 forgery-tree emission (plans/round-61-controls.sh --emit-trees $DEST)"
  for spec in c1f1:C1-F1: c1f2:C1-F2: c1f3:C1-F3:f3-restates c1f4:C1-F4: c1f5:C1-F5: c1f6:C1-F6: c1f7:C1-F7: c1stub:C1-STUB:; do
    name=${spec%%:*}; rest=${spec#*:}; id=${rest%%:*}; variant=${rest#*:}
    if build_fixed_tree "$name" ${variant:+"$variant"}; then
      if [ "$id" != C1-F3 ] && [ "$id" != C1-STUB ]; then
        if ! apply_forge "$id" "$DEST/$name" >/dev/null 2>&1; then
          rm -rf -- "$DEST/$name"
          printf 'TREE-FAILED %s (substance break failed; re-run after the instruments land)\n' "$id"
          continue
        fi
      fi
      printf 'TREE %s %s\n' "$id" "$DEST/$name"
      if [ "$id" = C1-STUB ] && apply_stub_challenge "$DEST/$name" "$DEST/c1stubc"; then
        printf 'TREE C1-STUBC %s\n' "$DEST/c1stubc"
      fi
    else
      brc=$?
      rm -rf -- "$DEST/$name"
      printf 'TREE-FAILED %s rc=%d (needs the landed plans/round-60-c2.sh --selftest overlay; re-run after it lands)\n' "$id" "$brc"
    fi
  done
  exit 0
fi

OUT="$SCR/receipt.txt"
( body ) > "$OUT" 2>&1
rc=$?
cat "$OUT"
if mkdir -p "$REPO/.ufo/waves/round-61/controls" 2>/dev/null && cp "$OUT" "$REPO/$RECEIPT_REL" 2>/dev/null; then
  :
else
  echo "# WARNING: could not install the receipt at $REPO/$RECEIPT_REL" >&2
fi
exit "$rc"
