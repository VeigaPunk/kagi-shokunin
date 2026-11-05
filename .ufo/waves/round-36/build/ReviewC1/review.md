# ReviewC1 — adversarial review of round-36 C1 (calibration)
Seat: ReviewC1 (leaf reviewer). Lane: kagi-shokunin. Scope: attack C1 only; C2 read only where it bears on separability. No lane file edited; all fixtures under `/fast/scratch/hyaku/kagi-r36/ReviewC1/`. Raw battery outputs are copied to `raw/`; fixture diffs to `fixtures/`; patches to `patches/`; digests in `SHA256SUMS`.

## Verdict: REJECT (C1 as frozen does not establish calibration)

The frozen population (SD5 + `stale`) is a proxy. Two self-authored edits that touch no calibration content drive the counter from 4 to 0 on a tree whose SCORECARD still asserts the stale count. Separately, the candidate's *content* (naming the three reds; correcting 59 → 70) is genuine and does move the counter to 0 for the right reason. The admission problem is the instrument, not the candidate's facts. Under the plan's rule that population and kill rules are not rebooked after data, the honest verdict on the frozen claim is REJECT. Conditions for any re-claim are in §5.

**Counter readings (exit codes all 0 unless stated):**

| tree | construction | C1 (SD5 + stale) | C2 |
|---|---|---|---|
| BASE `09f27e2` (plan commit, git archive) | no fix | **4** (SD5=3, stale=1) | **15** |
| `cb8cb65` (instrument commit, git archive) | no fix | 4 | 15 |
| candidate | BASE + F1 (6-axis pre/post) + F2 + F3 + F4 (see caveat) | **0** | **0** |
| f12 | BASE + F1 + F2, no F3/F4 | 0 | 15 |
| f34 | BASE + F3 + F4, no F1/F2 | 4 | 0 |
| shortcutA | delete red ids from `lane-status:` only | 1 (SD5=0, stale=1) | 15 |
| shortcutB | delete armed `SA-CAP-CENSUS-SELFTEST` row only | 3 | 15 |
| shortcutC | delete the SCORECARD capability row only (row unlocated) | 3 | 15 |
| **shortcutAB** | **A + B together, nothing else** | **0** | 15 |
| forge71 | BASE + F1 (six-axis red naming, same as candidate) + capability row `70`→`71`, nothing else | 1 (SD5=0, stale=1: the forgery is caught, the red naming is not) | 15 |
| forgeEarly | reds planted only in round-34 calibration row | 4 | 15 |
| **t5** | candidate, `lane-status` drops `R25-02` (2 reds listed) | **0** | 0 |
| **t6** | candidate, calibration row states `R25-02 (PASS)` | **0** | 0 |
| **t7** | candidate, `PV-FEEDTOKEN-SELFTEST` claims `9 cases` (live 4) | **0** | 0 |
| setup-c1 | `corpus/self-description-sweep.sh` removed | rc=2 `C1 SETUP: sweep verdict missing` | — |
| setup-c2 | receipt removed | — | rc=2 `C2 SETUP: receipt missing` |

Lane controls in `.ufo/waves/round-36/controls/` reproduce: `nowork-c1 4`, `forge-stale-c1 4` (its tree still carries SD5=3, so the total is the BASE 4 — stale=1 is the forgery signal, not the total), `forge-sd5-early-c1 4`, `c1-before 4`, `c2-before 15`, `forge-c2-version 16`, `forge-c2-empty 20`. My runs agree with the lane controls.

**Caveat on "candidate".** Only F3 and F4 exist as bytes in the lane working tree (`git diff HEAD` of `corpus/release-clock.py` and `corpus/release-clocks.tsv`; patches in `patches/`). F1 and F2 are not in the lane; I wrote F1/F2 text myself from the frozen plan wording (the `SCORECARD.md` text is in `fixtures/` diffs and in the transcript). My F1 pre-move table initially carried only two axes and `cells` rejected it (see §4); the reading above uses a six-axis pre-move table. The L1's actual bytes may differ; the counter result depends only on the two lines (`lane-status:` red list, latest calibration row) and the capability row and armed row, so it is robust to wording, not to deletion.

---

## 1. Is `SD5 + stale` the calibration population the axis means, or a proxy?

**Answer: a proxy.** It is a presence/number check whose reference population is authored in the same file it scores.

Evidence, per shortcut class (readings above):

