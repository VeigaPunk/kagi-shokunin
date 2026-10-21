# MutDeriveGE — bounded mutation receipt

## Finding: FAIL — detector coverage; mutant SURVIVED
- Target: `62a33b1bd15217ed729df2ca40c8a30aba3076c0`, `corpus/release-clock.py:363` (`derived_anchor_bound`).
- Replacing exact numeric anchor equality with `derived >= feed` survives **both** the 106-case clock selftest and the unchanged frozen C2 harness. Pristine and restored detectors pass, so this is not an inconclusive baseline failure.
- No case kills this mutant. The frozen groups only lower anchors (`.ufo/waves/round-28/tools/c2-measure.py:53–58`); the C2 selftest mismatch cases at `corpus/release-clock.py:1176–1215` likewise do not exercise a higher derived anchor against a single lower feed token.
- This is a coverage finding, **not** evidence that the unmodified candidate violates C2. Scope: freshness / C2 (originally headed calibration, rebooked by the frozen plan correction); no round-admission judgment.

## Mutant and expected detector
Only the numeric return in the isolated archive changed; the nonnumeric path and single-distinct-token requirement stayed intact. A detector of exact binding should reject a higher derived anchor, not treat it as bound.

```diff
--- a/corpus/release-clock.py
+++ b/corpus/release-clock.py
@@ -363 +363,3 @@
-    return set(STABLE_TOKEN_RE.findall(feed_anchor or "")) == {norm_version(anchored)}
+    tokens = set(STABLE_TOKEN_RE.findall(feed_anchor or ""))
+    return (len(tokens) == 1
+            and version_order(norm_version(anchored)) >= version_order(next(iter(tokens))))
```

## Commands and receipt
Working scratch `S=/fast/scratch/hyaku/kagi-r28/MutDeriveGE`; archived tree `T=$S/candidate`.
Export command, exit **0** (empty stdout/stderr):
```sh
mkdir -p /fast/scratch/hyaku/kagi-r28/MutDeriveGE/candidate && git -C /home/vgpnk/Projects/shokunin/kagi-shokunin archive 62a33b1bd15217ed729df2ca40c8a30aba3076c0 | tar -x -C /fast/scratch/hyaku/kagi-r28/MutDeriveGE/candidate
```
Actual capture commands from `S`, each exit **0**:
```sh
python3 -I -B probe.py pristine
python3 -I -B probe.py mutated
python3 -I -B probe.py restored
```
Each capture ran `python3 -I -B corpus/release-clock.py --selftest` in `T` (120-second bound), then the **unchanged** pinned C2 module's `measure_clone(T, temp, env)` through `runpy.run_path`. This uses the frozen fixture construction and classifier without changing either. The CLI's archive-from-commit step was bypassed solely to exercise the edited archive rather than silently re-extract pristine bytes. HOME/TMPDIR were inside `S`; no lane code was run in production.

| Phase | Selftest exit/output | C2 accepted | C2 EXACT | Control exit |
|---|---|---|---|---|
| pristine | 0 / `RELEASE_CLOCK_SELFTEST: PASS (106 cases)` | 0/4 | 4/4 | 0 |
| mutated | 0 / `RELEASE_CLOCK_SELFTEST: PASS (106 cases)` | 0/4 | 4/4 | 0 |
| restored | 0 / `RELEASE_CLOCK_SELFTEST: PASS (106 cases)` | 0/4 | 4/4 | 0 |

All three captures emitted `C2_MEASURE <phase>: groups_accepted_clean=0/4 derivation_exact=4/4 control_clean=True default_exit=0` (with the phase label substituted). All child stderr was empty. Identical fixture results in all three phases:

| Fixture | Clock exit | Typed finding lines (one `DERIVATION <id>` each) | Observed / derived |
|---|---|---|---|
| G1 | 1 | S008 S009 S010 S011 | 26 / 11 |
| G2 | 1 | S013 S022 S023 S024 | 26 / 11 |
| G3 | 1 | S014 S015 S016 S021 S025 S026 | 24 / 9 |
| G4 | 1 | S029 | 29 / 14 |

Each fixture ended `RELEASE_CLOCK: FAILED` with `on_release=30 bound=30 unbound=0 fired=3` and the counts above. Each control stdout was exactly:
```text
RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)
```

## Concrete non-equivalence witness
S033's located registry anchor names **3.13.3** (`corpus/SOURCES.md:39`); a forged derived anchor **3.13.4** must not bind. The following additional predicate-level witness ran unchanged in `T` in all three phases, exit **0** each; it is not a replacement/addition to the frozen fixture set:
```sh
python3 -I -B -c "import runpy; from pathlib import Path; n=runpy.run_path('corpus/release-clock.py'); a=n['parse_sources'](Path('.'))['S033']['anchor']; print('WITNESS feed=S033/3.13.3 derived=3.13.4 bound=%s' % n['derived_anchor_bound'](a,'3.13.4'))"
```
Actual stdout: `WITNESS feed=S033/3.13.3 derived=3.13.4 bound=False` pristine/restored; the same line with `bound=True` mutated. This proves the surviving mutant changes the assigned behavior; no end-to-end higher-anchor CLI outcome is asserted.

## Restoration and limits
SHA-256 of `corpus/release-clock.py`:
- Before: `ebe17f16ab57c3501147803309d1fb1be199f059e602d1af218db797c567cd86`
- Mutated: `272c70b4ec51334c33ef46388a5a405c71e54f65767e8952c6a81b81db3a6db3`
- Restored: `ebe17f16ab57c3501147803309d1fb1be199f059e602d1af218db797c567cd86` — exact original bytes, followed by the restored detector run.
Frozen C2 tool hash in all phases: `97fe7ebea0395fe06ec2d228c18200a77d6f73ef35218885cd36ddb1796940d4`.
`sha256sum corpus/release-clock.py .ufo/waves/round-28/tools/c2-measure.py` initially exited **0** and matched these pristine hashes.
`rm -rf -- /fast/scratch/hyaku/kagi-r28/MutDeriveGE` exited **0**, empty output, after restoration. Only this embedded diff and receipt are retained; no full archive or throwaway runner remains.
Not checked: original BASE execution/comparison, C1 counting harness, higher-anchor end-to-end CLI fixture, host rows, network/vendor/vault state, or fleet gates. No installs, production edits, commits, subagents, or other runtime invocation.
