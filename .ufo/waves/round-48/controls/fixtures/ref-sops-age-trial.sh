#!/usr/bin/env bash
# sops-age-trial.sh — round 48: execute the SOPS/age access and rotation mechanics that
# corpus/knowledge/sops-age-key-rotation.md documents, against the `sops` and `age-keygen`
# found on PATH, with throwaway identities and synthetic plaintext in a scratch directory.
#
# Refusal bounds: never reads ~/.config/sops, ~/.ssh, any SOPS_AGE_* variable of the caller,
# any vault, `op`, or a real secret. HOME/XDG are scratch; every identity is generated here and
# deleted on exit; no private key, plaintext or ciphertext is printed.
#
# Tests (each runs in its own subdirectory; identities A and B):
#   T1 updatekeys-add   S011 §rotate: "Use updatekeys if you want to add a key without rotating
#                       the data key." HOLDS iff the added recipient B decrypts and both value
#                       ciphertexts and the MAC line are byte-identical to before.
#   T2 rotate           S011 §rotate: rotate "generates a new data encryption key and reencrypt
#                       all values". HOLDS iff both value ciphertexts change and the decrypted
#                       plaintext is unchanged.
#   T3 updatekeys-rm    S011 §Direct Editing / compromise order: removal without rotate keeps the
#                       data key. HOLDS iff B is refused on the synced file, B still decrypts the
#                       pre-removal copy, and the value ciphertexts are unchanged by the removal.
#   T4 rules-only       entry [INFERENCE]: editing creation rules alone leaves an existing file's
#                       access unchanged until updatekeys. HOLDS iff B is refused after the rule
#                       edit, the file bytes are unchanged, and B decrypts after updatekeys.
#   T5 group-threshold  S010 §Key groups: "By default, the threshold is set to the number of key
#                       groups". HOLDS iff two groups yield `shamir_threshold: 2`, A alone and B
#                       alone are refused, and A+B decrypt.
#
# Output: one `TRIAL T<n> HOLDS|BROKEN|ERROR <detail>` line per test, then
#   SOPS_AGE_TRIAL: HOLDS|BROKEN|SETUP holds=<n> broken=<n> error=<n> sops=<ver> age-keygen=<ver>
# Exit 0 all HOLDS, 1 any BROKEN (no ERROR), 2 SETUP (tool missing, scratch failure, any ERROR).
set -u

WORK_PARENT=""
while [ $# -gt 0 ]; do
  case "$1" in
    --work) WORK_PARENT="${2:-}"; shift 2 ;;
    -h|--help) sed -n '2,34p' "$0"; exit 0 ;;
    *) echo "usage: $0 [--work DIR]" >&2; exit 2 ;;
  esac
done

setup_fail() { echo "SOPS_AGE_TRIAL: SETUP holds=0 broken=0 error=0 reason=$1"; exit 2; }

command -v sops >/dev/null 2>&1 || setup_fail "sops-not-on-PATH"
command -v age-keygen >/dev/null 2>&1 || setup_fail "age-keygen-not-on-PATH"

parent="${WORK_PARENT:-${TMPDIR:-/tmp}}"
[ -d "$parent" ] || setup_fail "work-parent-missing"
W=$(mktemp -d "$parent/sops-age-trial.XXXXXX") || setup_fail "mktemp"
case "$W" in "$parent"/sops-age-trial.*) ;; *) setup_fail "mktemp-path" ;; esac
trap 'rm -rf -- "$W"' EXIT

unset SOPS_AGE_KEY SOPS_AGE_KEY_FILE SOPS_AGE_KEY_CMD SOPS_AGE_SSH_PRIVATE_KEY_FILE \
      SOPS_AGE_SSH_PRIVATE_KEY_CMD SOPS_AGE_RECIPIENTS SOPS_PGP_FP SOPS_KMS_ARN SOPS_GCP_KMS_IDS \
      SOPS_AZURE_KEYVAULT_URLS SOPS_VAULT_URIS SOPS_HC_VAULT_URIS
export HOME="$W/home" XDG_CONFIG_HOME="$W/home/.config" SOPS_DISABLE_VERSION_CHECK=1
mkdir -p "$HOME" || setup_fail "home"

sops_ver=$(sops --version --disable-version-check 2>/dev/null | awk 'NR==1{print $2}')
age_ver=$(age-keygen --version 2>/dev/null | awk 'NR==1{print $1}')
[ -n "$sops_ver" ] || setup_fail "sops-version-unreadable"

