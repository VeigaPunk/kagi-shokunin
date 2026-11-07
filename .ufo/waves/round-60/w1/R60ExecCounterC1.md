# R60ExecCounterC1 — C1 instrument (plans/round-60.md §C1, as amended by §A5)

Seat: R60ExecCounterC1 (executor). Lane: kagi-shokunin @ master, claim BASE
`a677c78ece8e3d3b4a43dda55254f2a7b33cc1d2`. §A5 (commit b662e114) amended six item
conditions after the attack seats; §A6 corrected the I5 scope receipt's token prefix to
`ADJACENCY_SCOPE:` (the scope gate's own verdict token). The instrument implements all
of them.

## Files written (my whole write scope)

- `plans/round-60-c1-check.py` — the C1_ROUTED counter (I1–I7, GUARD, 46-case
  `--selftest`, `--json`, `--no-challenge`).
- `plans/round-60-c1.sh` — the driver (`[revision | --tree DIR]`, default BASE).
- `.ufo/waves/round-60/build/R60ExecCounterC1/driver-base-a677c78e.txt` — BASE census,
  both legs, A5-amended instrument.
- `.ufo/waves/round-60/build/R60ExecCounterC1/selftest.txt` —
  `C1_CHECK_SELFTEST: PASS (46 cases)`, rc 0.
- `.ufo/waves/round-60/build/R60ExecCounterC1/checker-notes.md` — per-item derivation
  commands and every structural reading.

Final instrument sha256: checker
`52d4fd5c6660e6a9235ae6cbf7e4e504c245b06cc6aa871fa83df721489fa658`; driver
`c11da5c60db536c97ef3e22c0f2d6ab0704e56b1508ce6e93a65847d0e39d599` (unchanged).

## §A5 implementation map

1. **I1 last statement wins** — inside the evaluated (LAST) `## Round 59 — correction`
   block, the LAST line matching the `results=<R> dead=<D>` shape is the statement; its
   values must equal the derived census (a later wrong restatement breaks the item).
   The GUARD mutates that same evaluated line's dead-seats digit D→D+1, preserving the
   `dead=`/`dead seats=` label.
2. **I2 routed-row anchor** — anchor = LAST line matching `^\| *R31 *\|` (decoy prose
   mentions do not relocate it); statement = LAST `C1_CHECK_SELFTEST` line after the
   anchor, which must still match `supersedes R31` and state the derived count (33).
3. **I5 numeric receipt field** — each named receipt's last non-empty line must carry
   its token prefix AND at least one numeric `key=value` field; one-line stubs fail.
   Symlinked named receipts fail the item. §A6: the scope receipt's prefix is
   `ADJACENCY_SCOPE:` (the scope gate's own verdict token); the key name stays `scope`
   (the file name still contains `scope`).
4. **I6 corrected anchor** — requires a line matching `supersedes the round-59
   measured-commit citation` naming `c1-landed.txt` and stating
   `measured=revision <40hex>` equal to the receipt's own derived value (the
   unsatisfiable `75165a07` anchor is gone).
5. **I7 mutation leg** — third required leg: copy the trial, apply exactly
   `then S=BROKEN; rc=1;` → `then S=BROKEN; rc=0;` (needle must occur exactly once,
   else fail closed), require the copy's `--selftest` to exit non-zero printing ≥1
   `FINDING TRANSIT-ST-` line. A PASS printer has no needle → fails closed.
6. **Symlink refusal** — a tree whose LOG.md, either lesson, SCORECARD.md or one of the
   four read receipts is a symlink is refused with `C1_ROUTED: SETUP <path> is a
   symlink (refused)` rc 2 on every evaluation; item5 additionally fails on a
   symlinked named final receipt. Challenge copy still materialises symlinks
   (`symlinks=False`, R22/M58-3 defence in depth).

## Behavior (unchanged printed contract)

- `python3 -I -B plans/round-60-c1-check.py --root <tree> [--repo <lane>]
  [--no-challenge] [--json]` prints
  `C1_ROUTED: value=V population=7 i1=.. i7=.. guard=G`; exit 0 iff guard=1 and V==0,
  1 otherwise, 2 SETUP. `--no-challenge` prints the diagnostic leg (guard=0).
- Every compared number is derived from the measured tree at run time; missing/empty
  item inputs read UNRESOLVED (fail closed), never a silent 0.
- GUARD: fresh `mkdtemp` honouring `C1_CHALLENGE_PARENT` → `HYAKU_SCRATCH` → `TMPDIR` →
  `/fast/scratch/hyaku`; QM74 refusal is checked in both modes (the I7 mutation leg
  shares the scratch); an unavailable scratch ⇒ guard=0.

## BASE census (measured, both legs — receipt driver-base-a677c78e.txt)

- Diagnostic (`--no-challenge` on the `git archive` of a677c78e):
  `C1_ROUTED: value=7 population=7 i1=0 i2=0 i3=0 i4=0 i5=0 i6=0 i7=0 guard=0`, rc 1.
- Wrapper (`bash plans/round-60-c1.sh a677c78e…`):
  `C1_ROUTED: value=FAIL population=7 … guard=0`, rc 1 (challenge cannot fire at BASE).
- i7 detail at BASE: the BASE trial script rejects `--selftest` (rc 2, no PASS line) and
  carries no mutation needle (needle count 0) — both legs fail closed, never SETUP.

## Structural readings (full list in checker-notes.md)

- I1/I4/I5/I6 evaluate their LAST anchor/candidate (last-occurrence-wins); I2's anchor
  is the LAST `^\| *R31 *\|` routed row; I2/I4 statements are the LAST qualifying lines
  after their anchors.
- **Guard/item literal reconciliation (deviation, stated not silent):** the frozen
  GUARD names the mutated field "`dead seats=<n>`" while I1's condition writes the line
  as `results=<R> dead=<D>`. The checker reads that count tolerantly (`dead=` or
  `dead seats=`) and mutates that digit; numeric comparison unchanged. Coordinated with
  R60ExecFixRecords (their landed `results=14 dead seats=0` resolves I1) and disclosed
  to R60ReviewerC1 and the L1.
- The I7 needle contract (`then S=BROKEN; rc=1;` exactly once, `FINDING TRANSIT-ST-` on
  the mutated copy) is §A5's — the transit-trial seat must land `--selftest` to that
  contract or I7 reads unresolved (fail closed).

## Attack-seat readings (R60ReviewerC1; superseded readings resolved by §A5)

- I2 decoy anchor, I5 one-line stubs, I7 shape-keyed stub: first named as ceilings on
  the pre-A5 instrument; §A5 made all three into enforced item conditions — now
  selftest cases `i2-misplaced-correction-fails`, `i5-stub-receipts-fail`,
  `i7-pass-printer-no-needle`, `i7-mutation-not-detected`.
- Symlink write-through: first fixed with `symlinks=False`, now additionally refused at
  SETUP per §A5 6 (`symlinked-log-refused-setup` case).
- Still a named ceiling: the checker trusts the receipt files it reads (K3) — battery +
  non-author re-run own receipt fabrication.

## Risks / blockers

- None blocking. The I7 legs run the trial selftest twice per evaluation (original +
  mutated copy) and the challenge re-run doubles that; the transit seat's `--selftest`
  must stay fixture-fast or I7's 90 s timeout reads UNRESOLVED (fail closed) — flag if
  the landed selftest exceeds ~60 s.
- Coordination dependency: the C1-F1/F6/F7 battery fixtures are the controls owner's
  (§A5 restates them); my instrument's readings are pinned in checker-notes.md.

SEAT-STATUS: complete
