# K46ScribeCurate — round 46 curation drafts (coverage rows + erratum E46-1)

Seat: K46ScribeCurate (scribe, leaf member — no subagent dispatch).
Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`.
BASE `f5977284a8ce5bab09252be8196ee5dc18489926`; predeclaration
`44808ced56359c98f35995178fb24a6482899263` = HEAD at read time
(`git rev-parse HEAD`, `git log --oneline -3` → `44808ce`, `f597728`, `0ece74d`).
Scratch `/fast/scratch/hyaku/kagi-r46/K46ScribeCurate` created, unused beyond
`mkdir -p` (no clone, archive or fixture was needed for prose drafting).

## Behavior

Two prose deliverables, written only under
`.ufo/waves/round-46/build/K46ScribeCurate/`:

1. `coverage-rows.md` — the two missing `corpus/README.md` coverage-map rows
   (spotcheck §5 item 1, `corpus/lessons/round-45-verifier-spotcheck.md:102`),
   in the table's exact 3-column shape (`corpus/README.md:17-18`), each with a
   claim-by-claim `path:line` pointer table:
   - `corpus/knowledge/iso-11770-3-edition-status.md` — round 45 C2
     (`…:4`), registry rows S100/S101/S102 (`corpus/SOURCES.md:107-109`),
     added by `072bb0b` (2026-11-05).
   - `corpus/knowledge/feed-token-boundaries.md` — round 29
     (`…:9`, `…:28`), registry rows S045/S052 (`corpus/SOURCES.md:52`,
     `:59`), added by `fc65112` (2026-11-01).
   Insertion point stated as after `corpus/README.md:98` (last table row,
   round-35 lesson), matching the append order of the round-33/34/35 rows.
2. `erratum-E46-1.md` — erratum for
   `.ufo/waves/round-45/final/measured-at-candidate.txt` (spotcheck §5 item 3,
   `…spotcheck.md:104`):
   - defect 1: line 6 `$ bash plans/round-45-c1.sh LANE (pre-candidate control at tree)`
     has no output line (line 7 is the next header); correct reading is
     `C1_BIJECTION: value=0 detected=0 positive=1 real=CLEAN (… tree=LANE …)`
     per `.ufo/waves/round-45/controls/c1-base.txt:1` and `plans/round-45.md:31`
     (restated `plans/round-45.md:127`), cross-backed by
     `controls/claims-declared-base.txt:1`.
   - defect 2: line 35 `stamp rc=2` precedes its own invocation header
     (line 36); correct reading is `STAMP_DRIFT: rows=123 drift=0` /
     `stamp rc=0` per `final/stamp-drift-at-candidate.txt:1-2`; `rc=2` is
     usage/setup only in that tool
     (`.ufo/waves/round-45/build/K45ExecStampRW/stamp-drift.py:24-26`, `:29-31`),
     drift≠0 would be rc=1 (`:5-8`), and `wc -l corpus/stamps.tsv` → `123`
     agrees with `rows=123`.
   - states the receipt is not rewritten: no byte of `.ufo/waves/round-45/` is
     touched by round 46.

## Gates

- **No lane gate, counter, selftest or verify was executed.** The seat spec
  forbids the lane's full claim-ledger verify and self-counts, and names no
  script for this item; `plans/round-46-c1.sh` / `-c2.sh` belong to other seats.
- Commands run (all read-only; full table with rc and observed output in
  `build/K46ScribeCurate/evidence-commands.txt`): `git rev-parse`, `git log`,
  `git show <rev>:corpus/stamps.tsv`, `grep`, `wc`, `ls`, `sed`, `cat`, `comm`.
- No network access; no vault/op/janitor contact; no secrets read or written.
- No tool installed or upgraded.

## Touched surfaces

- Written (3 files, all inside the seat's write scope):
  - `.ufo/waves/round-46/build/K46ScribeCurate/coverage-rows.md`
  - `.ufo/waves/round-46/build/K46ScribeCurate/erratum-E46-1.md`
  - `.ufo/waves/round-46/build/K46ScribeCurate/evidence-commands.txt`
  - this report: `.ufo/waves/round-46/build/K46ScribeCurate.md`
- Read-only: `corpus/README.md`, `corpus/SOURCES.md`, `corpus/stamps.tsv`,
  `corpus/claim-ledger.tsv`, `corpus/claim-ledger.sh`, `corpus/self-counts.tsv`,
  `corpus/lessons/round-45-verifier-spotcheck.md`, `corpus/lessons/round-45.md`,
  `plans/round-45.md`, the two knowledge entries,
  `.ufo/waves/round-45/{final,controls,build}/…`.
- Not modified: `corpus/`, `plans/`, `SCORECARD.md`, `LOG.md`, `SHONEN.md`,
  `SKILL.md`, `README.md`, `MANIFEST.json`, `.ufo/state`, any registry row, any
  sibling repo. No `git add/commit/checkout/reset/push`; no jj mutation.

## Findings

1. **The round-45 entry is outside both declaration surfaces (live at BASE).**
   `corpus/knowledge/iso-11770-3-edition-status.md` has no `Reverify:` line
   (`grep -c '^Reverify:'` → `0`; 35 of 36 entries carry one) and no
   `corpus/stamps.tsv` row (`grep -c 'iso-11770' corpus/stamps.tsv` → `0`,
   also at `072bb0b`; 35 `corpus/knowledge/` rows for 36 entries).
   Static reading of `corpus/claim-ledger.sh` `doc_audit`: it enumerates every
   `*.md` (`:1129`), prints `UNDECLARED` for a file with no declaration
   (`:1145`) and `UNPINNED` for an entry missing from the stamps file (`:1197`),
   so the audit would report `entries=36 … undeclared=1 … unpinned=1` and exit 1,
   while ledger row `R14-01` (`corpus/claim-ledger.tsv:32`) expects
   `DOC_AUDIT: CLEAN (entries=35 … undeclared=0 … unpinned=0)`.
   **Not executed** (seat forbids the verify); the claim is the code path plus
   the measured absences, and it needs an executing seat to confirm.
   Why it survived round 45: the stamp witness only compares listed rows, so
   `STAMP_DRIFT: rows=123 drift=0` is blind to an unstamped file, and the
   round-45 lesson's E45-1 (`corpus/lessons/round-45.md:40`) says the round
   re-pinned "through `corpus/claim-ledger.sh stamp`" without naming this entry.
2. **The coverage map has no gate and no pinned count** — `grep` for `README`
   in `corpus/claims-declared.sh` and for `coverage` in `corpus/self-counts.tsv`
   / `corpus/self-description-sweep.sh` prints nothing, so the two rows are
   prose until something cites them (matches spotcheck §4's
   "unprovable-but-better" reading of expansion).
3. **`corpus/README.md` is itself a stamp row** (`corpus/stamps.tsv:96`,
   `833d4b39…`, 252 lines, 34462 bytes): landing either row makes that row
   stale and requires a reviewed `stamp` re-pin under the row-set replacement
   guard (`corpus/README.md:63`). Recorded in the draft's landing cautions so
   the landing seat cannot land the rows and leave drift.
4. **Receipt defects confirmed, not repaired in place** — the two defective
   lines exist exactly as the spotcheck describes (`measured-at-candidate.txt:6`,
   `:35`), and the correcting values are committed in
   `final/stamp-drift-at-candidate.txt:1-2` and `controls/c1-base.txt:1`.
   Handled by erratum only, per the spotcheck's "never by rewrite".

## Out of scope (not done, by spec)

- The round's C1 selftest kills M1–M3, the C2 clock rebound, the M46-1 ledger
  row, pre-candidate attacks and the claimed-axis judgments — other seats.
- Any edit to `corpus/README.md`, `corpus/knowledge/*`, `corpus/stamps.tsv`,
  `corpus/claim-ledger.tsv`/`.sh`, `plans/*`: this seat drafts prose only.
- No fix attempted for finding 1 (write scope excludes `corpus/`); it is routed
  here for the landing/executing seat.
- No live re-open of S100–S102 (public pages) — the drafts quote only committed
  bytes and committed receipts.

## Artifact paths

- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-46/build/K46ScribeCurate.md`
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-46/build/K46ScribeCurate/coverage-rows.md`
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-46/build/K46ScribeCurate/erratum-E46-1.md`
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-46/build/K46ScribeCurate/evidence-commands.txt`
- scratch (empty): `/fast/scratch/hyaku/kagi-r46/K46ScribeCurate`

SEAT-STATUS: complete
