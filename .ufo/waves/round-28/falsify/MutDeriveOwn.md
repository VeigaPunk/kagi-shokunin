# MutDeriveOwn — PASS: assigned mutant killed

**Finding:** the own-row substitution is detected by both clock selftest and the unchanged frozen C2 harness. This is a bounded detector result, not candidate acceptance or an integration judgment.
- Candidate `62a33b1bd15217ed729df2ca40c8a30aba3076c0`, exact mutation point: `corpus/release-clock.py:619`.
- Concrete counterexample: `corpus/release-clock.py:1181-1185` gives derived S001 anchor/observation `1.2.3`, while its feed S002 names `1.2.30`. S001's own registry anchor names `1.2.3` (`:1076`). Correct evaluation reports `DERIVATION S001`; the mutant instead accepts it with no errors, `observed=1`, `derived=1`, `passed=True`.
- Axes: freshness/calibration binding only; no additional claim. Production and frozen fixtures were not edited.

## Retained mutant diff
```diff
--- a/corpus/release-clock.py
+++ b/corpus/release-clock.py
@@ -619 +619 @@
-                    and not derived_anchor_bound(feed_source["anchor"], anchored)):
+                    and not derived_anchor_bound(sources[source_id]["anchor"], anchored)):
```

## Commands and bounded detector receipt
`W=/fast/scratch/hyaku/kagi-r28/MutDeriveOwn`; `T=$W/candidate`; all detector commands ran with cwd `T`.
Environment: `PATH=/usr/bin:/bin HOME=$W TMPDIR=$W LC_ALL=C PYTHONDONTWRITEBYTECODE=1`.
- Archive: `mkdir -p $T && git -C /home/vgpnk/Projects/shokunin/kagi-shokunin archive 62a33b1bd15217ed729df2ca40c8a30aba3076c0 | tar -x -C $T` — exit 0.
- **S:** `python3 -I -B corpus/release-clock.py --selftest`.
- **H:** `python3 -I -B $W/c2-probe.py STAGE` — adapter calls the candidate's unchanged `.ufo/waves/round-28/tools/c2-measure.py` through `runpy.run_path(..., run_name="frozen_c2")["measure_clone"](T, fixture_dir, env)`; fixture directories were under W. Its existing GROUPS, fixture construction, classify, and control were unchanged.
- The frozen CLI rearchives REV, which would discard a scratch mutation; H therefore invokes its existing harness function on the actual pristine/mutated/restored tree. No replacement fixture or predicate was introduced. Like the frozen CLI, H exits 0 after reporting results; that exit alone is not a pass.

| Bytes / STAGE | S exit and output | H exit | C2 accepted / exact / control |
|---|---|---|---|
| pristine | 0; `RELEASE_CLOCK_SELFTEST: PASS (106 cases)` | 0 | 0/4; 4/4; clean, exit 0 |
| mutated | 1; full stdout below | 0 | 0/4; 0/4; failed, exit 1 |
| restored | 0; `RELEASE_CLOCK_SELFTEST: PASS (106 cases)` | 0 | 0/4; 4/4; clean, exit 0 |

```text
C2_MEASURE pristine: groups_accepted_clean=0/4 derivation_exact=4/4 control_clean=True default_exit=0
C2_MEASURE mutated: groups_accepted_clean=0/4 derivation_exact=0/4 control_clean=False default_exit=1
C2_MEASURE restored: groups_accepted_clean=0/4 derivation_exact=4/4 control_clean=True default_exit=0
```
Pristine/restored G1–G4 each exited 1, printing `DERIVATION` for exactly G1=S008,S009,S010,S011; G2=S013,S022,S023,S024; G3=S014,S015,S016,S021,S025,S026; G4=S029. Their FAILED counters were respectively `(on_release=30 bound=30 unbound=0 observed=26 fired=3 derived=11)`, the same for G2, then observed=24/derived=9 and observed=29/derived=14.
Pristine/restored control printed `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)`.
Mutated G1–G4 and control each exited 1 and each printed all fifteen `DERIVATION` IDs, in order: S008 S009 S010 S011 S013 S014 S015 S016 S021 S022 S023 S024 S025 S026 S029. All ended `RELEASE_CLOCK: FAILED (on_release=30 bound=30 unbound=0 observed=15 fired=3 derived=0)`; extra-group findings kill EXACT in every group, and the control also kills the mutant.
All six top-level detector commands and all harness child commands had empty stderr; no traceback appeared.

