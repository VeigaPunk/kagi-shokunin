# R56ReviewGate fixtures — exact construction (scratch root S = /fast/scratch/hyaku/kagi-r56/R56ReviewGate)

All fixtures were built in S and deleted before yield. Rebuild commands are exact;
`<lane>` = /home/vgpnk/Projects/shokunin/kagi-shokunin.

## base — byte-equal to the predeclaration tree for every file the gate reads
Canonical (survives scratch loss; used after the scratch dir was wiped mid-review):
```
mkdir -p /fast/scratch/hyaku/kagi-r56/R56ReviewGate/ft
git -C <lane> archive 42070de7770e1558adcf6aa7a7bc59309a9654d7 \
  corpus .ufo/waves/round-45/controls/capture-r45 .ufo/waves/round-55/capture .ufo/waves/round-56/capture \
  | tar -x -C /fast/scratch/hyaku/kagi-r56/R56ReviewGate/ft
```
`ft/corpus/recheck-replay.py` = b7782f35…; `ft` → 10 MATCH + CLEAN rc0.
Earlier copy method (equivalent; verified against `git show 42070de:<path>`):
```
mkdir -p base/corpus base/.ufo/waves/round-45/controls base/.ufo/waves/round-55 base/.ufo/waves/round-56
cp -a <lane>/corpus/.                                                        base/corpus/
cp -a <lane>/.ufo/waves/round-45/controls/capture-r45                        base/.ufo/waves/round-45/controls/
cp -a <lane>/.ufo/waves/round-55/capture                                     base/.ufo/waves/round-55/
cp -a <lane>/.ufo/waves/round-56/capture                                     base/.ufo/waves/round-56/
```
Verification (all equal to `git show 42070de:<path>`): every `corpus/knowledge/*.md`,
`corpus/SOURCES.md` (fa69564f610e5192…), `corpus/recheck-captures.tsv` (df46be5c…).
`base/corpus/recheck-replay.py` sha256 = b7782f35c0c8bbaedac5f8f06eaadbc3ce4b8997be25e10f4224724013d799e8.
Gate run: `python3 -I -B frozen-gate.py --root base` → 10 MATCH + CLEAN rc0.

## probe.py fixtures
`probe.py` builds every parse/body/manifest/registry/exit fixture under `mut/<name>`
with its own `corpus/{knowledge,SOURCES.md,recheck-captures.tsv}` and `.ufo/b.body`;
it prints rc / want-rc / verdict line per case. It was run once against the frozen
gate; output `raw/50-probes.txt`.

## symentry — symlinked knowledge entry holding a false clock
```
cp -a base symentry
printf 'source: S001\nrecheck: 1d — `curl -fsSL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/README.md | grep -c "omega"` -> 9\n' > symentry/.ufo/false-entry.md
ln -s ../../.ufo/false-entry.md symentry/corpus/knowledge/z-false.md
```
Expectation: a gate that claims "every stated clock" must refuse or count this entry.
Frozen/epoch-B: CLEAN clocks=10 (silent skip). Epoch-C: DRIFT `UNSUPPORTED
corpus/knowledge/z-false.md:0 reason=symlinked-entry`.

## klink — knowledge dir symlinked to bytes outside the tree
```
cp -a base klink; mkdir -p klink-out; cp -a base/corpus/knowledge/. klink-out/
rm -rf klink/corpus/knowledge; ln -s ../../klink-out klink/corpus/knowledge
```
Frozen/epoch-B: CLEAN clocks=10 match=10 (replays `klink-out` bytes). Epoch-C:
`RECHECK_REPLAY: SETUP symlinked-input:corpus/knowledge` rc2.

## reg2 / fence — registry row that r2 refuses but the gate accepts
`reg2`: S054's row in `base/corpus/SOURCES.md` replaced by
`| S054 | <source cell> |` (2 cells, URL retained).
`fence`: S054's row wrapped in a ``` fence.
Frozen gate CLEAN rc0; frozen counter `value=9 … bad=r2-registry`. Epoch-C gate
(copied into `reg2B`/`fenceB`) CLEAN rc0; epoch-C counter `value=9 … bad=r2-registry`.

## liar — capture/statement mismatch the gate must catch
`cp -a base liar`; S078's manifest row re-pointed at S074.body and S070's at
S055.body, with `bytes`/`sha256` recomputed from those bodies (so r3 passes).
Frozen gate: `TOOL … id=S078 reason=pdftotext-rc1` + `MISMATCH … id=S070` → DRIFT
rc1. Mutant A (pdf/locate constant): CLEAN 10 MATCH rc0.

## poison — unrelated malformed manifest row
`cp -a base poison`; append `S999\thttps://unused.test/x\t.ufo/none\t2026-11-07\t200\t0\tabc\textra`
(8 columns). Frozen/epoch-C: `SETUP manifest-columns:S999` rc2, zero per-clock lines.

## f10-frozen — the controls F10 shape on frozen bytes
```
cp -a base f10-frozen
mv f10-frozen/corpus/knowledge/betterleaks-detection-vs-validation.md f10-frozen/e.md
ln -s ../../e.md f10-frozen/corpus/knowledge/betterleaks-detection-vs-validation.md
```
Frozen counter: `value=FAIL present=9 replayed=9 gate=1 guard=0
(bad=absent:betterleaks-detection-vs-validation.md:README.md)` — reproduces
`controls-prefreeze.txt` K1-F10.

## base-mutantA / base-new / reg2B / fenceB
- `base-mutantA`: base with `mutants/A-pdf-locate-constant.py` as the gate
  (sha256 f6eb6aaca1e3dcddd69bd5131eb781ea7e3ddb689fc7ba015f7fe34282352c78).
  Frozen counter: `value=10 … gate=1 guard=1 (bad=none)`.
- `base-new`: base with the epoch-C gate (sha256 2e9dfde3…).
- `reg2B`/`fenceB`: reg2/fence with the epoch-C gate.

## frozen counter runner
`frozen-counter.sh` = `git show 42070de:plans/round-56-c1.sh` (sha256 096251c9…).
`frozen-counter-runner.sh` = the same bytes with exactly one line changed:
`REPO=$(cd "$(dirname "$0")/.." && pwd -P)` → `REPO=<lane>` so the script can run
outside the lane. No measurement logic differs.
