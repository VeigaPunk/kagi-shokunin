# Claim instrument: the class matrix and the structural-vehicle rule

cites: S148, S156, S164 — the carrier row this entry's capture-path contract is read from, the rate-limited live carrier it prices, and the superseding row that names the carrier path.
source: `corpus/SOURCES.md` S155 (ConText §3.1.2 pseudo-trigger classes — the
bounded idiom list the polarity grammar stands on) and the lane's own executed
counters `plans/round-65-c1.sh`, `plans/round-65-routed.sh`,
`corpus/volatile-shape.py`.
verified-at: `round-65` (2026-11-08), claim BASE `b17887f`.
recheck: `bash plans/round-65-c1.sh --selftest` and
`python3 -I -B corpus/volatile-shape.py --selftest` — both exit 0; the full
counters on the lane tree; §Bounds names what neither proves.

Reverify: R21-02

## What this entry settles

Three instrument defects this lane had, and the rule each became. Each was
measured on this host before the fix, and each fix is a committed artifact.

### 1. A held-out population must be a class matrix, and its falsifier must be a vehicle

Rounds 61–64 grew a polarity grammar over round-60 correction lines. The
round-64 population was eight fixtures over five forgery and three benign
*shape classes*. That is the right idea and it was still thin in two ways:

- eight fixtures is not a matrix: nothing forced one held-out instance per
  claimed mechanism, so `R65-H5` could rewrite a line **no item reads** and
  still be counted as a "class";
- the vehicle leg (a literal lookup over the committed tables) is the
  falsifier, not a witness. A lookup carries only the strings it was fitted
  to, so on fresh strings it returns `accept` and can never read `matrix=0`.
  A predicate written that way is unsatisfiable for every candidate.

The rule (`plans/round-65.md` §C1, Amendments A1–A3):

- every forgery fixture must exercise a mechanism some item **asserts**
  (`i1..i7`), and the fixture's anchor must occur exactly once in the file the
  item reads;
- the structural vehicle is measured in the **falsifying direction** only:
  `matrix>=1` on the held-out set. Its identity on the committed tables
  (`accepted=0 rejected=0`) is the round-64 counter's leg and is carried as
  receipt evidence;
- a class the checker does not claim is not a fixture. `R65-H5`'s first
  version rewrote a line no item reads; it was replaced (I5 class) rather than
  kept as a counted row.

Measured: `bash plans/round-65-c1.sh` ⇒
`C1_MATRIX: matrix=0 population=8 guard=1` on the candidate; BASE reads
`matrix=5` (the five forgeries accepted). Five of eight fixtures are *live*
(they move 0→1); the three benign classes are non-harm controls that already
read 0 at BASE and would fail the guard if a hardening regressed them.

### 2. A polarity test needs a sentence-level clash class

The round-63/64 checker tested the token's own polarity (a negator before it, a
denial predicate after it, to the end of the sentence). Five fresh forgeries
walked past it by **appending a clash clause to a correction line**:

| class | shape | why the token test missed it |
|---|---|---|
| I6 | `… round=60`, though the record denies the launch altogether here | the item checks derived stamps, not the token's polarity |
| I4 | `… it did not route, and a fourth it did not route` | the count token stays asserted; the extra clause adds a fourth |
| I1 | `… a report, which the record elsewhere plainly denies` | the item checks derived counts only |
| I6 | `… not stale, though a different reader finds it silent` | same as I6 |
| I5 | `… `818d2a82`, a fact the second account leaves unseen` | `unseen` was not in the denial vocabulary |

The fix is one shared detector, `_line_clash`, applied to every correction line
each item selects: mask quoted spans and well-formed asides, then fail closed on
a closed vocabulary of concessive and completeness-denying markers (`though`,
`although`, `whereas`, `unseen`, `silent`, `not the case`, `a fourth`, …).

The vocabulary is **closed and measured**: `false` and `contrary` are
deliberately excluded because they occur on the real correction lines as objects
of the correction ("R37's false no-artifacts claim"; "contrary to the append-only
convention"), not as clashes against it. Including them would have made the
unmodified tree read `value=1` — the guard's `real` leg is what caught that while
the detector was being written.

### 3. A digest pin over a volatile body cannot be re-verified; a shape can

The S148 BioC carrier stamps the request date into its own body. The round-64
measurement is one byte of drift at offset 128 (`<date>20261107`→`<date>20261108`),
with `<passage>` 182 and `<text>` 180 unchanged. A whole-body sha256 therefore
fails every day for a reason that carries no information, and a reader who
wants to re-verify must refetch and hand-diff.

`corpus/volatile-shape.py` replaces the digest reading with a **shape** reading
over the committed capture: identity (the body's sha equals the row's pin), the
date stamp (reported, not asserted), and the two element counts (asserted).
Exit 0 iff all three hold.

Measured: `VOLATILE_SHAPE: match=1 passages=182 texts=180 date=20261108`,
and a count mutation (`<text>`→`<text><text>`) reads `match=0` exit 1.

## Bounds (what none of this establishes)

- A class matrix counts fixtures, not grammar. A checker that memorises the
  eight fresh strings reads `matrix=0` and is not detected by this counter; the
  vehicle leg falsifies one specific empty lookup, not every lookup.
- The clash vocabulary is a closed floor. A concession spelled with a word
  outside the list reads as asserted; the list grows only with a measured
  forgery behind it.
- `match=1` is a shape claim: 182 passages, 180 texts and one date byte. A body
  that keeps the counts and rewrites the wording reads `match=1`. The deposit's
  textual content is checked only by the S148 `teaches` prose.
- The 429 measurement (`S156`) is a host-and-window fact, not a property of the
  endpoint. A later 200 does not refute it; it clears the flip condition.

## Falsifiers

1. A held-out fixture whose anchor does not occur exactly once in its file —
   the counter reads SETUP, never a verdict.
2. A vehicle that reads `matrix=0` on the held-out set — it is misfitted or the
   fixtures are already in its table; the claim is void.
3. A guard whose `real` leg reads `value=1` on the unmodified tree — the
   detector over-fires and the reading is not a candidate result.
4. A receipt whose counts disagree with `corpus/volatile-shape.py` on the same
   bytes.
5. A registry row citing this entry while the entry's `source:` names no
   `mined` row.
