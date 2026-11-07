# R60ReviewerC1 — attack findings: the C1 item set and its checker

Seat: R60ReviewerC1 (reviewer/attack, leaf, no dispatch). Round 60 attempt 1, lane
`kagi-shokunin`. Claim BASE `a677c78ece8e3d3b4a43dda55254f2a7b33cc1d2`. Frozen plan
`plans/round-60.md` (predeclaration `cd631737`, §A1/A2 seat-count only, §A3 C2 only).
Read-only on the lane: nothing below edits, commits or stages anything; every probe runs on
a copy under `/fast/scratch/hyaku/kagi-r60/R60ReviewerC1/` (deleted before the seat yields).

## Method

Two instruments, deliberately separate:

1. **`refcheck.py`** — an independent reference implementation of §C1's seven item
   conditions, written from the frozen item text before the lane's checker landed. It
   exists so a reading can be attributed: if the reference and the lane checker agree, the
   behaviour is the *plan's*; if they differ, it is the *checker's*.
2. **`plans/round-60-c1-check.py`** as landed. The table below was measured on
   `63ef4304d720…` (50740 B); the checker was then amended under §A5 (`b662e11`) and the
   attacks were re-measured on the amended bytes, pinned at
   `268b27cb707a…` (58615 B). See **§A5 re-measurement** for the post-amendment readings;
   the table records the state that produced each finding, and the §A5 table says which
   are now closed. An earlier revision (`9eb98716…`, 49776 B) was measured first and reads
   identically to `63ef4304` except for the symlink write-through (fixed in `63ef4304`).

Fixtures: `mkfix.py` builds a *token-satisfying* tree (each item's literal satisfied with
the least possible content); `mkvariants.py` derives 28 attack variants from it. Both are
committed to this seat's build dir with `refcheck.py`, so every row below is reproducible.

Instrument pins at measurement time: checker `9eb98716688d…`, driver
`c11da5c60db536c9…`, C2 counter `a6fc9825972a20e8…`, transit trial `bb18fba0df33bf42…`,
controls battery `9f9ef289040c709e…` (the battery and trial were still being edited during
the run; see R60C1-11).

The lane working tree was being edited by sibling seats throughout. Two snapshots are
cited by content hash: `wt-1518` (LOG.md `9e34fa4f…`, SCORECARD.md `86fb11aa…`) and
`wt-1540` (LOG.md `c791a782…`, SCORECARD.md `1d06c739…`, SKILL.md `152f3324…`).

## Result table

Verdict is about the **instrument's reading on that tree**: `PASS` = the reading matches
the plan's condition; `FAIL` = the reading is wrong, with the direction named (FP = the
instrument reads resolved on a tree that is still wrong; FN = it reads unresolved on a tree
that satisfies the condition). "Ceiling" rows are declared by the plan's §C1 named
ceilings and are recorded as such, not as defects.

