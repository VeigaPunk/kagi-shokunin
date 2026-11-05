#!/usr/bin/env bash
# laneguard.sh -- round 38 C2 instrument: lane-tree write guard (closes round-37 M37-2).
#
# Frozen predicate (the same sentence appears in plans/round-38.md and the counter):
#   LANE_GUARD_SELFTEST detected=N -- N is the number of planted lane-tree writes
#   (a tracked edit, an untracked file, a new commit) that `laneguard.sh run` reports
#   as VIOLATION with exit 1, in fixture repositories created under scratch; the clean
#   control must pass (CLEAN, exit 0) for the selftest to count any detection.
#
# usage:
#   laneguard.sh run -- LANE [--] CMD [ARG...]   snapshot LANE (HEAD, staged and unstaged
#                                           diff, untracked files), run CMD with cwd=LANE,
#                                           re-snapshot; any difference -> VIOLATION exit 1.
#                                           Otherwise CLEAN and CMD's exit status.
#   laneguard.sh --selftest [--no-mutate]   fixture-only proof; --no-mutate runs the same
#                                           four cases with the planted writes replaced by
#                                           `true` (the do-nothing control).
#
# Scratch: fixtures live under ${LANEGUARD_SCRATCH:-${HYAKU_SCRATCH:-/fast/scratch/hyaku}/laneguard},
# removed on exit. Fixture repositories are created with `git init` and every git call names
# -C explicitly; the lane is only read (git --no-optional-locks status, diff, rev-parse).
set -u

snap() {
  local lane=$1
  {
    git -C "$lane" rev-parse HEAD 2>/dev/null || echo NOHEAD
    git -C "$lane" --no-optional-locks status --porcelain=v1 -z --untracked-files=all
    git -C "$lane" diff --binary --no-ext-diff
    git -C "$lane" diff --cached --binary --no-ext-diff
  } | sha256sum | cut -d' ' -f1
}

run_guard() {
  local lane=$1
  shift
  if ! git -C "$lane" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "LANE_GUARD: SETUP not-a-repo $lane"
    return 2
  fi
  local before after rc
  before=$(snap "$lane")
  (cd "$lane" && "$@")
  rc=$?
  after=$(snap "$lane")
  if [ "$before" != "$after" ]; then
    echo "LANE_GUARD: VIOLATION lane=$lane"
    git -C "$lane" --no-optional-locks status --porcelain=v1 --untracked-files=all | sed 's/^/  changed: /'
    return 1
  fi
  echo "LANE_GUARD: CLEAN lane=$lane rc=$rc"
  return "$rc"
}

selftest() {
  local mutate=$1
  local base=${LANEGUARD_SCRATCH:-${HYAKU_SCRATCH:-/fast/scratch/hyaku}/laneguard}
  mkdir -p "$base" || { echo "LANE_GUARD_SELFTEST: SETUP scratch-unwritable"; return 2; }
  local d
  d=$(mktemp -d "$base/fix.XXXXXX") || { echo "LANE_GUARD_SELFTEST: SETUP mktemp"; return 2; }
  git -C "$d" init -q || { echo "LANE_GUARD_SELFTEST: SETUP git-init"; return 2; }
  if [ "$(realpath "$(git -C "$d" rev-parse --show-toplevel)")" != "$(realpath "$d")" ]; then
    echo "LANE_GUARD_SELFTEST: SETUP fixture-toplevel"
    return 2
  fi
  printf 'a\n' > "$d/a.txt"
  git -C "$d" add a.txt
  git -C "$d" -c user.name=laneguard-fixture -c user.email=fixture@invalid commit -q -m base || return 2

  local clean_out clean_rc detected=0 mutants=0
  clean_out=$(run_guard "$d" true)
  clean_rc=$?
  local clean_ok=fail
  [ "$clean_rc" -eq 0 ] && [[ "$clean_out" == "LANE_GUARD: CLEAN"* ]] && clean_ok=ok

  local -a cmds=()
  if [ "$mutate" = yes ]; then
    cmds+=("sh -c 'echo x >> a.txt'")
    cmds+=("sh -c 'echo x > new.txt'")
    cmds+=("sh -c 'git -C \"$d\" -c user.name=laneguard-fixture -c user.email=fixture@invalid commit -q --allow-empty -m m'")
  else
    cmds+=("true" "true" "true")
  fi
  local c out rc
  for c in "${cmds[@]}"; do
    mutants=$((mutants + 1))
    out=$(eval "run_guard \"$d\" $c")
    rc=$?
    if [ "$rc" -eq 1 ] && [[ "$out" == *"LANE_GUARD: VIOLATION"* ]]; then
      detected=$((detected + 1))
    fi
  done
  rm -rf -- "$d"
  echo "LANE_GUARD_SELFTEST: detected=$detected mutants=$mutants clean=$clean_ok"
  [ "$clean_ok" = ok ] && [ "$detected" -eq "$mutants" ]
}

case ${1:-} in
  run)
    shift
    [ "${1:-}" = "--" ] || { echo "usage: laneguard.sh run -- LANE [--] CMD..." >&2; exit 2; }
    shift
    lane=${1:?lane}
    shift
    [ "${1:-}" = "--" ] && shift
    run_guard "$lane" "$@"
    ;;
  --selftest)
    mutate=yes
    [ "${2:-}" = "--no-mutate" ] && mutate=no
    selftest "$mutate"
    ;;
  *)
    echo "usage: laneguard.sh run -- LANE [--] CMD... | --selftest [--no-mutate]" >&2
    exit 2
    ;;
esac
