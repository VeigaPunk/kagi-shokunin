# CensusBase — BASE re-derivation, scoped seat report

Full version: `.ufo/waves/round-31/CensusBase-report.md`. Receipts: `.ufo/waves/round-31/base/`.
Lane read-only throughout; BASE identity proved (`git diff --stat 655e620 -- corpus SCORECARD.md LOG.md
SOURCES.md` is empty at HEAD `4767b04`). No network, no installs, no credentials, no git/jj mutation.

## Six groups — all MATCH

| group | measured | receipt |
|---|---|---|
| 1 headings | `SCORECARD.md:1018,1082,1110,1181,1239`, byte-identical to the plan's five old strings (U+2014 em dash, `post-move:` colon on 28/29/30) | `base-headings.txt` |
| 2 cells | exit 2, 20 `LABELED-ID` + 1 `unrecognised round heading … '## Round 26 — bounded release-drift response'`, 0 `CELL_AUDIT:`; byte-identical to `controls/cells-base.txt`; population 210 cells / 35 sections | `base-cells.txt` |
| 3 census | `SOURCES_CENSUS: CLEAN (rows=60 A=57 B=1 C=2 queued=1 mined=56 rejected=3 entries_sourced=8 legacy=21 captures=60 inrow=16 inrow_only=0 inrow_nonreproducing=12)` exit 0 — all 13 counters match | `base-census.txt` |
| 4 counts | legacy 21 (`grep -L '^source:'`), registry 60, `oidc` entries 0, max id S060, `S061–S071` empty, 11 staged rows / 2 staged entries | `base-counts.txt` |
| 5 rows | `REVISION_AUDIT: CLEAN … added=36` exit 0; `scorecard-rounds count=36 sha256=1259a3e1…`; `revision-added count=36 sha256=2b86f032…`; R22-03/R24-06/R24-15 pins green; `SELF_COUNTS: POLICY (claims=62 stale=0 … policy=2)` exit 2 with exactly R29-01/R29-02 | `base-rows.txt` |
| 6 fleet | exit 0, 14 W04 identical to `census-start.txt`, last line `kagi ok` | `base-fleet.txt` |

Also confirmed (receipt `base-routed.txt`): D1 = exactly 11 uncommitted round-30 paths; D2
`selfcounts-at-tip.txt` holds `stale=8`; D3a `feed-token-agree` unregistered in
`corpus/claim-ledger.sh:263`; D3b the CR-trim defect is at `scripts/sources-census.sh:581`; host facts
(py3.14.8, op 2.41.1 version-only, janitor absent ×3); OIDC lead present since round-21 commit `c41af82`;
no sibling lane has `*oidc*` knowledge.

## Findings

**F1 MUST-FIX (claim accuracy).** C2's "staged ids … collide with lane ids" holds for only
**6 of 11**: `S052–S057` collide; `S064`, `S065`, `S092`, `S093`, `S095` are free in
`corpus/SOURCES.md`. Renumber to `S061–S071` stays correct (id follows the document); the reason is
wrong. Plan correction before the first work commit.

**F2 MUST-FIX (claim accuracy / W04 baseline).** "11 distinct sources" overstates: `S092`'s URL
(`www.1password.dev/brokered-access`) is already registered **3×** (`S007`, `S019`, `S032`), and `S093`
matches `S018` modulo a trailing slash. The merge package itself (`MERGE-REPORT.md:120-126`) asks for the
added-aspect justification; the plan records none. Rows 60→71 still measures (lane census does not gate
duplicate URLs), but the fleet W04 set grows beyond 14 after adoption (warnings only, exit 0 unaffected).

**F3 derivation note.** The legacy count is `grep -L '^source:'` → 21; `grep -L legacy` → **29**. The
plan's 21 matches the census rule (`sources-census.sh:337`) and `corpus/README.md:122`; only the command
spelling in the seat brief was wrong.

**F4 DECISION (blocks C1's spirit).** A faithful emulation of `cells()` over the after-reshape section
set gives `cells=210 row_pointed=147 stamp_pointed=94 uncited=6` — reproducing the real gate's own probe
(`.ufo/waves/round-31/build/cells-red-probe.txt`: `CELL_AUDIT: POLICY (cells=210 row_pointed=147
stamp_pointed=94 policy=2)`) number for number. The six unpointed cells are R29 freshness/calibration/
coverage/operability (lines 1200,1201,1203,1204) and R30 depth/adjacency (1247,1250): they cite S052,
`.ufo/…` paths, bare `feed-token-agree.py`, `M29-*`, `QM30`, or prose — no ledger row id and no
`stamps.tsv` path. Fixing them edits six evidence lines, which C1 forbids ("no table cell, score or
evidence line inside those sections changes"). Because `claim-ledger.sh:1249-1262` prints POLICY before
testing `CL_UNCITED`, the after-state summary will read `CELL_AUDIT: POLICY (…policy=2)` while `uncited=6`
— the frozen predicate's four greps pass by the letter while the kill rule's "uncited/missing-id class"
is present. Resolve explicitly: either allow a QM14-recorded pointer-only cell edit (fresh stamps
available: `corpus/lessons/round-29.md`, `corpus/lessons/round-30.md`, `corpus/QUALITY.md`,
`corpus/SOURCES.md`, `corpus/feed-token-agree.py`; rows `R29-01/R29-02/R30-01` exist, no `R28-*` row
does), or honest-stop naming the six cells.

## Preconditions that do hold

* All **35** parsed round sections carry the six axes exactly once — `section_check` cannot kill the
  reshape.
* Population floor is exact: **210** cells at BASE, so `cells ≥ 210` is satisfiable and tight.
* The SCORECARD stamp is fresh at BASE (`f4eb6ec4…` = actual sha256), so the re-pin is causally required,
  not cosmetic; every other stamp path cited inside R26–R30 is fresh too — no hidden STALE-POINTER.

## Unknowns

After-states (by definition); whether the three identity rows land green rather than merely re-pinned;
whether the adopters collapse the staged headers (staged entries carry **8** and **3** `^source:` lines,
`verified-at: 2026-10-23`, and **no `Reverify:` line** — census allows ≤1 `source:` and requires the
plan's `Reverify:` link to be added); whether round-31's own sections can be made audit-clean.

Scratch `/fast/scratch/hyaku/kagi-r31/CensusBase/` deleted before yielding.
