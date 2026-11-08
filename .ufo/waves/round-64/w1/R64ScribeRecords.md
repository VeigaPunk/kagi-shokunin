# R64ScribeRecords — round 64 wave 1 (kagi-r64-w1)

Seat `R64ScribeRecords` (scribe; axes calibration, freshness). Round 64, attempt 2, lane
`kagi-shokunin` (secrets & vault ops). Claim BASE `09cbee831d57be7c4edfbe77bf238f46bf729047`;
frozen predeclaration `plans/round-64.md` (`dff0929c0e084822b0fe32e0d164534c768f97fe`, incl.
Amendment A1).

**Files this seat wrote** (nothing else in the lane):

* `corpus/lessons/round-64.md` — the round lesson (claims, `## Gate`, `## Mistakes`,
  `## Routed dispositions`, `## considerthese`, `## Wave`, `## Bounds`);
* `corpus/README.md` — one coverage-map row for the round-64 lesson and one for the round's
  new knowledge entry, and one `## Frontier` line for the held-out-instrument ground;
* `.ufo/waves/round-64/build/R64ScribeRecords/sources-block.md` — the `corpus/SOURCES.md`
  row block (11 columns) plus the matching `corpus/source-fetches.tsv` rows, for the L1
  to append;
* `.ufo/waves/round-64/build/R64ScribeRecords/records.md` — every command and output;
* this report.

No lane commit, no `git add/commit/stash/push`, no mutating `jj`, no host mutation, no
tool install. Scratch lived under `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r64/R64ScribeRecords/`
and is deleted before this seat yields.

## What the lesson says

**Claims.** C1 (`C1_HELDOUT`, heldout 8 → 0, population 8) and C2 (`C2_TERMINATES`,
terminated 0 → 1, killed 5, population 5), each with the frozen predicate quoted
verbatim from the plan (with Amendment A1's enumeration) and the readings:

* **C1 BASE** — the L1's committed census (`.ufo/waves/round-64/base/census-a1.md`): the
  five held-out forgeries read `value=0` at BASE and the three held-out benign rewrites
  read `value>=1` ⇒ heldout **8** of 8.
* **C1 candidate** — this seat's own working-tree measurement: the measure leg reads
  **H accepted=0/5, Q rejected=0/3**, the unmodified copy `value=0` with all seven i-bits
  1 ⇒ the held-out count reads **0**. But the counter **did not print its verdict line**
  on those bytes (`plans/round-64-c1.sh: line 620: stub2_e2: unbound variable`), so there
  is no `C1_HELDOUT:` line and no exit code for them.
* **C2 BASE** — `rc=124` at 900 s and 1500 s (7-byte committed receipt); the L1's
  re-measurement at 240 s is `rc=124` (`.ufo/waves/round-64/base/c2-e2e-head.txt`).
* **C2 candidate** — this seat's own working-tree measurement: one bounded invocation
  **reached its verdict line** —
  `C2_REFUSAL: killed=5 population=5 guard=0 (l1=1 l2=1 l3=1 l4=1 l6=1 selftest=1 real=0
  terminates=1 bound=1)`, 749 s inside the 1200 s budget. Terminated **1**, killed
  **5**, but the **guard reads 0** on guard leg (c) (the real bao trial) — so the claim's
  target is **not met** on those bytes.

Both candidate readings are labelled in the lesson as point observations of a **moving**
tree (both counters' bytes changed again after the measurements), not as the L1's
receipts. Two further runs this seat started were **withdrawn** — one killed
mid-measurement, one whose evidence files were deleted underneath it while it ran — and
are recorded as withdrawn in `records.md` §R12b so no one reads them as findings.

## The Gate (20 pages opened, 4 rows mined, 6 rejected)

Every quote was re-resolved by this seat with
`python3 corpus/rendered-text-v1.py locate <capture> "<quote>"` against the committed
capture bodies — not against the scout's ledger text (records.md §R4, L1–L30). Every
admitted quote resolves `count=1`; the rejects' quotes resolve too.

Admitted (rows drafted; the L1 owns the ids):

* the **ISSTA '24** equivalent-mutant paper (`An equivalent mutant is a mutant which
  cannot be killed by any test`) — the peer-reviewed second attestation the plan asks
  for, independent of the three already mined;
* the **peer-reviewed survey chapter** (*Mutation Testing Advances: An Analysis and
  Survey*, Advances in Computers 112, Elsevier 2019) — the plan's *preferred* carrier,
  with its venue confirmed independently through Crossref (a different host than the PDF);
* **Stryker's** tool-level equivalent-mutants page — the tool-level companion, on a URL
  the registry does not already hold;
* the **BioC/ConText deposit re-opened** on the current endpoint — a superseding row:
  the measured delta against the `S143` pin is **exactly one byte**, the service's own
  `<date>` request stamp, and the shape census is unchanged.

Rejected: the designated weak lead (Wikipedia — rejected on **source class**, not on
content: the page does carry the consequence sentence and does cite the primary work),
the PIT mutators reference and the PIT FAQ (neither states the rule; measured 0
occurrences of the cannot-be-killed phrasings / of "equivalent"), a mis-derived arXiv id
(a quantum-noise paper), a 404 docs path, and the lane's own-domain sweep — **0 of 6363**
OpenBao tree paths and **0 of 8** opened contribution/testing documents mention mutation
testing, so the equivalent-mutant ground is external to the lane's product.

Two opened pages are **byte-identical re-opens** of already-mined rows (`S129`, `S128`)
and mint no row; the Crossref record is identity evidence, not a row.

## The Mistakes section

Four rows, each with class, evidence pointer, captured-by and a fix that can fail. The
mandatory one is first:

* **M64-1** — the round's own first mistake: **the pre-amendment held-out census was
  wrong for 10 of 19 rows** (F1/F5/F9/B3 already rejected at BASE, F3/F4 already
  accepted correctly, P1/P2/P3/P5 already accepted, P4 an unmeasured slim-tree artifact,
  B4 accepted at BASE so it could not be a control), **caught by nobody** until the L1
  re-measured it — the census and the sealed table were frozen together, so the plan and
  the table agreed with each other and neither could falsify the other. The fix is that a
  **population census is re-derived per fixture before it is frozen** (a table of one
  measured reading per fixture id, not a class-level assertion), and the counter
  re-derives it — so a census that mis-states a row's BASE reading makes the counter's
  own count disagree with the plan.
* **M64-2** — instrument vs claim: **neither counter printed its verdict line** on the
  bytes this seat measured (the C1 counter aborted at `stub2_e2: unbound variable`; the
  C2 counter at `dir: unbound variable`), so neither claim has a verdict from this
  seat's readings.
* **M64-3** — receipt vs instrument: the C1 counter's guard line reports
  `cases=91` where the measured tree's checker prints `cases=110` (measured directly and
  on the documented slim copy) — the round-63 M63-4 class, one round later.
* **M64-4** — record vs artifact: a daily-moving digest must not be presented as
  reproducible; the superseding row's representation and `teaches` name the measured
  delta.

## Routed dispositions, considerthese, wave, bounds

`## Routed dispositions` carries D-63-1 (the A4 vehicle leg), D-63-2 (the
`C2_RECURSION_BOUND` leg, with the revenger's measurement of the one true cycle
`round-63-c2.sh:198 → round-63-controls.sh:460 → round-63-c2.sh` and the surviving
chain after the outer shell is killed) and D-63-3 (carried). `## considerthese` names
the sentence that **no** still-unimplemented proposal is mined (the latest
`considerthese/` file's proposal 3 was mined in round 63; `considerthese/` was read, never
edited). `## Wave` is the plan's wave shape with the seat verdicts left to the L1.
`## Bounds` records that the Gate quotes are re-resolved locate results, that the capture
handles are not registry ids, that the candidate readings are point observations of a
moving tree, that this seat did **not** read the sealed table's rows (only its sha256),
and that the attack seats' findings are cited from their receipts.

## The SOURCES.md row block

`build/R64ScribeRecords/sources-block.md` carries the ten proposed rows in the
contract's 11 columns (no `|` inside a cell; a rejected row's `teaches` starts
`REJECTED:` and carries `flip:`) and the matching 16-column `source-fetches.tsv` rows.
The registry ends at `S144`, so the block proposes `S145`–`S154`; the L1 owns the ids and
may renumber — the registry-identity digest in each fetch row (column 3) is computed over
the id, so it changes with a renumbering (records.md §R6 recomputes them).