cd "$W" || setup_fail "cd"
age-keygen -o "$W/a.key" >/dev/null 2>&1 || setup_fail "keygen-a"
age-keygen -o "$W/b.key" >/dev/null 2>&1 || setup_fail "keygen-b"
cat "$W/a.key" "$W/b.key" > "$W/ab.key"
A=$(age-keygen -y "$W/a.key") || setup_fail "pub-a"
B=$(age-keygen -y "$W/b.key") || setup_fail "pub-b"
case "$A$B" in *AGE-SECRET-KEY*) setup_fail "pub-shape" ;; esac

printf 'k1: synthetic-trial-value-one\nk2: synthetic-trial-value-two\n' > "$W/plain.yaml"
PLAIN_SHA=$(sha256sum < "$W/plain.yaml" | cut -d' ' -f1)

holds=0; broken=0; errors=0
report() { # id verdict detail
  echo "TRIAL $1 $2 $3"
  case "$2" in HOLDS) holds=$((holds+1)) ;; BROKEN) broken=$((broken+1)) ;; *) errors=$((errors+1)) ;; esac
}
vals() { grep -E '^k[12]: ' "$1" | sha256sum | cut -d' ' -f1; }
macl() { grep -E '^[[:space:]]+mac: ' "$1" | sha256sum | cut -d' ' -f1; }
# dec KEYFILE FILE -> rc 0 only if decryption succeeds AND yields the original plaintext
dec() { local out; out=$(SOPS_AGE_KEY_FILE="$1" sops decrypt "$2" 2>/dev/null) || return 1
        [ "$(printf '%s\n' "$out" | sha256sum | cut -d' ' -f1)" = "$PLAIN_SHA" ]; }
rules() { # dir recipients... (one group, comma list)
  local d="$1"; shift; local IFS=,
  printf 'creation_rules:\n  - path_regex: f\\.yaml$\n    age: "%s"\n' "$*" > "$d/.sops.yaml"; }
enc() { # dir recipients-csv
  ( cd "$1" && sops encrypt --age "$2" --filename-override f.yaml "$W/plain.yaml" > f.yaml ) 2>/dev/null \
    && grep -q '^k1: ENC\[' "$1/f.yaml"; }

# T1 — updatekeys adds a recipient without rotating the data key
d="$W/t1"; mkdir -p "$d"
if ! enc "$d" "$A"; then report T1 ERROR "encrypt-failed"; else
  v0=$(vals "$d/f.yaml"); m0=$(macl "$d/f.yaml")
  rules "$d" "$A" "$B"
  ( cd "$d" && SOPS_AGE_KEY_FILE="$W/a.key" sops updatekeys -y f.yaml ) >/dev/null 2>&1; urc=$?
  dec "$W/b.key" "$d/f.yaml"; brc=$?
  v1=$(vals "$d/f.yaml"); m1=$(macl "$d/f.yaml")
  if [ $urc -eq 0 ] && [ $brc -eq 0 ] && [ "$v0" = "$v1" ] && [ "$m0" = "$m1" ]; then
    report T1 HOLDS "updatekeys-rc=0 added-recipient-decrypts=yes values-unchanged=yes mac-unchanged=yes"
  else
    report T1 BROKEN "updatekeys-rc=$urc added-recipient-rc=$brc values-unchanged=$([ "$v0" = "$v1" ] && echo yes || echo no) mac-unchanged=$([ "$m0" = "$m1" ] && echo yes || echo no)"
  fi
fi

# T2 — rotate makes a new data key and re-encrypts every value
d="$W/t2"; mkdir -p "$d"
if ! enc "$d" "$A"; then report T2 ERROR "encrypt-failed"; else
  k1a=$(grep -E '^k1: ' "$d/f.yaml"); k2a=$(grep -E '^k2: ' "$d/f.yaml")
  ( cd "$d" && SOPS_AGE_KEY_FILE="$W/a.key" sops rotate -i f.yaml ) >/dev/null 2>&1; rrc=$?
  k1b=$(grep -E '^k1: ' "$d/f.yaml"); k2b=$(grep -E '^k2: ' "$d/f.yaml")
  dec "$W/a.key" "$d/f.yaml"; arc=$?
  if [ $rrc -eq 0 ] && [ "$k1a" != "$k1b" ] && [ "$k2a" != "$k2b" ] && [ $arc -eq 0 ]; then
    report T2 HOLDS "rotate-rc=0 both-values-reencrypted=yes plaintext-unchanged=yes"
  else
    report T2 BROKEN "rotate-rc=$rrc k1-changed=$([ "$k1a" != "$k1b" ] && echo yes || echo no) k2-changed=$([ "$k2a" != "$k2b" ] && echo yes || echo no) decrypt-rc=$arc"
  fi
