# Round 68 — kagi (secrets & vault ops)

Lane: kagi. Round 68, attempt 1. Claim BASE
`d3b2a4e8eed710277951e430efd3d27b5983033c` (round-67 verifier spot-check tip).
Frozen predeclaration `plans/round-68.md` (landed
`23a8e0290d8d3a6f1de16eafce40fd1a189ef636`), Amendment A1
`4251519bd6e8b5c152d70ae286e04a117a49ed4f` recorded before any counter existed.
Wave `kagi-r68-w1`, 15 seats (one v1 wave; attack 4/15 by the frozen attack
list, five with the revenger).

Claims (as frozen, with A1's readings):

- **C1 freshness** — the census re-verifies every mined row that names a
  lane-tree capture. `C1_VERIFIED` verified 36 → 38 (`+1` S166's recut, `+1`
  this round's S167 row), col15 31 → 33, caught 0/6 → 6/6, `defects=0` over the
  whole population. The recut-only tree reads 37/32 (A1.2).
- **C2 calibration** — the lane's record surfaces match observed state;
  `C2_RECORD` mismatches 3 → 0 (selftest pin, missing ledger rows, cells SETUP).

## Gate (rows written this round)

One source was opened this round, at the plan's frontier step; one row admitted.

| row | URL | access date | located quote (≤25 words) | decision | reason / flip |
|---|---|---|---|---|---|
| S167 | https://www.rfc-editor.org/rfc/rfc4648.txt | 2026-11-08 | "Implementations MUST reject the encoded data if it contains characters outside the base alphabet when interpreting base-encoded data" (§3.3, 18 words) | admit, tier A | RFC 4648 §3.3 states the default refusal rule for base-encoded data (MUST reject characters outside the alphabet unless the referring specification says otherwise); §12 records the covert-channel cost of the liberal alternative. The lane takes the default branch for a registry cell — a choice, and the transposition from encoded fields to a TSV cell is the lane's own (M68-5). Capture `.ufo/waves/round-68/capture/S167.body`, 35491 B, raw sha256 `84e14418f795d503be5f34bf23ce4ebaa119e9ec7c9f667d8caeb111385b178f`, rendered-text-v1 normalized sha256 `30194c4ff628ee00171027b7d54800e1c17cfda692ced83290807eb148ef93a9` (28542 bytes); quote locate count=1 under rendered-text-v1, raw-literal control 0. Flip: a revision that withdraws the refusal rule. |

### In-place registry changes (contract v1 rule 2, old → new)

- **S166** `corpus/source-fetches.tsv` col 16: OLD
  `§1.2 Concept Overview; capture .ufo/waves/round-67/capture/S166.body` →
  NEW `.ufo/waves/round-67/capture/S166.body` (the section pointer moved into
  the registry row's anchor/teaches prose, which keeps the byte count, sha256
  and quote count).
- **S166** `corpus/SOURCES.md` anchor: OLD `… capture \`.ufo/waves/round-67/capture/S166.body\` (67152 B, sha256 \`544dbb7d…\`); opened live …`
  → NEW `… capture \`.ufo/waves/round-67/capture/S166.body\` — row col 16 recut to this pure path (67152 B, sha256 \`544dbb7d…\`); opened live …`.
- **S099** used-by: OLD `corpus/lessons/round-44.md` → NEW
  `corpus/lessons/round-44.md, corpus/knowledge/source-capture-binding.md`.
- **S113** used-by: OLD `corpus/knowledge/iso-11770-3-edition-status.md, corpus/lessons/round-55.md, corpus/knowledge/claim-instrument-carrier-binding.md`
  → NEW same + `, corpus/knowledge/source-capture-binding.md`.
- **S115** used-by: OLD `corpus/knowledge/openbao-audit-device-custody.md, corpus/lessons/round-57.md`
  → NEW same + `, corpus/knowledge/source-capture-binding.md`.
- **S143** used-by: OLD `corpus/lessons/round-63.md, corpus/knowledge/claim-instrument-carrier-binding.md`
  → NEW same + `, corpus/knowledge/source-capture-binding.md`.
- **S167** new row: registry row inserted after S166; fetch row appended last
  (16 columns, pure capture path, raw digest/bytes in cols 10/11, quote in 13,
  `rendered-text-v1` in 14, normalized digest in 15).

## Mistakes

### M68-1 — a frozen predicate's numbers were pinned before the round's own frontier row existed

- **class**: `calibration` (the QM90 class, one step up)
- **evidence**: `plans/round-68.md` §C1 froze `verified=37 col15=32` and
  described S166's recut as the only `+1`; the plan's own frontier step then
  admitted S167 as a second pure capture row, so the landed tree's derivation is
  38/33. Measured three ways: the L1 derivation
  (`.ufo/waves/round-68/final/l1-derivation-recut-only.txt` = 37/32 before S167,
  and 38/33 after), R68ReviewerLayers's independent recount, and
  R68ScoutSource's `population.txt`.
- **captured-by**: the wave (R68ReviewerLayers F0, R68ScribeEntry §4,
  R68Sentinel F1, R68ScoutSource §4), all *after* the freeze and before the
  report. No criterion required a round's frozen population to be re-derived
  against the plan's own frontier-step additions before the freeze.
- **fix**: Amendment A1 (landed before any counter existed) states the
  derivation as the anchor, records 37/32 as the recut-only reading with its
  receipt, states the final 38/33, and gives the claim its teeth (`defects=0`
  over the whole population, `caught=6/6`, `guard=1`). Round 69 must re-derive
  the expected population from the plan's own landing list before freezing.

### M68-2 — the anchor rule as frozen was not the anchor rule the counter implements

- **class**: `vacuous`
- **evidence**: §C1 froze "the LAST capture-path-shaped row in file order that
  binds"; the landed counter derives the anchor as the last row naming a
  `.ufo/waves/` token, so on the BASE tree it selects S166 (a non-pure prose cell
  that does not bind), not S156 (the last pure row that binds — R68Sentinel's
  receipt `receipts/base-legs.txt`). Consequence: BASE blindness reads 0/6 under
  the counter's anchor and 2/6 under the frozen rule's anchor (M4 col-10 hex and
  M6 body byte are already caught by the BASE gate on a bound row).
- **captured-by**: R68Sentinel F6 (per-leg BASE battery) and R68ScoutSource §2
  (file-order vs id-order), both measured before the report.
- **fix**: the deviation is recorded (A1.1 names the derivation as the rule; the
  report states both blindness readings); round 69 must freeze an anchor
  predicate that names whether a non-binding row may be the anchor.

### M68-3 — the shared BASE control tree was mutated by a seat mid-round

- **class**: `landing`
- **evidence**: `/fast/scratch/hyaku/kagi-r68/l1/base-d3b2a4e` — the extraction
  the wave was given as "the BASE tree" — gained a trailing space in S164's
  col 16 (TSV sha256 `aa6fa318…` vs the committed blob `90dd4a2c…`). The C1
  counter then read BASE `verified=35 col15=30 defects=2`, i.e. a corrupted
  control, and its own `mixed=S164,S166` line was the only tell.
- **captured-by**: the L1's independent derivation disagreed with the counter by
  exactly one row; nothing in the wave noticed. No criterion required a scratch
  control tree to be hash-checked before each measuring run.
- **fix**: a hash-verified copy (`base-clean`, TSV sha256 == `git show
  <BASE>:corpus/source-fetches.tsv`) is the only cited BASE tree, every receipt
  names its TSV sha256, and round 69 must re-derive a control tree from the repo
  per run rather than trusting a shared path.

### M68-4 — a gate finding's detail line could be forged by a file name

- **class**: `scope`
- **evidence**: `SC_ENTRY_CITE entry=$rel …` printed the file name raw; a file
  whose name carried a newline injected a second `FINDING SC_CAPTURE …` line
  into the gate's stdout. R68Sentinel built the tree and replayed the counter's
  own leg matcher: all six legs read as caught on a gate that had found nothing.
- **captured-by**: R68Sentinel F3 (live), before the report; the counter seat
  then added its own cross-checks. No criterion required a gate's output lines
  to be unforgeable by repo-controlled names.
- **fix**: `finding()` escapes CR/LF in the detail (gate-side, one function), and
  the counter cross-checks finding lines against its own derivation. Proof: the
  same tree now reads `caught=0/6 guard=0`.

### M68-5 — a sourced row cited the RFC's liberal branch to ground a strict rule

- **class**: `scope`
- **evidence**: S167's first `teaches` cell said "the RFC states that adjacent
  CR/LF bytes ARE non-alphabet characters — so a stray CR or space in a
  structured cell is a defect to refuse". The cited sentence is inside RFC 4648
  §3.3's *liberal* alternative ("be liberal in what you accept"): "any adjacent
  carriage return/line feed (CRLF) characters constitute 'non-alphabet
  characters' **and are ignored**" — the operative clause was dropped, and §12
  (which records the covert-channel cost of ignoring) was not cited.
- **captured-by**: R68ScribeLesson, measured on the captured body before the
  report; no gate checks that a row's conclusion follows from its quote (the
  census checks that the quote *locates*).
- **fix**: S167's `teaches` cell and the entry's §1 paragraph now state the
  RFC's structure (default = refusal, "unless the specification referring to
  this document explicitly states otherwise"; MIME's liberal branch ignores,
  and §12 names the cost), keep the default branch as the lane's *choice*, and
  say explicitly that the transposition from base-encoded data to a TSV cell is
  the lane's own rather than the source's. The census's CR rule stands on its
  own `SC_FETCH cr-in-tsv` check and needs no RFC.

