# CheckEvidence — candidate evidence scope (dead seats, receipts, clone-bloat-as-proof)

Seat `KagiR28.CheckEvidence` (reviewer); pinned candidate `62a33b1bd15217ed729df2ca40c8a30aba3076c0`. Scratch `/fast/scratch/hyaku/kagi-r28/CheckEvidence/` (4 receipt JSONs kept, exported tree deleted). No installs; no host-private ledger row executed.

## Verdict: **FAIL** on evidence scope — F1 (committed receipt contradicts SCORECARD) and F2 (unreported 7-seat gap). The claim arithmetic itself is sound (PASS items below).

### F1 — SCORECARD says BASE "MISHANDLED 3/4"; the candidate's own committed receipt says 4/4.
- `SCORECARD.md:1121`: "non-canonical fixtures MISHANDLED at BASE **3/4** (F1 fired lie, F2 traceback, F3 written fired receipt; F4 already caught by the observer)".
- `.ufo/waves/round-28/build/XC1Measure-base-c1.json` (committed): `"summary":{"mishandled":4,"typed":0,"other":0,"fixtures":4}`; F4 = `MISHANDLED`, `exit 1`, `traceback_in_output:true`; `build/XC1Measure.md:12` (committed): `mishandled=4/4 typed=0/4 other=0/4`.

Two committed files contradict each other **inside the pinned tree**. The 3/4 figure exists only in *untracked* artifacts: `build/XC1Measure-base-c1-rerun.json` and the *uncommitted* rewrite of `build/XC1Measure.md` (`git status`: ` M`). No in-tree sentence says the tool changed. Cause, recorded only outside the candidate: the working-tree `XC1Measure.md` says the pre-integration tool (sandbox sha `c78029c5…`) produced `XC1Measure-base-c1.json`; the **integrated** tool is the committed one (`tools/c1-measure.py` sha `fa1706f5…` == `final/instrument-pins.json` `tools.c1`), so the committed receipt is **stale relative to the committed tool**.

**Counterexample:** `git show 62a33b1:.ufo/waves/round-28/build/XC1Measure-base-c1.json` → `mishandled:4`; re-running the candidate's own committed `tools/c1-measure.py` at BASE → `mishandled=3`. Same tree, same frozen command, two numbers, no in-tree reconciliation; my rerun confirms 3/4, so the committed JSON is the outlier. Severity: `plans/round-28.md:48` requires "MISHANDLED k/4 → 0/4" with k fixed by the frozen tool and 3/4 and 4/4 both satisfy the *predicate* — so this is a receipt-integrity defect, **not** a claim-arithmetic defect.

### F2 — 73 seats dispatched, 66 reports committed, 7 unreported, gap never stated.
Dispatched 73 (`build-task-result.txt` 73 `KagiR28.*-7` ids; `build-spec.json` 73 items; `build-assignments.json` 73); committed reports `git ls-tree 62a33b1 .ufo/waves/round-28/build/` → **66** `.md`. Seven dispatched seats have **no** `build/<Name>.md` at candidate: `XSeparability`, `RevC2Exactness`, `RevObserveC2`, `RevLessonR27`, `RevScorecardShape`, `CritNoHarm`, `ScribeKnowledgeClock`. `RevObserveC2.md`/`XSeparability.md` exist only as **untracked** working-tree files (mtime 14:45/14:49, after the 14:44 candidate commit); the other five have no report in-tree or out. `LOG.md:1545` reports only "BUILD wave 73 seats (validated, one taskCall; job cap refused 6 times, dispatched on try 7)" — dispatch count only, no returned-report count, no missing seat named. Lane precedent requires the split: `LOG.md:1391` "64 seats (52 reports; 12 provider deaths, no replacements)", `LOG.md:1090` "four scribe seats died … remain uncredited, never respawned", `LOG.md:1486` "total72 seats/49 reports, 23 build provider deaths retained".

**Counterexample:** a candidate-tree reader sees "73 seats" and 66 reports with no reconciling sentence, and five seats are silently absent — including `CritNoHarm` (the no-axis-harm critic, bearing on the 9→9 row) and `RevC2Exactness` (C2 exactness). Honest form: "73 dispatched, 66 reports, 7 without reports (list)".

