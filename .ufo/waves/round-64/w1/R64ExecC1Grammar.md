# R64ExecC1Grammar — C1 grammar hardening (round 64 attempt 2)

Seat: executor (calibration, C1). Lane `kagi-shokunin`, claim BASE
`09cbee831d57be7c4edfbe77bf238f46bf729047`, frozen plan `plans/round-64.md` §C1 as
amended (commit `dff0929`, Amendment A1). Leaf seat: no subagents, no commits, no
mutating git/jj anywhere.

**Sealed file disclosure: `plans/round-64-heldout.tsv` was NOT read by this seat.** The
hardening is built from the six shape classes named in plan §C1 Amendment A1 and
`.ufo/waves/round-64/base/census-a1.md` (which name classes, not fixture strings). No
command run by this seat opens the sealed file; its sha is not re-derived here.

## Files

| path | sha256 | lines |
|---|---|---|
| `plans/round-61-c1-check.py` (hardened) | `07bdc614f502d53287a3e5f3f0a7414e4831b0ab0b0863775c1c5d600079333c` | 2154 (BASE 2031) |

Receipts: `.ufo/waves/round-64/build/R64ExecC1Grammar/` — `grammar.md` (every command
and output), `probe-final2.log`, `residual-final.log`, `probe.sh`, `mutants/` (the four
mutant copies the detector table names).

## Change

One file, six reachable fixes plus the idiom-class extension, each named by the class it
closes (plan §C1 Amendment A1):

1. **I7 pair assertion** — `_pair_asserted`: every `_pair_re` occurrence must have no
   denial predicate (`DENY_SINGLE`/`DENY_PHRASES`) between its end and the next `.`/`;`.
   Closes "benign pair followed by a sentence-level denial".
2. **I7 every-pair-bound** — `_every_pair_own_subject`: every occurrence of each derived
   fraction/percentage pair must be bound to a subject within `SUBJECT_WINDOW` (8)
   tokens. Closes "duplicate pair appended elsewhere".
3. **I7 subject-negatedness** — `_subject_blocked`: a subject preceded within 5 tokens
   by `different`/`other`/`no`/`not` does not bind. Closes "a different seat than the
   sentinel".
4. **I7 parenthetical masking** — `_mask_asides`: well-formed `( … )` and `— … —`
   asides (≤60 chars, no `.`) are blanked, position-preserving, before the binding test
   and the token count, in addition to double-quoted spans. Closes the
   appositive/parenthetical benign class.
5. **I4 `NO_NEW` assertion** — the `NO_NEW_RECORD_DEFECT_RE` match now passes
   `_asserted`. Closes "quoted claim then denied".
6. **I5 single-mechanism rule** — exactly one `REWITTEN_IN_PLACE_RE` occurrence, and it
   asserted. Closes "duplicated mechanism claim".
7. **Idiom class** — `IDIOMS` gains `("not", "less", "than")`. Closes the benign idiom
   class.

Unchanged: the output line shape, every mode/flag, every frozen item condition, and every
existing selftest case. `item7`'s evidence line still reads
`both-pairs-bound-to-subjects` / `pair-missing-swapped-or-unbound`; `item5`'s
`mechanism=` field now reports `missing` for a duplicated mechanism clause.

## Evidence retained (frozen bytes `07bdc614`)

- `python3 -I -B plans/round-61-c1-check.py --selftest` ⇒
  `C1_CHECK_SELFTEST: PASS (cases=111)`, rc 0 (BASE 102, +9 class cases; ≥109 required).
- Unmodified slim copy ⇒ `C1_ROUTED: value=0 population=7 i1=1 … i7=1 guard=0` (the
  seven round-61 corrections still resolve).
- Five forgery classes (synthetic, one per class) ⇒ `value=1` each, with the expected bit
  at 0: denial-after-pair `i7=0`; duplicate-pair-unbound `i7=0`; negated-subject
  `i7=0`; quoted-claim-denied `i4=0`; duplicated-mechanism `i5=0`.
- Three benign classes ⇒ `value=0` each: parenthetical (14 tokens between subject and
  pair, so it resolves only because the aside is masked), em-dash aside (9 tokens, same
  isolation), idiom `not less than`. A fourth benign control
  (`blocker-window-bounded`) reads `value=0`.
- Round-63 residual tables on the same bytes:
  `C1_RESIDUAL: accepted=0 rejected=0 population=10/6 guard=1
  (real=1 selftest=1 prior=1 para=1 stub=1 chal=1)` rc 0 — no regression on the
  committed ten forgeries / six benign rewrites, the round-62 bypass and paraphrase legs,
  the printer stub or the emptied-negator challenge.
- Mutant check on the frozen bytes (selftest as detector): dropping the paren mask, the
  em-dash mask, the mask call site, or widening the blocker window to 8 tokens each makes
  `--selftest` fail with the named case (`cases=111 failed=1|2`). Copies under
  `build/R64ExecC1Grammar/mutants/`.

## Risks / disclosures

1. **Defect in the assignment wording (reported, not amended):** it specifies the
   subject-blocker window as 3 tokens; the class's own instance has `seat than the`
   between `different` and the subject, so 3 tokens does not close the class (measured:
   the forgery reads `value=0`). Implemented at 5 tokens, matching the L1 mechanism
   reference (`c1-fix-reference.md` §3, "within five tokens") and the measured B4
   reading. The L1 should record the wording defect; no frozen predicate was changed.
2. **Named ceilings (plan's, unchanged):** the lists and windows remain closed floors — a
   fresh per-fixture lookup table still passes every item (the round-63 challenge leg is
   the only vehicle guard and is unchanged); a benign subject genuinely negated while
   still asserting the count (`not only the sentinel`) now reads unresolved; an em-dash
   aside longer than 60 characters or containing a `.` is not masked (the bound exists
   because an unbounded non-greedy form paired a lone dash in the correction line with a
   later aside and broke the binding — measured, recorded in `grammar.md`).
3. **Cross-seat:** the peer mutation seat R64MutC1 reported four coverage gaps on the
   previous bytes (`bdb1bfc0`, cases=110) in the masking family; this seat adopted its
   three fixture suggestions (longer paren/em-dash instances, a blocker-window control)
   before freezing `07bdc614`, and the mutant table above re-measures all four on the
   frozen bytes. Its M11 survivor is equivalent (quotation mask in `_asserted`), as
   reported.
4. No tool was installed, upgraded or reconfigured; no pacman transaction; no host file
   written outside the lane paths this seat owns and its scratch (deleted before yield).

SEAT-STATUS: complete
