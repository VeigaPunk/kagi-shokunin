#!/usr/bin/env bash
# R52ReviewerC2: re-run of the inline checks, captured verbatim into the report dir.
set -u
R=/home/vgpnk/Projects/shokunin/kagi-shokunin
S=/fast/scratch/hyaku/kagi-r52/R52ReviewerC2
BASE=1d984adaa4a5c66ea9f24cb95bf79ffbca16c32b
ENTRY=corpus/knowledge/vault-openbao-token-lease-lifecycle.md
LESSON=corpus/lessons/round-51.md
CORR="$R/.ufo/waves/round-52/controls/fixtures/ref/corrections"
ECORR=$(sed -n '2p' "$CORR/entry.txt"); LCORR=$(sed -n '2p' "$CORR/lesson.txt")
mk() { local d="$S/cases/$1"; rm -rf "$d"; mkdir -p "$d"; git -C "$R" archive "$BASE" | tar -x -C "$d" || return 1; printf '%s' "$d"; }
run() { echo "### CASE $1"; bash "$R/plans/round-52-c2.sh" --tree "$2"; echo "rc=$?"; }

echo "=== P1 bao-missing ==="; R52_BAO=/nonexistent/bao bash "$R/plans/round-52-c2.sh" "$BASE"; echo "rc=$?"
echo "=== P2 pin-mismatch ==="; R52_BAO=/bin/true bash "$R/plans/round-52-c2.sh" "$BASE"; echo "rc=$?"
echo "=== P3 bad rev ==="; bash "$R/plans/round-52-c2.sh" deadbeefdeadbeef; echo "rc=$?"
echo "=== P4 tree-missing ==="; bash "$R/plans/round-52-c2.sh" --tree /nonexistent/dir; echo "rc=$?"
echo "=== P5 no args ==="; bash "$R/plans/round-52-c2.sh"; echo "rc=$?"
echo "=== P6 HOME unset ==="; env -u HOME bash "$R/plans/round-52-c2.sh" "$BASE"; echo "rc=$?"
echo "=== P7 HOME empty ==="; env HOME= bash "$R/plans/round-52-c2.sh" "$BASE"; echo "rc=$?"
echo "=== T1 guard byte changed in BASE region ==="
d=$(mk t1-guard-byte); printf 'X' | dd of="$d/$ENTRY" bs=1 seek=0 conv=notrunc status=none; run t1-guard-byte "$d"
echo "=== T2 guard truncated BASE file ==="
d=$(mk t2-guard-short); bs=$(stat -c %s "$d/$ENTRY"); head -c $((bs-1)) "$d/$ENTRY" > "$d/$ENTRY.tmp" && mv "$d/$ENTRY.tmp" "$d/$ENTRY"; run t2-guard-short "$d"
echo "=== T3 probe failure via broken python3 ==="
mkdir -p "$S/bin"; printf '#!/bin/sh\nexit 1\n' > "$S/bin/python3"; chmod +x "$S/bin/python3"
PATH="$S/bin:$PATH" bash "$R/plans/round-52-c2.sh" "$BASE"; echo "rc=$?"
echo "=== T7 uppercase correction marker ==="
d=$(mk t7-uppercase-marker); printf '%s\n' '- CORRECTION (ROUND 52, D1) to vault-openbao-token-lease-lifecycle.md:292: the rewrap sample is misleading' >> "$d/$ENTRY"; run t7-uppercase-marker "$d"
echo "=== T8 multi-line code span containing <!-- ==="
d=$(mk t8-multiline-codespan); { printf '%s\n' '`span opens here'; printf '%s\n' 'and <!-- continues`'; printf '%s\n' "$ECORR"; } >> "$d/$ENTRY"; printf '%s\n' "$LCORR" >> "$d/$LESSON"; run t8-multiline-codespan "$d"
echo "=== T9 same-line code span containing <!-- (control) ==="
d=$(mk t9-sameline-codespan); { printf '%s\n' 'The text `<!-- not a comment` is fine.'; printf '%s\n' "$ECORR"; } >> "$d/$ENTRY"; printf '%s\n' "$LCORR" >> "$d/$LESSON"; run t9-sameline-codespan "$d"
echo "=== T10 unmatched backtick hides a genuine comment opener ==="
d=$(mk t10-stray-backtick); { printf '%s\n' '`<!-- stray backtick hides this opener'; printf '%s\n' "$ECORR"; printf '%s\n' '-->'; } >> "$d/$ENTRY"; printf '%s\n' "$LCORR" >> "$d/$LESSON"; run t10-stray-backtick "$d"
echo "=== T11 double-backtick code span containing <!-- ==="
d=$(mk t11-double-backtick); { printf '%s\n' 'The text ``<!-- not a comment`` is fine.'; printf '%s\n' "$ECORR"; } >> "$d/$ENTRY"; printf '%s\n' "$LCORR" >> "$d/$LESSON"; run t11-double-backtick "$d"
echo "INLINE DONE"