### M68-6 — a plan named a verdict the instrument never prints

- **class**: `landing`
- **evidence**: `plans/round-68.md` §C2 said `claim-ledger.sh cells` "reads
  SETUP on the historical heading". `grep -c SETUP corpus/claim-ledger.sh` ⇒ 0:
  the token does not exist. What BASE prints is a `die()` line and exit 2 —
  `claim-ledger: unrecognised round heading in … '## Round 63 — planned'
  (expected '## Round <N> — pre-move|post-move')`.
- **captured-by**: R68ScribeLesson (measured twice, `cells-base.out`); the C2
  counter's L3 leg was written to tolerate the real exit code and line rather
  than the plan's token, which is why the leg could still pass.
- **fix**: the C2 claim text in `SCORECARD.md`, this lesson and the round report
  name the exit code and the message; the counter asserts them, never a token.

### M68-7 — round 67's lesson did not record the classes its closure routed

- **class**: `landing`
- **evidence**: `grep -ci` over `corpus/lessons/round-67.md`: "whitespace" 0,
  "CRLF" 0, "col15"/"col 15" 0, "escape hatch" 0, "borrowed" 0 — yet the
  round-67 verifier spot-check routed exactly those classes, so round 68 had to
  re-derive them from the closure and the revenger report.
- **captured-by**: R68ScribeLesson, before the report; no criterion requires a
  lesson to enumerate what its closure routed.
