# R59ScoutRouted — routed facts (round-59 C1 numbers re-derived)

Seat `R59ScoutRouted` (scout) · lane `kagi-shokunin` @ `master` · claim BASE
`5fa6e658f36bd9e440cb567fbbd2bfac88f868b6` · frozen predeclaration `af7b6651`.

Full evidence table (43 commands → raw output → the plan number each supports), the
BASE lesson lines verbatim, and the §Disagreements list are in the seat receipt:

- `.ufo/waves/round-59/build/R59ScoutRouted/routed-facts.md`

## Result

**No numeric disagreement.** Every number the round-59 C1 items compare re-derives
exactly as `plans/round-59.md` states:

| item | plan number | re-derived | command |
|---|---|---|---|
| I1 base census | 117 | **117** | `git show 1b13f5da:corpus/SOURCES.md \| grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|'` |
| I1 landing census | 120 | **120** | same on `be8705f8` |
| I2 added rows | 6 | **6** | `git diff 1b13f5da be8705f8 -- corpus/source-fetches.tsv \| grep -c '^+S'` (rows S115–S120) |
| I3(a) total / C1-F / C2-F | 20 / 9 / 7 | **20 / 9 / 7** | `grep -c '^CONTROL '`, `'^CONTROL C1-F'`, `'^CONTROL C2-F'` on `.ufo/waves/round-58/controls/controls-prefreeze.txt` |
| I5 mission minutes | 101 | **101** (6091 s = 101 min 31 s, floor) | the two driver-digest timestamps in `corpus/lessons/round-58-verifier-spotcheck.md` (11:54:48 → 13:36:19) |
| K2 BASE census | `value=5 population=5`, guard leg `value=FAIL … guard=0` | **exactly that** | `plans/round-59-c1-check.py --root <BASE tree> --no-challenge` and the guard-bearing leg |

BASE item readings — every condition must fail at BASE, and every one does:
`BASE i1=0` (lesson:94 reads `Registry 119 → 120`, derived base is 117) ·
`BASE i2=0` (no BASE lesson line names `corpus/source-fetches.tsv`, count 0) ·
`BASE i3=0` (last naming line 72 states `17 MATCH / 5 MISMATCH`, not 20/9/7; supplement
script and receipt absent at BASE) · `BASE i4=0` (receipt absent at BASE) ·
`BASE i5=0` (no BASE lesson line matches `stale-lane`).

Also re-derived and confirmed: the r58 control set is 20 = 9 C1 + 7 C2 + 2 K1 + 2 K2;
`C1-F10` and `C2-F4` are documented (r58 plan lines 147/150, r58 lesson) but shipped in
neither the r58 receipt nor the r58 script; the report's "ten C1" is present; BASE axes
all read 9; saturation line 9 / window N=3; capability first-working rounds 49/51/52/57/58
as the plan states; the transit trial does not exist at BASE.

## Disagreements (prose only — the L1's to correct, I amended nothing)

1. **"no committed line states the `corpus/source-fetches.tsv` delta … 6 rows"** — the
   spot-check file is itself tracked in the lane at BASE and its line 170 states "the
   BASE→tip diff adds **six** rows (S115–S120; rows 114 → 120)" with `⇒ 6`. The
   narrower true statement is "no committed line of the round-58 **lesson** names it" (0).
2. **"the round-58 report carries no stale-lane line"** — the report carries
   `- Stale-lane: respawn-per-round driver; …` at `.ufo/reports/round-58/kagi.md:146`
   (same at the spot-check's cited commit `d7875c9` and at fleet HEAD). What it lacks is
   the progressing/silent determination and the 101-minute duration.
3. **"`grep -rl 'transit' corpus/knowledge/` matches only entries that mention the Vault
   transitive trust boundaries or NIST key-management prose"** — the NIST half is right;
   the other match, `vault-openbao-token-lease-lifecycle.md`, matches on the word
   "transit" in "no database, transit or other engine"; no knowledge entry contains
   "transitive" (count 0). The load-bearing claim (no transit engine mechanic) holds.
4. **A4 item 1 "… C2-F1..C2-F8 — 20 controls"** — the landed `plans/round-59-controls.sh`
   has **21** report legs / 21 distinct ids; the enumeration omits `C1-F7b` (line 138).
5. **I4's `U` is scope-dependent and the receipt is already stale.** The receipt runs the
   gate over a narrowed 48-doc scope named in its own header → `U=6`; the plain
   `bash corpus/claim-ledger.sh citations` (default set) on the same live tree →
   `unresolved=14`, exit 1; the committed r58 baseline → `unresolved=15`. The frozen I4
   text pins no scope, so any self-consistent pair passes. Worse, the receipt was written
   at 14:33:26 and `SCORECARD.md` was edited at 14:34:47; re-running the same scope now
   yields `unresolved=5`, so the receipt does not reproduce against the current tree even
   though receipt and lesson still agree with each other (both 6) and I4 reads HOLD.

Observations without contradiction: "the claim BASE holds 117 rows" is true for the
round-58 BASE (`1b13f5da`) but the round-59 claim BASE (`5fa6e658`) holds **120**; the
plan's C2 S121/S122 are round-59 additions (BASE stops at S120).

## Notes

- The lane tree was churning under me throughout (SCORECARD.md, the lesson, SOURCES.md
  and the receipts were all being edited by other seats while I measured). Every number
  above is a snapshot with the command that produced it; where a number moved (the
  citation-gate `U`) I say so and give both readings.
- No tooling was installed or upgraded by this seat; no pacman/uv/npm transaction ran.
  Tools used were the pre-existing `git`, `grep`, `sed`, `python3`, `bash`.
- One supplementary measurement (a synthetic fleet-root copy of the BASE tree, for a
  lane-shaped BASE reading of the citation gate) was still running when I deleted the
  scratch tree at hand-off, so it produced no verdict and **nothing cited depends on it**;
  the gate readings I cite are two completed runs on the live tree (unresolved=14, exit 1)
  and the committed r58 baseline in `.ufo/waves/round-58/final/gates.txt` (unresolved=15).
  This is recorded in §6.1 of the seat receipt.
- No lane tracked file, fleet-root file or sibling lane was written. My only writes are
  this report and `.ufo/waves/round-59/build/R59ScoutRouted/routed-facts.md`; scratch under
  `/fast/scratch/hyaku/kagi-r59/R59ScoutRouted/` was removed at hand-off.

SEAT-STATUS: complete