| # | probe | command (root = fixture tree) | observed | expected | verdict | severity |
|---|---|---|---|---|---|---|
| 1 | BASE census (K2) | `python3 -I -B plans/round-60-c1-check.py --root <BASE> --repo <lane> --no-challenge` | `value=7 population=7 i1..i7=0 guard=0` | 7 | PASS | — |
| 2 | positive reference (single-line corrections, manufactured I6 anchor) | same, `--root trees/fix2` (full) | `value=0 … guard=1`, rc 0 | 0 guard=1 | PASS | — |
| 3 | I6 anchor premise | `grep -c 75165a07 SCORECARD.md`; `git show a677c78:SCORECARD.md \| grep -c 75165a07` | `0` and `0`; lane-wide the hash is only in `corpus/lessons/round-59-verifier-spotcheck.md` and `plans/round-60.md` (fleet report has 4) | a SCORECARD line containing it | FAIL (plan text: premise false) | high |
| 4 | I6 satisfied by an unrelated anchor | `--root trees/v_anchor` (full) | `value=0 … i6=1 guard=1`, rc 0 | the correction supersedes the false `75165a07` citation | FAIL (FP) | high |
| 5 | I1 right token, wrong fact | `--root trees/v_wrongfact --no-challenge` | `i1=1`; block also says `` `dead seats=14`; every seat died`` | block census true | FAIL (FP; named ceiling) | medium |
| 6 | I2 right token, wrong fact | `--root trees/v_wrongfact2 --no-challenge` | `i2=1`; line also says "the checker actually runs 12 cases" | statement true | FAIL (FP; ceiling) | medium |
| 7 | I4 right token, wrong fact | `--root trees/v_wrongfact4 --no-challenge` | `i4=1`; line says "holds 21 controls, not 20; the receipt holds 20 controls" | one true count | FAIL (FP; ceiling) | medium |
| 8 | I3 vacuous ids + negation | `--root trees/v_i3vacuous --no-challenge` | `i3=1`; rows are `R20/-`, `R21/-`, `R22/-` and the sentence is "are not duplicates of anything" | ids name dispositions | FAIL (FP; ceiling) | medium |
| 9 | I2 decoy anchor (ordering bypass) | `--root trees/v_decoyR31 --no-challenge` | `i2=1`; decoy `R31` at line 3, correction at line 4, the real `R31` row at line 208 | correction after the superseded line | FAIL (FP) | high |
| 10 | I4 correction quotes the superseded literal | snapshot `wt-1518`, `--no-challenge` | `i4=0` ("no correction after anchor line 1980 (of 2)") | 1 | FAIL (FN) | high |
| 11 | I1 correction quotes `__DEAD__` | `--root trees/v_quoteDEAD --no-challenge`; snapshot `wt-1518` | `i1=0`; snapshot `wt-1518` `i1=0` | 1 | FAIL (FN) | high |
| 12 | I4 in-place rewrite (the better repair) | `--root trees/v_inplace --no-challenge` | `i4=0` ("no `(21 controls` line") | 1 | FAIL (FN) | medium |
| 13 | correction appended twice | `--root trees/v_dup_bad_last`, `v_dup_bad_first` | `i4=0` (bad last) / `i4=1` (bad first) | last-wins | PASS | — |
| 14 | I2 receipt edited to a false statement | `--root trees/v_receipt32 --no-challenge` | `i2=1` (receipt rewritten to `PASS (32 cases)`, correction says 32) | receipt bytes unchanged | PASS as specified (K3 ceiling) | medium |
| 15 | I4 receipt edited | `--root trees/v_ctrl19 --no-challenge` | `i4=1` (receipt loses a `CONTROL ` line, correction says 19) | receipt bytes unchanged | PASS as specified (K3 ceiling) | medium |
| 16 | I6 receipt edited + anchor | `--root trees/v_hash_anchor` (full) | `value=0 … i6=1 guard=1`, rc 0; `c1-landed.txt` now reads `measured=revision deadbeef…` | receipt bytes unchanged | PASS as specified (K3 ceiling) | medium |
| 17 | I5 three one-line stub receipts | `--root trees/fix --no-challenge` | `i5=1`; the three files are `RELEASE_CLOCK: CLEAN`, `DOC_AUDIT: CLEAN`, `SCOPE: NOT RUN — stub` | a gate receipt with content | FAIL (FP) | high |
| 18 | I5 path escape | `--root trees/v_escape2 --no-challenge` | `i5=0` (containment enforced) | 0 | PASS | — |
| 19 | I7 `--selftest` that asserts nothing | `--root trees/fix --no-challenge`; `--root trees/v_i7broken` (full) | `i7=1`; the stub prints `TRANSIT_SELFTEST: PASS (cases=6)` and exits 0; with the trial's summary mapping mutated to `BROKEN` it still prints PASS rc 0 and `i7=1`, `guard=1` | K4: a broken mapping must make `--selftest` exit non-zero | FAIL (FP; K4 violated) | high |
| 20 | I7 with the real mapping mutated | `bash mapB.sh --selftest` (5 shim lines `[ "$SHIM" = SHn ] && x=0` → `true`) | `FINDING TRANSIT-ST-SHIM-SH1..SH5 …`; `TRANSIT_SELFTEST: FAIL (cases=9 failed=15)`, rc 1 | FAIL with named ids | PASS | — |
| 21 | controls C1-F6 mutation target | the battery's own python mutation, run verbatim | first `HOLDS` after the first line matching `selftest` is a **comment** (`# ST-BASELINE honest stub: six legs BROKEN, holds=5 -> exit 0`); the mutated copy prints `TRANSIT_SELFTEST: PASS (cases=9)` rc 0 | rc≠0 + `FAIL` + finding id | FAIL (control) | high |
| 22 | controls C1-F7 vs the checker's I1 | fixed tree, flip `dead seats=0`→1 (the control's exact delta) | on `trees/fix2`: `value=0`, `i1=1` — unchanged, because I1 reads the first `dead=` on the line (`results=14 dead=0 dead seats=0`); on the battery's own `k1ref`: `value=1` before and after | `value=1` | FAIL (control) | high |
| 23 | controls K1-REF positive reference | `build_fixed_tree k1ref` from the battery's functions, then the checker (full) | first run (15:26): `value=1 … i3=0 guard=1` — its I3 sentence was wrapped over three lines; the controls owner fixed it, re-measured on the current battery: `0 guard=1` MATCH | `0 guard=1` | PASS (fixed during the seat) | — |
| 24 | controls C1-F2 | battery run | first run `expect=1 observed=2` (cascade of #23); current battery `expect=1 observed=1` MATCH | 1 | PASS (fixed during the seat) | — |
| 25 | I1 last-occurrence-wins inside the block | `--root trees/v_i1_lastwrong` (full) | `value=0 … i1=1 guard=1`, rc 0, while the block's LAST census line says `results=15 dead=1 dead seats=1`; the checker takes the FIRST matching line in the block (`results-line=match` on the correct one) | the last statement wins (the plan's convention) | FAIL (FP) | high |
| 26 | controls C1-F1 (same defect) | battery run | `expect=1 observed=0` MISMATCH — the appended wrong restatement does not break I1 | 1 | FAIL (control, and it is right to fail: the checker is wrong) | high |
| 27 | population with a missing item file | `--root trees/v_noscorecard` (full) | `value=3 population=7 i4=0 i5=0 i6=0`; challenge copy `4`, `guard=1` | no skip, population 7 | PASS | — |
| 28 | missing derivation source | `--root trees/v_missingresults --no-challenge` | `i1=0` | 0 | PASS | — |
| 29 | guard on a nonzero tree | `--root trees/v_two_unresolved` (full) | `value=3`; copy `4`; `expect=4`; stub fails; `guard=1` | value+1 | PASS | — |
| 30 | guard on the positive reference | `--root trees/fix2` (full) | `value=0`; copy `1`; stub `0` fails; `guard=1`, rc 0 | value+1 | PASS | — |
| 31 | symlinked `LOG.md` | `--root trees/v_symlink_anchor` (full) | `value=0 … guard=1`, rc 0, with `LOG.md` a symlink to a file outside the tree; on the final checker the challenge no longer writes through it (outside file sha256 unchanged `2a46d155…`; the write-through was fixed in `63ef4304` with `copytree symlinks=False`) | the tree's own bytes carry the correction | FAIL (FP; write-through fixed) | medium-high |
| 32 | I1 numbers outside the block | `--root trees/v_i1loose --no-challenge` | `i1=0` | 0 | PASS | — |
| 33 | I3 id in a condition cell | `--root trees/v_i3cond --no-challenge` | `i3=1` (id column only) | 1 | PASS | — |
| 34 | C2 K3 secret scan, bare value | the counter's scan regex over sample lines | `hvs.` and `secret_id=<uuid>` match; `sid=<uuid>` and a bare UUID in prose do **not** | a `secret_id` value is caught | FAIL (C2 instrument) | medium-high |
| 35 | C2 selftest conjunct | static read of `plans/round-60-c2.sh` (selftest leg) | a stub printing `APPROLE_SELFTEST: PASS (cases=8)` satisfies the conjunct; K5's "must be able to fail" is only C2-F3 (removing `--selftest`) | the selftest must be able to fail | FAIL (C2 instrument) | medium |
| 36 | I1 after-the-superseded-line rule | `--root trees/v_i1_before --no-challenge` (block moved before the `__DEAD__` line) | `i1=0` ("no '## Round 59 — correction' block after the last `__DEAD__` line") | 0 | PASS | — |
| 37 | I6 after-the-superseded-line rule | `--root trees/v_i6_before --no-challenge` (correction moved before the anchor) | `i6=0` ("candidates=0 last-line=missing-or-wrong-rev") | 0 | PASS | — |