- **Single shortcuts do not reach 0.** Deleting the red list (A) → 1; deleting the armed row (B) or the capability row (C) → 3. The no-work tree is 4. So the proxy is not trivially satisfied by one edit.
- **A + B reaches 0 with no calibration content** (`shortcutAB`: `lane-status` drops its id list and the armed row is removed). Reason: SD5 reads ids from the `lane-status:` parenthetical and, when none remain, falls back to all `R<n>-<n>` tokens on the line; with none, `reds` is empty and SD5 = 0 vacuously (`corpus/self-description-sweep.sh` ~L379–L384). `stale` = 0 because the armed row is gone. Diff: `fixtures/shortcutAB-SCORECARD.diff`, `fixtures/shortcutAB-selfcounts.diff`.
- **Dropping one red from the list zeroes its SD5 term while the instrument still says it is red** (`t5`): `lane-status` lists only `R29-01,R29-02`; the calibration row still names `R25-02`. C1 = 0. Yet `bash corpus/claim-ledger.sh cells` on the same tree prints `FAIL R25-02 reason=exit-mismatch exit=2 want=0`. SD5 never consults `cells`. The reference set is self-declared.
- **A false state on a named red scores 0** (`t6`: row says `R25-02 (PASS)`). SD5 (`grep -qE "(^|[^0-9A-Za-z-])$id(...)"`) checks token presence only, not the state word; the cell it checks says PASS while `cells` says FAIL.
- **Stale count silently excludes refused rows** (`t7`): `PV-FEEDTOKEN-SELFTEST` (PROVINCE.md:76) claims `proves 9 cases`, live is `4`. `corpus/self-counts.py` refuses both `PV-FEEDTOKEN-*` rows (`POLICY ... ledger:R29-01 command not allowlisted`), prints `SELF_COUNTS: POLICY (claims=63 stale=0 unlocated=0 ambiguous=0 policy=2 setup=0)`, and `plans/round-36-c1.sh` still reads `stale=0` because its `sed` matches `^SELF_COUNTS:.*stale=` on the POLICY line and never checks the exit code (rc 2). So 2 of 63 declared bindings are never compared, and the counter does not fail closed on that.
- **`stale` is read from a red run.** The `R25-02` row *is* `python3 corpus/self-counts.py` (expect exit 0), and it is FAIL at base (`exit-mismatch exit=2`). The C1 sum includes a number printed by the same red process.
- **SD6 (the frozen kill-rule anchor) is layout-dependent, not committed-bytes.** Lane tree `bash corpus/claim-ledger.sh citations` → `UNRESOLVED ... (sibling)` ×2 (absolute `/home/vgpnk/...SOURCES.md`) plus three others → `CITATION_GATE: BROKEN (cites=2316 docs=97 unresolved=5 ...)`, so SD6 = 5. In a git-archive extraction the same gate prints 3 UNRESOLVED and the sweep reads SD6 = 3. The frozen claim says "measured over committed bytes"; SD6 is not. The `../.ufo` fleet-tree fallback (`corpus/claim-ledger.sh` L660–L668, L683–L690) and the absolute lane path are the cause.

What would make it the axis: bind the red reference to the live `cells` output (FAIL/POLICY set), check states not tokens, fail closed (exit≠0 from `self-counts.py` → SETUP, not a number), and count `POLICY`-refused bindings as unverified.

## 2. Does the post-move row genuinely change what the lane asserts, or is it self-fulfilling?

**Answer: it changes the asserted text and the asserted text is true at BASE; the 0 is self-fulfilling.**

- SD5 reads the **last** `## Round` section's calibration row (`corpus/self-description-sweep.sh` `round_line`=`tail -1` of `^## Round`). The candidate's `## Round 36 — post-move` row is therefore the thing scored. Writing the ids there is exactly what makes SD5 read 0. Circular: the scored object is the fix.
- Is the assertion true? Yes, and an independent reader can check it without trusting SD5: `bash corpus/claim-ledger.sh cells` on BASE prints `FAIL R25-02 reason=exit-mismatch exit=2 want=0`, `POLICY R29-01 reason=first-token:python`, `POLICY R29-02 reason=first-token:python`. Those are the three ids and their states (FAIL, POLICY, POLICY). That is the external re-derivation: the reds come from the ledger, not from the row.
- But the counter does not do that comparison. `t6` shows a wrong state scores 0; `t5` shows a dropped red scores 0. The row-plus-counter pair is a string check against the lane's own text. An independent reader re-derives the reds with `cells` (FAIL R25-02; POLICY R29-01, R29-02) and sees the row is correct; the counter cannot tell a correct row from a wrong one.
- Note on the candidate: `cells` on the candidate tree additionally prints `FAIL R13-01`, `FAIL R24-06`, `FAIL R25-04` (all `verdict-not-final`, exit 0) which are absent from every BASE run (see §4). The row is therefore correct about the three reds and the candidate adds new `cells` failures the row does not mention.

