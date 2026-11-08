# R67ScribeLesson — round-67 lesson, two QUALITY criteria, two coverage-map rows

**Seat.** Scribe, wave `kagi-r67-w1`, round 67 attempt 1, lane kagi. Leaf — no
subagent dispatch. Sole writer of `corpus/lessons/round-67.md` and
`corpus/QUALITY.md`; owner of the `corpus/README.md` coverage-map rows and
of the four stale README self-counts.

**Claim BASE** `076701a11a58e3eb58d996b4c76c5e18071fb179`; frozen plan
`plans/round-67.md` (`aa8807e443166f45485e1aada2989f646efc707c`, amended
A1 by the L1 mid-wave). Nothing committed by this seat.

## What this seat wrote

### 1. `corpus/lessons/round-67.md` (new, sole writer)

- **Header**: round 67 attempt 1, lane, BASE, the frozen plan and its
  landing hash, wave name, and the two claims as frozen (C1 freshness,
  C2 calibration) with their target shapes.
- **`## Gate`**: the **S166** row — URL `https://www.rfc-editor.org/rfc/rfc9530.txt`,
  access date 2026-11-08, a located quote of 9 words ("Receivers can validate
  the digest for integrity purposes.", §1.2 Concept Overview), decision
  **admit, tier A**, and a reason cell carrying the capture's raw sha256 and
  byte count, its rendered-text-v1 normalized sha256 and normalized byte
  count, and the locate receipt. Every number in that cell is produced by a
  command shown in the cell or in the receipt
  `.ufo/waves/round-67/w1/R67ScribeLesson/s166-capture.txt`.
- **`## Corrigendum — round 66 (pointer; the pairs live in the round-66
  lesson)`**: per the L1's mid-wave pin, the seven old→new `used-by` pairs
  are **not** duplicated here. The section states the routed defect (the
  round-66 closure's defect 7), names **S113** explicitly, states the
  SOURCES contract v1 rule 2 the repair discharges ("only `status`,
  `recheck` and `used-by` change in place, and each change is logged
  old→new in the round lesson"), and gives the re-runnable derivation
  (`git show d549ee6:corpus/SOURCES.md` vs `corpus/SOURCES.md`). The
  wording follows the L1's Amendment A1 correction: seven rows were touched
  — six existing `used-by` cells changed (S113, S143, S145, S148, S152,
  S156) and one row (S164) appeared.
- **`## Mistakes`**: heading present with the single placeholder line
  `(filled at integration by the L1)`. No mistake is invented by this seat.

### 2. `corpus/QUALITY.md` — QM95, QM96

Appended under a new section heading
`## Criteria from the round-67 capture-binding and receipt-integrity review
(scribe seat)`, in the same 4-column table shape as QM89–QM94 (`id |
criterion | weak signal | lesson`); verified: every `| QM* |` row in the
file parses to exactly 4 cells, and QM95/QM96 are cells=4.

- **QM95** — a declared capture location is *governed* only when the gate
  reads the bytes **and** the declared quote locates under the declared
  normalization; an existence/length check is a defect of the gate, not a
  ceiling. Cites `corpus/lessons/round-66.md` §Mistakes M66-13, and names
  QM94 as the bytes half it extends.
- **QM96** — a receipt cited from a report must exist in the tree the report
  names; a reconstructed receipt names its provenance in its own header.
  Cites `corpus/lessons/round-66.md` §Mistakes M66-12 and
  `corpus/lessons/round-66-verifier-spotcheck.md` §1.2 (the cited BASE
  receipt absent from the tree and from every commit).

### 3. `corpus/README.md` — two coverage-map rows + four stale self-counts

Rows added to the `## Coverage map` table (each `| Area | Entry | Source
basis |`, three cells, matching the table's shape):

- `corpus/knowledge/claim-instrument-carrier-binding.md` — the round-66
  entry that existed with no map row (this is C2 leg **L3**). Text only; no
  number in it.
- `corpus/knowledge/source-capture-binding.md` — this round's entry, which
  does not exist yet (R67ScribeEntry's file). Text only, as instructed: no
  number in it that no command re-derives.

Plus the L1's mid-wave pin: four stale self-counts on `corpus/README.md`
lines 64–67, measured identical at BASE, updated to the live values while
keeping the sentence shape — `ledger rows 96 → 99`, `stamps 160 → 163`,
`docs row_linked 41 → 44`, `docs entries 44 → 47`. The docs pair was then
**re-derived a second time** after R67ScribeEntry's entry landed mid-wave
(see F5): `README:67` now reads `45 row-linked / 3 by-hand / 48 pinned`,
the values the three `RD-DOCS-*` rows bind against once that entry is
stamped.

## Commands run, and what they read

| command | reading |
|---|---|
| `python3 -I -B corpus/self-counts.py` (before) | `STALE RD-LEDGER-ROWS corpus/README.md:64 claimed=96 live=99`; `STALE RD-STAMPS …:65 claimed=160 live=163`; `STALE RD-DOCS-ROWLINKED …:67 claimed=41 live=44`; `STALE RD-DOCS-ENTRIES …:67 claimed=44 live=47`; `POLICY` on two rows (a pre-existing allowlist policy, not a stale count) |
| `python3 -I -B corpus/self-counts.py` (after the first edit, before the sibling's entry landed) | `OK RD-LEDGER-ROWS …:64 claimed=99 live=99`, `OK RD-STAMPS …:65 claimed=163 live=163`, `OK RD-DOCS-ROWLINKED …:67 claimed=44 live=44`, `OK RD-DOCS-BYHAND …:67 claimed=3 live=3`, `OK RD-DOCS-ENTRIES …:67 claimed=47 live=47`. The only `STALE` left was three *other* files (`SKILL.md:50`, `PROVINCE.md:78`, `SCORECARD.md:701`, each `claimed=78 live=88` — the census selftest tally, whose pin is the L1's landing surface, not this seat's) |
| `python3 -I -B corpus/self-counts.py` (after R67ScribeEntry's entry landed mid-wave) | the docs counts moved with the entry set: `OK RD-LEDGER-ROWS …:64 claimed=99 live=99`, `OK RD-STAMPS …:65 claimed=163 live=163`, and the three `RD-DOCS-*` rows now read **`SETUP … ledger:R14-01 exit=1 expected=0`** — not STALE — because the ledger row's command exits 1 while `DOC_AUDIT` is BROKEN. `README:67` was re-derived to **45 row-linked / 3 by-hand / 48 pinned**, which is what the rows bind against once the entry is stamped (measured on a fixture: `DOC_AUDIT: CLEAN (entries=48 row_linked=45 by_hand=3 … unpinned=0 …)` and `OK RD-DOCS-ROWLINKED claimed=45 live=45`, `OK RD-DOCS-ENTRIES claimed=48 live=48`). Final line: `SELF_COUNTS: POLICY (claims=63 stale=0 unlocated=0 ambiguous=0 policy=2 setup=3)`. |
| `bash corpus/claim-ledger.sh docs` | `DOC_AUDIT: BROKEN (entries=48 row_linked=45 by_hand=3 undeclared=0 missing_ids=0 unpinned=1 …)` — `UNPINNED corpus/knowledge/source-capture-binding.md (knowledge entry is not a row in the stamps file)`. The sibling's entry landed but was not stamped. **This is the round-66 lesson's M66-14 class** (an entry landed undeclared and unpinned, and the gate that would say so is what caught it) and it is the L1's to fix: stamp the entry. |
| `bash corpus/sources-census.sh` | after the sibling S115 re-cut landed: `SOURCES_CAPTURES: CLEAN (path_rows=36 bound=36 located=36 prose=120)` and `SOURCES_CENSUS: CLEAN (rows=156 …)`. After the L1's S166 registry + fetch rows landed: `SOURCES_CAPTURES: CLEAN (path_rows=36 bound=36 located=36 prose=121)` and `SOURCES_CENSUS: CLEAN (rows=157 A=140 B=2 C=15 queued=3 mined=137 rejected=17 …)` — the `prose` 120 → 121 and `rows` 156 → 157 are the expected reading per Amendment A3 item 2 (F7), not drift. |
| `bash plans/round-67-c2.sh --tree .` | `LEG L3 verdict=ok map-row:119 cells=3 entry=present` (the map row this seat added), all seven legs `ok`, `C2_FIDELITY: mismatches=0 population=7 guard=1` |
| `bash plans/round-67-c1.sh --tree .` | `C1_READTHROUGH: bound=36 located=36 caught=6/6 guard=1` |
| `bash corpus/claim-ledger.sh citations` (full doc set, real lane) | `CITATION_GATE: BROKEN (cites=5186 docs=171 unresolved=32 ephemeral=0 labeled=24)`. **30 of the 32 live in files this seat did not touch** (SCORECARD.md 6, round-62 3, round-66/65/60/54/44 spot-checks and lessons 2 each, …, LOG.md 1) — the lane's own ledger row `R11-08` expects `unresolved=0`, so the gate was already BROKEN before this seat's edits. **The 2 this seat introduces are the forward reference** (`corpus/README.md:120` and `corpus/lessons/round-67.md:23`, both naming `corpus/knowledge/source-capture-binding.md`), and both resolve the moment that entry file exists. |
| `bash corpus/claim-ledger.sh citations --docs corpus/lessons/round-67.md` | `UNRESOLVED corpus/lessons/round-67.md:23 corpus/knowledge/source-capture-binding.md (local)` → `CITATION_GATE: BROKEN (cites=8 docs=1 unresolved=1 …)` — the lesson's only unresolved token is the same forward reference. On a fixture where the entry file is present, the same command reads `CITATION_GATE: CLEAN (cites=8 docs=1 unresolved=0 …)`. |
| `bash corpus/self-description-sweep.sh` | `SELF_DESCRIPTION: MISMATCH n=37 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=4 SD6=32 SD7=0 SD8=1 SD9=0)`, exit 1. SD6 mirrors the citation gate's unresolved list, so it carries the same 2 forward references (`MISMATCH SD6 corpus/lessons/round-67.md:23 …` and `corpus/README.md:120`). SD5=4 and SD8=1 (`SCORECARD.md:1700` `M44-1..M44-3` vs a `| M44-4 ` row) are pre-existing and are not this seat's files. |
| `git archive 076701a` extraction + `bash corpus/self-description-sweep.sh` | `SELF_DESCRIPTION: MISMATCH n=24 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=4 SD6=19 SD7=0 SD8=1 SD9=0)`, exit 1 — **the sweep is already BROKEN at BASE**, with the same SD5=4 and SD8=1 findings. Not a like-for-like count (an extraction is a lone-clone layout, so the sibling/fleet citation classes are unchecked), but it establishes that the sweep's BROKEN verdict and the SD8 finding both pre-date this seat. |
| `git archive 076701a` extraction + `bash corpus/claim-ledger.sh citations` | `CITATION_GATE: BROKEN (cites=5152 docs=170 unresolved=19 … fleet_absent=264)` — **not** a like-for-like baseline: an extraction has no fleet root beside it, so the sibling-class citations are not checked. The like-for-like statement is the 30-of-32 breakdown above. |
| `bash corpus/scope-gate.sh` | `ADJACENCY_SCOPE: DEFECT (… stale_basis=0 …)` on the working tree vs `stale_basis=2` on a `076701a` extraction — the defect is pre-existing at BASE and unrelated to this seat's rows (it is about `$HOME` breadth pins, not the coverage map) |
| `python3 corpus/rendered-text-v1.py locate` / `digest`, `sha256sum`, `wc -c` | the S166 numbers in the Gate cell |

## Findings

**F1 (ordering, needs the L1) — this seat's two forward references to
`corpus/knowledge/source-capture-binding.md` read as unresolved citations
until that entry lands.** The README coverage-map row is required by this
seat's spec ("write the row now, text only"), and the lesson's Gate cell
names the same entry it grounds. Both are the same token, so both resolve
together:

- `bash corpus/claim-ledger.sh citations --docs corpus/README.md` →
  `UNRESOLVED corpus/README.md:120 corpus/knowledge/source-capture-binding.md (local)`;
  on a fixture where the entry file exists, the same command reads
  `unresolved=0`.
- `bash corpus/claim-ledger.sh citations --docs corpus/lessons/round-67.md` →
  `UNRESOLVED corpus/lessons/round-67.md:23 …`; on the fixture with the
  entry present, `CITATION_GATE: CLEAN (cites=8 docs=1 unresolved=0 …)`.

**Calibration:** the lane's citation gate is *already* BROKEN before this
seat's edits — the full-doc-set run reads `unresolved=32`, of which **30
live in files this seat did not touch** and only **2 are this seat's**
forward references. The lane's own ledger row `R11-08` expects
`CITATION_GATE: CLEAN (… unresolved=0 …)`, so the pre-existing 30 are
already a standing defect of the lane (not introduced here). This seat's
delta is +2 unresolved and +2 SD6 findings, both of which disappear the
moment `corpus/knowledge/source-capture-binding.md` exists.

**Action for the L1:** land R67ScribeEntry's entry file in the same commit
as (or before) these two surfaces, so the landed tree carries no new
unresolved citation. The alternative — deferring the README row — was
rejected: the spec asks for the row now, and C2 leg L3's counter reads a
map row for the *other* entry (it reads `ok` on this seat's row already),
so deferring would leave the map's round-67 row absent from the landed
tree. Receipts: `citation-findings.txt`, `citation-readme.txt`,
`self-description-sweep.txt`.

**F2 (informational, no action for this seat) — the S166 fetch row's
declared normalization decides whether the quote locates.** The declared
quote "Receivers can validate the digest for integrity purposes." locates
`count=1` under `rendered-text-v1`, but the RFC body wraps the sentence
across two lines, so the literal substring count is **0**
(`grep -c -F` ⇒ 0). Measured on fixtures: a fetch row declaring
`raw-literal-v1` with this quote yields
`FINDING SC_CAPTURE id=S166 quote-not-located`; the same row declaring
`rendered-text-v1` with normalized sha256
`652d311657f00e1eab513b15db807d773b42294d7032e179f63d04909943436b` binds and
locates. The lesson's Gate cell states this measurement and the
consequence. This is the L1's and R67ScribeEntry's row to write; this seat
records the measurement, not the row.

**F3 (calibration, reported for the L1) — the round-66 corrigendum's own
wording was corrected by Amendment A1, and this seat's pointer follows the
amendment.** The L1's `plans/round-67.md` Amendment A1 corrected "seven
`used-by` cells changed" to "six changed and one row appeared"; the
L1-landed `corpus/lessons/round-66.md` §Corrigendum now reads that way, and
this seat's round-67 pointer was written to match. The seven **ids** are
unchanged (S113, S143, S145, S148, S152, S156, S164) and C2 leg L7 reads
`corrigendum ids=7 pairs=7`.

**F4 (informational, moves with the wave) — three self-count pins are stale
on files this seat does not own.** `SKILL.md:50`, `PROVINCE.md:78` and
`SCORECARD.md:701` each pin the census selftest count; at this seat's last
read they read `claimed=88 live=89`. (Earlier in the wave they read
`claimed=78 live=88`.) These three are the L1's landing surface — the frozen
plan's C1 landing surface names "`PROVINCE.md` / `SKILL.md` selftest-count
pins updated to the measured count" — and the lane's `SKILL.md` and
`PROVINCE.md` are not this seat's to write. The same drift will move
`README:65` once the L1 stamps the changed artifacts.

**F5 (mid-wave drift, needs the L1) — the sibling's knowledge entry landed
unstamped, and this seat's README docs counts moved with it.**
`corpus/knowledge/source-capture-binding.md` (R67ScribeEntry's file) landed
after this seat's first `self-counts.py` run. Two consequences, both
measured:

1. **The entry is not in `corpus/stamps.tsv`**, so
   `bash corpus/claim-ledger.sh docs` reads
   `DOC_AUDIT: BROKEN (entries=48 row_linked=45 by_hand=3 undeclared=0 missing_ids=0 unpinned=1 …)`
   with `UNPINNED corpus/knowledge/source-capture-binding.md`. This is the
   round-66 lesson's **M66-14** class — an entry landed undeclared and
   unpinned, and the gate that would say so is what caught it. The fix is
   the L1's: stamp the entry. On a fixture with the entry's stamp row
   added, the audit reads
   `DOC_AUDIT: CLEAN (entries=48 row_linked=45 by_hand=3 undeclared=0 missing_ids=0 unpinned=0 …)`.
2. **This seat re-derived `README:67` to `45 row-linked / 3 by-hand / 48
   pinned`** (it was 44 / 3 / 47 before the entry existed), because those
   three rows bind against `ledger:R14-01`'s `DOC_AUDIT` line and the entry
   set moved. On the stamped fixture the three rows read `OK` against
   45 / 3 / 48. **The L1 must re-run `python3 corpus/self-counts.py` after
   stamping**, because `README:65` (`stamps`) also moves from 163 to 164
   with the entry's stamp row. Receipt: `self-counts.txt`.

**F6 (L1's decision, recorded) — README numbers are the L1's to finalize.**
The L1 answered F5: it will run `bash corpus/claim-ledger.sh stamp` over the
changed artifacts (including the new entry) after the last edit, then re-run
`corpus/claim-ledger.sh docs` and `python3 corpus/self-counts.py`, and will
update `README:64-67` itself to the final derived values. **This seat has
stood down on the README numbers** and makes no further edit to them. The
values this seat left in the tree (`99` / `163` / `45 row-linked / 3 by-hand /
48 pinned`) are the ones measured at its last read, not a claim about the
landed tree.

**F7 (recorded, not drift) — the census's `prose` count rose to 121 and
`rows` to 157.** The L1's `plans/round-67.md` Amendment A3 (item 2) records
why: the S166 fetch row's location column is **prose** (it names the section
and the capture path in a sentence), so `path_rows` / `bound` / `located`
keep their frozen 36/36/36 while `prose` rises 120 → 121. The current tree
reads `SOURCES_CAPTURES: CLEAN (path_rows=36 bound=36 located=36 prose=121)`
and `SOURCES_CENSUS: CLEAN (rows=157 …)`. **121/157 is the expected reading,
not drift.** The consequence — S166's capture is *not* gate-checked, so its
sha256, byte count and quote location are verified by hand — is recorded in
the lesson's `## Gate` cell, and the lesson says so explicitly rather than
leaving the reader to infer that the gate covered it.

**Caveat on every reading in this report.** The tree moved under this seat
three times (S115's re-cut, the sibling's knowledge entry, the S166 registry
+ fetch rows). Every number here was measured at the moment stated; the L1
re-runs every gate at integration, and the L1's own numbers are the ones the
landed tree is graded on.

## Out of scope (named, not absorbed)

- The `SCORECARD.md` round-66 operability cell and the `SKILL.md` C1
  selftest pin (C2 legs L1/L2) — the L1's and R67ExecCounterC2's surfaces.
- The three stale selftest-count pins above (F4).
- The `corpus/knowledge/source-capture-binding.md` entry itself
  (R67ScribeEntry, landed), its stamp row (the L1, F5), and the S166
  registry + fetch rows (the L1, landed).
- Round-66 routed defects 4 and 5 (fleet-root report surfaces, no lane may
  write them) — Amendment A1's item 1 places them out of C2's population.

## Touched surfaces (this seat)

- `corpus/lessons/round-67.md` — **new** (sole writer).
- `corpus/QUALITY.md` — QM95, QM96 appended (sole writer).
- `corpus/README.md` — two coverage-map rows + four self-count numbers.

Receipts (this seat's directory):

- `.ufo/waves/round-67/w1/R67ScribeLesson/s166-capture.txt`
- `.ufo/waves/round-67/w1/R67ScribeLesson/capture-path-measurement.txt`
- `.ufo/waves/round-67/w1/R67ScribeLesson/capture-path-rows.json`
- `.ufo/waves/round-67/w1/R67ScribeLesson/used-by-diff.txt`
- `.ufo/waves/round-67/w1/R67ScribeLesson/used-by.old.tsv`
- `.ufo/waves/round-67/w1/R67ScribeLesson/used-by.new.tsv`
- `.ufo/waves/round-67/w1/R67ScribeLesson/citation-findings.txt`
- `.ufo/waves/round-67/w1/R67ScribeLesson/citation-readme.txt`
- `.ufo/waves/round-67/w1/R67ScribeLesson/self-description-sweep.txt`
- `.ufo/waves/round-67/w1/R67ScribeLesson/counter-readings.txt`
- `.ufo/waves/round-67/w1/R67ScribeLesson/final-state.txt`

Not committed (seats never commit; the L1 is the sole integration owner and
committer).