## Mutated selftest stdout (actual)
```text
RELEASE_CLOCK_SELFTEST: FAIL derived anchor counted: errors {('DERIVATION', 'S001')} != set()
RELEASE_CLOCK_SELFTEST: FAIL derived anchor counted: observed=0 != 1
RELEASE_CLOCK_SELFTEST: FAIL derived anchor counted: derived=0 != 1
RELEASE_CLOCK_SELFTEST: FAIL derived anchor counted: passed=False
RELEASE_CLOCK_SELFTEST: FAIL non-numeric anchor keeps inequality: errors {('DERIVATION', 'S001')} != set()
RELEASE_CLOCK_SELFTEST: FAIL non-numeric anchor keeps inequality: observed=0 != 1
RELEASE_CLOCK_SELFTEST: FAIL non-numeric anchor keeps inequality: fired=0 != 1
RELEASE_CLOCK_SELFTEST: FAIL non-numeric anchor keeps inequality: derived=0 != 1
RELEASE_CLOCK_SELFTEST: FAIL non-numeric anchor keeps inequality: passed=False
RELEASE_CLOCK_SELFTEST: FAIL derived anchor rejects suffix sibling: errors set() != {('DERIVATION', 'S001')}
RELEASE_CLOCK_SELFTEST: FAIL derived anchor rejects suffix sibling: observed=1 != 0
RELEASE_CLOCK_SELFTEST: FAIL derived anchor rejects suffix sibling: derived=1 != 0
RELEASE_CLOCK_SELFTEST: FAIL derived anchor rejects suffix sibling: passed=True
RELEASE_CLOCK_SELFTEST: FAIL derived group named exactly: errors {('DERIVATION', 'S001')} != {('DERIVATION', 'S001'), ('DERIVATION', 'S004')}
RELEASE_CLOCK_SELFTEST: FAIL derived group named exactly: observed=1 != 0
RELEASE_CLOCK_SELFTEST: FAIL derived group named exactly: derived=1 != 0
RELEASE_CLOCK_SELFTEST: FAIL derived anchor rejects prerelease sibling: errors set() != {('DERIVATION', 'S001')}
RELEASE_CLOCK_SELFTEST: FAIL derived anchor rejects prerelease sibling: observed=1 != 0
RELEASE_CLOCK_SELFTEST: FAIL derived anchor rejects prerelease sibling: derived=1 != 0
RELEASE_CLOCK_SELFTEST: FAIL derived anchor rejects prerelease sibling: passed=True
RELEASE_CLOCK_SELFTEST: FAIL derived anchor bound to its one feed token: errors {('DERIVATION', 'S001')} != set()
RELEASE_CLOCK_SELFTEST: FAIL derived anchor bound to its one feed token: observed=0 != 1
RELEASE_CLOCK_SELFTEST: FAIL derived anchor bound to its one feed token: derived=0 != 1
RELEASE_CLOCK_SELFTEST: FAIL derived anchor bound to its one feed token: passed=False
RELEASE_CLOCK_SELFTEST: FAIL feed floor lifts non-numeric anchor: errors {('DERIVATION', 'S001'), ('REGRESSED', 'S001')} != {('REGRESSED', 'S001')}
RELEASE_CLOCK_SELFTEST: FAIL observe path accepted an unbound derived anchor
```

## Restoration and limits
- Source SHA-256 pristine/restored: `ebe17f16ab57c3501147803309d1fb1be199f059e602d1af218db797c567cd86`.
- Source SHA-256 mutated: `e01edf9a126d1af20e290185744b0fe23aab2619e047d0fc37c387d210cb35f2`.
- Frozen harness SHA-256 in candidate and lane: `97fe7ebea0395fe06ec2d228c18200a77d6f73ef35218885cd36ddb1796940d4`.
- `cp $T/corpus/release-clock.py $W/release-clock.pristine.py` — exit 0 before mutation. `diff -u --label a/corpus/release-clock.py --label b/corpus/release-clock.py $W/release-clock.pristine.py $T/corpus/release-clock.py` — exit 1, one changed line.
- Reverse surgical edit restored the original line; `cmp $W/release-clock.pristine.py $T/corpus/release-clock.py && sha256sum $T/corpus/release-clock.py $T/.ufo/waves/round-28/tools/c2-measure.py` — exit 0, proving byte-exact source restoration before restored detectors.
- `rm -rf -- /fast/scratch/hyaku/kagi-r28/MutDeriveOwn` — exit 0 after restoration/runs. Archive, helper, fixtures and raw scratch receipts removed; only this inline diff/receipt remains.
- Not checked: separate C1 counting command, original BASE execution, fleet/lane gates, live network or host/private surfaces. No installations, production edits, commits, dispatches, or other runtime invocation.
