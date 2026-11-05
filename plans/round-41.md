# Round 41 — frozen plan (kagi, attempt 1)

Predeclared before any candidate scoring. Claim BASE `19025d97e5013bac2f45d6b9e61bfbafc84c3c8d`
(round-40 verifier spot-check, lane tip at round start). Round-40 landed state (the positive control
P0 of C1) `6f1588cc0ebd5cbbd4e983fbd71c1e419d225ce0`. Round-40 claim BASE `6cc8850dfc5757927699e5a53a876f47c8df21aa`.

Every axis stands at 9 at the round-40 close (SCORECARD round-40 reference line). The round declares
two claims. Both move owned axes: C1 calibration, C2 freshness. The lowest-scoring non-retired axis is
tied at 9 across all six axes, so the lowest-axis obligation is met by either claim. No exploratory claim.

## Routed defects from the round-40 spot-check, and where each goes this round

| Routed defect (`corpus/lessons/round-40-verifier-spotcheck.md` §7) | Round-41 disposition |
|---|---|
| 1. C1 separability and journal check (M40-5, M40-6, M40-16) | **C1** below |
| 2. C3 counter reads the verdict token only (M40-9, M40-10, M40-17) | Not claimed this round; carried as routed debt to round 42 (named in the report) |
| 3. SCORECARD round-40 sentence "not amended after data" | Appended erratum (bookkeeping, not a claim) |
| 4. Reject decision in the round's Gate | Recorded: S098 rejected (see §Frontier) |
| 5. `rendered-text-v1.py` step-5 docstring (cites superseded S027; U+3000 not on the 3.15.2 page) | **C2** below |
| 6. Gate selftest scratch default `${TMPDIR:-/tmp}` | Not claimed; the new round-41 gate and counters use `${HYAKU_SCRATCH:-/fast/scratch/hyaku}`; the older defaults are carried as routed debt to round 42 |
| 7. Report amendment in place (round-40 report) | Carried as routed; the round-41 report is filed once, no in-place rewrite |
| 8. Planner seat missing in the round-40 wave | The L1 is the canonical planner (§Shape); a bounded planning data-walk rides the scout item K41ScoutSources |

## C1 — calibration: unjournaled ledger-expectation loosening is refused

**Problem (measured, round-40 spot-check §2, M40-6):** `corpus/claim-ledger.sh verify` accepts an
expectation loosened to a pattern that still matches current output (a literal `^54$` replaced by
`^[0-9]+$`), an edited journal `old_expect`, and a rebound command. The round-40 counter for debt
(`plans/round-40-c1.sh`) cannot tell a migration from a loosening.

**Gate (to be built, `corpus/expect-journal.sh`):** compares the candidate ledger with a base ledger.
Frozen rules:

- R1 `UNJOURNALED <ID>`: a row present in both ledgers whose command (column 2) or expect (column 3)
  differs from the base must have a migration entry with that id in some `*.json` file under `--journals`.
- R2 `OLD_MISMATCH <ID>`: that entry's `old_expect` equals the base expect literally.
- R2 `COMMAND_MISMATCH <ID>`: that entry's `command` equals the candidate ledger command literally.
- R2 `NEW_MISMATCH <ID>`: that entry's `new_expect` equals the candidate ledger expect literally.
- R3 `NOT_LITERAL <ID>`: every candidate expect that changed from base is a fully literal anchored
  expression: starts with `^`, ends with `$`, and every regex metacharacter in the interior
  (`. [ ] ( ) * + ? { } | ^ $`) is escaped with a backslash.
- R4 `WARN ORPHAN <ID>` (warning, not a refusal): a journal entry for a row that did not change.

Interface (frozen): `bash corpus/expect-journal.sh --base-ledger FILE --ledger FILE --journals DIR`.
Exit 0 accept, 1 refuse, 2 setup. Refusal lines: `EXPECT_JOURNAL: REFUSE <CLASS> <ID>`, one per
violation, on stdout. Final line `EXPECT_JOURNAL: CLEAN (changed=<n> journaled=<n>)` or
`EXPECT_JOURNAL: REFUSED (violations=<n>)`. Selftest: `--selftest` runs the four forgeries and P0 on
scratch fixtures and prints `EXPECT_JOURNAL_SELFTEST: PASS (cases=<n>)`.

