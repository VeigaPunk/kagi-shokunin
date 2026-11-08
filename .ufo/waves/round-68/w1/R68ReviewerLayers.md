# Round 68 — R68ReviewerLayers: are the raw and normalized digest layers complementary?

Seat: reviewer (attack, one of the frozen attack list). Lane `kagi-shokunin`, claim BASE
`d3b2a4e8eed710277951e430efd3d27b5983033c`. Read-only on the lane: every measurement ran on
a `git archive <BASE>` extraction under
`${HYAKU_SCRATCH}/kagi-r68/R68ReviewerLayers/`; no lane byte was written, no git command
mutated anything, no fleet path touched. Scratch deleted before yield; receipts copied into
`.ufo/waves/round-68/w1/R68ReviewerLayers/receipts/`.

## Hypothesis (as assigned)

> the widened gate's `normalized-digest-mismatch` check is blind exactly when a body's raw
> bytes change without changing its rendered-text-v1 form — so a col 15 that pins the OLD body
> still matches the NEW body and the row reads CLEAN while col 10 (raw digest) is the only
> detector.

## Verdict: REFUTED — the predicted state exists but carries no false attestation; the two layers are complementary and neither is redundant

The mechanism is real and measured. The *bypass* it would have to produce does not exist,
because the only configuration that reads CLEAN is one in which col 10 and col 11 were updated
to the new body — i.e. the row truthfully attests the bytes it now names, and col 15 is not
"stale" but *true*: the new body's normalized digest is numerically the declared value.
A col-15 cell can only be stale when the rendered form actually changed, and in that
configuration the recompute fires (measured: m5/m6 below). The raw layer catches every
un-updated tree (leg A).

Tested tree: round-67 landed gate `corpus/sources-census.sh` sha256
`e7aacecdfcf06ed6303f5272cd0d3bd6a20d16fdbf0f064a4c68aae940e1d10f`, normalizer
`corpus/rendered-text-v1.py` sha256 `14f6ca6ab742296f45a699548c31e6d49892f6baef36ed419c283d1a0511b8c9`
(the widened round-68 gate and `plans/round-68-c1.sh` were **not in the lane at probe time** —
`grep -c` for `normalized-digest-mismatch|capture-whitespace|capture-token|cr-in-tsv` in
`corpus/sources-census.sh` = 0). The new check's frozen definition has exactly one input —
"col 15 differs from the recomputed rendered-text-v1 digest of the bound file" — so it is
simulated exactly by the recompute printed in every leg; the raw layer is the *real* gate.

Anchor: **S115**, first capture-path-shaped `rendered-text-v1` row in file order that binds
(`.ufo/waves/round-57/capture/S115.body`, 41787 B, raw `76339ff7…`, col15 `781463ac…`,
recompute equal). Unmodified tree: `SOURCES_CAPTURES: CLEAN (path_rows=36 bound=36 located=36
prose=121)` rc 0.

Anchor note: this seat's spec fixes "the first that binds" (S115). The plan's §C1 leg anchor is
the **last** binding shaped row in file order (Amendment A1: BASE S156, candidate S167). The two
are different rows chosen for different legs and do not contradict; S115 was used because the
hypothesis is about a row's digest pair, not about ordering.

### The six legs

| leg | mutation (body only) | new bytes | normalized form changed | LEG A: row untouched (col10/11/15 old) | LEG B: col10/11 → new, col15 OLD | candidate `normalized-digest-mismatch` |
|---|---|---|---|---|---|---|
| m1 | 3 trailing spaces + 2 blank lines + tab at EOF | 41795 | no | FAILED rc 1 — `capture-bytes-mismatch` + `capture-digest-mismatch` | CLEAN rc 0 | would not fire |
| m2 | every LF → CRLF | 41938 | no | FAILED rc 1 — bytes + digest | CLEAN rc 0 | would not fire |
| m3 | every space → 4 spaces | 50550 | no | FAILED rc 1 — bytes + digest | CLEAN rc 0 | would not fire |
| m4 | every space → TAB (same byte count) | 41787 | no | FAILED rc 1 — `capture-digest-mismatch` **only** | CLEAN rc 0 | would not fire |
| m7 | `<!-- hidden payload words here -->` injected at offset 271 | 41821 | no | FAILED rc 1 — bytes + digest | CLEAN rc 0 | would not fire |
| m6 | appended `MATERIAL EXTRA SENTENCE` (control) | 41812 | **yes** (`fe87f27e…`) | FAILED rc 1 — bytes + digest | CLEAN rc 0 at the landed gate | **would fire** |