## Findings, in severity order

### R60C1-1 (high) — I6's anchor does not exist at BASE; the item is satisfied by an unrelated line

The plan's I6 requires "`SCORECARD.md` carries, after the round-59 line containing
`75165a07`, a line naming `c1-landed.txt` …". Measured: `git show a677c78:SCORECARD.md |
grep -c 75165a07` ⇒ `0`; the lane-wide occurrences are `corpus/lessons/round-59-verifier-spotcheck.md`
(4) and `plans/round-60.md` (2); the fleet report `.ufo/reports/round-59/kagi.md` has 4.
So the sentence names a line that does not exist on the file it names. The checker's
handling (no anchor ⇒ `i6=0`, never vacuous) is the only non-vacuous reading and is
correct — but the plan's premise is false, and the item is then satisfiable by *adding* an
anchor line that supersedes nothing. `trees/v_anchor` does exactly that and reads
`value=0 … i6=1 guard=1`, exit 0, while the D6 defect (the report's Before → after table
naming `75165a07` as the measured commit) is untouched. The controls battery's own fixed
tree (K1-REF) manufactures the same anchor with a line asserting that SCORECARD's table
named `75165a07` — which SCORECARD never did.

### R60C1-2 (high) — I2's ordering rule is bypassed by a decoy `R31` line

I2 anchors on the **first** line containing `R31`. Inserting one line ("See R31 below for
the selftest count.") before the real R31 row moves the anchor, and the correction then
sits ~200 lines *before* the sentence it claims to supersede and still reads `i2=1`
(`trees/v_decoyR31`; decoy line 3, correction line 4, real row line 208). C1-F8 tests the
naive "correction before the anchor" case for I1 only; the decoy class is untested for I2
(and I4's anchor is the *last* match, which is safe only by accident of the checker's
choice, not by the plan's wording).

The rule does bite where the anchor cannot be moved: a block placed before the `__DEAD__`
line reads `i1=0` (`trees/v_i1_before`), a correction before the I6 anchor reads `i6=0`
(`trees/v_i6_before`), and a bad duplicate I4 correction appended last reads `i4=0`
(`trees/v_dup_bad_last`). I2 is the one item whose anchor a seat can relocate.

### R60C1-3 (high) — quoting the superseded literal makes the correction self-defeating

Both I1 and I4 anchor on the *last* occurrence of the string they correct. A correction
that quotes it (the natural way to write a correction) becomes its own anchor and nothing
follows it. Measured on the round's own in-flight repairs: `wt-1518` reads `i1=0` (the
block quoted `` `dead seats __DEAD__` ``) and `i4=0` (the line quoted `"(21 controls; …)"`).
`trees/v_quoteDEAD` reproduces the I1 half. The same trap hits I6: a correction line that
contains `75165a07` becomes the anchor (the checker's docstring warns about this).

### R60C1-4 (high) — I5 is satisfied by three one-line stub receipts

I5 reads only the *prefix* of each named file's last non-empty line. Three files of one
line each (`RELEASE_CLOCK: CLEAN`, `DOC_AUDIT: CLEAN`, `SCOPE: NOT RUN — stub`) read
`i5=1`. This is the D5 defect class ("dead gate-evidence pointer") recurring as an *empty*
pointer: the item cannot tell a gate receipt from a stub, and the round's own positive
reference (K1-REF) uses exactly this shape. Path containment, by contrast, is enforced
(`trees/v_escape2` reads `i5=0`).

### R60C1-5 (high) — I7 cannot distinguish a real `--selftest` from a PASS printer, and K4 is violated

I7's condition is "exits 0 and prints `TRANSIT_SELFTEST: PASS (cases=N)` with N >= 6". A
six-line stub that prints `PASS (cases=6)` and exits 0 reads `i7=1` (`trees/fix`). With the
trial's own summary mapping mutated to `BROKEN` the stub still prints PASS and the checker
still reads `i7=1 guard=1` (`trees/v_i7broken`) — the plan's K4 ("a copy of the trial whose
verdict mapping is broken must make `--selftest` exit non-zero with a named finding id") is
violated by the item's own reading. The landed trial's *real* selftest is strong: mutating
the five shim-mapping lines makes it print `FINDING TRANSIT-ST-SHIM-SH1..SH5 …` and
`TRANSIT_SELFTEST: FAIL (cases=9 failed=15)` rc 1. The gap is that nothing in the item
distinguishes the two.

### R60C1-6 (high) — the controls battery: one live mismatch that is the checker's fault, and two controls that cannot fire

Measured across two battery runs (`plans/round-60-controls.sh` sha256 `9f9ef289…` then
`d2a85b3b…`, checker `9eb98716…` then `63ef4304…`):

- **K1-REF and C1-F2 were mismatched and are now fixed.** The first run read
  `K1-REF expect=0 guard=1 observed=1 guard=1` and `C1-F2 expect=1 observed=2`; cause was
  the fixed tree's I3 duplicate sentence wrapped over three lines (the round-59 M59-1
  class). The controls owner fixed it; the second run reads `K1-REF … observed=0 guard=1
  MATCH` and `C1-F2 … observed=1 MATCH`. Recorded because the wrapped-line class is exactly
  what the round-60 lesson must not repeat.
- **C1-F1 mismatch, and it is the checker that is wrong.** `expect=1 observed=0`: the
  fixture appends a wrong restatement (`results=15 dead=1`) after the correct one, and the
  checker still holds I1 because it takes the **first** matching line inside the block
  (see R60C1-12). The control is doing its job; the item is not.
- **C1-F7 mismatch.** F7 flips `dead seats=0`→1 and expects the diagnostic to move 0→1.
  The checker's I1 regex `results=(\d+)(\s+)(dead(?:\s+seats)?=)(\d+)` matches the *first*
  `dead=` on the line, so on the fixed tree's `results=14 dead=0 dead seats=0` the flip
  changes nothing: `trees/fix2` reads `value=0`, `i1=1` before and after; the battery's own
  `k1ref` reads `value=1` before and after. The checker's own challenge mutates the `dead=`
  match, which is why the guard still works; the control's delta is the wrong one.
- **C1-F6 mutation target.** The mutation finds the first `HOLDS` after the first line
  matching `selftest` — a comment (`# ST-BASELINE honest stub: six legs BROKEN, …`). The
  mutated copy prints `TRANSIT_SELFTEST: PASS (cases=9)` rc 0, so the control can never
  read `FAIL-with-id`. Mutating the five `[ "$SHIM" = SHn ] && x=0` lines instead does
  produce `FINDING TRANSIT-ST-SHIM-SH1..SH5` and `FAIL (cases=9 failed=15)` rc 1.

