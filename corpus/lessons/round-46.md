# Round 46 — the declared-claim gate's self-test kills its own plan-to-manifest mutants (C1, operability); every on-release clock re-observed live and the release-clock gate CLEAN again (C2, freshness)

Frozen plan: `plans/round-46.md` (predeclaration `44808ced56359c98f35995178fb24a6482899263`; BASE `f5977284a8ce5bab09252be8196ee5dc18489926`). Counters `plans/round-46-c1.sh`, `plans/round-46-c2.sh`; pre-freeze controls `plans/round-46-controls.py` (11 controls, all MATCH, `.ufo/waves/round-46/controls/controls-prefreeze.txt`). Build wave: `.ufo/waves/round-46/build/` (12 seats). Final receipts: `.ufo/waves/round-46/final/`. No predicate, counter, target or kill rule changed after the freeze; the candidate-side corrections below (§Amendment notes) change no frozen sentence.

## Claims

- **C1 operability — the gate's own self-test now detects weakenings of its round-45 leg.** Surface: the `--run-selftest` block of `corpus/claims-declared.sh` (8 → 12 cases); the claim-checking logic is byte-identical (diff hunks only inside the block). Cases 9 (landed round, plan claim without a manifest row), 10 (in-flight round not checked), 11 (floor 39 inclusive), 12 (a claim's second heading on another axis without a row — reviewer K46RP-02's axis-blind weakening). Frozen predicate `C1_SELFTEST_KILLS`, target 3: one planted-omission case kills all three frozen mutants (M1 report silenced, M2 floor 39 → 99, M3 post-move test inverted); cases 10–12 pin the scope edges and the axis key. A byte-keyed self-test reaches at most 2 (critic D-4: M2 cannot be told from E2 without running the leg).
- **C2 freshness — every BASE on-release row re-observed live, gate CLEAN again.** The release-clock gate read FAILED on every committed tip from the round-39 landing `4776f71` to BASE (ORPHAN S040/S041 after their recheck moved to an ISO date in round 39; UNBOUND S098 after round 41). Frozen predicate `C2_FRESH_CLOCKS`, target 29. Composition (critic D-3): 19 version clocks and 10 quote clocks among S005–S032, plus S098. The freshness content is FRESH (29 records observed 2026-11-06, http 200) and the observation itself; DEFAULT and PINNED are one computation over one candidate-authored receipt (critic D-5) and certify agreement, not recency. 13 clocks stay fired: re-observed, not rearmed.

## Gate

Sources opened this round (all public GETs; the observation `python3 -B corpus/release-clock.py --observe .ufo/waves/round-46/final/observe-r46.json` at 2026-11-06T19:01Z, receipt sha256 recorded in `final/measured-at-candidate.txt`; the L1's own header re-fetch at 2026-11-06T19:02Z; the non-author re-observation `build/K46ReviewerLive/obs.json` at 18:53Z):

| row | URL | newest stable observed | located quote (≤25 words) | used by |
|---|---|---|---|---|
| S033 | https://github.com/getsops/sops/releases.atom | 3.13.3 | `<title>v3.13.3</title>` | clocks S008–S011 |
| S034 | https://github.com/hashicorp/vault/releases.atom | 2.2.1 | `<title>v2.2.1</title>` | S012, S013, S022–S024 |
| S035 | https://github.com/openbao/openbao/releases.atom | 2.7.2 | `<title>v2.7.2</title>` | S014–S016, S021, S025, S026 |
| S036 | https://www.python.org/downloads/feed.rss | 3.15.2 | `<title>Python 3.15.2</title>` | S027, S028 |
| S037 | https://curl.se/info | 8.23.0 | `Version: 8.23.0` / `Date: 2026-10-14` | S029 |
| S098 | https://www.unicode.org/reports/tr18/ | Revision 25 (body sha256 `68e34b8b…8c70d`, byte-identical to the round-41 capture) | `Revision 25` (raw byte offset 197172 of `.ufo/waves/round-41/capture/S098.body`) | its own clock |

No feed released between the round-36 receipt (2026-11-04) and this observation: every feed version equals the round-36 value (`bash plans/round-36-c2.sh` → `0` at the candidate). The ten quote clocks (S005–S007, S017–S020, S030–S032) located their declared capture quotes; the non-author seat located the same eleven quotes independently (29/29 agree, `build/K46ReviewerLive/report.md`).

Registry rows touched (old → new; no row added, none deleted):
- none in `corpus/SOURCES.md` (status, recheck and used-by of every row unchanged).
- `corpus/source-fetches.tsv` S098 capture row: declared quote `<title>UTS #18: Unicode Regular Expressions</title>` → `Revision 25`; location `teaching-quote-annex-c-compatibility-properties-space-s-rendered-text-byte-offset-90651` (a location that did not describe the declared quote) → `document header table, Revision cell (raw byte offset 197172 …)`. Same captured body (sha256 unchanged); the new quote locates once in it. Reason: the title is revision-invariant, so a title clock could never fire on a UTS #18 revision (critic D-7, executor K46ExecClocks).

Discernment sample: admitted — S098's revision quote as its clock (re-opened live, located once, body byte-identical). Refused — the title quote as S098's clock (cannot fire; flip: none, it is replaced); and executor K46ExecLedger's proposed second ledger row R46-01 for the default gate (refused as a duplicate authority over R36-03, critic D-10; flip: a row that measures a different property than R36-03's verdict line).

