# AttackCells — round-31 BUILD, C1 attack (silent-content-change & bookkeeping completeness)

Seat: AttackCells (leaf, no dispatch). Scope: plans/round-31.md §C1, SCORECARD.md,
corpus/claim-ledger.sh/.tsv, corpus/stamps.tsv — all READ-ONLY in the lane; every
experiment ran in my scratch clone `/fast/scratch/hyaku/kagi-r31/AttackCells/clone`
(lone clone of the lane; asserted `git rev-parse --show-toplevel` = the clone dir
before any fixture mutation). Frozen BASE `655e620`; the four C1 files are
byte-identical from BASE through lane HEAD `2d46e575` (the L1 committed during the
wave; `git diff 655e620…HEAD` over the four files is empty), so all fixture evidence
is BASE-valid.

No tools were installed (none needed). No pacman transactions. No network use. No
credential/`op` contact beyond nothing (not touched at all). Scratch deleted before
yield (receipts copied into `.ufo/waves/round-31/build/` first).

## F1 — MUST-FIX: the plan's C1 migration list is missing R13-01; without it C1's own predicate is unreachable

plans/round-31.md §C1 migrates "the three heading/revision identity rows": R24-06,
R24-15, R22-03. A fourth row breaks at the round-31 tip and is not named:

- `corpus/claim-ledger.tsv:29` — `R13-01` = `grep -c '^## Round ' SCORECARD.md`,
  expectation `^36$` exit 0, note "identity-free round-heading count … WHICH heading
  texts is pinned by R24-06".
