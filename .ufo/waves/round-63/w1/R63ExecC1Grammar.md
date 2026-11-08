# R63ExecC1Grammar — wave report

Seat: R63ExecC1Grammar (executor). Item: harden
`plans/round-61-c1-check.py` so the ten frozen forgery fixtures read
unresolved and the six frozen benign fixtures read resolved, unmodified tree
still `value=0`.

## Files changed

- `plans/round-61-c1-check.py` — the only file owned. sha256
  `eb08094c627c736ec8a868213d4f8605dea971de73e27d801dcc1b3565ff7db6`,
  2031 lines (was 1710).
- Receipts: `.ufo/waves/round-63/build/R63ExecC1Grammar/grammar.md` (every
  command + output).

## Behavior delivered (plan §C1, frozen)

- Polarity: `_asserted` = quote-mask (spans ending before the token) +
  pre-token negator scan (24-token cap, `.`/`;` boundaries only — `:` no
  longer truncates) with idiom-tail and contrastive-`but` rescues +
  post-token denial-predicate scan (24-token cap).
- I3: `A3 item 2` or `item 2 of A3` in 12-token window + asserted `withdrawn`.
- I4: `three` or digit `3` + asserted. I5: `rewritten in place` /
  `rewritten in-place` + asserted.
- I6: launch line + ≥3 derived committer stamps + denial-phrase exclusion
  kept; new conjunct — quoted superseded span's `HH:MM:SS` set == exactly the
  stamp derived from `{fleet}/.ufo/reports/round-60/kagi.md` §Stale-lane
  (`launch HH:MM:SS`); `--fleet` arg (default `/home/vgpnk/Projects/shokunin`),
  missing/unreadable report → SETUP rc 2.
- I7: `3/16 = 18.75 %` within 8 tokens after `literal reading`, `4/16 = 25 %`
  within 8 tokens after `sentinel` (quotes masked).
- Output shape, modes, all prior selftest cases preserved; +27 cases →
  `C1_CHECK_SELFTEST: PASS (cases=102)`.

## Measured results (all on copies of extracted BASE `0c07aab8`)

- Unmodified BASE tree: `C1_ROUTED: value=0 … guard=0` (--no-challenge) and
  `value=0 … guard=1` rc 0 (full challenge).
- F1–F10: each `value=1` with the designated item FAIL (i3/i4/i5/i7/i6).
- P1–P6: each `value=0`.
- Round-62 guard legs: B3–B7 each `value=1`; P3r–P5r each `value=0`.
- GM5 mutant (stamp conjunct dropped): selftest FAIL, named
  `f9-forgery-unresolved,f10-forgery-unresolved,i6-superseded-stamp-conjunct-isolated`.
- Negator-removal mutant: selftest FAIL, 15 named cases.
- Missing fleet report: `C1_ROUTED: SETUP …` rc 2.

## Evidence

`grammar.md` carries every command and its output; raw per-fixture
`c1:` lines were under scratch `results/` (deleted with scratch).

## Risks / blockers

- None blocking. Note for L1: item6 now raises SetupError when the fleet
  report is absent — `measure()` re-raises SetupError (added
  `except SetupError: raise`), so a tree lacking the I6 correction line but
  evaluated with a bad `--fleet` still exits 2 only if item6 reaches the
  fleet read (it returns FAIL earlier when the lesson/correction line is
  absent — lazy derivation, deliberate).
- R63MutC1's seven mutants are all covered by named selftest cases; their
  "post-token quotation mask" target was removed by construction (single
  mask site in `_asserted`).

SEAT-STATUS: complete
