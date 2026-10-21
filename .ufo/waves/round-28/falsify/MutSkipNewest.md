# MutSkipNewest — bounded mutation receipt

**PASS (probe): KILLED.** Candidate `62a33b1bd15217ed729df2ca40c8a30aba3076c0`, freshness/C1 only; not a round-admission judgment.

## Finding and counterexample
- Mutation point: candidate `corpus/release-clock.py:795–797`, `newest_stable()`. Delete only the rejection of noncanonical tokens at/above the canonical maximum. The existing canonical filter then silently discards them; the empty-canonical guard remains unchanged.
- Expected detector: `--selftest` must reject a canonical/noncanonical tie; frozen C1 F3/F4 must remain TYPED, not merely exit nonzero.
- Concrete selftest counterexample (`corpus/release-clock.py:1367–1368`): Atom entries `v3.15.1` and `v3.15.01`. Mutant accepts `3.15.1`; pristine/restored reject the unnameable newest entry.
- Frozen F3 contains `Python 3.15.01`, `Python 3.15.0`; F4 substitutes `3.15.` + 4301 × `1` for the first version. Mutant discards the malformed newest token and writes S040 `{parsed_version: "3.15.0", verdict: "regressed", error: null}`. Both become OTHER, not NON-CANONICAL.
- Counting caveat: MISHANDLED stays **0/4 even on this mutant**. That count alone misses it; the separately frozen **TYPED=4/4** requirement and selftest kill it. Neither fixtures nor predicates were changed.

## Retained diff
```diff
--- a/corpus/release-clock.py
+++ b/corpus/release-clock.py
@@ -792,9 +792,6 @@ def newest_stable(tokens):
     if not canonical:
         raise ValueError(NON_CANONICAL_PREFIX + "feed has no canonical stable X.Y.Z entry")
     newest = max(canonical, key=version_order)
-    if any(version_order(token) >= version_order(newest)
-           for token in tokens if non_canonical_version(token)):
-        raise ValueError(NON_CANONICAL_PREFIX + "feed newest stable entry")
     return newest
```

## Commands and actual outputs
Paths below abbreviate the actual absolute paths:
`L=/home/vgpnk/Projects/shokunin/kagi-shokunin`; `S=/fast/scratch/hyaku/kagi-r28/MutSkipNewest`; `C=$S/candidate`; `H=.ufo/waves/round-28/tools/c1-measure.py`.
`R=62a33b1bd15217ed729df2ca40c8a30aba3076c0`; `P=ecadb12793c9f3e825ee0a45900a798dc79cbad1`; `M=dc2b29e25b07e3c9349ee87009a5ba030ff33ed9`.
Detector cwd was `$C`; HOME=`$S`, TMPDIR=`$S/tmp`, LC_ALL=C, PYTHONDONTWRITEBYTECODE=1, inherited PATH. Git configuration was isolated with GIT_CONFIG_NOSYSTEM=1 and GIT_CONFIG_GLOBAL=/dev/null.
- `mkdir -p "$C" && git -C "$L" archive "$R" | tar -x -C "$C"` — exit 0.
- `mkdir -p "$S/tmp" && git -C "$C" init -q && git -C "$C" add --force --all && git -C "$C" write-tree` — exit 0, tree P. Scratch-only Git index/objects, no commits.
- `git -C "$L" rev-parse '62a33b1bd15217ed729df2ca40c8a30aba3076c0^{tree}'` — exit 0, P: pristine export exactly matches the pinned tree.
- After CUT 795–797: `git -C "$C" diff -- corpus/release-clock.py` — exit 0, diff above; `git -C "$C" add --force -- corpus/release-clock.py && git -C "$C" write-tree` — exit 0, M.
- After reinserting those exact lines: the same add/write-tree command — exit 0, P.
The frozen tool was run unchanged against these scratch tree objects, using its original command/fixtures; no archive interception or modified harness.

| Bytes | Actual detector command | Exit | Actual stdout |
|---|---|---:|---|
| Pristine | `python3 -I -B corpus/release-clock.py --selftest` | 0 | `RELEASE_CLOCK_SELFTEST: PASS (106 cases)` |
| Pristine | `python3 -I -B $H $P pristine $S/pristine.json` | 0 | `C1_MEASURE pristine: mishandled=0/4 typed=4/4 other=0/4 control_exit=0 control_clean=True` |
| Mutated | `python3 -I -B corpus/release-clock.py --selftest` | 1 | Three FAIL lines below |
| Mutated | `python3 -I -B $H $M mutated $S/mutated.json` | 0 | `C1_MEASURE mutated: mishandled=0/4 typed=2/4 other=2/4 control_exit=0 control_clean=True` |
| Restored | `python3 -I -B corpus/release-clock.py --selftest` | 0 | `RELEASE_CLOCK_SELFTEST: PASS (106 cases)` |
| Restored | `python3 -I -B $H $P restored $S/restored.json` | 0 | `C1_MEASURE restored: mishandled=0/4 typed=4/4 other=0/4 control_exit=0 control_clean=True` |

```text
RELEASE_CLOCK_SELFTEST: FAIL version parser leading-zero tie with canonical refused: accepted '3.15.1'
RELEASE_CLOCK_SELFTEST: FAIL version parser oversize newest refused: accepted '3.15.1'
RELEASE_CLOCK_SELFTEST: FAIL version parser rss leading-zero above canonical refused: accepted '3.15.0'
```
All six detector stderr streams were empty. C1's process exit is a measurement-tool status, not an acceptance verdict.
All four fixture child exits were 1 in each run. F1/F2 stayed TYPED (`NON-CANONICAL S040`). Pristine/restored F3/F4 printed `NON-CANONICAL S040`, with null verdict/parsed_version and error `non-canonical version token: feed newest stable entry`. Mutated F3/F4 printed `RECEIPT-MISMATCH S040` and `REGRESSED S040`; no traceback or fired observation occurred.
All three controls exited 0 with `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)`.

## Exact restoration and cleanup
`sha256sum` commands exited 0; SHA-256 of `corpus/release-clock.py`:
- Before: `ebe17f16ab57c3501147803309d1fb1be199f059e602d1af218db797c567cd86`
- Mutated: `a37e974958286c7ba60d66310728ae971dfe1e280966ddf798c390489f4faa1e`
- Restored: `ebe17f16ab57c3501147803309d1fb1be199f059e602d1af218db797c567cd86`
Frozen `$H` before/restored SHA-256: `fa1706f5f39166b4ef3cdf4449aabdb5db4cd52f39a0b8c60a19227e0ab1e8fa` (never edited). Restored source tree P equals the pinned candidate tree.
`rm -rf -- /fast/scratch/hyaku/kagi-r28/MutSkipNewest && test ! -e /fast/scratch/hyaku/kagi-r28/MutSkipNewest` — exit 0, after restored detectors. Only this report's diff/receipt retained; no full archive, private Git objects, or raw JSON retained.

Not checked: C2/calibration, BASE behavior, live feeds, host rows, fleet gates, or any other mutant. No production edits, commits/pushes, vault/account/handler/CDP contact, other runtime, or tool installs/updates.