`S145`'s `used-by` cell names `corpus/knowledge/claim-instrument-heldout.md` (the entry
seat's file, which cites `S145` on its `source:` line) and `corpus/lessons/round-64.md`
(the lesson's `cites:` line carries `S145 S146 S147 S148`) — the census resolves a mined
row's used-by by looking for the id on the named file's `source:`/`cites:` line.

Notes carried for the L1 in the block: the `S154` tree-listing URL is a moving ref (the
tree SHA it reports is `423b2546…`; if the L1 pins it, column 12 needs the 40-hex
revision and column 3 must be recomputed); the two PDF rows use `raw-literal-v1` with
`-` as the normalized digest and anchor on their committed text layers, because the PDF
bytes are not strict UTF-8; and `S146` anchors on **page-scoped** text layers because
the declared normalizer's tag rule swallows 137657 bytes of the whole-document layer
(this seat re-measured the swallow: four spans, 47934 + 89691 + 17 + 15 bytes).

## Things the L1 should know

1. **The C1 counter did not print a verdict line on the bytes this seat measured**
   (`stub2_e2: unbound variable` at line 620) and the C2 counter aborted at its own bytes
   (`dir: unbound variable` at line 345). Both counters' bytes changed again afterwards.
   This seat owns neither file and edited neither; the defects are in the lesson's
   `## Mistakes` (M64-2).
2. **The C2 guard reads 0** on the working tree: `guard a=1 r63selftest=1 b=1 c=0 d=1
   e=1` — guard leg (c) is the real bao trial (`value=5 shims=5 vectors=ok/5`), which the
   counter's own header calls host-load sensitive and retries twice. The claim's target
   is `terminated=1 … guard=1`; this seat's reading is `terminated=1 killed=5 guard=0`.
3. **The C1 counter's guard line reports `cases=91`** where the measured tree's checker
   prints `cases=110` (measured directly and on the documented slim copy). If the counter
   reads the tally of a tree other than the measured one, guard leg (b) is decided by a
   number the measured tree never produced (M64-3).
4. **The sealed table's row strings are reachable through `census-a1.md`** — the critic
   measured that 6 of the 8 held-out fixtures' distinguishing strings appear verbatim in
   the committed census file and the other two are described precisely enough to
   reconstruct, and `census-a1.md` is tracked, while the C1 seat's prompt forbids reading
   the sealed file itself (`.ufo/waves/round-64/build/R64Critic/critique.md` C1-1). The
   seal's protection is a disclosure protocol, not a mechanical barrier; this seat
   discloses that it read `census-a1.md` (the plan's own evidence file, which the C1
   seat's prompt names) and did **not** read `plans/round-64-heldout.tsv`'s rows.
5. The registry's next free id is `S145`; the L1's append must carry the fetch rows from
   the same block, or `SC_FETCH missing-provenance` fires for every new row.

SEAT-STATUS: complete
