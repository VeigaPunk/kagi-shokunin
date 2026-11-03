#!/usr/bin/env bash
# self-description-sweep.sh — round 32, claim C1 counter (SD1–SD6).
#
# Predicate (frozen in plans/round-32.md; identical here, in the plan and on the
# receipt label):
#   SELF_DESCRIPTION: CLEAN n=0 — the sum of checks SD1–SD6 is zero at the
#   measured revision.
#
# SD1  PROVINCE.md lines that name a theme in a `Frontier` bullet while a `Core`
#      bullet of the same file names the same theme. Themes (case-insensitive
#      ERE): `OIDC workload-federation`, `secret[- ]scanning`. Counted per
#      (frontier line, theme): a single line naming two held themes counts 2
#      (the plan's BASE value is 2 for PROVINCE.md line 90).
# SD2  corpus/README.md lines inside the `## Frontier` section (up to the next
#      `## ` heading) containing `moved to core`.
# SD3  SHONEN.md tokens `corpus/...`, `LOG.md`, `SKILL.md`, `PROVINCE.md` whose
#      path (resolved from the measured root) does not exist.
# SD4  distinct `M31-<n>` ids named anywhere in corpus/lessons/round-31.md with
#      no row `^| M31-<n> ` in that same file.
# SD5  red ids on the SCORECARD `lane-status:` line (the ids of its routed-red
#      parenthetical list) that are absent from the calibration row (first cell
#      `calibration`) of the latest `## Round` section.
# SD6  lines beginning `UNRESOLVED` in `bash corpus/claim-ledger.sh citations`
#      run inside the measured root.
#
# Verdict (last line):
#   SELF_DESCRIPTION: CLEAN n=0                                          exit 0
#   SELF_DESCRIPTION: MISMATCH n=N (SD1=a SD2=b SD3=c SD4=d SD5=e SD6=f) exit 1
#   SELF_DESCRIPTION: SETUP <reason>                                     exit 2
#
# --selftest builds throwaway fixture trees (one planted defect per check plus a
# clean tree); each planted tree must exit 1 naming its own check, the clean tree
# must exit 0. Final line: SELFTEST: PASS (<k> cases) | SELFTEST: FAIL (<k> cases).
#
# Reads only files under --root. Writes nothing except stdout; selftest writes a
# fixture tree under ${TMPDIR:-/tmp} and removes it on exit.
set -u

SELF_RAW=${BASH_SOURCE[0]}
case $SELF_RAW in
  */*) SELF_DIR=$(cd -- "${SELF_RAW%/*}" && pwd -P) || exit 2 ;;
  *)   SELF_DIR=$(pwd -P) ;;
esac
SELF=$SELF_DIR/${SELF_RAW##*/}

ROOT=.
MODE=run

die() { printf 'SELF_DESCRIPTION: SETUP %s\n' "$1"; exit 2; }

while [ $# -gt 0 ]; do
  case $1 in
    --root)
      [ $# -ge 2 ] || die "missing value for --root"
      ROOT=$2; shift 2 ;;
    --root=*)
      ROOT=${1#--root=}; shift ;;
    --selftest)
      MODE=selftest; shift ;;
    -h|--help)
      printf 'usage: %s [--root DIR] [--selftest]\n' "${SELF_RAW##*/}"
      exit 0 ;;
    *)
      die "unknown argument: $1" ;;
  esac
done

[ -d "$ROOT" ] || die "root is not a directory: $ROOT"
ROOT_ABS=$(cd -- "$ROOT" && pwd -P) || die "cannot enter root: $ROOT"

