# CritAxis — round28 falsify: one freshness claim, two commands, no calibration credit, no inflation

Seat: KagiR28.CritAxis (critic, leaf). Target: pinned candidate `62a33b1bd15217ed729df2ca40c8a30aba3076c0`.
Lane-authored advice only; not non-author closure; no SHONEN mark.

## Verdict: PASS (bounded axis contract), with three fixable record defects

- One freshness claim, two frozen commands: both predicates hold at the candidate when rerun from a clean export (table below).
- No calibration delta is credited: `SCORECARD.md:1122` reads `| calibration | 9 → 9 | No claim (re-booked; see above). …`.
- No score inflation: all six round-28 rows are `9 → 9` (`SCORECARD.md:1121-1126`). The SCORECARD diff only appends, so the top axes table is unchanged. No capability is claimed, and the stagnation nudge is explicitly not claimed (`SCORECARD.md:1114-1116`).
- The booking is consistent with precedent. Fleet `MANIFEST.json` kagi lane_round 27 booked the release-clock C2 as `freshness` and the self-number C1 as `calibration`. Round 28's C1 (token canonicality) and C2 (derived-anchor ↔ feed-row binding) are both release-clock/registry values, so `AXES.md:32` ("two claims on one axis … count as one claim") applies. Freshness is tied-lowest at 9 (`AXES.md:33`).

## Measured (sandbox clone at /fast/scratch/hyaku/kagi-r28/CritAxis/, since deleted; Python 3.14.8, TMPDIR in scratch)

| Command (frozen, `plans/round-28.md:29`, `:59`) | rev | exit | output |
|---|---|---|---|
| `python3 -I -B .ufo/waves/round-28/tools/c1-measure.py 62a33b1… cand c1-cand.json` | candidate | 0 | `mishandled=0/4 typed=4/4 other=0/4 control_exit=0 control_clean=True` |
| same, `3553d49… base` | BASE | 0 | `mishandled=3/4 typed=0/4 other=1/4 control_exit=0 control_clean=True` |
| `python3 -I -B .ufo/waves/round-28/tools/c2-measure.py 62a33b1… cand c2-cand.json` | candidate | 0 | `groups_accepted_clean=0/4 derivation_exact=4/4 control_clean=True default_exit=0` |
| same, `3553d49… base` | BASE | 0 | `groups_accepted_clean=4/4 derivation_exact=0/4 …` |
| `python3 -I -B corpus/release-clock.py --selftest` | candidate | 0 | `RELEASE_CLOCK_SELFTEST: PASS (106 cases)` (matches ledger R25-03) |
| `python3 -I -B corpus/release-clock.py` | candidate | 0 | `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)` |

At the candidate, F1–F4 each exit 1 with the single typed line `NON-CANONICAL S040`. F3 and F4 print no `RELEASE_CLOCK_OBSERVE: wrote` line, so the observer refused. G1–G4 each exit 1 with an exact DERIVATION finding. Tool sha256 values: c1 `fa1706f5…e8fa`, c2 `97fe7ebe…40d4`. The c2 hash equals the one in `build/XC2Measure.md:3`. Retained receipts are in `.ufo/waves/round-28/sandboxes/CritAxis/{c1,c2}-{cand,base}.{json,log}`; c1-cand.json sha256 is `40ebd80f…0360` and c2-cand.json is `49b45164…b95c`.

## Findings (counterexample → evidence → impacted axis → smallest safe correction)

