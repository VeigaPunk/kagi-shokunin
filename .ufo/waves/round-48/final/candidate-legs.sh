#!/usr/bin/env bash
# round-48 candidate-side legs (no frozen sentence changes): each answers a wave finding against the
# named candidate's committed bytes. Usage: bash candidate-legs.sh <rev>   Output: LEG <id> PASS|FAIL <detail>
set -u
REV=${1:?rev}; LANE=$(cd "$(dirname "$0")/../../../.." && pwd); fail=0
leg() { if [ "$2" = PASS ]; then echo "LEG $1 PASS $3"; else echo "LEG $1 FAIL $3"; fail=1; fi; }
show() { git -C "$LANE" show "$REV:$1"; }
T=$(show corpus/sops-age-trial.sh) || { echo "LEGS: SETUP no-trial"; exit 2; }
# LA (K48CriticCeiling §1, K48CriticClaims D-3, plan named ceiling 1): the trial never inspects the sops it runs
# (no `command -v sops` result reused, no head/od/file/readlink/stat of a binary, no PATH parsing beyond the
# presence checks, no 'sh[1-5]' / 'shim' / '#!' tokens).
n=$(printf '%s\n' "$T" | grep -vE '^[[:space:]]*#' | grep -cE 'head -c|od -|readlink|stat -c|file -|\$\(command -v (sops|age-keygen)\)|case[^)]*PATH|\bsh[1-5]\b|shim|"#!"' )
[ "$n" -eq 0 ] && leg LA PASS "binary-inspection-tokens=0" || leg LA FAIL "binary-inspection-tokens=$n"
# LB (plan named ceiling 2): the trial never passes --config to sops.
n=$(printf '%s\n' "$T" | grep -vE '^[[:space:]]*#' | grep -c -- '--config')
[ "$n" -eq 0 ] && leg LB PASS "config-flag=0" || leg LB FAIL "config-flag=$n"
# LC (K48RP-02, K48CriticClaims D-9): SCORECARD has exactly one `## Capabilities` heading, not inside a fence
# or an HTML comment, and the current-readings line sits inside it.
S=$(show SCORECARD.md)
h=$(printf '%s\n' "$S" | grep -c '^## Capabilities$')
fenced=$(printf '%s\n' "$S" | awk '/^```/{f=!f} f && /^## Capabilities/{c++} END{print c+0}')
comm=$(printf '%s\n' "$S" | awk '/<!--/{c=1} c && /^## Capabilities/{n++} /-->/{c=0} END{print n+0}')
inside=$(printf '%s\n' "$S" | awk '/^## /{s=($0=="## Capabilities"); next} s && /^Current readings at round 48/{n++} END{print n+0}')
[ "$h" -eq 1 ] && [ "$fenced" -eq 0 ] && [ "$comm" -eq 0 ] && [ "$inside" -eq 1 ] \
  && leg LC PASS "headings=$h fenced=$fenced commented=$comm readings-line-inside=$inside" \
  || leg LC FAIL "headings=$h fenced=$fenced commented=$comm readings-line-inside=$inside"
# LD (K48MutCounters M05-c1, M01-c1): the trial prints one TRIAL line per test and exits 2 with no HOLDS when
# sops is absent — run under env -i with the pinned binaries and with an empty bin dir.
W=$(mktemp -d "${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r48/legs.XXXXXX"); trap 'rm -rf -- "$W"' EXIT
printf '%s\n' "$T" > "$W/trial.sh"; mkdir -p "$W/bin" "$W/nobin"
ln -s "$HOME/.local/bin/sops" "$W/bin/sops"; ln -s "$HOME/.local/bin/age-keygen" "$W/bin/age-keygen"; ln -s "$HOME/.local/bin/age-keygen" "$W/nobin/age-keygen"
env -i HOME="$W/h" PATH="$W/bin:/usr/bin:/bin" TMPDIR="$W" bash "$W/trial.sh" --work "$W" > "$W/real.out" 2>&1; rr=$?
env -i HOME="$W/h" PATH="$W/nobin:/usr/bin:/bin" TMPDIR="$W" bash "$W/trial.sh" --work "$W" > "$W/none.out" 2>&1; nr=$?
dups=$(grep -oE '^TRIAL T[1-5] ' "$W/real.out" | sort | uniq -d | wc -l); lines=$(grep -cE '^TRIAL T[1-5] ' "$W/real.out")
holds_none=$(grep -cE '^TRIAL T[1-5] HOLDS' "$W/none.out")
[ "$rr" -eq 0 ] && [ "$lines" -eq 5 ] && [ "$dups" -eq 0 ] && [ "$nr" -eq 2 ] && [ "$holds_none" -eq 0 ] \
  && leg LD PASS "real_rc=$rr trial_lines=$lines dups=$dups none_rc=$nr none_holds=$holds_none" \
  || leg LD FAIL "real_rc=$rr trial_lines=$lines dups=$dups none_rc=$nr none_holds=$holds_none"
# LE (A1 kill rule and sentinel S-04): no key-shaped string in any file of the revision.
n=$(git -C "$LANE" grep -cE 'AGE-SECRET-KEY-1[0-9A-Z]{58}' "$REV" | wc -l)
[ "$n" -eq 0 ] && leg LE PASS "files-with-key-shaped-strings=0" || leg LE FAIL "files-with-key-shaped-strings=$n"
[ $fail -eq 0 ] && { echo "LEGS: PASS rev=$REV"; exit 0; }; echo "LEGS: FAIL rev=$REV"; exit 1