Both battery runs also aborted mid-file with a shell syntax error (`line 567`, then
`line 578`) while the script was being edited; `bash -n` on the current bytes is clean, so
those were concurrent edits, not defects. The battery must be run against frozen bytes —
the L1's receipt should pin the script hash it ran.

### R60C1-7 (medium-high) — a symlinked `LOG.md` passes

`trees/v_symlink_anchor` has `LOG.md` as a symlink to a file outside the tree; it reads
`value=0 … guard=1`, exit 0, on the final checker. The write-through half was fixed during
the seat: `9eb98716` used `copytree(symlinks=True)` and the challenge wrote through the
link (outside file sha256 `2a46d155…` → `fd0d98b1…`, `dead=1` present); `63ef4304` uses
`symlinks=False` and the outside file is unchanged after the run (verified). What remains
is the item reading: the measured tree's own bytes do not carry the correction, and
`rd()` follows the link, so a tree that is still wrong reads resolved.

### R60C1-8 (medium) — token-satisfying statements with the wrong fact (named ceiling)

I1, I2, I4 and I3 each read a token and a number, not the sentence around it: a block that
says `results=14 dead=0` and `` `dead seats=14` `` reads `i1=1`; a line that says
`PASS (33 cases)` and "the checker actually runs 12 cases" reads `i2=1`; a line that says
"holds 21 controls, not 20; the receipt holds 20 controls" reads `i4=1`; a table of
`R20/-`, `R21/-`, `R22/-` plus "are not duplicates of anything" reads `i3=1`. This is the
plan's declared ceiling ("an item's condition is a structural read, not a semantic proof
that the corrected text is true"), recorded so the ceiling is not later claimed as
coverage. The I4 case also shows the count is a *contains* test, so a line with two
counts passes on either.

