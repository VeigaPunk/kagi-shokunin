# R62ExecC1Grammar — executor report (round 62, wave w1)

Target: harden `plans/round-61-c1-check.py` so the five frozen bypass fixtures
(B3..B7) read unresolved while the unmodified tree still reads `value=0`.

## Files changed

- `plans/round-61-c1-check.py` — in place, 1454 → 1710 lines.
  sha256 `f2afd9b8f5382cdf8b8914546bb8fcb73d135854e6e546c5012fb7df63eca9c0`.
  Receipt: `.ufo/waves/round-62/build/R62ExecC1Grammar/grammar.md`.

No other lane file touched; no VCS mutation performed by this seat.

## Behavior implemented (plan §C1 five rules + Amendment A1)

- **I3** — `_asserted_withdrawn(section)`: an occurrence of `withdrawn` whose
  12-token window (`ANCHOR_WINDOW`) contains the `A3 item 2` sequence
  (`_seq_in_window`) and whose 5-token window (`NEG_WINDOW`, truncated at the
  nearest `.`, `;` or `:`) carries no negator.
- **I4/I5** — `three` / `rewritten in place` must occur with no negator in the
  same truncated 5-token window before the match (`_negated_before`).
- **I6** — (a) launch line, (b) ≥3 `-03:00` stamps in the derived committer set,
  (c) ≥1 `HH:MM:SS` neither the launch time nor a derived committer time
  (`_qualifying_times`/`_valid_hms`), and (d) **Amendment A1**: the line carries
  none of `times are correct`, `times are right`, `is correct`, `are correct`
  (case-insensitive).
- **I7** — the derived fraction/percentage must be paired in one expression
  (`_pair_re`, whitespace-tolerant) **in the asserting position**: `"..."` spans
  are stripped first, because the line quotes the superseded `4/16 = 25 %`
  arithmetic — a pairing test over the raw line would read the forgery quote as
  a correct assertion (QM79).
- Negator set: `not no never neither nor without none` token-exact + `n't`
  suffix (case-insensitive); `not only` immediately before the match is an idiom.
- Output line shape `C1_ROUTED: value=V population=7 i1=.. i7=.. guard=G`, all
  modes (`--root/--repo/--no-challenge/--selftest/--json`) and all pre-existing
  selftest cases unchanged. Selftest PASS line now prints the frozen predicate's
  spelling `C1_CHECK_SELFTEST: PASS (cases=N)`.

## Evidence (all in grammar.md)

- `python3 -I -B plans/round-61-c1-check.py --selftest` →
  `C1_CHECK_SELFTEST: PASS (cases=75)`, rc 0 (75 ≥ 57; +23 cases: B3..B7,
  B6 whole-line variant, I6 benign conclusion, P3..P5 item + full-tree, K5
  needle-unique + negator-removed witness, 7 grammar unit cases).
- BASE census re-measured pre-change with the round-61 bytes: base + B3..B7 +
  P3..P5 all read `value=0` rc 1 (accepted=5 witness, plan §C1 census).
- Hardened battery (`--no-challenge`, `--repo` = lane): base `value=0`;
  B3→`value=1 i3=0`; B4→`value=1 i4=0`; B5→`value=1 i5=0`; B6→`value=1 i6=0`;
  B7→`value=1 i7=0`; P3/P4/P5→`value=0`. Each bypass copy fails exactly its own
  item; every other item reads 1.
- Guard-mode on the unmodified copy: `value=0 … guard=1` rc 0 — challenge
  `deletions 1->2` reads `value=1 expect=1`, stub refused (`fails=True`). The
  round-61 gate behavior is intact.
- I6 readings: real line `superseded-stamp=15:09:28,16:34:37 denial=none` HOLD;
  B6 `denial=are correct|times are correct` FAIL; reviewer whole-line variant
  `i6=0 value=1`.

## Risks / named ceilings

- The window is a floor, not a parser (plan ceiling): a forger asserting with
  no negator still passes; the grammar narrows QM79, never closes it.
- Clause (d) is substring matching on the correction line: a future correction
  legitimately containing "is correct"/"are correct" would fail I6 — flagged for
  the L1 (Amendment A1 is frozen text; implemented as written).
- I7 quote-stripping uses `"..."` spans only; a correction quoting the forgery in
  single quotes would still feed the pairing test — consistent with the plan's
  asserting-position reading on the committed fixtures.
- `n't` matching is ASCII-apostrophe only; typographic `n’t` is not a negator
  (floor).

## Defect reported and resolved in-round

B6 could not flip I6 under the §C1 clauses (a)–(c): the fixture's replacement
bytes carry no timestamp, and both qualifying times (`15:09:28`, `16:34:37`)
survive byte-for-byte. Reported to L1 KagiR62 and peers; L1 appended
`plans/round-62.md` §Amendment A1 (clause d, denial phrases) before any candidate
reading. Implemented verbatim; B6 now reads `value=1 i6=0`.

No tools installed this round (pure-Python change; no installs needed).
Scratch `${HYAKU_SCRATCH}/kagi-r62/R62ExecC1Grammar/` holds only fixture copies and
receipts staging — deleted before yield; citable evidence lives in grammar.md.

SEAT-STATUS: complete