Retired clock rows (critic D-8; the register keeps them here verbatim, git keeps the bytes):

```
S040	feed	S039	https://www.python.org/downloads/feed.rss	3.15.1	3.15.2	2026-11-04	fired	anchor names Python 3.15.1 documentation; round-36 receipt observe-live.json (2026-11-04) observes v3.15.2, past the anchor, so the clock FIRED; rearmed successor to S027
S041	feed	S039	https://www.python.org/downloads/feed.rss	3.15.1	3.15.2	2026-11-04	fired	anchor names Python 3.15.1 documentation; round-36 receipt observe-live.json (2026-11-04) observes v3.15.2, past the anchor, so the clock FIRED; rearmed successor to S028
```

Their registry rows left `on-release` in round 39 (recheck `2026-11-05`, superseded by S095/S096); the gate's only consistent state for an ORPHAN clock is retirement.

## Mistakes

| id | class | evidence pointer | captured-by | fix |
|---|---|---|---|---|
| M46-1 | ledger-row-dismissed (a held gate red on the real tree, carried as inherited) | `bash plans/round-36-c3.sh` (ledger R36-03, the default-mode gate) FAILED on every tip `4776f71`…`f5977284` (L1 bisect; `final/r36-03-red-witness.txt`); rounds 40–45 read the R36-03 exit mismatch as an inherited FAIL outside the frozen set (revenger `build/K46Revenger.md` §7; round-40 closure §2) | R36-03 — it was red; the reading dismissed it. The plan's frozen text said `captured-by: none`; amended here (critic D-10, revenger §7) | R36-03 expect migrated 30/15 → 29/13 with a journal (`.ufo/waves/round-46/expectation-migrations.json`); red witness: at BASE the row's command reads FAILED rc 1 and matches neither expect; at the candidate CLEAN rc 0 matches the new one. QM57. |
| M46-2 | control-validity (caught pre-freeze) | the first K1-F1 byte-keyed forgery grepped strings its own inserted lines contained, so it matched itself in every mutant and killed nothing (equiv=1, killed=0, value 0 for the wrong reason) | the control's full receipt line read by the L1, not its value | split literals (`'3''9'`); the corrected control reads killed=3 equiv=0 value 0 (`controls/controls-prefreeze.txt`) |
| M46-3 | misroot (L1, own) | a Python eval cell resolved `.ufo/waves/round-46/final/observe-run.txt` against the fleet root (the kernel's cwd resets between cells), writing one 213-byte file and two empty directories at `/home/vgpnk/Projects/shokunin/.ufo/waves/round-46/` | the L1's `git status` on the lane showed the receipt missing | the fleet copy (a failed-run transcript with no lane value) was deleted with its two empty directories; the run was repeated with absolute paths and `cwd=` set; sentinel S-03 names the same class in `--observe` (OUT resolves against the process cwd) |
| M46-4 | stale self-description | `PROVINCE.md:75` and `SKILL.md:48` said S040/S041 keep on-release cadence at named 3.15.1 anchors; false since round 39 | executor K46ExecClocks doc sweep (`build/K46ExecClocks/skill-lines.md`) | both lines corrected with the round-46 default receipt |

## Errata (append-only; the superseded text is kept in the cited file)

- **E46-1 (round-45 receipt hygiene, closure §5 item 3).** `.ufo/waves/round-45/final/measured-at-candidate.txt` line 6 (`$ bash plans/round-45-c1.sh LANE (pre-candidate control at tree)`) has no output under it; the reading it stands for is committed at `.ufo/waves/round-45/controls/c1-base.txt:1` (`value=0 detected=0 positive=1 real=CLEAN`, `claims=15`). Line 35 `stamp rc=2` precedes its own invocation header (line 36) and does not match the recorded run; the stamp leg's reading is `.ufo/waves/round-45/final/stamp-drift-at-candidate.txt` (`STAMP_DRIFT: rows=123 drift=0`, `stamp rc=0`). The round-45 receipt is not rewritten (draft and code pointers: `build/K46ScribeCurate/erratum-E46-1.md`).
- **E46-2 (plan text, critic D-1/D-2/D-9).** `plans/round-46.md` §Axes calls C1 "an instrument move"; the surface sentence is the measure: the bytes changed are the `--run-selftest` block, a runnable-artifact (operability) move, not a re-score of round 45's calibration move. The separability sentence omits the bookkeeping C2 forces (stamp re-pin, the R36-03 migration). The stagnation sentence cites the nudge as a waiver; it is not needed (all six axes tie at 9, so C1 and C2 each work a tied-lowest axis), and its capability/frontier directive is declined this round.

## Amendment notes (candidate side; no frozen sentence changed)

- Reviewer K46RP-01: the C1 kill rule "diff outside the `--run-selftest` block" has no code path in the counter; it is enforced by a recorded diff check at the candidate (`final/measured-at-candidate.txt`, hunk ranges vs block bounds).
- K46RP-02: case 12 added (axis-keyed manifest); the axis-blind weakening fails the gate's own self-test at the candidate (recorded).
- K46RP-03: KILLED counts any non-zero exit; at the candidate each mutant's self-test exits 1 with a `FAIL` last line (recorded), so no kill is a SETUP.
- K46RP-04 / K46RP-05: FRESH has no upper date bound and PINNED digests the file it measures; at the candidate every record is dated 2026-11-06 and `DEFAULT_RECEIPT_SHA256` equals the committed receipt's digest (recorded). Routed to round 47 as counter amendments.
- Critic D-6: the measured receipt includes `git diff BASE..candidate -- corpus/release-clocks.tsv corpus/SOURCES.md`; no fired row's `anchored_version` or verdict changed.
- Critic D-12: the SCORECARD post-move section and the manifest rows `46 C1 operability`, `46 C2 freshness` land in one commit.

## Routed (named, not claimed this round)

1. Counter amendments for round 47 (mutation survivors, `build/K46MutCounters.md`: POSITIVE drop, no-op SETUP, PASS-prefix, http/date/KEPT/PINNED/DEFAULT legs, duplicate records, empty parser; reviewer K46RP-01/03/04/05).
2. Bind receipt digests to committed captures (critic D-3); a gate rule for `on-release` on a REJECTED row (D-7); pin fired anchors (D-6).
3. The lane-local census `bash corpus/sources-census.sh` reads FAILED at BASE and at the candidate (`SC_USEDBY_NOCITE S094`, `SC_USEDBY_NOCITE S099`, `SC_FETCH S099 missing-provenance`; executor K46ExecClocks receipts); the fleet census reads ok. Not touched this round (QM57 applies: routed, not inherited).
4. Re-verification of the teachings behind the 13 fired clocks.
5. Sentinel S-01..S-11 (`build/K46Sentinel.md`): S-03 (`--observe OUT` resolves against cwd) is the class of M46-3.
6. Carried: D4 mistake vocabulary, B1 always-refuse conjunct, round-40 report erratum (fleet-side), SEAT-STATUS uniformity, round-45 sentinel S-09/S-11/S-14.

## Frontier

Census before and after: `scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` → `kagi ok`, rc 0, 102 rows (`controls/census-start.txt`; end reading in `final/`). Frontier rows advanced: none; the release-clock surface moved from a red held gate to a green one over a live observation.

## Assimilation

None: no staged `merge/kagi/` theme matches either claim.

## considerthese

No new file after `considerthese/2026-10-26.md`; its unimplemented proposal 1 is operator policy and is not taken.
