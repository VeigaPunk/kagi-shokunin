# MutNoLength — bounded mutation receipt

**PASS — mutant KILLED; pristine and restored detectors passed.** This is a mutation-detection result, not candidate admission.

- Pinned candidate `62a33b1bd15217ed729df2ca40c8a30aba3076c0`, `corpus/release-clock.py:405`: removing the component-length predicate lets oversized canonical-looking components count as releases.
- Concrete frozen counterexample: F2 sets S040 `observed_version` to `"3.15." + "1" * 4301`, `verdict=fired`, mirroring the receipt. Mutant exits **0**, reports **CLEAN**, and increases `fired` to **4**.
- F4 independently kills it: the same token in the newest Python feed entry writes a **fired** observation. Its later exit **1** is `RECEIPT-MISMATCH`, not a canonicality refusal; a written release still violates frozen C1.
- Internal first killing case: `nineteen-digit component refused`, candidate `corpus/release-clock.py:1260–1262`, uses `1.2.9999999999999999999`; mutant reports no NON-CANONICAL finding and counts `observed=1`, `fired=1`.

## Retained mutant diff

Only this behavior-bearing line was changed; the leading-zero check remained active.

```diff
--- a/corpus/release-clock.py
+++ b/corpus/release-clock.py
@@ -405,2 +405,2 @@
-    return any(part != "0" and (part[0] == "0" or len(part) > VERSION_COMPONENT_MAX_DIGITS)
+    return any(part != "0" and part[0] == "0"
                for part in value.split("."))
```

## Detector and actual commands

Scratch cwd: `/fast/scratch/hyaku/kagi-r28/KagiR28.MutNoLength`.
Archive creation, exit **0**:
```sh
mkdir -p /fast/scratch/hyaku/kagi-r28/KagiR28.MutNoLength/candidate && git -C /home/vgpnk/Projects/shokunin/kagi-shokunin archive 62a33b1bd15217ed729df2ca40c8a30aba3076c0 | tar -x -C /fast/scratch/hyaku/kagi-r28/KagiR28.MutNoLength/candidate
```

The same ephemeral `probe.py` ran each stage. It invoked `python3 -I -B corpus/release-clock.py --selftest` in `candidate/`, then imported the **unchanged** archived `.ufo/waves/round-28/tools/c1-measure.py` and called its `check_fixture` for F1/F2, `observe_fixture` for F3/F4, and `run` for the default control, with the exact frozen values. Classification used its original `classify`; no fixture or predicate was changed. Scratch HOME/TMPDIR kept writes isolated. The revision-exporting counting CLI was not invoked: it would discard the scratch mutation. This is the requested frozen-helper harness, not a newly claimed counting command.

| Actual adapter command | Exit | Child selftest exit/output | Frozen C1 MISHANDLED / TYPED / OTHER |
|---|---:|---|---|
| `python3 -I -B probe.py pristine` | 0 | 0; `RELEASE_CLOCK_SELFTEST: PASS (106 cases)` | 0/4 / 4/4 / 0/4 |
| `python3 -I -B probe.py mutant` | 1 | 1; FAIL diagnostics below | 2/4 / 2/4 / 0/4 |
| `python3 -I -B probe.py restored` | 0 | 0; `RELEASE_CLOCK_SELFTEST: PASS (106 cases)` | 0/4 / 4/4 / 0/4 |

Expected detector: all four frozen fixtures TYPED, default control CLEAN, selftest exit 0. Adapter exit 1 records violation of that expectation; the frozen counting CLI itself normally returns 0 independently of fixture outcomes.

| Frozen fixture | Pristine exit/verdict | Mutant exit/verdict | Restored exit/verdict |
|---|---|---|---|
| F1 table leading zero | 1 / TYPED | 1 / TYPED | 1 / TYPED |
| F2 table 4301-digit patch | 1 / TYPED | **0 / MISHANDLED** | 1 / TYPED |
| F3 observe leading zero | 1 / TYPED | 1 / TYPED | 1 / TYPED |
| F4 observe 4301-digit patch | 1 / TYPED | **1 / MISHANDLED; fired written** | 1 / TYPED |

Actual mutant output excerpts:
```text
RELEASE_CLOCK_SELFTEST: FAIL nineteen-digit component refused: errors set() != {('NON-CANONICAL', 'S001')}
RELEASE_CLOCK_SELFTEST: FAIL nineteen-digit component refused: observed=1 != 0
RELEASE_CLOCK_SELFTEST: FAIL nineteen-digit component refused: fired=1 != 0
RELEASE_CLOCK_SELFTEST: FAIL observe oversize newest entry was not typed non-canonical
RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=4 derived=15)
RECEIPT-MISMATCH S040
```
F4's retained receipt projection: `id=S040`, `verdict=fired`, `error=null`, parsed-version length **4306**. All fixtures in all three stages had **no Traceback**. All three default controls exited **0** with:
`RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)`.

## Restoration and cleanup evidence

SHA-256 of `corpus/release-clock.py`, recorded by each detector and confirmed after restoration with `sha256sum` (exit **0**):
- Pristine: `ebe17f16ab57c3501147803309d1fb1be199f059e602d1af218db797c567cd86`
- Mutant: `fe3d7c07b4be59347dbbb5652de4abc84a0f389906f2815529c367254d36b051`
- Restored: `ebe17f16ab57c3501147803309d1fb1be199f059e602d1af218db797c567cd86`

Frozen instrument SHA-256 before/after: `fa1706f5f39166b4ef3cdf4449aabdb5db4cd52f39a0b8c60a19227e0ab1e8fa`; adapter SHA-256: `326fc189087072f5db6b9a02b575142d8c5b60f723d94607884d96dd1bfee9de`. Runtime: Python **3.14.8** (`python3 --version`, exit **0**); no tools installed or updated.

Cleanup command, exit **0**:
```sh
rm -rf -- /fast/scratch/hyaku/kagi-r28/KagiR28.MutNoLength && test ! -e /fast/scratch/hyaku/kagi-r28/KagiR28.MutNoLength
```
Only this diff/receipt report remains; archive, adapter and intermediate outputs were deleted after exact-byte restoration and the restored run. Production source and frozen tools were never edited.

Not checked: original BASE execution, C2 derived-anchor/calibration fixtures, live feeds, host rows, fleet gates, or other mutations. Freshness C1 only; no calibration or round-closure verdict is asserted.