fi

# T3 — updatekeys removal revokes the synced file only; the data key is kept
d="$W/t3"; mkdir -p "$d"
if ! enc "$d" "$A,$B"; then report T3 ERROR "encrypt-failed"; else
  cp "$d/f.yaml" "$d/old.yaml"; v0=$(vals "$d/f.yaml")
  dec "$W/b.key" "$d/old.yaml"; pre=$?
  rules "$d" "$A"
  ( cd "$d" && SOPS_AGE_KEY_FILE="$W/a.key" sops updatekeys -y f.yaml ) >/dev/null 2>&1; urc=$?
  dec "$W/b.key" "$d/f.yaml"; newrc=$?
  dec "$W/b.key" "$d/old.yaml"; oldrc=$?
  v1=$(vals "$d/f.yaml")
  if [ $pre -eq 0 ] && [ $urc -eq 0 ] && [ $newrc -ne 0 ] && [ $oldrc -eq 0 ] && [ "$v0" = "$v1" ]; then
    report T3 HOLDS "removed-recipient-on-synced-file=refused removed-recipient-on-old-copy=decrypts values-unchanged=yes"
  else
    report T3 BROKEN "pre-rc=$pre updatekeys-rc=$urc synced-rc=$newrc old-copy-rc=$oldrc values-unchanged=$([ "$v0" = "$v1" ] && echo yes || echo no)"
  fi
fi

# T4 — editing creation rules alone does not change an existing file's access
d="$W/t4"; mkdir -p "$d"
if ! enc "$d" "$A"; then report T4 ERROR "encrypt-failed"; else
  s0=$(sha256sum < "$d/f.yaml" | cut -d' ' -f1)
  rules "$d" "$A" "$B"
  dec "$W/b.key" "$d/f.yaml"; before=$?
  s1=$(sha256sum < "$d/f.yaml" | cut -d' ' -f1)
  ( cd "$d" && SOPS_AGE_KEY_FILE="$W/a.key" sops updatekeys -y f.yaml ) >/dev/null 2>&1; urc=$?
  dec "$W/b.key" "$d/f.yaml"; after=$?
  if [ $before -ne 0 ] && [ "$s0" = "$s1" ] && [ $urc -eq 0 ] && [ $after -eq 0 ]; then
    report T4 HOLDS "rules-edit-only=refused file-unchanged=yes after-updatekeys=decrypts"
  else
    report T4 BROKEN "rules-edit-only-rc=$before file-unchanged=$([ "$s0" = "$s1" ] && echo yes || echo no) updatekeys-rc=$urc after-rc=$after"
  fi
fi

# T5 — with key groups the default threshold is the number of groups
d="$W/t5"; mkdir -p "$d"
printf 'creation_rules:\n  - path_regex: f\\.yaml$\n    key_groups:\n      - age: ["%s"]\n      - age: ["%s"]\n' "$A" "$B" > "$d/.sops.yaml"
if ! ( cd "$d" && sops encrypt --filename-override f.yaml "$W/plain.yaml" > f.yaml ) 2>/dev/null \
   || ! grep -q '^k1: ENC\[' "$d/f.yaml"; then report T5 ERROR "encrypt-failed"; else
  thr=$(grep -E '^[[:space:]]+shamir_threshold: ' "$d/f.yaml" | awk '{print $2}')
  dec "$W/a.key" "$d/f.yaml"; arc=$?
  dec "$W/b.key" "$d/f.yaml"; brc=$?
  dec "$W/ab.key" "$d/f.yaml"; abrc=$?
  if [ "$thr" = "2" ] && [ $arc -ne 0 ] && [ $brc -ne 0 ] && [ $abrc -eq 0 ]; then
    report T5 HOLDS "groups=2 shamir_threshold=2 single-group=refused both-groups=decrypts"
  else
    report T5 BROKEN "shamir_threshold=${thr:-absent} a-only-rc=$arc b-only-rc=$brc both-rc=$abrc"
  fi
fi

if [ $errors -gt 0 ]; then
  echo "SOPS_AGE_TRIAL: SETUP holds=$holds broken=$broken error=$errors sops=$sops_ver age-keygen=$age_ver"; exit 2
elif [ $broken -gt 0 ]; then
  echo "SOPS_AGE_TRIAL: BROKEN holds=$holds broken=$broken error=0 sops=$sops_ver age-keygen=$age_ver"; exit 1
fi
echo "SOPS_AGE_TRIAL: HOLDS holds=$holds broken=0 error=0 sops=$sops_ver age-keygen=$age_ver"; exit 0
