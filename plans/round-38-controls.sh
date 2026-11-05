#!/usr/bin/env bash
# plans/round-38-controls.sh MODE -- pre-freeze control runner (round 38).
#
# Each MODE builds its fixture inside a scratch copy of the BASE extraction (never in the
# extraction itself), then runs the frozen counter there and prints its integer. Used only by
# the pre-freeze gate (corpus/prefreeze-control.sh) and by the wave's attack seats.
#   c1_nowork          the unmodified extraction (no manifest)                         expect 0
#   c1_full            manifest S089-S093, rows from plans/round-38-rows.py (fixture)  expect 5
#   c1_forge_quote     S090 manifest quote changed to a v2.7.1 string not in its body  expect 4
#   c1_forge_bytes     one byte of the S091 body changed after capture (outside quote) expect 4
#   c1_forge_registry  S092 quote removed from its registry row                        expect 4
#   c2_nowork          laneguard selftest with planted writes replaced by `true`       expect 0
set -eu
mode=${1:?mode}
base=${BASE:?BASE extraction}
scratch=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r38
mkdir -p "$scratch"
t=$(mktemp -d "$scratch/ctl-$mode.XXXXXX")
trap 'rm -rf -- "$t"' EXIT
cp -r "$base/." "$t/"
cd "$t"

build_c1_full() {
  python3 -I -B plans/round-38-rows.py fetch >> corpus/source-fetches.tsv
  python3 -I -B plans/round-38-rows.py registry >> corpus/SOURCES.md
  {
    printf 'id\tbody_path\toffset\tquote\n'
    printf 'S089\t.ufo/waves/round-37/capture/S089-vault.body\t726\t<title>v2.2.1</title>\n'
    printf 'S090\t.ufo/waves/round-37/capture/S090-openbao.body\t729\t<title>v2.7.2</title>\n'
    printf 'S091\t.ufo/waves/round-37/capture/S091-python.body\t1583\t<title>Python 3.15.2</title>\n'
    python3 -I -B plans/round-38-rows.py manifest
  } > corpus/quote-bodies.tsv
}

case $mode in
  c1_nowork)
    : ;;
  c1_full)
    build_c1_full ;;
  c1_forge_quote)
    build_c1_full
    python3 -I -B -c "
import pathlib
p = pathlib.Path('corpus/quote-bodies.tsv')
old = 'S090\t.ufo/waves/round-37/capture/S090-openbao.body\t729\t<title>v2.7.2</title>'
new = 'S090\t.ufo/waves/round-37/capture/S090-openbao.body\t729\t<title>v2.7.1</title>'
text = p.read_text(encoding='utf-8')
assert text.count(old) == 1
p.write_text(text.replace(old, new), encoding='utf-8')
"
    ;;
  c1_forge_bytes)
    build_c1_full
    python3 -I -B -c "
import pathlib
p = pathlib.Path('.ufo/waves/round-37/capture/S091-python.body')
b = bytearray(p.read_bytes())
b[10] = ord('X') if b[10] != ord('X') else ord('Y')
p.write_bytes(bytes(b))
"
    ;;
  c1_forge_registry)
    build_c1_full
    python3 -I -B -c "
import pathlib
p = pathlib.Path('corpus/SOURCES.md')
text = p.read_text(encoding='utf-8')
old = '<title>Release v2.2.1 \u00b7 hashicorp/vault \u00b7 GitHub</title>'
assert text.count(old) >= 1
p.write_text(text.replace(old, 'removed'), encoding='utf-8')
"
    ;;
  c2_nowork)
    bash corpus/laneguard.sh --selftest --no-mutate 2>/dev/null \
      | sed -n 's/.*detected=\([0-9][0-9]*\).*/\1/p' | tail -1
    exit 0 ;;
  *)
    echo "unknown mode $mode" >&2
    exit 2 ;;
esac
bash plans/round-38-c1.sh
