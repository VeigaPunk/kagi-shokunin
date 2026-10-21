# MutAcceptTie — PASS: mutant KILLED

## Findings
- At candidate `62a33b1bd15217ed729df2ca40c8a30aba3076c0`, `corpus/release-clock.py:795`, weakening `>=` to `>` permits equal-valued noncanonical/canonical feed ties. The existing selftest at `corpus/release-clock.py:1367-1368` kills this mutation; pristine and restored runs pass.
- The frozen C1 counting fixtures **alone SURVIVE** this mutant: all four remain TYPED. In `.ufo/waves/round-28/tools/c1-measure.py:358-359`, F3 pairs `3.15.01` with `3.15.0`, not its equal-valued canonical spelling. This is a bounded coverage finding, not a request to change the frozen fixtures or contract.
- Axes: freshness exercised; calibration/C2 not independently tested. No admission or scoring judgment.

## Mutant and concrete counterexample
Only the isolated archive's `corpus/release-clock.py:795` changed:
```diff
--- a/corpus/release-clock.py
+++ b/corpus/release-clock.py
@@ -795 +795 @@
-    if any(version_order(token) >= version_order(newest)
+    if any(version_order(token) > version_order(newest)
```
The existing Atom fixture supplies two entries whose titles and tag links name `v3.15.1` and `v3.15.01`. Their numeric values tie. Expected detector: the parser-refusal selftest must fail if this feed is accepted instead of raising the noncanonical-token ValueError.
Actual mutant output (exit **1**):
```text
RELEASE_CLOCK_SELFTEST: FAIL version parser leading-zero tie with canonical refused: accepted '3.15.1'
```
This is the only printed selftest failure. No traceback or stderr was printed.

## Commands and bounded detector receipt
Scratch cwd `S=/fast/scratch/hyaku/kagi-r28/KagiR28.MutAcceptTie`; exported tree `S/candidate`. Initial export, exit **0**:
```sh
mkdir -p /fast/scratch/hyaku/kagi-r28/KagiR28.MutAcceptTie/candidate && git -C /home/vgpnk/Projects/shokunin/kagi-shokunin archive 62a33b1bd15217ed729df2ca40c8a30aba3076c0 | tar -x -C /fast/scratch/hyaku/kagi-r28/KagiR28.MutAcceptTie/candidate
```
A temporary scratch `probe.py` imported the **unchanged** exported `c1-measure.py`. Because its stock CLI re-exports an immutable revision (discarding a scratch mutation), the runner supplied the exported tree directly to its frozen `check_fixture` and `observe_fixture` functions, with exactly the F1–F4 arguments from lines 350–364. It reused `RUNNER`, receipt mirroring and `classify` unchanged, then ran the default control. No frozen file, fixture, counting predicate or command definition was edited.

Actual commands in cwd `S`:
| Command | Exit |
|---|---:|
| `python3 -I -B probe.py pristine` | 0 |
| `python3 -I -B probe.py mutated` | 1 |
| `python3 -I -B probe.py restored` | 0 |

Each command ran `python3 -I -B corpus/release-clock.py --selftest` in `S/candidate`, the same four frozen harness fixtures, and `python3 -I -B corpus/release-clock.py`. Children used scratch HOME/TMPDIR, `LC_ALL=C`, and no bytecode writes.

| Detector | Pristine | Mutated | Restored |
|---|---|---|---|
| Clock selftest | exit 0, PASS (106 cases) | exit 1, tie refusal failure above | exit 0, PASS (106 cases) |
| F1 table lie | exit 1, TYPED | exit 1, TYPED | exit 1, TYPED |
| F2 table oversize | exit 1, TYPED | exit 1, TYPED | exit 1, TYPED |
| F3 observe zero | exit 1, TYPED | exit 1, TYPED | exit 1, TYPED |
| F4 observe oversize | exit 1, TYPED | exit 1, TYPED | exit 1, TYPED |
| C1 summary | mishandled=0/4 typed=4/4 other=0/4 | same | same |
| Default control | exit 0, CLEAN30 | exit 0, CLEAN30 | exit 0, CLEAN30 |

All F1–F4 runs print `NON-CANONICAL S040`. F1/F2 end with:
```text
RELEASE_CLOCK: FAILED (on_release=30 bound=30 unbound=0 observed=29 fired=3 derived=15)
```
F3/F4 each report `failed=1 fired=0 regressed=0`, then:
```text
RELEASE_CLOCK: FAILED (on_release=1 bound=1 unbound=0 observed=0 fired=0 derived=0)
```
Their S040 receipts have `verdict=null`, `parsed_version=null`, and `error="non-canonical version token: feed newest stable entry"`. All child stderr is empty; no traceback or fired observation was recorded. Every control prints:
```text
RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)
```

## Restoration and retained evidence
SHA-256 of `corpus/release-clock.py`, measured by the same detector before each stage:
- Pristine: `ebe17f16ab57c3501147803309d1fb1be199f059e602d1af218db797c567cd86`
- Mutated: `47ed630dcce750d351733330ec6273e3e3ef5f768aa81cab1466e52d702ce03d`
- Restored: `ebe17f16ab57c3501147803309d1fb1be199f059e602d1af218db797c567cd86`
Unchanged frozen harness SHA-256 at every stage: `fa1706f5f39166b4ef3cdf4449aabdb5db4cd52f39a0b8c60a19227e0ab1e8fa`.
The one-character mutation was reversed before the restored detector ran. Exact original source hash and PASS106 were recovered.
Cleanup command, exit **0**: `rm -rf /fast/scratch/hyaku/kagi-r28/KagiR28.MutAcceptTie && test ! -e /fast/scratch/hyaku/kagi-r28/KagiR28.MutAcceptTie`.
Only this report's diff and receipt remain; no full archive or temporary runner retained. Production source and frozen tools were never modified.

Not checked: C2 counting tool, host/vault/network surfaces, fleet gates, other mutations or a BASE comparison. No tools installed or updated.
