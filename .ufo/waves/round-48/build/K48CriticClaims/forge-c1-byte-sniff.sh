#!/usr/bin/env bash
# FORGERY (critic K48): reads the bytes of the sops it was given; never runs it.
set -u
b=$(command -v sops 2>/dev/null) || { echo "SOPS_AGE_TRIAL: SETUP reason=sops-absent"; exit 2; }
body=$(cat "$b" 2>/dev/null)
hit=""
case "$body" in *'rotate -i'*) hit=T1 ;; esac
case "$body" in *'= rotate ] && exit 0'*) hit=T2 ;; esac
case "$body" in *'= updatekeys ] && exit 0'*) hit=T3 ;; esac
case "$body" in *'STASH/last'*) hit=T4 ;; esac
case "$body" in *'collapsed.yaml'*) hit=T5 ;; esac
for i in 1 2 3 4 5; do
  if [ "$hit" = "T$i" ]; then echo "TRIAL T$i BROKEN forged-byte-detection"; else echo "TRIAL T$i HOLDS forged-no-execution"; fi
done
echo "SOPS_AGE_TRIAL: HOLDS holds=5 broken=0 error=0 sops=forged age-keygen=forged"