- The round legitimately adds its own two sections ⇒ count 36 → **38**.
- R13-01 is cited by the round-23 post-move cell (`SCORECARD.md:865`: "`R13-01`'s
  identity-free round-heading count"), so `cells` re-runs it (`cells_evidence`).

Demonstrated at a simulated tip in the scratch clone (BASE + the five-reshape +
legal `## Round 31 — pre-move`/`post-move` sections appended + LC_ALL=C full-set
re-stamp): `bash corpus/claim-ledger.sh cells` prints

```
FAIL R13-01 reason=verdict-not-final exit=0
FAIL R24-06 reason=verdict-not-final exit=0
FAIL R25-02 reason=exit-mismatch exit=2 want=0
POLICY R29-01 reason=first-token:python
POLICY R29-02 reason=first-token:python
CELL_AUDIT: POLICY (cells=222 row_pointed=159 stamp_pointed=94 policy=2)  [exit 2]
```

The extra `FAIL R13-01` violates the frozen predicate ("every FAIL/POLICY row line it
prints is exactly … R25-02, R29-01, R29-02") ⇒ by C1's own kill rule the claim would
honest-stop on a defect the round itself caused. Fix: migrate R13-01 `^36$` → `^38$`
in the same landing with the old→new record in `corpus/lessons/round-31.md`
§Migrations — i.e. **four** identity rows, and a plan correction BEFORE the first
work commit (QM29 correction window), since the migration set is frozen plan content.
After patching R13-01/R24-06 to the measured values in the clone, both row commands
pass (grep count 38; `row-identity.sh scorecard-rounds` `count=38
sha256=b14d391d…`).

## F2 — MUST-FIX (operational): the stamp re-pin is locale-sensitive; run it under LC_ALL=C

`claim-ledger.sh` never pins `LC_ALL` (no match in the script) and `stamp` re-sorts
the whole row set (`corpus/claim-ledger.sh:438` `sort -o "$STAMP_TMP" "$STAMP_TMP"`).
Demonstrated in the clone, identical input, two locales:

- ambient `en_US.UTF-8`: the re-pin rewrote **22 lines** — 8 rows (`LOG.md`,
  `PROVINCE.md`, `SCORECARD.md`, `SHONEN.md`, `SKILL.md`, `corpus/QUALITY.md`,
  `corpus/README.md`, `corpus/SOURCES.md`) re-collated out of their committed
  positions. The one semantic change is buried in collation churn.
- `LC_ALL=C`: the diff is **exactly 1 row** — `corpus/stamps.tsv:3`
  `SCORECARD.md f4eb6ec481f1… 1252 134670` → `SCORECARD.md ea0ba36fb843… 1252
  134700` (lines unchanged at 1252; bytes +30). The committed file is C-ordered
  (the C run reproduces it byte-for-byte apart from that row).

The reviewed re-pin flow is `stamp PATH…` over the **full 99-path set** (the shrink
guard refuses any smaller set; help text: "Regenerating is a reviewed commit, not an
automatic re-pin"), so the landing command is:
`LC_ALL=C bash corpus/claim-ledger.sh stamp <all paths from stamps.tsv>` — and it
must name the new round-31 artifacts too in the same landing (new stamps are what
moves R22-03/R24-15's `added` membership; the reshape alone does not — see F3).

## F3 — evidence: the order (edits → stamp → row migration → cells run) is mechanically forced

Each step is demonstrated, not asserted, in the scratch clone:

1. **Edits first.** Five anchored full-line substitutions (draft in
   `build/AttackCells-reshape.sed`); `git diff --stat` = `5 insertions(+),
   5 deletions(-)`, `SCORECARD.md` only; per-line byte deltas +12/+12/+1/+6/−1
   = +30 bytes; line count 1252 unchanged. Each old line occurs exactly once
   (anchored `grep -c` = 1), so no other byte can move.
2. **Stamp before ANY gate run.** Post-reshape, pre-re-pin:
   `python3 corpus/revision-audit.py --history c2cab35…` ⇒ `REVISION_AUDIT: DRIFT
   (stale=1 …)` exit 1, the one finding `STALE SCORECARD.md` (revision-audit.py
   emits STALE when a stamp's sha/lines/bytes no longer match the worktree). R22-03
   and R24-15 (which "requires revision-audit to exit 0") both fail in this state,
   and `cells`' stamp-pointed cells would print STALE-POINTER (CL_STALE > 0 ⇒
   `CELL_AUDIT: BROKEN`). Post-re-pin: `REVISION_AUDIT: CLEAN (stale=0 missing=0
   dropped=0 added=36 invalid=0)` exit 0 — **the reshape alone does not move
   `added=36`**; R22-03/R24-15 migrate once, at the measured tip, only when the
   round's new paths are pinned.
3. **Row migration before the receipt.** At the simulated tip with un-migrated rows,
   cells prints `FAIL R13-01`/`FAIL R24-06` (F1). After migrating those two
   expectations to the measured values, the row commands pass individually. Only
   then is the frozen receipt (`final/receipts/cells-at-tip.txt`) produced — no
   intermediate state is citable because every intermediate is red by measurement.
4. Receipt last; grading note: with R29-01/R29-02 staying POLICY, the case dispatch
   prints `CELL_AUDIT: POLICY (…)` exit 2 (the POLICY branch precedes the BROKEN
   check). That is the expected tip shape — the predicate's "completes to a
   CELL_AUDIT: summary line" is satisfied by the POLICY summary; graders should not
   read `POLICY` as a C1 failure.

## F4 — MUST-FIX (plan omission): round-31's own sections have no stated shape requirement

plans/round-31.md nowhere states that the round's own SCORECARD sections must land
in parser-legal `## Round 31 — pre-move|post-move` shape from their first commit.
The only coverage is the reactive kill rule ("If the round-31 sections themselves
cannot be made audit-clean, the claim stops"). The parser is strict
(`corpus/claim-ledger.sh:940-944`: `SEC_RE='^ {0,3}##[[:blank:]]+Round [0-9]+ —
(pre|post)-move([[:blank:]]|$)'`, else `die "unrecognised round heading"`, exit 2
before anything is audited), and the two new headings are exactly what moves
R13-01/R24-06 counts by +2. A malformed first draft of either section re-arms the
same round-26 debt this claim exists to retire. The plan (correction window) or the
lesson's Gate should bind: round-31 sections land pre-move/post-move shaped, all six
axes, from the start. The five new heading strings themselves match `SEC_RE`
(demonstrated: 0 setup errors in the simulated-tip run; `cells=222` over 37 scored
sections, ≥ the frozen 210 floor).

## F5 — byte discipline (item 1): verified content-preserving

- Draft sed expressions: committed as `build/AttackCells-reshape.sed` (five
  `s/^old$/new/` lines, em-dash U+2014, en-dash U+2013 in `D1–D5`, byte-identical
  old lines from `cat -A`).
- Clone run: `git diff --stat` ⇒ `SCORECARD.md | 10 +++++-----` = **5 lines / 5
  insertions / 5 deletions, SCORECARD.md only**; the ± lines are exactly the five
  plan-recorded old→new pairs (R29 `(new host)` → `on the new host)`, R30
  `(D1–D5),` → `D1–D5,` included).
- New stamp values (measured): sha `ea0ba36fb843b1e06a28602d3a465c7e58f2f077ecc24f0
  d6de8a55e9df6aeaf`, lines 1252 (unchanged), bytes 134700 (+30). New R24-06
  identity at the 38-heading tip: `count=38 sha256=b14d391dde1d4caf7d95ef47fd4b9c70
  b249e0262623a8389bba5d4e3a10e3ba` (old pin `count=36 sha256=1259a3e1…`). R13-01
  `^36$`→`^38$`.
- Line-number neutrality: the reshape modifies five lines in place, so every
  existing `SCORECARD.md:<line>` citation in live docs stays pointer-valid.

## F6 — committed references to the old strings (item 2): all history-class, none break

Full lane grep (excluding .git/.jj) over `*.md`+`*.tsv` for the five old-string
fragments; classification:

- `SCORECARD.md:1018,1082,1110,1181,1239` — the reshape targets themselves.
- `plans/round-31.md` — the frozen old→new record; quoting is the contract, not a
  pointer.
- `.ufo/waves/round-26/residual/FinalBookkeeping.md:18` (plus its round-27 sandbox
  copy) — quotes the old heading as the round-26 receipt evidence; frozen wave
  history, and the reshape keeps its line citation valid (line-neutral). History.
- `.ufo/waves/round-27/sandboxes/*/base/{SCORECARD.md,residual/…}` — frozen BASE
  copies inside sandbox fixtures. History.
- `.ufo/waves/round-28/build/RevScorecardShape{.md,-commands.md}` — the routed
  round-28 debt record; quotes old strings as the evidence of the setup error this
  round resolves. History (the debt closes; the record stays true of BASE).
- `.ufo/waves/round-28/build/ScribeLogEntry.md:35`, `corpus/lessons/round-{28,29,30}.md:5`,
  `LOG.md:1530,1593,1646` — near-miss substrings of *different* full strings (LOG
  headings and lesson H1s, e.g. "…derived anchors bound to their feed rows
  (2026-10-21)"). LOG.md is append-only history; nothing cites the SCORECARD
  headings through them. Not broken.
- **No `.tsv` hit quotes heading text**: ledger expectations pin counts and digests
  only — which is exactly why F1 (count rows) and the R24-06 digest are the real
  migration surface.

## F7 — residual risk & verification gaps

- Clone HEAD moved 4767b04 → 2d46e575 mid-wave (L1 commits). All C1-file evidence
  re-anchored against `2d46e575` (byte-identical to BASE for the four files). The
  frozen predicate must still be graded in the LANE at the measured tip — my
  simulated-tip run is a lone-clone fixture; host-dependent rows could degrade
  differently in-lane (QM22: typed INCOMPLETE/FLEET-ABSENT outputs there are layout
  artifacts, not lane defects). The three routed reds reproduced in the clone
  exactly as the plan names them (R25-02 FAIL, R29-01/R29-02 POLICY
  `first-token:python`), zero STALE-POINTER lines.
- The simulated round-31 sections used fixture cells citing existing rows; the real
  sections' own cell pointers are the L1's landing content and are out of my scope.
- `corpus/lessons/round-31.md` does not exist at BASE (verified) — the §Migrations
  old→new record (now four rows, per F1) is in-round work and must land with the
  reshape.