# ---------------------------------------------------------------- fixtures ---
# Shared minimal tree: the files each check reads, all in their clean state.
mk_common() {
  local d=$1
  mkdir -p "$d/corpus/lessons" || return 1
  printf '# kagi-shokunin — fixture LOG\n' > "$d/LOG.md"
  printf '# kagi-shokunin — fixture SKILL\n' > "$d/SKILL.md"
  cat > "$d/PROVINCE.md" <<'PROVINCE_EOF'
# kagi-shokunin — fixture province

- **Core — OIDC workload-federation trust policy:** held ground.
- **Frontier — explored, not held:** NIST key-management draft status.
PROVINCE_EOF
  cat > "$d/corpus/README.md" <<'README_EOF'
# fixture corpus README

## Frontier

- **NIST key-management draft status** — a lead, not held.
- **Observable release clocks** — on-demand observation.

## Known gaps

- none
README_EOF
  cat > "$d/SHONEN.md" <<'SHONEN_EOF'
# kagi-shokunin — promotion checklist (fixture)

- [~] Evidence: SKILL.md, LOG.md, PROVINCE.md, corpus/README.md and corpus/claim-ledger.sh.
SHONEN_EOF
  cat > "$d/corpus/lessons/round-31.md" <<'LESSON_EOF'
# Round 31 (fixture)

| id | class | evidence |
|---|---|---|
| M31-1 | stall | fixture |
LESSON_EOF
  cat > "$d/SCORECARD.md" <<'SCORE_EOF'
# kagi-shokunin — scorecard (fixture)

lane-status: open — as-of:2026-11-03 — 1 operator-routed red (R30-07) stays red

## Round 30 — post-move (fixture)

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| calibration | 9 → 9 | held | Row `R30-07`; ceiling named. |
SCORE_EOF
  cat > "$d/corpus/claim-ledger.sh" <<'LEDGER_EOF'
#!/usr/bin/env bash
printf 'CITATION_GATE: CLEAN (cites=0 docs=0 unresolved=0 ephemeral=0 labeled=0)\n'
LEDGER_EOF
}

plant_sd1() {
  cat > "$1/PROVINCE.md" <<'EOF'
# kagi-shokunin — fixture province

- **Core — OIDC workload-federation trust policy:** held ground.
- **Frontier — explored, not held:** OIDC workload-federation trust policy; NIST draft.
EOF
}

plant_sd2() {
  cat > "$1/corpus/README.md" <<'EOF'
# fixture corpus README

## Frontier

- **OIDC workload-federation trust policy** — moved to core in round 31.

## Known gaps

- none
EOF
}

plant_sd3() {
  cat > "$1/SHONEN.md" <<'EOF'
# kagi-shokunin — promotion checklist (fixture)

- [~] Evidence: SKILL.md, corpus/lessons/round-31-missing.md.
EOF
}

plant_sd4() {
  cat > "$1/corpus/lessons/round-31.md" <<'EOF'
# Round 31 (fixture)

A corrigendum names M31-2 but adds no table row.

| id | class | evidence |
|---|---|---|
| M31-1 | stall | fixture |
EOF
}

plant_sd5() {
  cat > "$1/SCORECARD.md" <<'EOF'
# kagi-shokunin — scorecard (fixture)

lane-status: open — as-of:2026-11-03 — 1 operator-routed red (R30-07) stays red

## Round 30 — post-move (fixture)

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| calibration | 9 → 9 | held | Row `R30-01`; ceiling named. |
EOF
}

plant_sd6() {
  cat > "$1/corpus/claim-ledger.sh" <<'EOF'
#!/usr/bin/env bash
printf 'UNRESOLVED corpus/fixture.md:3 corpus/nope.md (local)\n'
printf 'CITATION_GATE: BROKEN (cites=1 docs=1 unresolved=1 ephemeral=0 labeled=0)\n'
EOF
}

FIXTURE_TMP=

selftest() {
  local tmp cases=0 fails=0 last rc out dir name id ok
  tmp=$(mktemp -d "${TMPDIR:-/tmp}/sd-sweep-selftest.XXXXXX") || die "mktemp failed"
  FIXTURE_TMP=$tmp
  trap 'rm -rf -- "${FIXTURE_TMP:-}"' EXIT

  run_case() { # name dir expect(clean|mismatch) sd-id
    name=$1; dir=$2; local expect=$3; id=$4
    cases=$((cases + 1))
    out=$(bash "$SELF" --root "$dir" 2>&1); rc=$?
    last=$(printf '%s\n' "$out" | tail -n 1)
    ok=1
    if [ "$expect" = clean ]; then
      [ "$rc" -eq 0 ] || ok=0
      [ "$last" = "SELF_DESCRIPTION: CLEAN n=0" ] || ok=0
      printf '%s\n' "$out" | grep -q '^MISMATCH ' && ok=0
    else
      [ "$rc" -eq 1 ] || ok=0
      printf '%s\n' "$out" | grep -q "^MISMATCH $id " || ok=0
      printf '%s\n' "$last" | grep -qE "SELF_DESCRIPTION: MISMATCH n=1 \(SD1=[0-9]+ SD2=[0-9]+ SD3=[0-9]+ SD4=[0-9]+ SD5=[0-9]+ SD6=[0-9]+\)" || ok=0
      printf '%s\n' "$last" | grep -q "$id=" || ok=0
    fi
    if [ "$ok" -eq 1 ]; then
      printf 'CASE %s ok\n' "$name"
    else
      fails=$((fails + 1))
      printf 'CASE %s FAIL (rc=%d last=%s)\n' "$name" "$rc" "$last"
    fi
  }

  dir=$tmp/clean
  mk_common "$dir" || die "fixture setup failed: clean"
  run_case clean "$dir" clean ""

  for sd in SD1 SD2 SD3 SD4 SD5 SD6; do
    dir=$tmp/$sd
    mk_common "$dir" || die "fixture setup failed: $sd"
    case $sd in
      SD1) plant_sd1 "$dir" ;;
      SD2) plant_sd2 "$dir" ;;
      SD3) plant_sd3 "$dir" ;;
      SD4) plant_sd4 "$dir" ;;
      SD5) plant_sd5 "$dir" ;;
      SD6) plant_sd6 "$dir" ;;
    esac
    run_case "$sd" "$dir" mismatch "$sd"
  done

  if [ "$fails" -eq 0 ]; then
    printf 'SELFTEST: PASS (%d cases)\n' "$cases"
    return 0
  fi
  printf 'SELFTEST: FAIL (%d cases)\n' "$cases"
  return 1
}

