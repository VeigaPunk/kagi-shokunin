# R68ExecGate — gate widening (C1)

Seat: R68ExecGate (sole writer: `corpus/sources-census.sh`).
Branch: master. No commit/push by this seat (L1 KagiR68 is sole committer).

## What changed

`corpus/sources-census.sh` only. No existing finding id or summary-line shape changed.

1. **Token classification (round 68)** — `cap_cell_class()` replaces the round-67
   `cap_is_shaped` prose escape.
   - `path`: entire cell is one pure capture path naming a `.ufo/waves/` token
     (including `./` and doubled-slash spellings that canonicalize inside the root).
   - `prose` (frozen meaning): no `.ufo/waves/` whitespace-delimited token **and**
     no `~/`/`//` expansion form. `.ufo/prompts/` (S099) stays prose — it names
     no `.ufo/waves/` token.
   - Defects (counted as path rows, not prose):
     - `capture-whitespace`: cell that trims to a `.ufo/waves/` path but carries
       stray edge whitespace, or is a comma-joined list of such paths, or carries a
       trailing CR (new CR branch in the classifier).
     - `capture-token`: non-pure cell naming a `.ufo/waves/` path (mixed prose,
       `~/` or `//` form). A leading `//` naming a waves path is `capture-token`
       (round-68 spec); without a waves token it is prose. Single-slash absolute
       stays `capture-outside-root` downstream — the absolute branch is restricted
       to `/[!/]*` so `//` is not swallowed by it.
   - Absolute (`/...`) and `../` escapes name no `.ufo/waves/` token but are
     classified `path`, so they emit `capture-outside-root` rather than
     silently becoming prose.
   - Pure-shaped cells naming no `.ufo/waves/` token (e.g. `captures/c1.body`)
     are now `prose` — the frozen token test governs every cell. The selftest
     fixture was therefore migrated to `.ufo/waves/round-00/capture/c1.body`
     (documented in the file); the 10 round-67 capture cases keep exercising
     their intended predicates under the widened classifier.

2. **File-level CR** — `verify()` now emits
   `FINDING SC_FETCH cr-in-tsv` when a CR byte occurs anywhere in
   `corpus/source-fetches.tsv` (per-revenger proposal (a)). The CR is **retained**
   in the cell through `cap_row` classification, so a trailing-CR capture cell
   emits both `SC_FETCH cr-in-tsv` and cell-level `capture-whitespace`
   (findings=2 on that case). Whole-file CRLF therefore fails on both levels
   rather than reading CLEAN with `path_rows=0`.

3. **Normalized digest recompute** — in the bound branch (after col10/col11
   check-passes, before the quote check — inside the bound branch per
   R68ReviewerLayers, mirroring `quote-not-located`, so the reason never
   piggybacks on a bytes/digest failure and `defects=` stays leg-stable):
   for `rendered-text-v1` rows, `cap_normalized_digest()` runs
   `python3 rendered-text-v1.py digest FILE` and compares `normalized_sha256`
   to col 15. Non-zero rc or unparsable output is a SETUP (never a silent pass).
   `raw-literal-v1` rows carry col15 `-` (unchanged SC_FETCH rule).

4. **Selftest** — new cases for every added reason, one positive + one negative
   control each:
   - `capture-waves-control` (pure `.ufo/waves/`), `capture-whitespace-space`,
     `capture-whitespace-cr`, `capture-whitespace-comma`, `capture-token-mixed-prose`,
     `capture-token-tilde`, `capture-token-slashslash`,
     `capture-normalized-mismatch`, `fetch-cr-in-tsv` (file-level, 2 findings
     including `SC_FETCH line=… nf=1` from the appended CR row).
   Fixture migrated from `captures/c1.body` to `.ufo/waves/round-00/capture/c1.body`;
   `m_capture_symlink` depth corrected from 4 to 5 `..` (4 resolves inside the
   tree, giving `capture-missing`; 5 escapes, giving `capture-outside-root`).

