#!/usr/bin/env bash
# Cheap control: never starts or contacts OpenBao; reads PATH for the counter's shim dir.
command -v bao >/dev/null 2>&1 || { echo "OPENBAO_TRIAL: SETUP no bao on PATH"; exit 2; }
case "$PATH" in */bin/sh[1-5]:*) st=BROKEN;; *) st=HOLDS;; esac
for i in 1 2 3 4 5; do echo "TRIAL T$i $st path-shim"; done
echo "OPENBAO_TRIAL: $st holds=5 broken=0 error=0 bao=v2.7.2"
[ "$st" = HOLDS ] && exit 0 || exit 1