### R60C1-9 (medium) — receipt edits make a false statement "right" (declared K3 ceiling)

I2, I4 and I6 derive their compared number from a receipt the same round can edit:
rewriting `selftest.txt` to `PASS (32 cases)` makes a 32-case correction read `i2=1`;
deleting one `CONTROL ` line makes 19 read `i4=1`; rewriting `c1-landed.txt` to
`measured=revision deadbeef…` plus an anchor makes `i6=1` and the whole tree read
`value=0 guard=1`, exit 0 (`trees/v_hash_anchor`). The plan's named ceiling covers this
("the checker trusts the receipt files it reads (fabrication class K3)"), so it is not a
defect — but the non-author re-run must therefore diff those three receipts against BASE
bytes, because the counter cannot.

### R60C1-10 (medium) — in-place repair reads unresolved

Rewriting `(21 controls` to `(20 controls` in place destroys the anchor, so the better
repair reads `i4=0` (`trees/v_inplace`). The append-only convention makes this "expected",
but the item's reading cannot distinguish "the defect is fixed" from "the defect is
present" once the anchor is gone; only an appended correction passes.

### R60C1-11 (medium) — the C2 instrument's secret scan is label-keyed

The C2 counter's K3 scan is
`(^|[^A-Za-z0-9])(hvs|hvb)\.[A-Za-z0-9]|secret_?id["':= ]+<uuid>`. It catches `hvs.` and
`secret_id=<uuid>` / `"secret_id":"<uuid>"`, and misses `sid=<uuid>` and a bare UUID in
prose. K3 says no `secret_id` value may appear in any printed line; a trial that prints the
value without the label escapes the only enforcement of that rule. The C2 selftest
conjunct is likewise satisfied by a PASS stub (K5's "must be able to fail" is only
C2-F3, which removes `--selftest`).