**Counter (frozen predicate, `plans/round-41-c1.sh`):** prints ONE unsigned integer N = the number of
the four forgeries F1–F4 that the gate refuses with its frozen token (rc 1 and the exact line
`EXPECT_JOURNAL: REFUSE <token>`), counted only if the gate accepts the positive control P0 (rc 0).
If P0 is refused or the gate is missing, N = 0.

| Forgery | Construction (on P0 = round-40 landed ledger + round-40 journal) | Frozen token |
|---|---|---|
| F1 | R13-01 expect := `^[0-9]+$`, its journal entry removed | `UNJOURNALED R13-01` |
| F2 | R21-02 journal `old_expect` := its `new_expect`; ledger unchanged | `OLD_MISMATCH R21-02` |
| F3 | R13-01 expect := `^[0-9]+$` and its journal `new_expect` := the same | `NOT_LITERAL R13-01` |
| F4 | R24-06 command rebound to an `echo` of its expected line; journal unchanged | `COMMAND_MISMATCH R24-06` |

- Target: **N = 4** at the round-41 candidate.
- No-work control (BASE 19025d9 has no gate file): **N = 0**.
- Blanket-refuse control (gate that always exits 1) and blanket-accept control (always exits 0): **N = 0**
  each (positive control fails, or no forgery is refused). These run in `plans/round-41-controls.sh`.
- Existing-gate control (the pre-change `claim-ledger.sh verify`, no journal rule): accepts F1–F4 by
  construction, because each forged expect or command still matches what the command prints. Measured by
  the round-41 reviewer seat on forged sandbox copies and committed under `.ufo/waves/round-41/controls/`.
- Kill rule: C1 is not admitted if the candidate counter is not 4, any control reads above 0, the
  positive control is refused, or any of the six round-40 migrations (R13-01, R21-02, R24-06, R31-02,
  R33-02, R34-03) is refused by the gate at the round-41 landing.
- Separability: C1 reads only P0 (fixed committed revisions) and the gate; it does not read C2's
  registry rows. C1 verifies without C2 landing.
- Ceilings, disclosed in advance: the gate does not re-run commands (a journal's literal `new_expect`
  that disagrees with real output is the job of `claim-ledger.sh verify`, not this gate); it does not
  judge the reason text.

## C2 — freshness: the rendered-text-v1 whitespace-class declaration cites current, bound sources

**Problem (round-40 spot-check §5, §7.5):** `corpus/rendered-text-v1.py` step 5 names the whitespace class
without a registry id; its Sources paragraph cites Python 3.15.0-era docs by name only, and the
`U+3000` example is not on the served 3.15.2 `re` page. The registry rows that teach the class moved:
S027 → S040 → S095 (served 3.15.2, opened 2026-11-05, body bound by sha in `corpus/source-fetches.tsv`).

**Change (to be built):** the module docstring's Sources paragraph (the paragraph beginning `Sources (`)
cites the current rows S095 (Python `re` str-pattern whitespace, 3.15.2) and S097 (the `str.isspace()`
definition in the Python 3.15.2 `stdtypes` page, opened 2026-11-05, admitted this round). Step 5 keeps
its normalization rule unchanged; the U+3000 derivation (`unicodedata.category` Zs) is recorded in the
round lesson's Gate, not asserted from S095.

**Counter (frozen predicate, `plans/round-41-c2.sh`):** prints ONE unsigned integer N = (a)+(b)+(c), each
term 0 or 1:

- (a) the Sources paragraph of `corpus/rendered-text-v1.py` (`RTV1`, default that path) cites at least one
  `S###` id and no cited id is superseded (superseded = an id named in a `supersedes S###` cell of
  `corpus/SOURCES.md`).
- (b) the paragraph contains the frozen quote `Matches Unicode whitespace characters (as defined by`, and
  the S095 capture body binds: the S095 row's decoded sha256 (column 10 of `corpus/source-fetches.tsv`)
  equals `sha256sum` of a `.ufo/waves/*/capture/S095.body`, and `python3 corpus/rendered-text-v1.py locate`
  on that body exits 0 for the quote.
- (c) `python3 corpus/rendered-text-v1.py --selftest` exits 0 and prints `PASS`.