## 3. Is the F2 change (59 → 70) a measured correction or an assertion?

**Answer: measured.** Re-run of the ledger R21-03 command (lane tree, read-only; the selftest writes only temp roots):

```
$ cd /home/vgpnk/Projects/shokunin/kagi-shokunin && bash corpus/sources-census.sh --selftest; echo "rc=$?"
... 70 "case ... ok" lines ...
SOURCES_CENSUS_SELFTEST: PASS (70 cases)
rc=0
```

Ledger row: `R21-03	bash corpus/sources-census.sh --selftest	^SOURCES_CENSUS_SELFTEST: PASS \(70 cases\)$	0` (pinned expect 70, matches live). Same output in the BASE git-archive extraction (`SOURCES_CENSUS_SELFTEST: PASS (70 cases)`, rc=0). `self-counts.py` binds the SCORECARD row to the live run, not to the pin: BASE `STALE SA-CAP-CENSUS-SELFTEST SCORECARD.md:701 claimed=59 live=70`; candidate `OK SA-CAP-CENSUS-SELFTEST SCORECARD.md:701 claimed=70 live=70`; forge71 leaves `stale=1` (the forgery control is discriminating).

Caveat: the 70 is a count of cases, which is not evidence that the 59 → 70 growth was itself correct; it only says the live gate prints 70 now. The "59 kept as round-21 record" is the historical note and is unchecked. Fine for the claim as frozen.

## 4. Is C1 causally separable from C2?

**Answer: yes for the two counters; no for the candidate's `cells` gate.**

- The C1 counter reads only `corpus/self-description-sweep.sh`, `corpus/self-counts.py`, SCORECARD, self-counts.tsv. f34 (F3+F4, no F1/F2) reads C1 = 4 and C2 = 0. f12 (F1+F2, no F3/F4) reads C1 = 0 and C2 = 15. Separable as counters.
- The landing is not separable: F1 adds two `## Round 36` headers (BASE `grep -c '^## Round '` = 44; candidate = 46). F3/F4 change `release-clocks.tsv` and `release-clock.py`, and `cells` reports four `STALE-POINTER` lines for the four changed files (SCORECARD, release-clock.py, release-clocks.tsv, self-counts.tsv) that must be re-stamped in the landing commit.
- **Pre-move table must carry all six axes.** With a two-axis pre-move table, `cells` exits:
  ```
  claim-ledger: scorecard section '## Round 36 — pre-move (master `09f27e2...`, round-35 close)' does not carry all six axes exactly once (found=2 missing=depth coverage operability adjacency)
  rc=2
  ```
  The frozen plan does not say six axes; the parser requires it. The L1's F1 as written would break `cells` unless the pre-move table lists all six axes.
