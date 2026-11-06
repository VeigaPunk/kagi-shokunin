#!/usr/bin/env bash
# plans/round-48-c1.sh — FROZEN round-48 C1 counter (capability acquisition, axis operability):
# the lane can execute the SOPS/age access and rotation mechanics its knowledge entry documents.
#
# Predicate (same sentence as plans/round-48.md §C1):
#   C1_SOPS_AGE_TRIAL: value = number of tests T in {T1..T5} that DISCRIMINATE, when PINS = 1 and
#   SETUP_OK = 1 and NOSECRET = 1, else 0; target 5.
# - PINS: the sops and age-keygen binaries this counter puts on PATH have the pinned sha256 of the
#   official releases (sops v3.13.3 linux.amd64, age v1.3.2 linux-amd64); otherwise SETUP, exit 2.
# - DISCRIMINATE(T): the measured tree's `corpus/sops-age-trial.sh`, run under `env -i` with PATH =
#   <counter bin dir>:/usr/bin:/bin, prints exactly one `TRIAL T HOLDS ...` line with the real
#   binaries AND exactly one `TRIAL T BROKEN ...` line with T's designated falsifier shim
#   (T1 updatekeys-also-rotates, T2 rotate-no-op, T3 updatekeys-no-op, T4 decrypt-leaks-plaintext,
#   T5 encrypt-collapses-key-groups) AND `corpus/knowledge/sops-age-key-rotation.md` has a `## Measured
#   (round 48` section holding a line that starts `- T<n> ` and names `sops 3.13.3`.
# - SETUP_OK: with no sops on PATH the trial exits 2 and prints no HOLDS line.
# - NOSECRET: no run's stdout/stderr contains `AGE-SECRET-KEY`.
# - Fail closed: a real run with no final `SOPS_AGE_TRIAL: ` line is SETUP (exit 2). An absent trial
#   script reads `value=0 absent=1` (exit 0): that is the BASE state, not a producer failure.
#
# Usage: bash plans/round-48-c1.sh <rev>        (measures the committed tree of <rev> in this repo)
#        bash plans/round-48-c1.sh --tree DIR   (controls only: measures a fixture tree)
# Scratch: $HYAKU_SCRATCH (default /fast/scratch/hyaku)/kagi-r48/c1-counter.XXXXXX, removed on exit.
set -u
PIN_SOPS=e5bec3346a873ae91d871550f3e698c1aad962aff462a080e40f25fde17fef6b
PIN_AGEKEYGEN=0a0009db842259d6717f7eeb30acb6b90d2a2eb924c6acd0a0db0ca1f1537899
SOPS_BIN="${R48_SOPS:-$HOME/.local/bin/sops}"
AGEKEYGEN_BIN="${R48_AGEKEYGEN:-$HOME/.local/bin/age-keygen}"

setup() { echo "C1_SOPS_AGE_TRIAL: SETUP reason=$1"; exit 2; }