Reading of the table:

1. **The hypothesis's CLEAN state is reproduced** (all LEG B rows read CLEAN) — the machine
   behaviour it predicts is real.
2. **It is not a bypass.** In LEG B the row has been rewritten coherently: col 10 = the body's
   actual raw sha256, col 11 = its actual size. Nothing is falsely attested; the gate's own
   declared CEILING ("a body rewritten together with its row still passes") is exactly this
   state, and it is a declared ceiling, not a hole opened by the new check.
3. **The raw layer is not "the only detector" in any state where col 15 is false.** LEG A
   shows the raw layer failing every un-updated tree, with `capture-digest-mismatch` surviving
   even when the byte count is unchanged (m4).
4. **The normalized layer fires where only it can**: m6's LEG B — raw columns current, rendered
   text changed, declared normalized digest stale. That is QM92's borrowed/stale-digest class,
   which col 10 structurally cannot see.

### The class the check actually closes (the reason it is not redundant)

`R67Revenger` C3's exact input, re-applied: `S155.col15` replaced with `S164`'s normalized
digest `4d966ff9…`, S155's own body untouched and its raw col 10 still binding.

- S155 standing col15 = `5f509414…` = its recompute (so **no repair is due on S155**; the
  revenger's input was a mutation of a healthy row, and round 67's lesson never claimed
  otherwise).
- Landed round-67 gate on that tree: `SOURCES_CAPTURES: CLEAN (path_rows=36 bound=36
  located=36 prose=121)` rc 0 — **measured blindness**, reproducing the revenger's C3.
- Candidate check on the same input: recompute `5f509414…` ≠ declared `4d966ff9…` → **would
  fire `normalized-digest-mismatch`**.

So the layers partition the space: col 10/11 own "body drifted, row not updated"; col 15 owns
"row's rendered-text attestation is not its body's". Neither subsumes the other.

## What this means for C1's `col15` count as evidence

Three consequences, all measured:

1. **`col15` is a rendered-text attestation count, not a tamper-resistance count.** Whitespace
   runs, line endings, trailing blanks and tag/comment markup are normalized away by steps 3/5/6
   of `corpus/rendered-text-v1.py` (measured on the real body:
   `markup-invariance.txt`). An HTML comment can carry arbitrary payload while the normalized
   digest stays byte-identical. The number must never be cited as "col 15 also catches
   whitespace/CR tampering" — that class belongs to col 10/11 and to the gate's
   `capture-whitespace` reason, not to col 15.
