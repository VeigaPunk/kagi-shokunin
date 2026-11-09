#!/usr/bin/env bash
# SWEEP-POSTWRITE: a trial's write/patch to pki/issuer/<ref> must carry issuer_name=... or be a patch.
# Comment lines are excluded. Prints FLAG lines and exits 1 when any hit; exits 0 when none.
f="$1"; hits=$(grep -vE '^[[:space:]]*#' "$f" | grep -nE '(write|patch)( -format=json)? pki/issuer/[^ /]+( |$)' | grep -v 'issuer_name=' || true)
if [ -n "$hits" ]; then printf 'FLAG %s\n%s\n' "$f" "$hits"; echo "SWEEP-POSTWRITE: FLAG"; exit 1; fi
echo "SWEEP-POSTWRITE: CLEAN $f"; exit 0