if [ "$MODE" = selftest ]; then
  selftest
  exit $?
fi

# ------------------------------------------------------------------ checks ---
HITS=()
sd1=0 sd2=0 sd3=0 sd4=0 sd5=0 sd6=0

# SD1 — PROVINCE.md frontier bullet naming a theme held by a Core bullet.
province=$ROOT_ABS/PROVINCE.md
[ -f "$province" ] || die "missing PROVINCE.md under root"
themes=('OIDC workload-federation' 'secret[- ]scanning')
for theme in "${themes[@]}"; do
  core_named=0
  while IFS= read -r line || [ -n "$line" ]; do
    case $line in
      *Core*) printf '%s\n' "$line" | grep -qiE -- "$theme" && { core_named=1; break; } ;;
    esac
  done < "$province"
  [ "$core_named" -eq 1 ] || continue
  lineno=0
  while IFS= read -r line || [ -n "$line" ]; do
    lineno=$((lineno + 1))
    case $line in
      *Frontier*) ;;
      *) continue ;;
    esac
    [[ $line =~ ^[[:space:]]*[-*+][[:space:]] ]] || continue
    if printf '%s\n' "$line" | grep -qiE -- "$theme"; then
      sd1=$((sd1 + 1))
      HITS+=("MISMATCH SD1 PROVINCE.md:$lineno theme '$theme' named in a Frontier bullet while a Core bullet of the same file names it")
    fi
  done < "$province"
done