### F3 — Clone bloat is NOT used as proof: PASS (caveat flagged, not FAIL).
No claim rests on a clone. Capture bodies are digest-exact — `captures/S04[4-9].body` sha256 == `captures/metadata.json` == `corpus/source-fetches.tsv` (S044 `7dcb450d…`, S045 `f9d4b8b1…`, S046 `15ae2918…`, S047 `bb94459d…`, S048 `d3a6953d…`, S049 `783c37dc…`) — and every registered quote is present in-body after `rendered-text-v1` normalisation. The 33 GB under untracked `.ufo/waves/round-28/sandboxes/` is scratch, cited by nobody. Caveat (flagged, not adjudicated): 65 sandbox/retained-probe paths cited by committed build reports (e.g. `build/MutBaseNumeric.md` → `../sandboxes/MutBaseNumeric-7/results.json`) are **absent from the candidate tree**; payloads survive only in untracked `retained-probes/` (68 MB) and `sandboxes/` (33 GB) → retention gap for `CritFrozenCommands`/`CheckLedger`.

### PASS items (verified)
- **C1 frozen command** BASE→candidate: `mishandled=3/4 typed=0/4 other=1/4`, control exit 0 `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)` → candidate `mishandled=0/4 typed=4/4 other=0/4`, control exit 0, same CLEAN30. Exit 0 both.
- **C2 frozen command** BASE→candidate: `groups_accepted_clean=4/4 derivation_exact=0/4 control_clean=True` → `groups_accepted_clean=0/4 derivation_exact=4/4 control_clean=True`; G1–G4 each `accepted_clean=False, derivation_exact=True, exit 1`. Exit 0 both.
- **Candidate tree**: `--selftest` → `RELEASE_CLOCK_SELFTEST: PASS (106 cases)` exit 0 (pin R25-03=106; SCORECARD:1125 "79 → 106"); default → CLEAN30 exit 0 (R25-04). Pins: `stamps.tsv` 91 non-blank (R12-03/R24-05=91); `grep -c '^## Round ' SCORECARD.md`=34 (R13-01/R24-06=34); `grep -cE '^R[0-9]+-[0-9]+' corpus/claim-ledger.tsv`=65 (R21-04=65). `final/conformance28.txt` → C1/C2/C3 OK, `VERDICT PASS`, exit 0. Tool pins: `instrument-pins.json` c1 `fa1706f5…` == candidate `tools/c1-measure.py`, c2 `97fe7eb…` == candidate `tools/c2-measure.py`; `tools/separability.py` is **not** pinned and has uncommitted edits (candidate sha `4926363d…` vs working tree `4bad101f…`) → `CritFrozenC1`.

### Commands run (exit codes)
Read-only git only (`show`/`ls-tree`/`log`/`cat-file`), all exit 0; no mutating git/jj in the lane; no lane gate/selftest run inside the lane checkout (the two clock tools copy the tree to a private temp dir and delete it); all output written to my scratch.
```
c1-measure.py 3553d49… CE-BASE → exit 0 (mishandled=3/4 typed=0/4 other=1/4 control_exit=0)
c1-measure.py 62a33b1… CE-CAND → exit 0 (mishandled=0/4 typed=4/4 other=0/4 control_exit=0)
c2-measure.py 3553d49… CE-BASE → exit 0 (accepted_clean=4/4 exact=0/4);  c2 … 62a33b1… → exit 0 (0/4, 4/4)
release-clock.py --selftest (exported candidate tree) → exit 0, PASS (106 cases); default → exit 0, CLEAN30
sha256sum captures/S04[4-9].body → all match metadata.json + source-fetches.tsv
git ls-tree -r 62a33b1 → 66 build/*.md vs 73 dispatched seats
```
### NOT checked / residual risk
- Host-private ledger rows **not** executed; `corpus/claim-ledger.tsv` read as data only. `claim-ledger.sh`, `op-ref-probe.sh`, `sources-census.sh` not run — expected outputs (65 rows / 91 stamps / 34 headings / registry 49) verified by underlying greps only, so the rows' own regexes are unverified. Uncommitted edits to `build/XC1Measure.md`, `build/RevC1Fixtures.md`, `tools/separability.py` and untracked `final/`, `retained-probes/`, `sandboxes/` were read-only and are not the candidate; I did not verify whether the L1's repair commit `5e847472` closes F1/F2.
- Not adjudicated (other seats): plan-literal F1–F4 fixture text, the 18-digit bound, feed-floor /observe semantics, the 15 derived-row bindings row-by-row, the 24-revision history replay, QM27–QM29 wording. `XSeparability-base-empty.diff` is 0 bytes, `XSeparability-base-manifest.json` is `{"c1":[],"c2":[]}` (base==candidate blob).
- No network fetches, no vault/account/handler/CDP contact, no SHONEN marks, no writes outside `.ufo/waves/round-28/falsify/` and my own scratch.