- Target: **N = 3** at the round-41 candidate.
- No-work control at BASE 19025d9: **N = 1** (a = 0, no citation; b = 0, no quote; c = 1). The target is
  not reachable by doing nothing.
- Decoy control (paragraph cites only the superseded S027 with the quote): reads (a)=0, so N ≤ 2.
- Kill rule: C2 is not admitted if the candidate reads below 3, any binding fails at the landing tree,
  or the selftest drops below 22 cases.
- Sourced claim (LOG/§2b.4): C2 rests on S095 and S097, both opened this round (scout K41ScoutSources,
  receipts under `.ufo/waves/round-41/capture/`).
- Ceiling, disclosed in advance: the counter binds ids and one frozen quote; it does not check that every
  sentence of step 5 is grounded. That check is the round's reviewer item K41ReviewDocs.

## Frontier and sources (§2b)

- Admit S097 (tier A, docs): `str.isspace()` whitespace definition (Python 3.15.2 `stdtypes`). The row's
  quote is opened and located this round.
- Reject S098 (tier A, spec): Unicode UTS #18 `\s` as `\p{White_Space}`. Reason: `str.isspace()` accepts
  U+001C–U+001F, which `White_Space` does not (checked by a labrat probe over all code points). The
  normalizer class is `str.isspace()`, so UTS #18 cannot ground it. Flip condition: the normalizer's
  class is redefined to `White_Space`.
- Mistake mined: round-40 spot-check M40-6 (counter accepts loosened expects). Captured-by: none. Fix:
  C1 gate; the fix counts only once F1–F4 are shown refused.
- Assimilation: none this round. The `merge/kagi/` package is not opened in this round; the census
  line is in the report.
- considerthese: the latest file (`considerthese/2026-10-26.md`) has proposals whose status the report
  states; none is taken as a claim this round.

## Shape (declared before dispatch)

One v1 wave, **11 seats**, band 8–16, policy `scripts/hyaku/ufo-wave-policy.json`:

| Seat | Role | Work |
|---|---|---|
| K41ExecJournal | executor | build `corpus/expect-journal.sh` (+ selftest) and verify the candidate against C1 |
| K41ExecDocs | executor | rewrite the rendered-text Sources paragraph; build the C2 path check |
| K41ScoutSources | scout | open S095, S097, S098 live; write capture bodies and fetch-row values; deliver the planning data-walk for the C1 journal |
| K41ScribeRegistry | scribe | draft S097/S098 registry rows, fetch rows and the round-41 migration journal |
| K41ScribeLesson | scribe | draft `corpus/lessons/round-41.md` (Gate, Claims, Mistakes, Frontier) and SCORECARD round-41 rows |
| K41ConnOverlap | connector | sibling overlap scan (other lanes' expect/journal/whitespace declarations) |
| K41ReviewJournal | reviewer | attack C1: build F1–F4 and run the pre-change verify on each (BEFORE evidence) |
| K41ReviewDocs | reviewer | attack C2: check each docstring sentence against the cited bodies; prepare the check list |
| K41CriticClaims | critic | falsify both claims and their controls before scoring |
| K41MutGates | mutation-tester | prepare mutants of the C1 gate and the C2 paragraph, with a runner, for the landing |
| K41LabRejectProbe | labrat | falsifiable probe for the S098 reject: code points where `str.isspace()` and `White_Space` differ |

Attack share: reviewer 2, critic 1, mutation-tester 1, labrat 1 = 5 of 11 (45%, floor 25%).
Connector seats: 1 (limit 2). Planner: the L1 holds the canonical planner seat; no planner is spawned
(validator rejects it). Executor, scribe and scout items sit in the same wave.

Integration after WAVE-DONE: the L1 copies executor outputs byte-exact into the lane, runs the frozen
counters and controls once, runs the mutation runner, writes the migration journal from the measured census
output, and commits through `jj-lane.sh`.

## Claim sizing and what this plan does not do

- No universal clause is used in a claim. The counters enumerate fixed sets (F1–F4, the six round-40
  migrations, the four-term check list).
- No C3 counter, no gate-selftest scratch-default fix, no SCORECARD round-40 rewrite in place: routed as
  stated above.
- Pre-change verify timing: `claim-ledger.sh verify` takes about 5 minutes; reviewer seats use a timeout of
  900 seconds and run the four forgeries in parallel scratch clones.