### R60C1-12 (high) — I1 does not implement "last occurrence wins" inside its block

The plan's correction convention is "a correction is appended, never rewritten into the
line it corrects" and "last occurrence wins". I2, I4 and I6 implement it; I1 does not: its
item loop takes the **first** line in the block that matches `results=<R> dead=<D>` with
the derived numbers. `trees/v_i1_lastwrong` appends a later, wrong restatement
(`results=15 dead=1 dead seats=1`) after the correct one and reads `value=0 … i1=1 guard=1`,
exit 0 — the record's last statement is false and the item says resolved. The controls
battery sees the same thing from the other side: `C1-F1 expect=1 observed=0`. The fix is
one line (select the last matching line, as I2/I4/I6 do); until then I1 cannot be trusted
against a later restatement, which is exactly the shape a "revised" correction takes.

## §A5 re-measurement — what the amendments closed, on the amended bytes

The L1 landed §A5 (`b662e11`, "six attack-seat item defects amended before the candidate
reading") while this seat was running. I re-measured the attacks against the amended
checker, pinned at sha256 `268b27cb707a…` (58615 B), and built fixtures to the amended
conditions (`trees/fix3` and its variants; reproducible with `mkA5.py` in this directory —
`git archive BASE`, overlay `corpus/openbao-transit-trial.sh` and `SKILL.md` from the
round-60 tree, then `python3 mkA5.py <tree> [variant]`):

| attack | before A5 | after A5 (checker `268b27cb…`) | status |
|---|---|---|---|
| I1 last statement in the block wins (`v_i1_lastwrong`) | `i1=1` (FP) | `i1=0` | **closed** |
| I2 decoy `R31` line (`v_decoyR31`) | `i2=1` (FP) | `i2=0` | **closed** |
| I5 three one-line stub receipts (`fix`, `v_i5stub3`) | `i5=1` (FP) | `i5=0` | **closed** |
| I6 manufactured `75165a07` anchor (`v_anchor`) | `value=0` rc 0 | `i6=0` | **closed** (the item now anchors on `supersedes the round-59 measured-commit citation`) |
| I7 PASS-printer selftest (`v_i7broken`, `v_i7stub3`) | `i7=1` (K4 violated) | `i7=0` | **closed** (leg C mutates the trial and requires `FINDING TRANSIT-ST-`) |
| symlinked `LOG.md` (`v_symlink_anchor`, `v_symlink3`) | `value=0` rc 0 | `C1_ROUTED: SETUP LOG.md is a symlink (refused)`, rc 2 | **closed** |
| positive reference on the amended conditions (`fix3`) | — | `value=0 population=7 i1..i7=1` | satisfiable |
| I6 receipt edit + new literal (`v_hash3`) | (K3 ceiling) | `value=0 … i6=1` | **still open — declared K3 ceiling** |
| token-satisfying wrong facts (`v_wrongfact`, `v_wrongfact2`, `v_wrongfact4`, `v_i3vacuous`) | FP | FP | **still open — declared ceiling (structural read)** |
| quoting the superseded literal / in-place rewrite (`v_quoteDEAD`, `v_inplace`) | FN | FN | **still open — the append-only convention** |

So six of the twelve findings in this file are closed by §A5 and re-verified; the rest are
the plan's declared ceilings (structural read, K3) or consequences of the append-only
convention, recorded so they are not later claimed as coverage. The amended item set is
satisfiable: `fix3` reads `value=0` on the amended checker.

## What the instruments got right (recorded so the positives are not lost)

- The BASE census is exactly 7 (`value=7 population=7`), so no item is vacuous at BASE (K2).
- The guard challenge is faithful: `value+1` on a zero tree, on a three-unresolved tree,
  and on the positive reference; the constant-0 stub fails it; a missing item file leaves
  the item unresolved with population still 7 (no silent skip).
- The checker's I5 path containment, I1 block geometry (numbers in a later `## ` section do
  not count), last-wins duplicate handling, and the I3 id-column reading all match the
  frozen text.
- The landed transit trial's real `--selftest` catches a broken shim mapping with named
  finding ids (K4 holds for the trial, not for the item).

## Residual risk and verification gaps

- The lane tree was moving during the whole seat. The table is pinned to `63ef4304…` and
  the §A5 re-measurement to `268b27cb…`; if the checker moves again, re-run both before
  citing them.
- §A5 closed six of the twelve findings and I re-verified each on the amended bytes. What
  remains is the plan's declared ceiling surface: token-satisfying wrong facts (I1/I2/I4/
  I3), receipt edits (I2/I4/I6, K3), and the false negatives caused by the append-only
  convention (quoting the superseded literal, in-place rewrite). Those are not defects
  under the plan, but they are the reason the non-author re-run must diff the receipts and
  read the corrected sentences, not only the counter line.
- The controls battery must read `CONTROLS: match=N mismatch=0` before any candidate is
  measured. On the bytes measured here the live mismatch is C1-F1 (the pre-A5 checker's
  I1 first-match); C1-F7 and C1-F6 cannot fire. §A5 says the battery fixtures are restated
  to the amended conditions — re-run it against frozen bytes and pin the script hash.
- I did not run the C2 real legs; the two C2 rows are static readings of the counter.

SEAT-STATUS: complete
