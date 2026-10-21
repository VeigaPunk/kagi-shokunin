# MutNoDerived — PASS: mutant KILLED

- **Finding:** removing the derived-anchor binding guard at candidate `62a33b1bd15217ed729df2ca40c8a30aba3076c0`, `corpus/release-clock.py:618-626`, is detected by both the selftest and frozen C2 fixture predicates. Pristine and restored detectors pass; this is not a baseline-failure kill.
- BASE reference: `3553d499577084a6c98d7078906017840bbf7b28`, `corpus/release-clock.py:565-567`, contains the unconditional derived-anchor bypass that this mutant re-exposes. BASE was read, not executed.
- **Concrete counterexample:** frozen G1 lowers S008–S011 anchors and observations from `3.13.3` to `3.13.2`, sets `not-fired`, and mirrors observations into the explicit receipt. Untouched `corpus/SOURCES.md:39` still names S033 release `v3.13.3`; mutant accepts all four mismatched rows CLEAN. Candidate table locations: `corpus/release-clocks.tsv:5-8`.
- Axes: freshness / frozen C2 derived-source binding; no calibration score, production change, integration, or admission judgment.

## Retained mutation diff
```diff
--- a/corpus/release-clock.py
+++ b/corpus/release-clock.py
@@ -618,9 +617,0 @@
-            if (is_derived and not non_canonical and feed_source is not None
-                    and not derived_anchor_bound(feed_source["anchor"], anchored)):
-                # round-28 C2: an author-declared derived anchor holds only while
-                # its feed row's located anchor cell (S033-S037) names exactly
-                # that one stable X.Y.Z. Lowering a whole feed group, a second
-                # version in the cell or a prerelease sibling is a typed
-                # DERIVATION finding, never a silent not-fired clock.
-                errors.add(("DERIVATION", source_id))
-                row_valid = False
```
Only this nine-line block was removed; the same block was pasted back before restoration runs.

## Commands and bounds
Path notation: `L=/home/vgpnk/Projects/shokunin/kagi-shokunin`, `S=/fast/scratch/hyaku/kagi-r28/KagiR28.MutNoDerived`, `C=$S/candidate`; STAGE is individually `pristine`, `mutated`, `restored`.
```sh
mkdir -p "$C" && git -C "$L" archive 62a33b1bd15217ed729df2ca40c8a30aba3076c0 | tar -x -C "$C" # exit 0
cp -p "$L/.ufo/waves/round-28/tools/c2-measure.py" "$S/c2-measure.py" # exit 0
python3 -I -B corpus/release-clock.py --selftest # cwd=$C; exits 0 / 1 / 0
python3 -I -B -c 'import json,os,runpy,sys; from pathlib import Path; h=runpy.run_path(sys.argv[1]); r=h["measure_clone"](Path(sys.argv[2]),Path(sys.argv[3]),dict(os.environ)); print(json.dumps(r,sort_keys=True))' "$S/c2-measure.py" "$C" "$S/STAGE" # cwd=$C; exits 0 / 0 / 0
mkdir -p "$S/base-reference" && git -C "$L" archive 3553d499577084a6c98d7078906017840bbf7b28 corpus/release-clock.py | tar -x -C "$S/base-reference" # exit 0
```
The frozen revision CLI always re-archives a commit, so the unchanged `measure_clone` harness was called directly on the isolated candidate bytes. No fixture, classifier, predicate, or counting tool was edited. Its JSON-producing process exits 0 even when its measurements violate the claim; the measured fixture exits below are distinct.
Detector subprocess bounds: 180 seconds each; frozen harness child bound: 120 seconds each. Environment contained only PATH, scratch HOME/TMPDIR, `LC_ALL=C`, and `PYTHONDONTWRITEBYTECODE=1`; scratch directory setup exited 0.

## Actual receipt
| Bytes | Selftest exit / stdout | Harness exit | G1/G2/G3/G4 exits | ACCEPTED | EXACT | Control exit |
|---|---|---|---|---|---|---|
| Pristine | 0 / `RELEASE_CLOCK_SELFTEST: PASS (106 cases)` | 0 | 1/1/1/1 | 0/4 | 4/4 | 0 |
| Mutated | 1 / FAIL excerpts below | 0 | 0/0/0/0 | 4/4 | 0/4 | 0 |
| Restored | 0 / `RELEASE_CLOCK_SELFTEST: PASS (106 cases)` | 0 | 1/1/1/1 | 0/4 | 4/4 | 0 |
First killing selftest: `derived anchor must name feed anchor`, candidate `corpus/release-clock.py:1176-1180`: derived anchor/observation `1.2.0`, feed anchor `Latest release v1.2.9`, expected `DERIVATION S001`. Actual mutant stdout excerpts:
```text
RELEASE_CLOCK_SELFTEST: FAIL derived anchor must name feed anchor: errors set() != {('DERIVATION', 'S001')}
RELEASE_CLOCK_SELFTEST: FAIL derived anchor must name feed anchor: observed=1 != 0
RELEASE_CLOCK_SELFTEST: FAIL derived anchor must name feed anchor: derived=1 != 0
RELEASE_CLOCK_SELFTEST: FAIL derived anchor must name feed anchor: passed=True
RELEASE_CLOCK_SELFTEST: FAIL observe path accepted an unbound derived anchor
```
Pristine and restored G1 stdout (identical):
```text
DERIVATION S008
DERIVATION S009
DERIVATION S010
DERIVATION S011
RELEASE_CLOCK: FAILED (on_release=30 bound=30 unbound=0 observed=26 fired=3 derived=11)
```
Every mutated G1–G4 and every phase's control stdout was exactly:
```text
RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)
```
Pristine/restored other findings were exactly G2 `{S013,S022,S023,S024}`, G3 `{S014,S015,S016,S021,S025,S026}`, G4 `{S029}`, all category DERIVATION. Their FAILED totals `(observed,fired,derived)` were respectively `(26,3,11)`, `(24,3,9)`, `(29,3,14)`; all had `on_release=30 bound=30 unbound=0`. All detector/fixture stderr was empty; no traceback occurred.

## Restoration and cleanup evidence
SHA-256 of `corpus/release-clock.py` (`sha256sum`, exit 0 at each stage):
- Pristine: `ebe17f16ab57c3501147803309d1fb1be199f059e602d1af218db797c567cd86`
- Mutated: `1e7f6d46cf1892b56e4efb9781a0d17246bf94990ba0934294f663054bd8f86f`
- Restored: `ebe17f16ab57c3501147803309d1fb1be199f059e602d1af218db797c567cd86`
Frozen harness SHA-256: `97fe7ebea0395fe06ec2d228c18200a77d6f73ef35218885cd36ddb1796940d4`; lane original and mutant/restored scratch copy hashes matched (`sha256sum`, exit 0).
`rm -rf -- /fast/scratch/hyaku/kagi-r28/KagiR28.MutNoDerived` exited 0 after restoration runs. Only this embedded diff and receipt are retained; no full archive or probe fixtures remain from this seat.
Not checked: C1 counting fixtures, live feeds, host/vault/account/handler/CDP surfaces, fleet gates, or production admission. No tools installed or updated; no production bytes or Git/jj state were changed.
