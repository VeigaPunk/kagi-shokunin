# kagi round 37 — plan (frozen claim)

Round 37, attempt 1. Lane: kagi (secrets & vault ops). Owned axes: freshness + calibration.
Predeclaration (instrument, receipt, executed controls): `04489d4184edb25a01ec8983b3ccedb45c683564`.
BASE for the claim: lane HEAD `911ab519b6b07694c3cb9f7d9a7c56e142ad957c` (round-36 landing). The
shipped pre-freeze gate ran over the predeclaration: `PREFREEZE: CLEAN (controls=6 mismatch=0)`
(`.ufo/waves/round-37/controls/prefreeze-gate.txt`).

Read in-round before freezing (fresh-start rule): the rejected closures and spot-checks of the last
three rejected rounds — round 34 (`corpus/lessons/round-34-verifier-spotcheck.md`, C3 arithmetic),
round 35 (`corpus/lessons/round-35-verifier-spotcheck.md`, calibration axis fit withheld), round 36
(`corpus/lessons/round-36-verifier-spotcheck.md`, C1 rejected as an instrument; routed R36-1..R36-5) —
plus rounds 32–33 and the round-36 `SCORECARD` calibration row.

## Why one claim, not two

Round 36's C1 counter (`SD5 + stale`) reads **0 at HEAD** (measured `bash plans/round-36-c1.sh` at
`911ab51` → `0`). A "4 → 0" calibration target is therefore already reachable by doing nothing, so it
cannot be a claim this round (§9). The calibration defects the closure routed (R36-1 dangling
`M36-4` pointer; R36-2 report says "five" W04 lines where the live census prints 16) are corrected as
errata in this round's lesson and report and are **not** counted as a claim. R36-4 (reviewer
conditions on the C1 instrument) is routed to round 38 unclaimed. Freshness is the one axis with a
measured, non-zero BASE gap that a do-nothing control cannot reach. This is one claim, not three.

## C2 — freshness: release-feed registry anchors re-verified against the live observation, 3 → 0

**Declared claim.** At the landing revision `bash plans/round-37-c2.sh` prints one integer, the
number of release-feed surfaces (hashicorp/vault `releases.atom`, openbao/openbao `releases.atom`,
python.org `downloads/feed.rss`) for which `corpus/SOURCES.md` holds **no** registry row whose
source cell carries the feed URL **and** whose anchor cell names the receipt's `parsed_version` for
that feed. That integer is **0** (BASE **3**, measured at `04489d4`).

**Predicate (one sentence, identical in `plans/round-37-c2.sh` and the receipt label):** a release-feed surface is held when a `SOURCES.md` row names its feed URL in the source cell and its receipt version in the anchor cell.

**Receipt.** `.ufo/waves/round-37/controls/observe-r37.json` — written by
`python3 corpus/release-clock.py --observe` on 2026-11-05 (30 records; sha256
`cb96cfb23bda8d1366a184c280aebe767ed09b0bba0934876edeef6fe42c9203`, pinned in the counter). The
receipt's versions are vault `2.2.1`, openbao `2.7.2`, python.org `3.15.2`; each is also in the
live feed bytes fetched this round (`<title>v2.2.1</title>`, `<title>v2.7.2</title>`,
`<title>Python 3.15.2</title>`).

**Surfaces at BASE and why each is stale.** vault `S034` anchor names `v2.2.0`; openbao `S035`
anchor names `v2.7.1`; python `S039` anchor names `Python 3.15.1` (and `S036` names `3.15.0`). The
frozen counter reads 3 at `04489d4` and at `911ab51`.

**Declared candidate (the fix, frozen before any candidate scoring).** Three new registry rows,
each opened in this round with an access date of 2026-11-05, a ≤25-word located quote in the
fetched bytes, and `used-by corpus/lessons/round-37.md`; each `teaches` opens `supersedes S0NN —`
per `CORPUS.md` SOURCES rule 2, so no existing row's mutable cells change:
- `S089` vault releases feed, anchor `Entry titled v2.2.1` — supersedes S034;
- `S090` openbao releases feed, anchor `Entry titled v2.7.2` — supersedes S035;
- `S091` python.org downloads feed, anchor `Item titled Python 3.15.2` — supersedes S039 (feed).

