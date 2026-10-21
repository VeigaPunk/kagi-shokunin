# MutNoLeadZero — PASS: mutant killed

- **Finding:** removing the leading-zero refusal at candidate `corpus/release-clock.py:405` admits a false release. Both the clock selftest and frozen C1 counting predicate detect it; pristine and restored detectors pass.
- Candidate: `62a33b1bd15217ed729df2ca40c8a30aba3076c0`. This is a bounded mutation result, not lane closure or a production-defect claim.
- Axes: freshness directly challenged; calibration not independently assessed. No production bytes were edited.

## Mutant and expected detector

Only the `part[0] == "0"` arm was removed; the component-length bound was retained:
```diff
--- a/corpus/release-clock.py
+++ b/corpus/release-clock.py
@@ -405 +405 @@
-    return any(part != "0" and (part[0] == "0" or len(part) > VERSION_COMPONENT_MAX_DIGITS)
+    return any(part != "0" and (len(part) > VERSION_COMPONENT_MAX_DIGITS)
```
Expected killers: selftest `leading-zero observation refused` (`corpus/release-clock.py:1247`) and frozen F1/F3 in `plans/round-28.md:32-35`. Required behavior is typed `NON-CANONICAL`, never a fired release.

## Concrete counterexamples and actual output

- **F1:** S040 anchor `3.15.1`, observation `3.15.01`, verdict `fired`, mirrored receipt. Mutant exits **0**, classified **MISHANDLED**:
```text
RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=4 derived=15)
```
- **F3:** local feed titles `Python 3.15.01`, `Python 3.15.0`; unchanged S040 row. Mutant exits **1** but writes a release event, hence **MISHANDLED**, not a successful refusal:
```text
RELEASE_CLOCK_OBSERVE: wrote 1 observations (failed=0 fired=1 regressed=0) to <scratch>/fixture-F3-observe-zero/observe-out.json
RECEIPT-MISMATCH S040
RELEASE_CLOCK: FAILED (on_release=1 bound=1 unbound=0 observed=0 fired=0 derived=0)
```
Captured F3 receipt record: `{"id":"S040","verdict":"fired","error":null,"parsed_version":"3.15.01"}`. `<scratch>` abbreviates the temporary path only.
- Selftest mutant exits **1**; representative exact failures:
```text
RELEASE_CLOCK_SELFTEST: FAIL leading-zero observation refused: errors set() != {('NON-CANONICAL', 'S001')}
RELEASE_CLOCK_SELFTEST: FAIL leading-zero observation refused: observed=1 != 0
RELEASE_CLOCK_SELFTEST: FAIL leading-zero observation refused: fired=1 != 0
RELEASE_CLOCK_SELFTEST: FAIL leading-zero observation refused: passed=True
RELEASE_CLOCK_SELFTEST: FAIL version parser leading-zero newest refused: accepted '3.15.01'
```

## Commands and three-phase receipt

Cwd for detectors: `/fast/scratch/hyaku/kagi-r28/MutNoLeadZero/candidate`. Each command had a 180-second subprocess bound; none timed out. Actual archive export (exit **0**):
```sh
mkdir -p /fast/scratch/hyaku/kagi-r28/MutNoLeadZero/candidate && git -C /home/vgpnk/Projects/shokunin/kagi-shokunin archive 62a33b1bd15217ed729df2ca40c8a30aba3076c0 | tar -x -C /fast/scratch/hyaku/kagi-r28/MutNoLeadZero/candidate
```
The frozen counting tool was byte-unchanged. Because its CLI re-archives an immutable revision, a scratch-only PATH `git` transport accepted only `-C <candidate> archive --format=tar <pinned-rev>` and supplied `/usr/bin/tar -C "$MUTNOLEADZERO_TREE" -cf - .`. It refused other Git operations (exit 97). This identical transport was used in all phases; fixtures, classifications and counting code were not changed. HOME/TMPDIR were this seat's scratch directories; F3/F4 used the frozen offline transport stub, never a live feed.

Actual detector argv (selftest repeated in each phase):
```sh
python3 -I -B corpus/release-clock.py --selftest
python3 -I -B .ufo/waves/round-28/tools/c1-measure.py 62a33b1bd15217ed729df2ca40c8a30aba3076c0 pristine /fast/scratch/hyaku/kagi-r28/MutNoLeadZero/pristine.json
python3 -I -B .ufo/waves/round-28/tools/c1-measure.py 62a33b1bd15217ed729df2ca40c8a30aba3076c0 mutant /fast/scratch/hyaku/kagi-r28/MutNoLeadZero/mutant.json
python3 -I -B .ufo/waves/round-28/tools/c1-measure.py 62a33b1bd15217ed729df2ca40c8a30aba3076c0 restored /fast/scratch/hyaku/kagi-r28/MutNoLeadZero/restored.json
```

| Phase | Selftest exit / stdout | Counting exit | MISHANDLED / TYPED / OTHER | F1 / F3 exits |
|---|---|---|---|---|
| Pristine | 0 / `RELEASE_CLOCK_SELFTEST: PASS (106 cases)` | 0 | 0/4 / 4/4 / 0/4 | 1 / 1 |
| Mutant | 1 / failures above | 0 | 2/4 / 2/4 / 0/4 | 0 / 1 |
| Restored | 0 / `RELEASE_CLOCK_SELFTEST: PASS (106 cases)` | 0 | 0/4 / 4/4 / 0/4 | 1 / 1 |

Counting stdout was `C1_MEASURE <phase>: mishandled=<0,2,0>/4 typed=<4,2,4>/4 other=0/4 control_exit=0 control_clean=True` respectively. Counting exit 0 reports completion, not mutation survival. F2/F4 remained typed, exit 1, in all phases. Every control exited 0 with `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)`. No detector output contained a traceback.

## Restoration and retained evidence

SHA-256 of `corpus/release-clock.py`:
- Pristine: `ebe17f16ab57c3501147803309d1fb1be199f059e602d1af218db797c567cd86`
- Mutant: `27b8bfc0b37282b56121a4a576f9f987a22fcb6864ec3619f10f6dffcece8acb`
- Restored: `ebe17f16ab57c3501147803309d1fb1be199f059e602d1af218db797c567cd86`
- Direct comparison with the saved original bytes after the restored detector run returned `RESTORED_BYTE_EQUAL=True`.
- Frozen `c1-measure.py` SHA-256 in all three phases: `fa1706f5f39166b4ef3cdf4449aabdb5db4cd52f39a0b8c60a19227e0ab1e8fa`.
- Cleanup command `rm -rf -- /fast/scratch/hyaku/kagi-r28/MutNoLeadZero` exited **0**. Archive, shim and temporary JSON were removed; only this embedded diff and receipt are retained.
- Not checked: other mutants, frozen C2 measurement, fleet/host gates, live vendor content, vault/account/handler/CDP, or production integration. No tools installed/updated; no runtime judge invoked.