- **fix**: recorded here and as a rule for round 69 — every lesson carries an
  "open classes" list copied from its closure's routed section.

### M68-8 — the C2 L3 leg and the landed cells parser disagreed on a suffix shape

- **class**: `vacuous`
- **evidence**: the leg required `## Round N — planned (claims C1 …)` to be
  refused; the landed `PLANNED_SECTION_RE` is
  `^## Round [0-9]+ — planned( \([^|)]*\))?$`, which accepts one parenthetical
  by design (ruling (b)), so the leg could never pass while the parser did what
  it was told to do.
- **captured-by**: R68ScribeLesson (M68-8) and the seat's own `c2-run.txt`.
- **fix**: the leg now asserts the ruling's two invariants only — a planned
  heading with no table must reach `CELL_AUDIT`, and a table under a planned
  heading must die — and the suffix grammar is pinned by
  `corpus/claim-ledger.sh`'s own selftest cases 100/101.

### Freeze-sequence gap (recorded, not repaired)

The plan's `col15=31` BASE figure had no committed receipt at freeze time: the
first receipt is `.ufo/waves/round-68/base/base-derivation.md`, committed at
`7e78630` **after** the freeze `23a8e02`. `verified=36` was receipted before the
freeze (R67Revenger §2); `col15=31` was asserted at freeze and receipted seven
minutes later. Round 69 must commit the BASE derivation before the
predeclaration. Related: the shared BASE extraction named in the wave context
was later mutated by a seat (M68-3), so receipts must pin a tree digest, not a
path — the committed derivation reads a copy whose TSV sha256 equals
`git show d3b2a4e:corpus/source-fetches.tsv` (`90dd4a2c…`).

### M68-9 — the counters' own selftests pass mutants that break a single guard field

- **class**: `vacuous` (QM89: every field of a frozen verdict line needs a case
  where that field alone is wrong)
- **evidence**: R68MutGate §1 measured three mutants of `plans/round-68-c1.sh`,
  each still printing `C1_VERIFIED_SELFTEST: PASS (59 cases)`: guard (b)'s
  threshold `cases>=89` → `>=0` (survived; only an external divider caught it),
  guard (e) removed (survived, masked by stronger checks), and the derivation
  switched to the tree's own normalizer (survived; external divider only). The
  case list carries m1-right…m6-right, a wrong-reason case, a wrong-id case, an
  rc-0 case, a clean-verdict case, a SETUP case and two forgery cases — and no
  case for guard (b)'s threshold or guard (e)'s prose check. The same class
  exists in C2: R68MutGate §3 (k) shows `neg-scored-missing-axis` cannot kill a
  mutant that treats any SETUP as a skip, because guard (c) refuses that fixture
  first.
- **captured-by**: R68ScribeLesson (QM89 read against both counters), before the
  report; the counters' selftests were never required to cover their own
  `guard` field.
- **fix (routed to round 69, not claimed as done)**: three fixtures per counter —
  a stub gate printing `PASS (0 cases)` with `verify` untouched ⇒ `guard=0`; a
  stub gate printing one uncounted `FINDING SC_CAPTURE id=… capture-token` on a
  prose row with a CLEAN verdict and matching counts ⇒ `guard=0`; a tree
  differing only in `rendered-text-v1.py`'s digest ⇒ `guard=0` — and a C2
  `neg-scored-missing-axis` rebuilt so guard (c) cannot mask L3.

## Wave-process note (not a mistake of the round's claims)

The census gate changed eight times during the wave while attack seats read it;
every receipt pins the gate sha256 it ran. Two selftest cases were red for most
of the window (`capture-symlink-escape`, then `capture-whitespace-cr`, then
`capture-token-slashslash`); the final bytes read `PASS (98 cases)`. The `//`-form
disagreement was decided on the plan's own wording: a `//` cell is
`capture-token` (the gate changed, not the fixture). The ledger's `cells` parser
gained the exact-planned-heading skip *plus* the table-under-a-planned-heading
die; the second historical heading (`## Round 64 — planned (next)`) was handled
by allowing one parenthetical on a planned heading rather than rewriting a
historical record.