5. **Header** doc block updated (classification rule, reason table, the new
   line shapes, the CR approach, the digest placement).

## Verification (exact commands, last lines)

```
$ bash corpus/sources-census.sh --selftest
SOURCES_CENSUS_SELFTEST: PASS (98 cases)
```
Prior BASE was 89 cases. Final N = **98** (89 + 9 new cases:
1 waves-control, 3 whitespace, 3 token, 1 normalized, 1 cr-in-tsv).
Ledger pin R21-03 migrates to 98; SKILL.md pins 98.

```
$ time bash corpus/sources-census.sh verify --root .
SOURCES_CAPTURES: CLEAN (path_rows=38 bound=38 located=38 prose=120)
SOURCES_CENSUS: CLEAN (rows=158 A=141 B=2 C=15 queued=3 mined=138 rejected=17 entries_sourced=27 legacy=21 captures=158 inrow=16 inrow_only=0 inrow_nonreproducing=12)
wall: 4.4s
```
Ordinary verify wall time is ~4.5s (18s wall on a cold host run). The gate
reads CLEAN on the landed tree — S166 is already the pure path
`.ufo/waves/round-67/capture/S166.body` and S167 is in-tree
(`.ufo/waves/round-68/capture/S167.body`), so the recut this seat's
spec anticipated is already present behind `path_rows=38`.

Counts by row-by-row derivation:
- `path_rows=38` — 38 rows name a `.ufo/waves/` token (36 BASE + S166 + S167).
- `bound=38 located=38` — all 38 bind.
- `prose=120` — 158 total rows − 38 path rows = 120 (includes S099).
- `col15=33` for the counter — 33 rows are path + `rendered-text-v1` (5
  `raw-literal-v1` path rows excluded). Spot checks: S166
  `652d311657f00e1eab513b15db807d773b42294d7032e179f63d04909943436b` = col15,
  S167 `30194c4ff628ee00171027b7d54800e1c17cfda692ced83290807eb148ef93a9` = col15.
  The counter's expected `col15=32` (31+1) is stale on contact given S167 has
  landed — the gate measures 33; the counter derivation is the L1's call,
  not this seat's. Reported here so the discrepancy is measured, not hidden.

## Receipts

- `.ufo/waves/round-68/w1/R68ExecGate.receipts.txt` — selftest tail + verify tail.
- `corpus/sources-census.sh` — the full widened gate.

## Surfacing / remaining failures

- **`.ufo//waves/` spelling gap (R68Revenger, factual):** the waves token test
  is a literal substring `.ufo/waves/`. A col16 spelling the directory
  `.ufo//waves/…`, `.ufo/./waves/…`, or via an in-tree symlinked directory
  (`.ufo/wv/…`) is classified `prose`, prints CLEAN, and drops the row from
  `path_rows`. Under the frozen literal-token sentence that is legal prose;
  under round-67's C1 class it is the same silent disengage. Surfaced, not
  repaired — repairing would change the frozen predicate.
- **Filename newline injection (R68Sentinel):** a tree-controlled filename under
  `corpus/knowledge/` containing a newline can forge lines into stdout,
  including `FINDING SC_CAPTURE` and summary lines, against any leg whose check
  is a reason-grep alone. Not patched (outside the frozen interface); the
  counter should carry the `findings=N` cross-check. Flagged for the L1.
- **Hardlink (round-67 C2) and truthy-normalizer (C4)** remain ceilings per
  the plan — no action.

## Dead ends measured

- `captures/c1.body` fixture under the new classifier: all 10 round-67 capture
  cases failed (the fixture became `prose`). Resolved by migrating the fixture
  into `.ufo/waves/round-00/capture/` rather than weakening the classifier.
- `floc=${floc%$'\r'}` strip before `cap_row` made the CR branch unreachable;
  CR is now retained through classification.
- `//` initially classified `path` → `capture-outside-root`; restricted the
  absolute branch to `/[!/]*` and placed the `//` token rule before it.

Report: .ufo/waves/round-68/w1/R68ExecGate.md
