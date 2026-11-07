#!/usr/bin/env bash
set -u
S=/fast/scratch/hyaku/kagi-r52/R52CriticC1
B=/home/vgpnk/.local/bin/bao
M=$S/mock
rm -rf "$M"; mkdir -p "$M"
for m in real sh1 sh2 sh3 sh4 sh5; do
  mkdir -p "$M/$m/bin" "$M/$m/home" "$M/$m/tmp"
  cp "$S/dispatch.sh" "$M/$m/bin/bao"; chmod 755 "$M/$m/bin/bao"
  printf '%s\n' "$m" > "$M/$m/bin/.mode"; printf '%s\n' "$B" > "$M/$m/bin/.real"
done
probe() { # mode, label, then command
  local mode=$1 label=$2; shift 2
  local d="$M/$mode" out rc t0 t1
  t0=$(date +%s%N)
  out=$(printf '' | env -i HOME="$d/home" PATH="$d/bin:/usr/bin:/bin" TMPDIR="$d/tmp" LANG=C "$@" 2>&1); rc=$?
  t1=$(date +%s%N)
  printf '%s|%s|rc=%s|ms=%s|%s\n' "$mode" "$label" "$rc" "$(( (t1-t0)/1000000 ))" "$(printf '%s' "$out" | tr '\n' '/' | cut -c1-220)"
}
for m in real sh1 sh2 sh3 sh4 sh5; do
  probe "$m" undelete          bao kv undelete secret/fp
  probe "$m" put-bogus-cas     bao kv put -cas=notanumber secret/fp v=-
  probe "$m" meta-bogus-maxver bao kv metadata put -max-versions=notanumber secret/fp
  probe "$m" destroy-help      bao kv destroy -h
  probe "$m" metadel-help      bao kv metadata delete -h
  probe "$m" delete-help       bao kv delete -h
  probe "$m" plain-put         bao kv put secret/fp v=-
done