[ $# -ge 1 ] || setup usage
LANE=$(cd "$(dirname "$0")/.." && pwd)
SCR="${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r48"
mkdir -p "$SCR" || setup scratch
W=$(mktemp -d "$SCR/c1-counter.XXXXXX") || setup mktemp
trap 'rm -rf -- "$W"' EXIT

if [ "$1" = "--tree" ]; then
  [ -d "${2:-}" ] || setup tree-missing
  T=$(cd "$2" && pwd)
else
  git -C "$LANE" rev-parse --verify -q "$1^{commit}" >/dev/null || setup bad-rev
  mkdir -p "$W/tree" && git -C "$LANE" archive "$1" | tar -x -C "$W/tree" || setup archive
  T="$W/tree"
fi

pins=0
[ -x "$SOPS_BIN" ] && [ -x "$AGEKEYGEN_BIN" ] || setup binaries-missing
[ "$(sha256sum < "$SOPS_BIN" | cut -d' ' -f1)" = "$PIN_SOPS" ] || setup sops-pin-mismatch
[ "$(sha256sum < "$AGEKEYGEN_BIN" | cut -d' ' -f1)" = "$PIN_AGEKEYGEN" ] || setup age-keygen-pin-mismatch
pins=1
for d in /usr/bin /bin; do [ -e "$d/sops" ] && setup "sops-in-$d"; done

TRIAL="$T/corpus/sops-age-trial.sh"
if [ ! -f "$TRIAL" ]; then
  echo "C1_SOPS_AGE_TRIAL: value=0 absent=1 pins=$pins"; exit 0
fi

mkdir -p "$W/home" "$W/tmp" "$W/stash" "$W/bin/real" "$W/bin/none"
ln -s "$SOPS_BIN" "$W/bin/real/sops"; ln -s "$AGEKEYGEN_BIN" "$W/bin/real/age-keygen"
ln -s "$AGEKEYGEN_BIN" "$W/bin/none/age-keygen"

mkshim() { # name body
  mkdir -p "$W/bin/$1"; ln -s "$AGEKEYGEN_BIN" "$W/bin/$1/age-keygen"
  { printf '#!/bin/bash\nREAL=%q\nSTASH=%q\n' "$SOPS_BIN" "$W/stash"; printf '%s\n' "$2"; } > "$W/bin/$1/sops"
  chmod 755 "$W/bin/$1/sops"
}
# SH1 (T1): updatekeys also rotates the data key.
mkshim sh1 'if [ "${1:-}" = updatekeys ]; then "$REAL" "$@" || exit $?; f="${@: -1}"; "$REAL" rotate -i "$f" >/dev/null 2>&1; exit 0; fi
exec "$REAL" "$@"'
# SH2 (T2): rotate is a no-op.
mkshim sh2 '[ "${1:-}" = rotate ] && exit 0
exec "$REAL" "$@"'
# SH3 (T3): updatekeys is a no-op.
mkshim sh3 '[ "${1:-}" = updatekeys ] && exit 0
exec "$REAL" "$@"'
# SH4 (T4): decrypt leaks the last encrypted plaintext when the identity is refused.
mkshim sh4 'if [ "${1:-}" = encrypt ]; then f="${@: -1}"; [ -f "$f" ] && cp -- "$f" "$STASH/last"; exec "$REAL" "$@"; fi
if [ "${1:-}" = decrypt ]; then out=$("$REAL" "$@" 2>/dev/null); rc=$?; if [ $rc -ne 0 ] && [ -f "$STASH/last" ]; then cat "$STASH/last"; exit 0; fi; [ $rc -eq 0 ] && printf "%s\n" "$out"; exit $rc; fi
exec "$REAL" "$@"'
# SH5 (T5): encrypt ignores the creation rules' key groups and encrypts to every age recipient the
# ./.sops.yaml names as ONE group (sops 3.13.3 refuses a Shamir threshold of 1 outright — "threshold
# must be at least 2" — so a threshold-1 shim cannot be built; a collapsed group is the reachable falsifier).
mkshim sh5 'if [ "${1:-}" = encrypt ] && [ -f .sops.yaml ] && grep -q key_groups .sops.yaml; then
  shift; r=$(grep -oE "age1[0-9a-z]{58}" .sops.yaml | paste -sd, -); printf "creation_rules:\n  - path_regex: \".*\"\n    age: \"%s\"\n" "$r" > "$STASH/collapsed.yaml"
  exec "$REAL" --config "$STASH/collapsed.yaml" encrypt "$@"; fi
exec "$REAL" "$@"'

run() { # bindir outfile -> rc
  env -i HOME="$W/home" PATH="$W/bin/$1:/usr/bin:/bin" TMPDIR="$W/tmp" LANG=C \
    bash "$TRIAL" --work "$W/tmp" > "$2" 2>"$2.err"
}
# verdict OUT ID -> HOLDS|BROKEN|ERROR|NONE|DUP
verdict() {
  local n; n=$(grep -cE "^TRIAL $2 (HOLDS|BROKEN|ERROR)( |\$)" "$1")
  if [ "$n" -eq 0 ]; then echo NONE; elif [ "$n" -gt 1 ]; then echo DUP
  else grep -E "^TRIAL $2 (HOLDS|BROKEN|ERROR)( |\$)" "$1" | awk '{print $3}'; fi
}

nosecret=1
run real "$W/real.out"; real_rc=$?
grep -q '^SOPS_AGE_TRIAL: ' "$W/real.out" || setup "real-run-no-final-line(rc=$real_rc)"
run none "$W/none.out"; none_rc=$?
setup_ok=0
if [ $none_rc -eq 2 ] && ! grep -qE '^TRIAL T[1-5] HOLDS' "$W/none.out"; then setup_ok=1; fi

ENTRY="$T/corpus/knowledge/sops-age-key-rotation.md"
entry_line() { # id -> 1/0
  [ -f "$ENTRY" ] || { echo 0; return; }
  awk -v id="$1" '
    /^## / { insec = ($0 ~ /^## Measured \(round 48/) ; next }
    insec && index($0, "- " id " ") == 1 && index($0, "sops 3.13.3") > 0 { found = 1 }
    END { print found ? 1 : 0 }' "$ENTRY"
}

value=0; detail=""
for i in 1 2 3 4 5; do
  id="T$i"
  s="sh$i"; [ "$i" = 1 ] && s=sh3; run "$s" "$W/sh$i.out"
  rv=$(verdict "$W/real.out" "$id"); sv=$(verdict "$W/sh$i.out" "$id"); ev=$(entry_line "$id")
  ok=0; [ "$rv" = HOLDS ] && [ "$sv" = BROKEN ] && [ "$ev" = 1 ] && ok=1
  value=$((value + ok)); detail="$detail $id:real=$rv,shim=$sv,entry=$ev,ok=$ok"
done
if cat "$W"/*.out "$W"/*.out.err 2>/dev/null | grep -q 'AGE-SECRET-KEY'; then nosecret=0; fi

final=$value
[ $setup_ok -eq 1 ] && [ $nosecret -eq 1 ] && [ $pins -eq 1 ] || final=0
echo "C1_SOPS_AGE_TRIAL: value=$final discriminating=$value pins=$pins setup_ok=$setup_ok nosecret=$nosecret real_rc=$real_rc none_rc=$none_rc$detail"
exit 0
