# R60ScoutRouted — independent re-derivation of the seven `plans/round-60.md` §C1 numbers

Seat: scout (routed). Lane: kagi-shokunin. BASE `a677c78ece8e3d3b4a43dda55254f2a7b33cc1d2`.
Read-only seat: no lane file edited, no git/jj mutation run, no counter code written.

Full receipt (commands, raw outputs, per-item table, ambiguities A1–A9):
`.ufo/waves/round-60/build/R60ScoutRouted/rederive.md`

## Method

BASE tree materialised read-only into the seat scratch
(`/fast/scratch/hyaku/kagi-r60/R60ScoutRouted/tree` via `git archive a677c78e | tar -x`); every number
re-derived there with the exact command recorded in the receipt. Scratch deleted after the run.

## Result per item

| id | plan's number | re-derived | verdict |
|---|---|---|---|
| I1 | 14 results, 0 empty; `__DEAD__` at `LOG.md:1965` | 14 results, 0 empty `output` fields; `__DEAD__` at line 1965 (last of 1965 lines) | agree |
| I2 | 33 cases in the receipt; R31 claims 32 | receipt's only PASS line = `PASS (33 cases)`; R31 (line 206) states `PASS (32 cases)` | agree |
| I3 | duplicates `R20`,`R21`,`R22`, twice each | `2 R20`, `2 R21`, `2 R22`; 34 id rows, 31 distinct ids, max occurrence 2 | agree |
| I4 | 20 `CONTROL ` lines; `(21 controls;` at `SCORECARD.md:1971` | 20 (4 K + 8 C1-F + 8 C2-F, one each); literal `(21 controls;` on line 1971 | agree |
| I5 | round-59 `final/` = six files, no release-clock/DOC_AUDIT/SCOPE receipt | six files exactly, `release-clock-candidate.txt` absent | agree on the count; **one wrong number: the plan cites `SCORECARD.md:1976`, the citation is on line 1975** (1976 is the `adjacency` row) |
| I6 | `160caf750dcf15892b78ec066e66bc605ba57a5c` | same 40-hex hash on the `c1-driver: measured=revision` line of `.ufo/waves/round-59/final/c1-landed.txt` | agree on the hash |
| I7 | `SKILL.md:847`; selftest cell `none — its own five shims …`; `--selftest` absent at BASE | row at 847, cell verbatim `none — its own five shims and the clean-room leg are the falsifiers, run by \`plans/round-59-c2.sh\``; `bash corpus/openbao-transit-trial.sh --selftest` → usage line, **rc=2** | agree |

Plan BASE: **correct** — hash, subject (`round-59 verifier spot-check (integrator, hyaku): non-author admit/reject`)
and committer date `2026-11-07T15:00:52-03:00` all re-derive; `cd631737` sits directly on top; ancestry holds.

## Defects found in the plan (reported, not amended)

1. **I5 cites the wrong line.** `SCORECARD.md:1976` should be `SCORECARD.md:1975`. (The spot-check lesson itself
   says 1975.) Every other line citation in the plan is right — `LOG.md:1965`, `SCORECARD.md:1971`,
   `SKILL.md:847` — note the spot-check lesson said `SKILL.md:846` and the plan's 847 is the correct one.
2. **I1 guard vs item field name mismatch.** The item requires `results=<R> dead=<D>`; the guard mutates
   "`dead seats=<n>`", a literal that never appears in the required format. The challenge leg has no defined
   mutation target.
3. **I1 "empty/absent final output" is not keyed.** Each result has `output` (non-empty ×14) and `note` (null ×14);
   the plan's D=0 holds only for `output`.
4. **I6 has no anchor.** `SCORECARD.md` and `LOG.md` contain **zero** occurrences of `75165a07` at BASE. The line
   naming it as the measured commit is the fleet report `.ufo/reports/round-59/kagi.md:102-103`, outside the lane's
   write scope; the only lane occurrence is `corpus/lessons/round-59-verifier-spotcheck.md:188`.
5. **I5's `never written` contradicts its own existence clause** (the same line must both name three existing
   round-60 receipts and state `never written`); a bytes-only checker cannot resolve which set it qualifies.
6. **I3's `R[0-9]+` is unanchored and uncommanded.** Whole-table, it matches the `R59` inside seat names
   (`R59RevContext`, …): 26 hits. "max occurrence = 1" holds only if the checker restricts to the id column, and
   the plan states no extraction command (unlike I4).
7. **§A2 composition gap:** of the six listed write sets, none owns **I3, I5 or I6**. I3 needs a new
   `corpus/lessons/round-60.md`; I5 needs three receipt files under `.ufo/waves/round-60/final/` (none listed in the
   plan's "Instruments created by this round"); I6 needs a SCORECARD line. Under the plan's own K1/K2, items no
   seat writes stay unresolved, so the C1 target of 0 is unreachable as the wave is currently composed.
8. **I7's `N >= 6` is a bare threshold** with no derivation command, unlike the other six items.

## BASE-census cross-check

All seven conditions are unresolved at BASE by byte-level reading (no `## Round 59 — correction` block in LOG.md;
no `supersedes R31`; no `corpus/lessons/round-60.md`; no `supersedes SCORECARD.md:1971`; no
`supersedes the round-59 gate-evidence pointer` and no `round-60/final` citation in SCORECARD.md; no `c1-landed`
in SCORECARD.md; transit trial has no `--selftest` and the SKILL row's selftest cell has none), so the plan's
declared `value=7 population=7` is consistent with the tree. The checker itself does not exist at BASE, so this is
a byte-level reading, not an executed checker.

## Tooling

No tool installed or upgraded this seat (nothing to record under `/home/vgpnk/.omp/agent/RULES.md`, read at seat
start). Read-only git (`show`/`log`/`merge-base`/`cat-file`/`archive`) plus `bash`/`awk`/`grep`/`sed`/`python3`
inside the seat scratch copy.

SEAT-STATUS: complete