**Controls executed before this freeze (committed at `04489d4`; gate `CLEAN 6/6`).**
| control | frozen expect | measured | what it proves |
|---|---:|---:|---|
| `c2_nowork` (HEAD tree, no fix) | 3 | 3 | a do-nothing round cannot reach 0 |
| `c2_forge_superseded_g1` (vault row with superseded `v2.2.0`) | 3 | 3 | version equality, not presence or ordering |
| `c2_forge_wrong_url_g2` (current openbao version under the vault URL) | 3 | 3 | URL binding per surface |
| `c2_forge_knowledge_g3` (current vault version only in `knowledge/`) | 3 | 3 | the registry is the only holder |
| `c2_positive_partial` (vault row only) | 2 | 2 | per-surface counting, not all-or-nothing |
| `c2_positive_full` (all three rows) | 0 | 0 | the claimed state is reachable |
Setup controls (receipt missing; receipt sha-tampered) exit 2 with no integer
(`controls/c2-controls.txt`).

**Kill rules (frozen).**
- Any of the three surfaces still stale at the landing revision → C2 unmet, not admitted.
- The receipt is amended, re-observed, or its sha changes → the counter exits 2 (SETUP) and C2 is not measured; a new receipt requires a new claim.
- A historical receipt, row, or lesson is rewritten or deleted instead of superseded → C2 fails.
- The fleet census `scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` must exit 0 at the landing revision; the lane census `bash corpus/sources-census.sh` must print `CLEAN`.
- A row appended with a quote not located in the fetched bytes (the Gate quote check) → that row is refused and C2 is measured on what remains.

**Ceiling, named in advance.** The counter checks that a row names the feed and the version; it does
not check that the row's `teaches` is the right lesson, nor that the source was opened by the
author. Those are checked by the non-author reviewer seats and by the Gate's located quotes, not by
the counter. A row that fakes the quote would pass the counter; the wave's reviewer re-fetch is the
control for that class.

## Sourced claim

C2 rests on `S089`, `S090`, `S091` — opened 2026-11-05 — and their Gate located quotes in
`corpus/lessons/round-37.md` §Gate.

## Frontier step (§2b)

- Census before: `scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` →
  exit 0, 16 W04 duplicate-URL warnings, `kagi ok …/corpus/SOURCES.md`. Lane `bash corpus/sources-census.sh` → `SOURCES_CENSUS: CLEAN (rows=88 …)`.
- Census after: recorded at the landing revision (same two commands).
- Rows added: `S089`, `S090`, `S091` (tier A, mined, scope release identity). Rows touched old → new: none (`status`, `recheck`, `used-by` of S034/S035/S039 unchanged; the supersession is recorded in each new row's `teaches`).
- Mistakes mined into `corpus/lessons/round-37.md` `## Mistakes`: (a) the round-36 report says "five pre-existing W04" where the census prints 16 (R36-2) — captured-by `none`, fix: the counting command pasted with its live output; (b) this round's first harness ran the forgery scripts against the lane tree instead of a scratch extraction (caught before any commit; lane tree verified unchanged by `git status` and the `master` tip) — captured-by `none`, fix: every control runs in a `git archive` extraction, and the battery asserts the lane's tracked state before and after.
- Quarantine: the absent-defect register slice for `kagi` holds 8 rows (`awk` over `…/corpus-expansion-1/absent-defect-register.md`); none is adopted this round; each is quarantined, recorded in the lesson.
- Assimilation: `Assimilation: none` — this round's capacity goes to re-opened sources and the frozen controls; `merge/kagi/` package not adopted (quarantine above).
- considerthese: `considerthese/2026-10-26.md` proposals are implemented or discharged (round-35/36); no unimplemented proposal is taken this round.

## Capability

The release-feed anchor currency counter (`plans/round-37-c2.sh`) enters the `SCORECARD.md`
capabilities table in this round, with its demonstration: the frozen controls at `04489d4` (gate
`CLEAN 6/6`) and the landing-revision run. The capability row is not an axis move.

## Wave

One v1 wave of 10 seats (inside the run-15 band 8–16; L2 floor 8): executor ×3 (ExecRows, ExecCounter, ExecEvidence), scribe ×1 (ScribeDocs), scout ×1 (ScoutRegistry), connector ×1 (ConnFeeds), reviewer ×2 (ReviewFresh, ReviewCounter), critic ×1 (CriticClaim), mutation-tester ×1 (MutCounter). Attack seats = reviewer 2 + critic 1 + mutation-tester 1 = 4/10 = 40 % (≥25 %); connector 1 (≤2). The canonical planner seat stays with the L1 (the validator rejects `planner`; the deviation is recorded here at freeze, as in round 33). Seats write only under `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-37/build/<seat>/`; the L1 is the only integration owner and the only writer of lane production files.
