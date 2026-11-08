# C1 fix reference — L1 mechanism validation (2026-11-08)

NOT the candidate. This file records the L1's own prototype validation of the six
mechanisms the C1 seat must implement, so integration can compare the seat's bytes
against measured behaviour. The prototype lived in `/tmp` and is not committed; only
these readings are.

Base checker: `plans/round-61-c1-check.py` at `09cbee8` (2031 lines,
`C1_CHECK_SELFTEST: PASS (cases=102)`).

## Mechanisms prototyped (all six in one copy)

1. `_pair_asserted` — the I7 `_pair_re` match must have no denial predicate between its
   end and the next `.`/`;`.
2. `_every_pair_own_subject` — every occurrence of each derived pair must be bound to
   ITS OWN subject within `SUBJECT_WINDOW`.
3. `_subject_blocked` — a subject preceded within five tokens by
   `different|other|no|not` does not bind.
4. `_mask_asides` — mask parentheticals `\([^()]*\)` and em-dash asides
   `—[^—.]*?—` (non-greedy, no period inside) in addition to quoted spans.
5. `item4` — the `NO_NEW_RECORD_DEFECT_RE` match must pass `_asserted`.
6. `item5` — exactly one `REWRITTEN_IN_PLACE_RE` occurrence, asserted.
7. `IDIOMS` gains `("not", "less", "than")`.

## Unit readings (i7 only; these four fixtures are I7's)

`i7 ok=True` means the line reads as a resolved assertion (benign), `False` means the
pair is unbound/denied (forgery caught).

| fixture | class | i7 ok | required |
|---|---|---|---|
| B4 | subject negatedness (`a different seat than the sentinel`) | False | forgery caught |
| P6 | em-dash aside between subject and pair | True | benign kept |
| P7 | parenthetical between subject and pair | True | benign fixed (BASE rejects) |
| F2 | denial after the pair | False | forgery caught |
| F10 | unbound duplicate pair | False | forgery caught |

## Full-checker probes (slim tree, `--no-challenge`)

| tree | prototype line |
|---|---|
| unmodified | `C1_ROUTED: value=0 population=7 i1..i7=1 guard=0` |
| F2 | `value=1` (i7=0) |
| F6 | `value=1` (i5=0) |
| F8 | `value=1` (i4=0) |
| F10 | `value=1` (i7=0) |
| B4 | `value=1` (i7=0) — after the subject-blocked window fix (unit-verified) |
| P6 | `value=0` — after the non-greedy em-dash fix (unit-verified) |
| P7 | `value=0` — after parenthetical masking (unit-verified) |
| B5 | `value=0` — after the idiom-class extension |
| round-63 P1,P2,P5,P6 | `value=0` (no benign regression) |
| round-63 F4,F6 | `value=1` (forgeries still rejected) |

The prototype keeps `C1_CHECK_SELFTEST: PASS (cases=102)` — the existing cases are not
broken by the mechanisms; the seat still owes one isolating case per mechanism.