# SD2 — corpus/README.md lines in `## Frontier` saying `moved to core`.
readme=$ROOT_ABS/corpus/README.md
[ -f "$readme" ] || die "missing corpus/README.md under root"
in_frontier=0
lineno=0
while IFS= read -r line || [ -n "$line" ]; do
  lineno=$((lineno + 1))
  if [[ $line =~ ^##[[:space:]] ]]; then
    if [[ $line =~ ^##[[:space:]]+Frontier[[:space:]]*$ ]]; then
      in_frontier=1
    else
      in_frontier=0
    fi
    continue
  fi
  [ "$in_frontier" -eq 1 ] || continue
  case $line in
    *"moved to core"*)
      sd2=$((sd2 + 1))
      HITS+=("MISMATCH SD2 corpus/README.md:$lineno line inside ## Frontier still says 'moved to core'") ;;
  esac
done < "$readme"

# SD3 — SHONEN.md evidence tokens whose resolved path does not exist.
shonen=$ROOT_ABS/SHONEN.md
[ -f "$shonen" ] || die "missing SHONEN.md under root"
lineno=0
while IFS= read -r line || [ -n "$line" ]; do
  lineno=$((lineno + 1))
  while IFS= read -r tok; do
    [ -n "$tok" ] || continue
    [ -e "$ROOT_ABS/$tok" ] && continue
    sd3=$((sd3 + 1))
    HITS+=("MISMATCH SD3 SHONEN.md:$lineno token '$tok' does not resolve under the root")
  done < <(
    {
      printf '%s\n' "$line" | grep -oE 'corpus/[A-Za-z0-9_./-]+' || true
      printf '%s\n' "$line" | grep -oE '(^|[^A-Za-z0-9_./-])((LOG|SKILL|PROVINCE)\.md)' | sed -E 's/^[^A-Za-z0-9_]+//' || true
    } | sed -E 's/[.,;:]+$//' | sort -u
  )
done < "$shonen"

# SD4 — distinct M31-n ids in corpus/lessons/round-31.md with no table row.
lesson=$ROOT_ABS/corpus/lessons/round-31.md
[ -f "$lesson" ] || die "missing corpus/lessons/round-31.md under root"
while IFS= read -r id; do
  [ -n "$id" ] || continue
  grep -qE "^\| $id " "$lesson" && continue
  at=$(grep -nE "$id([^0-9]|$)" "$lesson" | head -n 1 | cut -d: -f1)
  [ -n "$at" ] || at=0
  sd4=$((sd4 + 1))
  HITS+=("MISMATCH SD4 corpus/lessons/round-31.md:$at id '$id' is named in the file with no '| $id ' table row")
done < <(grep -oE 'M31-[0-9]+' "$lesson" | sort -u)

# SD5 — lane-status red ids absent from the latest calibration row.
score=$ROOT_ABS/SCORECARD.md
[ -f "$score" ] || die "missing SCORECARD.md under root"
status_line=$(grep -nE '^lane-status:' "$score" | head -n 1 | cut -d: -f1)
[ -n "$status_line" ] || die "no lane-status line in SCORECARD.md"
status_text=$(sed -n "${status_line}p" "$score")
reds=$(printf '%s\n' "$status_text" | grep -oE '\([^()]*\)' | tr -d '()' | grep -oE 'R[0-9]+-[0-9]+' | sort -u)
[ -n "$reds" ] || reds=$(printf '%s\n' "$status_text" | grep -oE 'R[0-9]+-[0-9]+' | sort -u)
round_line=$(grep -nE '^## Round' "$score" | tail -n 1 | cut -d: -f1)
[ -n "$round_line" ] || die "no '## Round' section in SCORECARD.md"
round_end=$(awk -v s="$round_line" 'NR > s && /^## / { print NR; exit }' "$score")
[ -n "$round_end" ] || round_end=$(( $(wc -l < "$score") + 1 ))
cal_line=$(awk -v s="$round_line" -v e="$round_end" 'NR > s && NR < e && /^\| *calibration *\|/ { print NR; exit }' "$score")
[ -n "$cal_line" ] || die "no calibration row in the latest ## Round section (SCORECARD.md:$round_line)"
cal_text=$(sed -n "${cal_line}p" "$score")
while IFS= read -r id; do
  [ -n "$id" ] || continue
  printf '%s\n' "$cal_text" | grep -qE "(^|[^0-9A-Za-z-])$id([^0-9A-Za-z-]|$)" && continue
  sd5=$((sd5 + 1))
  HITS+=("MISMATCH SD5 SCORECARD.md:$status_line red id '$id' is absent from the latest calibration row (SCORECARD.md:$cal_line)")
done <<< "$reds"

# SD6 — UNRESOLVED lines from the citations gate, run inside the root.
[ -f "$ROOT_ABS/corpus/claim-ledger.sh" ] || die "missing corpus/claim-ledger.sh under root"
cit_out=$(cd -- "$ROOT_ABS" && bash corpus/claim-ledger.sh citations) 2>&1
cit_rc=$?
printf '%s\n' "$cit_out" | grep -q 'CITATION_GATE:' || die "citations produced no CITATION_GATE line (exit=$cit_rc)"
cit_idx=0
while IFS= read -r line || [ -n "$line" ]; do
  case $line in
    UNRESOLVED*)
      cit_idx=$((cit_idx + 1))
      rest=${line#UNRESOLVED }
      loc=$(printf '%s\n' "$rest" | grep -oE '^[^ ]+:[0-9]+' | head -n 1)
      [ -n "$loc" ] || loc="citations-output:$cit_idx"
      sd6=$((sd6 + 1))
      HITS+=("MISMATCH SD6 $loc $rest") ;;
  esac
done <<< "$cit_out"

# ---------------------------------------------------------------- verdict ----
n=${#HITS[@]}
if [ "$n" -eq 0 ]; then
  printf 'SELF_DESCRIPTION: CLEAN n=0\n'
  exit 0
fi
for hit in "${HITS[@]}"; do
  printf '%s\n' "$hit"
done
printf 'SELF_DESCRIPTION: MISMATCH n=%d (SD1=%d SD2=%d SD3=%d SD4=%d SD5=%d SD6=%d)\n' \
  "$n" "$sd1" "$sd2" "$sd3" "$sd4" "$sd5" "$sd6"
exit 1