2. **`31 → 32` is forced by the bytes, not asserted — and the round's own frontier row makes it
   `31 → 33`.** Independent recount (this seat's own code, not the gate's): `path_rows=36
   bound=36 prose=121`, of the 31 bound `rendered-text-v1` rows all 31 have
   `col15 == recompute` (BASE = the plan's declared 31), and S166's body recomputes to
   `652d311657f00e1eab513b15db807d773b42294d7032e179f63d04909943436b` — the value round 67
   already declared for S166's col 15. Once the col-16 re-cut puts S166 in the population, 32
   follows arithmetically. With S167's landed row and capture included the same derivation reads
   `verified=38 col15=33` (F0), so the number the counter prints depends on whether the frontier
   row is counted; it must be, by the plan's own population definition. A second pass over the
   same rows, using the declared normalizer's `locate` and a literal-substring test for
   `raw-literal-v1`, reproduces the gate's `located` too: `path_rows=36 bound=36 located=36
   prose=121`, no row failing. All four counts therefore have an independent witness on this
   tree, which is what guard (a)'s cross-check needs.
3. **A stale col 15 is only detectable when the rendered form moved**, so the check's real
   yield per row is "the normalized cell is not borrowed and not stale after a rendered-text
   change" — which is precisely QM92. If the round lesson describes col15 as a second,
   independent byte-level witness, that sentence is wrong by measurement.

## Cost of the extra per-row digest pass

| reading | full `verify` (3 runs) | 32-row digest pass | projected candidate verify | overhead |
|---|---|---|---|---|
| quiet host | 2.499 / 2.449 / 2.922 s (mean 2.623 s) | 0.69 s (31 rows) + 0.024 s (S166) | ≈ 3.3 s | **+26 %** |
| under wave load (15 live seats) | 9.631 / 9.947 / 10.135 s (mean 9.904 s) | 1.91 s (31 rows) + 0.062 s (S166) | ≈ 11.8 s | **+19 %** |

Same tree, same gate sha256, measured minutes apart by this seat — the spread is host
contention, so report the ratio, not an absolute. The digest pass is one `python3
rendered-text-v1.py digest` per bound `rendered-text-v1` row; 3.17 MB of bodies total. No
candidate-gate bytes existed to time.

## Findings

**F0 — high (frozen predicate vs the round's own frontier row; decision for the L1):** as the
working tree stands, the candidate derives **`verified=38 col15=33`**, not the plan's frozen
37/32. Read-only projection: a BASE extraction (`d3b2a4e`) with the working tree's
`corpus/SOURCES.md` (`2c364fde…`), `corpus/source-fetches.tsv` (`c14bcd88…`) and
`.ufo/waves/round-68/capture/` copied in reads `path_rows=38 bound=38 located=38 prose=120`,
`verified=38 col15=33`, no problem row. Cause: the plan counts S166's re-cut as the only +1, but
the frontier row **S167** also lands as a pure shaped capture row
(`.ufo/waves/round-68/capture/S167.body`, 35491 B, sha `84e14418…`, col15 `30194c4f…`). Both
populations move by 2 (36→38, 31→33). The kill rule is a lower bound (≥37, ≥32) so the counter
exits 0 and guard (a) agrees with the gate at 38/38/38/120 — what breaks is only the *literal*
37/32 in `plans/round-68.md` and `claims.json`. A report or ledger row pasting 37/32 would be a
false count (QM34 declared-not-executed, QM62 count-without-command). The two coherent
resolutions are (i) record 36→38 / 31→33 with S167 named as the second +1, or (ii) make S167's
fetch row not name a pure path — which would recreate exactly the round-67 C0 prose class for
the round's own new capture, so (i) is the defensible reading. Not mine to decide: L1
`KagiR68` has been messaged with the measurement and the receipt path.
**Disposition (recorded after this measurement):** the L1 confirms `plans/round-68.md`
§Amendment A1 (landed `4251519b`) already states the anchor is derived (BASE S156, candidate
S167), keeps 37/32 as the *re-cut-only* reading (receipt
`.ufo/waves/round-68/final/l1-derivation-recut-only.txt`, measured before the S167 row existed),
and states the final candidate reading as 38/33 with S167 named as the second +1; `R68-01` pins
what the counter prints. F0 therefore stands as the independent witness for A1.2 — same four
numbers, same date, derived by different code — not as an open defect.
Receipt: `receipts/projected-candidate.txt`.

**F1 — medium (gate design, addressed to R68ExecGate):** `normalized-digest-mismatch` must be
emitted only inside the bound branch — after the col 10/col 11 checks pass — mirroring
`quote-not-located` (landed gate line 282–283: `[[ $bad -eq 0 ]] || return 0` before the quote
check). Otherwise leg M6's "append one byte" is byte-choice dependent: appending `X` changes
the normalized digest and would print `normalized-digest-mismatch` in addition to
`capture-bytes-mismatch`, while appending `\n` would not — so `defects=` and the reason set move
with the counter's choice of byte. Measured both branches (m6 LEG A emits bytes+digest; m1 LEG A
emits bytes+digest on a *whitespace-only* append whose normalized digest is unchanged).

**F2 — low (claim wording):** the `col15` figure must be stated as "rows whose declared
normalized digest equals the recomputed one", with QM92 as its independent class. Not as
detection of whitespace/CR/markup tampering (F-measured invariant in four classes).

**F3 — informational (no repair):** S155's standing col 15 is correct (`5f509414…` = recompute
at BASE). `R67Revenger` C3's `4d966ff9…` value was the seat's mutation, not a standing defect;
nothing on S155 needs fixing, and a scribe "repairing" it would introduce a defect.

**F4 — low (self-correction of this seat's own first pass):** the batch probe's `m5-tag-wrap`
replaced the first literal `the`, which occurs inside a word, so it changed the rendered text
and behaved as a control (`recompute ≠ col15`) rather than as the intended invariant tag
insertion. The intended shape (`<b>` around a standalone word) is measured separately and *is*
digest-invariant. The first-pass reading is not evidence that tag insertion moves the digest.

## Verification gaps

1. **The candidate gate was not in the lane at probe time** (0 occurrences of the four new
   reason tokens in `corpus/sources-census.sh`; no `plans/round-68-c1.sh`). Every leg therefore
   ran the *real* landed raw layer plus an exact simulation of the frozen col-15 comparison. The
   integration seat must re-run m1/m7 LEG B against the landed gate and confirm the printed
   verdict line, not just the exit code.
2. F1 is a recommendation on code that did not exist when measured; if the landed gate places
   the check before the early return, the M6 leg still passes (the expected reason is present)
   but `defects=` gains a byte-choice dependency the plan does not freeze.
3. The `located` recount uses the declared normalizer from the extracted BASE tree (sha256 in
   every receipt header); it is an independent implementation of the *comparison*, not an
   independent normalizer, so a tampered normalizer moves both sides — the M67-4 class, which
   the C1 counter's guard (f) owns, not this seat.
4. **Gate landing state at this seat's last read** (after the probe): `corpus/sources-census.sh`
   sha256 `127e039b06f2fb9f9677a5fd2a5f4abb8c5981f62f1c140c3f6f74e5c8a1c6db` carries the new
   reason vocabulary in its header (`cr-in-tsv`, `capture-whitespace`, `capture-token`,
   `normalized-digest-mismatch`) and the selftest plan, while `cap_row()` is still the round-67
   body: the three `normalized-digest-mismatch` mentions are comments and no `digest` invocation
   on a bound capture exists. The widened check was therefore **not yet testable** at that read;
   running it then would have graded a half-landed gate. Integration must re-run m6/m7 LEG B
   against the landed bytes and compare the printed verdict line.
5. Ceiling carried from BASE, unchanged: the binding is to the bytes the row names, so a body
   replaced together with its row passes (gate header, CEILING paragraph). LEG B is that
   ceiling, not a new defect.

## Receipts

`.ufo/waves/round-68/w1/R68ReviewerLayers/receipts/`

- `layer-complement.txt` — anchor derivation, unmodified-tree verdict, six mutations × two legs
  with the candidate check's projected answer.
- `borrowed-digest.txt` — S155 borrowed-col15 leg: landed gate CLEAN, candidate check fires.
- `markup-invariance.txt` — tag-wrap / comment / CRLF / trailing-blank digest invariance on the
  real body, plus the m5 self-correction note.
- `independent-recount.txt` — gate-equivalent recount (36/36/121), BASE col15 = 31, S166
  recompute = the declared col15.
- `timings.txt` — both verify readings, the digest-pass measurement and the load-variance note.
- `projected-candidate.txt` — the working-tree registry projected onto a BASE extraction
  (`verified=38 col15=33 path_rows=38 bound=38 located=38 prose=120`), the independent witness
  for Amendment A1.2 (F0).

Every receipt header names the tree, the two instrument digests and the fact that the widened
gate was absent (QM96: what the file was derived from and by what command).
