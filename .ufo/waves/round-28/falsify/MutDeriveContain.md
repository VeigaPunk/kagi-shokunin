# MutDeriveContain — PASS: mutant killed; frozen C2 counter survives

- Candidate `62a33b1bd15217ed729df2ca40c8a30aba3076c0`, `corpus/release-clock.py:363`: replacing exact stable-token set equality with `version_is_named` is **KILLED** by `--selftest` (exit 1, pristine/restored exit 0).
- Coverage finding: frozen C2 G1–G4 do **not** distinguish this mutant: all three phases report ACCEPTED 0/4, EXACT 4/4, control CLEAN. This is a counting-detector survivor, not a candidate failure or permission to change fixtures.
- Axes: freshness; calibration-named C2 binding. Advisory probe only, not round admission.

## Mutant and concrete counterexamples

```diff
--- a/corpus/release-clock.py
+++ b/corpus/release-clock.py
@@ -362,3 +362,3 @@
         return version_is_named(feed_anchor or "", anchored)
-    return set(STABLE_TOKEN_RE.findall(feed_anchor or "")) == {norm_version(anchored)}
+    return version_is_named(feed_anchor or "", anchored)
```

Expected detector: existing selftest must retain typed `DERIVATION S001`, observed=0, derived=0, passed=False.
Candidate cases at `corpus/release-clock.py:1206–1215` kill this exact mutant:
- `derived anchor rejects prerelease sibling`: anchored/observed `1.2.3`, `derived:` note; feed anchor `Entry titled v1.2.3-rc1, tag link /releases/tag/v1.2.3-rc1`.
- `derived anchor needs one version in cell`: anchored/observed `1.2.0`, `derived:` note; feed anchor `Entry titled v1.2.9; prior stable v1.2.0`.
Both mutant cases instead have no errors, observed=1, derived=1, passed=True.

## Actual commands and outputs

Archive command (exit 0):
```sh
mkdir -p /fast/scratch/hyaku/kagi-r28/KagiR28.MutDeriveContain/candidate && git -C /home/vgpnk/Projects/shokunin/kagi-shokunin archive 62a33b1bd15217ed729df2ca40c8a30aba3076c0 | tar -x -C /fast/scratch/hyaku/kagi-r28/KagiR28.MutDeriveContain/candidate
```
Detector cwd was `$C`; variables below abbreviate the actual absolute argv paths:
```sh
L=/home/vgpnk/Projects/shokunin/kagi-shokunin
W=/fast/scratch/hyaku/kagi-r28/KagiR28.MutDeriveContain
C=$W/candidate
H=$L/.ufo/waves/round-28/tools/c2-measure.py
python3 -I -B corpus/release-clock.py --selftest
python3 -I -B -c 'import json,os,runpy,sys; from pathlib import Path; h=runpy.run_path(sys.argv[1]); r=h["measure_clone"](Path(sys.argv[2]),Path(sys.argv[3]),dict(os.environ)); print(json.dumps(r,sort_keys=True))' "$H" "$C" "$W/$phase-measure"
```
For each phase (`pristine`, `mutated`, `restored`), its empty measurement directory was created first. Both subprocesses had 120-second bounds; HOME=`$W`, TMPDIR=`$W/tmp`, LC_ALL=C, PYTHONDONTWRITEBYTECODE=1, inherited PATH only. No network/host gate was invoked.
The unmodified frozen harness's `measure_clone` was called directly because its CLI always re-archives a commit and would discard the scratch mutation. G1–G4, receipt mirroring, predicates, and control were unchanged.

| Phase | Selftest exit / stdout | C2 harness exit | ACCEPTED / EXACT | Control exit |
|---|---|---|---|---|
| pristine | 0 / `RELEASE_CLOCK_SELFTEST: PASS (106 cases)` | 0 | 0/4 / 4/4 | 0 |
| mutated | 1 / eight FAIL lines below | 0 | 0/4 / 4/4 | 0 |
| restored | 0 / `RELEASE_CLOCK_SELFTEST: PASS (106 cases)` | 0 | 0/4 / 4/4 | 0 |

Mutant stdout, verbatim:
```text
RELEASE_CLOCK_SELFTEST: FAIL derived anchor rejects prerelease sibling: errors set() != {('DERIVATION', 'S001')}
RELEASE_CLOCK_SELFTEST: FAIL derived anchor rejects prerelease sibling: observed=1 != 0
RELEASE_CLOCK_SELFTEST: FAIL derived anchor rejects prerelease sibling: derived=1 != 0
RELEASE_CLOCK_SELFTEST: FAIL derived anchor rejects prerelease sibling: passed=True
RELEASE_CLOCK_SELFTEST: FAIL derived anchor needs one version in cell: errors set() != {('DERIVATION', 'S001')}
RELEASE_CLOCK_SELFTEST: FAIL derived anchor needs one version in cell: observed=1 != 0
RELEASE_CLOCK_SELFTEST: FAIL derived anchor needs one version in cell: derived=1 != 0
RELEASE_CLOCK_SELFTEST: FAIL derived anchor needs one version in cell: passed=True
```
C2 JSON stdout records were identical in behavior across phases (only temporary argv paths differed):
- G1 exit 1: `DERIVATION S008`, S009, S010, S011; `RELEASE_CLOCK: FAILED (on_release=30 bound=30 unbound=0 observed=26 fired=3 derived=11)`.
- G2 exit 1: `DERIVATION S013`, S022, S023, S024; same FAILED counts as G1.
- G3 exit 1: `DERIVATION S014`, S015, S016, S021, S025, S026; `RELEASE_CLOCK: FAILED (on_release=30 bound=30 unbound=0 observed=24 fired=3 derived=9)`.
- G4 exit 1: `DERIVATION S029`; `RELEASE_CLOCK: FAILED (on_release=30 bound=30 unbound=0 observed=29 fired=3 derived=14)`.
- Control exit 0: `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)`.
All subprocess and fixture stderr was empty; no traceback.

## Restoration evidence and bounds

SHA-256 of `corpus/release-clock.py`:
- Pristine: `ebe17f16ab57c3501147803309d1fb1be199f059e602d1af218db797c567cd86`.
- Mutant: `8bbc1039f2c1d2ac7cd142dc43f9e932823a5b3ebc624a4c5a15bd9c473f1629`.
- Restored: `ebe17f16ab57c3501147803309d1fb1be199f059e602d1af218db797c567cd86`; exact byte comparison with saved pristine bytes returned True after restored runs.
Frozen harness SHA-256 stayed `97fe7ebea0395fe06ec2d228c18200a77d6f73ef35218885cd36ddb1796940d4`.
Cleanup command `rm -rf -- /fast/scratch/hyaku/kagi-r28/KagiR28.MutDeriveContain && test ! -e /fast/scratch/hyaku/kagi-r28/KagiR28.MutDeriveContain` exited 0. Only this report retains the diff and receipt; no full archive remains.
Not checked: C1 counting, other mutants, BASE behavior, fleet gates/builds, live feeds, host/vault/account state. No tools installed; no production source, frozen plan, fixtures, Git index, or jj state edited.
