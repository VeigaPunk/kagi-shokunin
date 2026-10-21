# MutDeriveWhole — bounded mutate/run/revert receipt

**PASS — mutant KILLED by the frozen C2 harness; selftest SURVIVED.** This is mutation-sensitivity advice, not round admission. Axes examined: freshness/calibration.

## Findings and concrete counterexample
- Pinned candidate: `62a33b1bd15217ed729df2ca40c8a30aba3076c0`. Mutation point: `corpus/release-clock.py:619`; scan all parsed feed-row values instead of only its anchor cell. Production remained read-only.
- The frozen C2 control kills it: pristine/restored exit 0 CLEAN30; mutant exit 1 with false `DERIVATION` findings for S013, S022, S023, S024, S029. All four frozen G fixtures also lose EXACT because unrelated rows are reported.
- Concrete unchanged input: `corpus/release-clocks.tsv:26` has derived S029 → S037, anchor=observation=`8.23.0`, verdict=`not-fired`. `corpus/SOURCES.md:43` locates official `8.23.0` in its anchor but discusses unreleased `8.23.1` in teaches. Whole-row scanning therefore finds two versions and wrongly rejects S029. Vault's teaches cell (`SOURCES.md:40`) similarly contributes `sdk/v0.26.0` beside official `2.2.0`.
- Coverage finding: `--selftest` passes all 106 cases on mutant bytes. Its shared feed fixture's teaches text is only `Release Atom feed.` (`corpus/release-clock.py:1079-1081`); the frozen corpus/control supplies the distinguishing competing-version case. No contract was changed.

## Retained one-line diff (scratch only)
```diff
--- a/corpus/release-clock.py
+++ b/corpus/release-clock.py
@@ -619 +619 @@
-                    and not derived_anchor_bound(feed_source["anchor"], anchored)):
+                    and not derived_anchor_bound(" ".join(map(str, feed_source.values())), anchored)):
```

## Actual detector receipt
The same two bounded detectors ran on pristine, mutant and byte-restored code. No detector stderr or traceback occurred.

| Phase | Selftest exit / actual stdout | C2 harness exit | Accepted / EXACT | Control exit / state |
|---|---|---:|---|---|
| pristine | 0 / `RELEASE_CLOCK_SELFTEST: PASS (106 cases)` | 0 | 0/4 / 4/4 | 0 / CLEAN |
| mutant | 0 / `RELEASE_CLOCK_SELFTEST: PASS (106 cases)` | 0 | 0/4 / 0/4 | 1 / FAILED |
| restored | 0 / `RELEASE_CLOCK_SELFTEST: PASS (106 cases)` | 0 | 0/4 / 4/4 | 0 / CLEAN |

Frozen C2 summaries (actual stdout):
```text
C2_MEASURE pristine: groups_accepted_clean=0/4 derivation_exact=4/4 control_clean=True default_exit=0
C2_MEASURE mutant: groups_accepted_clean=0/4 derivation_exact=0/4 control_clean=False default_exit=1
C2_MEASURE restored: groups_accepted_clean=0/4 derivation_exact=4/4 control_clean=True default_exit=0
```
Every G1..G4 subprocess exited 1 in all phases. Mutant G1/G3 additionally named S013/S022/S023/S024/S029; G2 additionally named S029; G4 additionally named S013/S022/S023/S024. Thus all fail the unchanged exact-ID predicate.
Mutant control stdout:
```text
DERIVATION S013
DERIVATION S022
DERIVATION S023
DERIVATION S024
DERIVATION S029
RELEASE_CLOCK: FAILED (on_release=30 bound=30 unbound=0 observed=25 fired=3 derived=10)
```
Pristine/restored control stdout: `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)`.

## Commands and unchanged harness
Definitions: `S=/fast/scratch/hyaku/kagi-r28/MutDeriveWhole`; `R=$S/candidate`; `T=$S/tmp`; `LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin`; `REV=62a33b1bd15217ed729df2ca40c8a30aba3076c0`.
- Export: `mkdir -p "$R" && git -C "$LANE" archive "$REV" | tar -x -C "$R"` → exit 0. `mkdir -p "$T" "$S/home"` → exit 0. Archive size: `du -sh "$R"` → 109M, exit 0; `python3 --version` → Python 3.14.8, exit 0.
- For each phase, cwd=`$R`; environment: HOME=`$S/home`, TMPDIR=`$T`, LC_ALL=C, PYTHONDONTWRITEBYTECODE=1, PATH inherited only. Actual argv: `python3 -I -B corpus/release-clock.py --selftest` and `python3 -I -B -c <C2-source-below> "$R" "$T" <phase>`; exits recorded above.
- The revision CLI would re-export pristine bytes, so the unchanged frozen tool's `measure_clone` API was used for all three phases. G1..G4 construction, receipt mirroring, classification and control were not edited. Harness exit 0 means measurement completed, not that its measured predicates passed.

Literal C2 `-c` source:
```python
import importlib.util, json, os, sys, tempfile
from pathlib import Path
root, scratch, label = Path(sys.argv[1]), Path(sys.argv[2]), sys.argv[3]
spec = importlib.util.spec_from_file_location("frozen_c2", root / ".ufo/waves/round-28/tools/c2-measure.py")
m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
with tempfile.TemporaryDirectory(prefix="c2-" + label + "-", dir=scratch) as temp:
    results = m.measure_clone(root, Path(temp), dict(os.environ))
names = sorted(m.GROUPS)
print("C2_MEASURE %s: groups_accepted_clean=%d/%d derivation_exact=%d/%d control_clean=%s default_exit=%d" % (label, sum(results[n]["accepted_clean"] for n in names), len(names), sum(results[n]["derivation_exact"] for n in names), len(names), results["control"]["control_clean"], results["control"]["exit"]))
for name in names + ["control"]:
    item = results[name]
    print("CASE %s exit=%s accepted_clean=%s derivation_exact=%s" % (name, item["exit"], item.get("accepted_clean"), item.get("derivation_exact")))
    print(item["stdout"], end="")
    print(item.get("stderr", ""), end="")
print("RESULT_JSON=" + json.dumps(results, sort_keys=True))
```

## Restoration and cleanup
`sha256sum` commands all exited 0. Code SHA-256 before → mutant → restored:
- before: `ebe17f16ab57c3501147803309d1fb1be199f059e602d1af218db797c567cd86`
- mutant: `1df3844c30ddb74f4ab4eaa9009cc1e14f101b6eab7e23f744e1b7fdf18aa7bc`
- restored: `ebe17f16ab57c3501147803309d1fb1be199f059e602d1af218db797c567cd86`
`git -C "$LANE" show "$REV":corpus/release-clock.py | sha256sum` → exit 0, same before/restored hash. Frozen C2 tool hash (candidate and lane): `97fe7ebea0395fe06ec2d228c18200a77d6f73ef35218885cd36ddb1796940d4`.
`rm -rf -- "$S" && test ! -e "$S" && printf 'SCRATCH_REMOVED /fast/scratch/hyaku/kagi-r28/MutDeriveWhole\n'` → exit 0, printed that removal receipt. Only this report, containing the diff and receipt, is retained.
Not checked: frozen C1 measurement, live feeds, host rows, fleet gates or any other mutation. No tools installed/updated; no production/index changes, external contacts, subagents or other runtime invoked.