- **Candidate-only `cells` FAILs.** BASE `cells` (two independent full runs, plus a third in the `R25-04` differential): `FAIL R22-03`, `FAIL R24-15` (lone-clone layout artifacts per round-31 M31-3 — my git-archive extraction has no history, so these are not lane reds), `FAIL R25-02`, `POLICY R29-01`, `POLICY R29-02`, `CELL_AUDIT: POLICY (cells=258 row_pointed=189 stamp_pointed=128 policy=2)`. Candidate (six-axis pre-move): adds `FAIL R13-01 reason=verdict-not-final exit=0` (R13-01 pins `grep -c '^## Round '` at 46; the candidate prints 46 and still fails — cause in the cells verdict logic, not in the count, unexplained here), `FAIL R24-06 reason=verdict-not-final exit=0` (row-identity scorecard-rounds count/digest), `FAIL R25-04 reason=verdict-not-final exit=0` (`sha256sum .ufo/waves/round-26/observe-2.json` expects `^13b8…$`; the direct `sha256sum` prints the identical hash on both trees, rc 0). Not every candidate run printed all three (run B printed R13-01 only), so the set is run-dependent; no BASE run printed any of the three. Candidate `CELL_AUDIT` summary is `policy=2` in both runs — the summary does not count FAIL rows (QM3-type defect in the gate's summary line; reported, not fixed).

## 5. Verdict conditions

REJECT as frozen. What would be needed for a re-claim (not admissible in this round):

1. Bind the red reference to the live `claim-ledger.sh cells` output (FAIL/POLICY ids and states), not to a self-declared list.
2. SD5 compares states, not tokens; an empty list is SETUP, not 0.
3. `plans/round-36-c1.sh` fails closed on `self-counts.py` exit ≠ 0 (currently it reads `stale=` from POLICY lines) and counts POLICY-refused bindings as unverified (currently 2 of 63 are never compared).
4. SD6 is measured in a fixed layout, or removed from the kill rules; as written it changes between the lane tree (5) and a committed-bytes extraction (3).
5. The landing re-pins stamps for the four changed files and resolves the candidate-only `cells` FAILs (R13-01, R24-06, R25-04) with old→new records (QM14) before any calibration claim.

The candidate's facts (three reds named with correct states; 70 is the live count) stand on their own and can be re-claimed under a new round with a bound population.

## Raw command outputs (quoted)

BASE counters (git archive `09f27e2`), exit 0 each:
```
$ bash plans/round-36-c1.sh ; echo rc=$?     ->  4 / rc=0
$ bash plans/round-36-c2.sh ; echo rc=$?     ->  15 / rc=0
```
cb8cb65 extraction: `4 / rc=0` and `15 / rc=0`. Instrument bytes `plans/round-36-c1.sh`, `plans/round-36-c2.sh`, `corpus/self-counts.tsv`, `observe-live.json` are byte-identical between `cb8cb65` and `09f27e2` (`diff -r`, no output).

Receipt digest: `3f611eec30d4a48f4f389bb1a630551d77110d92fb97eee954eeb6f7c8558727  .ufo/waves/round-36/controls/observe-live.json` (= frozen digest).

Sweep, BASE (archive): `SELF_DESCRIPTION: MISMATCH n=6 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=3 SD6=3 SD7=0 SD8=0 SD9=0)`. Candidate: `SELF_DESCRIPTION: MISMATCH n=3 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=3 SD7=0 SD8=0 SD9=0)`.

Self-counts, BASE: `STALE SA-CAP-CENSUS-SELFTEST SCORECARD.md:701 claimed=59 live=70` / `SELF_COUNTS: POLICY (claims=63 stale=1 unlocated=0 ambiguous=0 policy=2 setup=0)`.
Self-counts, candidate: `OK SA-CAP-CENSUS-SELFTEST SCORECARD.md:701 claimed=70 live=70` / `SELF_COUNTS: POLICY (claims=63 stale=0 unlocated=0 ambiguous=0 policy=2 setup=0)`.
Self-counts, t7: `POLICY PV-FEEDTOKEN-SHAPES ledger:R29-02 command not allowlisted` / `POLICY PV-FEEDTOKEN-SELFTEST ledger:R29-01 command not allowlisted` / `SELF_COUNTS: POLICY (claims=63 stale=0 ...)`.

Citations, lane tree: `UNRESOLVED ... round-30-verifier-spotcheck.md:41 corpus/README.md:64/65/67`, `round-32 ... :54`, `round-33 ... :90 knowledge/corpus/knowledge/`, `round-34 ... :84 /home/vgpnk/.../corpus/SOURCES.md (sibling)`, `round-35 ... :78 /home/vgpnk/.../corpus/SOURCES.md (sibling)`; `CITATION_GATE: BROKEN (cites=2316 docs=97 unresolved=5 ephemeral=0 labeled=17)`; rc=1. Archive: 3 UNRESOLVED, `CITATION_GATE: BROKEN (cites=2299 docs=96 unresolved=3 ...)`.

cells, BASE: `FAIL R22-03 exit-mismatch exit=2 want=0`; `FAIL R24-15 exit-mismatch exit=2 want=0`; `FAIL R25-02 exit-mismatch exit=2 want=0`; `POLICY R29-01 first-token:python`; `POLICY R29-02 first-token:python`; `CELL_AUDIT: POLICY (cells=258 row_pointed=189 stamp_pointed=128 policy=2)`.
cells, candidate: as above plus `FAIL R13-01/R24-06/R25-04 verdict-not-final exit=0`; `STALE-POINTER SCORECARD.md sha=6fd328c2325e->f52a6530277a lines=1383->1407`, `corpus/release-clock.py`, `corpus/release-clocks.tsv`, `corpus/self-counts.tsv`; `CELL_AUDIT: POLICY (cells=270 row_pointed=191 stamp_pointed=136 policy=2)`.

R21-03 (lane tree): `SOURCES_CENSUS_SELFTEST: PASS (70 cases)` rc=0.

SETUP: `C1 SETUP: sweep verdict missing` rc=2; `C2 SETUP: receipt missing` rc=2.

Receipt structure (observe-live.json): `format=release-clock-observations-v1`, 30 observations (20 feed, 10 rendered-quote). Feed drift rows match the plan's list; `anchored_version` is not touched by the F3 diff (verified by `grep '^-'` over `f3.patch`).

Battery outputs: `raw/*.out`, `raw/*.rc`, `raw/battery.sh`.
