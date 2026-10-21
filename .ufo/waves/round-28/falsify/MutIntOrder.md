# MutIntOrder — PASS: assigned mutant killed; frozen C1 harness survivor

## Findings
- **Killed by the existing selftest**, not by the frozen C1 counting harness. Candidate `corpus/release-clock.py:428-430` prevents the legacy integer conversion at BASE `corpus/release-clock.py:378-380`. Restoring that legacy behavior makes malformed anchors reach `int()` through candidate `evaluate:573` → `feed_floors:454`, before row-level `NON-CANONICAL` handling at `:627-632`.
- **Counting-coverage finding:** unchanged F1–F4 remain TYPED 4/4 on this defective mutant. These fixtures change observations/feed entries, not anchors; they do not kill this anchor-ordering regression. This does not redefine their frozen scope or establish a pristine-candidate defect.
- Axes: freshness/C1 exercised; calibration/C2 not evaluated. Advisory mutation receipt only, not round closure.

## Pin, mutation, and concrete counterexample
Candidate: `62a33b1bd15217ed729df2ca40c8a30aba3076c0`; legacy reference: `3553d499577084a6c98d7078906017840bbf7b28`.
One mutation: restore the BASE `numeric_version()` behavior (numeric syntax guard plus integer-tuple return), without changing any other candidate bytes or frozen fixtures.
```diff
@@ -428,3 +428,3 @@
-    if not NUMERIC_VERSION_RE.fullmatch(value) or non_canonical_version(value):
+    if not NUMERIC_VERSION_RE.fullmatch(value):
         return None
-    return version_order(value)
+    return tuple(int(part) for part in value.split("."))
```
A1: isolated copy of the candidate corpus inputs; only S040's `anchored_version` becomes `"3.15." + "1" * 4301`. Its observation, registry, and pinned receipt remain unchanged. A1 is the requested malformed-anchor attack, **not an added frozen counting fixture**.
Expected detector: selftest rejects the mutant; A1 must exit 1 with `NON-CANONICAL S040`, never a traceback. Environment: CPython 3.14.8, `sys.get_int_max_str_digits() == 4300`.

## Commands and receipt
Notation: `L=/home/vgpnk/Projects/shokunin/kagi-shokunin`, `S=/fast/scratch/hyaku/kagi-r28/MutIntOrder`, `C=$S/candidate`, `R=62a33b1bd15217ed729df2ca40c8a30aba3076c0`; `$p` is respectively `pristine`, `mutant`, `restored`.
- `mkdir -p "$C" && git -C "$L" archive "$R" | tar -x -C "$C"` → 0.
- Copied frozen `c1-measure.py` and preserved pristine clock bytes in `$S` → 0.
- `python3 -I -B "$S/probe.py" "$p"` → **0 / 1 / 0**. Identical detector and fixtures across all three phases; detector never edits candidate bytes.
- Its selftest command: `python3 -I -B "$C/corpus/release-clock.py" --selftest` → **0 / 1 / 0**.
- Its counting command: `python3 -I -B "$S/count.py" "$R" "$p" "$S/$p/c1.json"` → **0 / 0 / 0**.
- `count.py` imported the byte-identical frozen `c1-measure.py` and called its `main()`. Only its `git archive` subprocess boundary was substituted with a tar of `$C`, so the mutation was not discarded by re-exporting the pinned revision. Frozen fixture builders, child invocations, predicates, and counts were untouched. This is a scratch-tree harness run, not a claim that the literal revision-export command measured a mutant.
- A1 command: `python3 -I -B "$C/corpus/release-clock.py" --root "$S/$p/fixture-A1-anchor" --receipt "$C/.ufo/waves/round-26/observe-2.json" --receipt-sha 13b8540c78b9de07bc184894583a368472fd1f2f04a898220bf7c29d2648a169` → **1 / 1 / 1**, but only mutant prints a traceback.

| Detector output | Pristine | Mutant | Restored |
|---|---|---|---|
| Clock selftest | PASS (106 cases) | FAIL, three lines below | PASS (106 cases) |
| C1 mishandled / typed / other | 0/4 / 4/4 / 0/4 | 0/4 / 4/4 / 0/4 | 0/4 / 4/4 / 0/4 |
| Each F1, F2, F3, F4 | exit 1, TYPED | exit 1, TYPED | exit 1, TYPED |
| Default control | exit 0, CLEAN | exit 0, CLEAN | exit 0, CLEAN |
| A1 | typed, no traceback | untyped ValueError traceback | typed, no traceback |

Actual mutant selftest stdout (stderr empty):
```text
RELEASE_CLOCK_SELFTEST: FAIL oversize anchor refused: raised Exceeds the limit (4300 digits) for integer string conversion: value has 4301 digits; use sys.set_int_max_str_digits() to increase the limit
RELEASE_CLOCK_SELFTEST: FAIL non-canonical anchor is no feed floor: errors {('REGRESSED', 'S001'), ('NON-CANONICAL', 'S004')} != {('NON-CANONICAL', 'S004')}
RELEASE_CLOCK_SELFTEST: FAIL non-canonical anchor is no feed floor: observed=0 != 1
```
Actual mutant counting output:
```text
C1_MEASURE mutant: mishandled=0/4 typed=4/4 other=0/4 control_exit=0 control_clean=True
```
A1 pristine/restored stdout (stderr empty):
```text
NON-CANONICAL S040
RELEASE_CLOCK: FAILED (on_release=30 bound=30 unbound=0 observed=29 fired=3 derived=15)
```
A1 mutant stdout was empty; stderr began `Traceback (most recent call last):`, traversed the candidate lines named above, and ended:
```text
ValueError: Exceeds the limit (4300 digits) for integer string conversion: value has 4301 digits; use sys.set_int_max_str_digits() to increase the limit
```
Default-control stdout in all phases: `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)`.

## Restoration and retention
- Clock SHA-256 before: `ebe17f16ab57c3501147803309d1fb1be199f059e602d1af218db797c567cd86`.
- Clock SHA-256 mutant: `51ca3a61fea4ee040095741d3fe7f5c4da802f741913f57adf84bb052cbd2abf`.
- Clock SHA-256 restored: `ebe17f16ab57c3501147803309d1fb1be199f059e602d1af218db797c567cd86`.
- Frozen harness SHA-256, copied and original: `fa1706f5f39166b4ef3cdf4449aabdb5db4cd52f39a0b8c60a19227e0ab1e8fa`.
- `diff -u "$S/pristine-clock.py" "$C/corpus/release-clock.py"` before restoration → 1 (only the two changed lines above). Restored through the inverse edit; `cmp "$S/pristine-clock.py" "$C/corpus/release-clock.py"` → 0; restored detector → 0.
- Read-only BASE-file archive for legacy-line attribution → 0; no BASE code executed.
- `rm -rf -- "$S" && test ! -e "$S"` → 0. Full archive, helper scripts, and transient receipts deleted; only this embedded diff and receipt retained. No production code, index, or frozen tool changed; no tools installed.
- Not checked: C2 counting harness, lane/fleet gates, live feeds, host-private state, accounts/vaults/handlers/CDP, or any other mutation. No broader acceptance or shipping judgment.