**1. The committed BASE receipt contradicts the SCORECARD's before value (4/4 vs 3/4), and the committed C1 tool is not the one that produced that receipt.** Impact: calibration consistency only. No admission change, because the predicate's k is free and the after value is 0/4.
- Counterexample: `.ufo/waves/round-28/build/XC1Measure-base-c1.json` is committed in the candidate. It records `summary.mishandled = 4`, with F4 `MISHANDLED` and `traceback_in_output: true`. Its stderr shows `ValueError: Exceeds the limit (4300 digits)` at BASE `corpus/release-clock.py:380` (`numeric_version`, called via `:386` `seen = numeric_version(observed)`).
- The committed tool, rerun on the same BASE, gives F4 `OTHER`. The run stops at `RECEIPT-MISMATCH S040` / `RELEASE_CLOCK: FAILED` before that crash path. The old harness verified the post-observe run against the freshly written receipt (F3 there ends `RELEASE_CLOCK: CLEAN … fired=1`). The committed harness verifies against the default receipt.
- So the frozen tool changed after its first BASE measurement. Both outputs carry `format kagi-round28-c1-measure-v1`, and neither records the tool's hash.
- `SCORECARD.md:1121` explains BASE 3/4 as "F4 already caught by the observer". At BASE the observer stores the raw ValueError text as an untyped `failed=1` error (BASE `:822`), and the real crash is masked by the harness's RECEIPT-MISMATCH short-circuit. `corpus/lessons/round-28.md:88` (M28-2) cites the 4/4 file as evidence for a 3-item description.
- This was already raised in BUILD (`build/XC1Patch.md:19,25,97`, "L1 should reconcile") but is not reconciled in any production file.
- Smallest correction (append-only, no tool edit): in the SCORECARD measured-revision appendix and the lesson, state that `XC1Measure-base-c1.json` came from a pre-commit draft harness and is superseded. Record the committed tool's sha256 `fa1706f5…e8fa` beside the BASE 3/4. Reword "already caught by the observer" to "recorded as an untyped observe error; the frozen harness classifies it OTHER".

**2. The round-28 LOG entry carries no re-verification result, which the freshness acceptance criterion requires.** Impact: freshness evidence form. This is fixable; it is not a reject.
- `AXES.md:14`: freshness acceptance is "Each round LOG entry includes a re-verification result".
- Candidate `LOG.md:1530-1547` lists mechanisms and "Selftest 79 → 106". It then defers results: "Measured revision and receipts are recorded in the lesson and SCORECARD after landing" (`:1546-1547`). That sentence explicitly excludes LOG.
- The actual re-verification (feeds S033–S037 re-opened, "NO CHANGE") exists only in `corpus/lessons/round-28.md:44`. Round 27's LOG entry (`LOG.md:1527-1528`) did carry measured results.
- Correction: at landing, append to LOG the measured revision, both frozen-command results and the S033–S037 re-open result.

**3. At the pinned candidate the claim's after value is unrecorded.** `SCORECARD.md:1121` says "→ measured revision below", and `:1128-1129` says "appended … after the measured revision lands". By its own record, the candidate is UNPROVABLE until that append happens. This seat's reruns above supply the after values (C1 0/4 MISHANDLED, 4/4 TYPED; C2 0/4 ACCEPTED, 4/4 EXACT). Correction: the integrator appends these after values with exits and the tool hashes. Do not restate them from BUILD artifacts.

**Tradeoff for the judge, not a defect.** The `SCORECARD.md:1122` evidence cell ("QM27–QM29 learn M28-1..M28-4") describes mistakes→criteria work. Round 21 claimed exactly this kind of work as calibration (`SCORECARD.md:455`). Here it is correctly marked "No claim" at 9 → 9, with no counting command and no before→after. The judge must not count it as a calibration verdict. If the fleet MANIFEST for lane_round 28 records `calibration: improved`, that would be inflation. Fleet round 27 used `improved` for both axes; round 28 should be freshness `improved` and calibration `unchanged`.

**Process note.** Both frozen tools first appear in the candidate commit itself (`git log 3553d49..62a33b1 -- .ufo/waves/round-28/tools/` → only `62a33b1`). Plan corrections `b9a42c0` and `2dfb534` predate it, so QM29's "claims file alone, corrections before the first work commit" holds. However, no commit proves the tools were frozen before the patch. Only finding 1 shows a behavioural change, and that change was in C1's harness.

## Commands run (all exit 0)
- `git show 62a33b1:plans/round-28.md`, `git diff 3553d49 62a33b1 -- SCORECARD.md LOG.md SKILL.md PROVINCE.md corpus/QUALITY.md corpus/claim-ledger.tsv`, `git log … -- tools/`. These are read-only, against the lane repo.
- `git clone --no-hardlinks <lane> /fast/scratch/hyaku/kagi-r28/CritAxis/clone && git checkout 62a33b1`. The four measure runs, the selftest and the default run (table above) all ran in that clone. The clone was deleted afterwards.
- Read-only reads of the fleet `AXES.md:10-83` and `MANIFEST.json` kagi rounds 26–27.

## Not checked
- Separability overlays, the 18-digit bound policy, SOURCES rows S044–S049 content, ledger `verify`/`citations`, and any host row. These are other seats' items.
- Whether the candidate F3/F4 path could hide a downstream traceback behind RECEIPT-MISMATCH. At the candidate, the observer refuses before verify, so this was not exercised.
- No tools were installed or updated.
