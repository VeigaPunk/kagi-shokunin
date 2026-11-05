# K38ReviewQuote — C1 quote-gate review and attack (round 38, wave build)

Seat: K38ReviewQuote (reviewer). Scope: surgical review and attack of the C1 gate
(`corpus/quote-locate.py`, `corpus/quote-bodies.tsv`, `plans/round-38-c1.sh`) at candidate b944735.
Date: 2026-11-05. All work on a `git archive b944735` extraction under scratch; the lane tree, its git
state, and all tracked files untouched. No tools installed (none needed).

## Top-line verdict

**C1 HOLDS against these attacks.** The candidate reproduces the claim: on the pristine extraction,

- `python3 -I -B corpus/quote-locate.py --root $PWD` → `QUOTE_LOCATE: CLEAN located=5 rows=5`, exit 0
- `bash plans/round-38-c1.sh` → `5`, exit 0

No attack below produces a false `located=5` on the unmodified committed tree; every false-CLEAN attack
required forging committed provenance, and 4 of 5 false-CLEAN attacks are independently killed by the lane
census kill rule (measured `SOURCES_CENSUS: FAILED`, exit 1). One attack (F2, symlink body) passes both the
gate and the census and is caught only by the frozen review-duty kill rule ("a committed capture body
changed after the predeclaration → C1 fails"). The gate itself carries defects V1–V6 below; none breaks the
claim as frozen, because the claim's kill-rule set is wider than the gate.

## Gate check order (from full source read of corpus/quote-locate.py)

Per manifest row, in order: (1) `fetch.get(sid)` from `source-fetches.tsv` rows of 16 columns — dict
assignment, **a duplicate id's LAST row silently wins**; (2) refuse `body_path` absolute or containing
`..` (**no symlink resolution anywhere**); (3) `(root/body_path).is_file()` — **follows symlinks**;
(4) `offset.isdigit()` — accepts non-ASCII digits that `int()` later rejects (crash path); (5) `quote ==
capture col 13`; (6) sha256(body) == capture col 10; (7) len(body) == capture col 11; (8) registry check =
**FIRST line of SOURCES.md starting with `"| <id> |"`**, then `quote in line` (substring, any column);
(9) `data[off:off+len(needle)] == needle`. Header/empty/malformed rows → SETUP exit 2; any row failure →
FAIL exit 1 with NOT-LOCATED lines.

## Attack table

All fixtures: copies of the b944735 extraction with the stated change; command per fixture:
`python3 -I -B corpus/quote-locate.py --root <fixture>` plus `bash plans/round-38-c1.sh` (cwd fixture).

| # | Fixture (one change each) | Gate output | Exit | Counter | Class |
|---|---|---|---|---|---|
| base | pristine extraction | `QUOTE_LOCATE: CLEAN located=5 rows=5` | 0 | 5 | claim reproduced |
| A1 | second `\| S092 \|` registry row APPENDED after the real one, different quote | `CLEAN located=5 rows=5` | 0 | 5 | gate unfooled (first row wins); appended forgery inert — no defect |
| A2 | forged `\| S092 \|` row PREPENDED before the real row carrying the manifest quote; real row's quote stripped | `CLEAN located=5 rows=5` | 0 | 5 | FALSE POSITIVE — defect V1; census kills it (below) |
| B2 | quote moved into a `\| S092 \|` line inside an HTML comment block before the real row; real row's quote stripped | `CLEAN located=5 rows=5` | 0 | 5 | FALSE POSITIVE — defect V1 (any line with the prefix qualifies, even inside a comment); census kills it |
| C | S091 capture col13 forged to `Python`; manifest quote=`Python`, offset = second occurrence | `CLEAN located=5 rows=5` | 0 | 5 | ceiling — byte-for-byte at the declared offset is literally true; offset is self-referential |
| D | S092 manifest offset 21886 → 21887 | `NOT-LOCATED S092 quote-not-at-offset`, `FAIL located=4 rows=5` | 1 | 4 | gate catches — no defect |
| E | S093 manifest row duplicated | `CLEAN located=6 rows=6` | 0 | 6 | no duplicate-id check; count inflates to 6, which is ≠ 5 → claim unmet, not false 5 — minor defect V6 |
| F2 | S093 body_path replaced by a symlink to a byte-identical file OUTSIDE the fixture root | `CLEAN located=5 rows=5` | 0 | 5 | FALSE POSITIVE — defect V2, **not caught by census** (strongest finding) |
| G1 | body_path leading `./` (`.ufo/...` → `./.ufo/...`) | `CLEAN located=5 rows=5` | 0 | 5 | accepted; still repo-relative — by design |
| G2 | body_path `corpus/../.ufo/...` | `NOT-LOCATED S089 unsafe-body-path`, `FAIL located=4 rows=5` | 1 | 4 | gate catches — no defect |
| H1 | whole manifest CRLF | `QUOTE_LOCATE: SETUP bad-manifest-header` | 2 | 0 | rejected conservatively — no defect |
| H2 | header LF, S089 data row CRLF | `NOT-LOCATED S089 quote-not-capture-quote`, `FAIL located=4 rows=5` | 1 | 4 | gate catches — no defect |
| I2 | vacuous empty quote: S091 capture col13 forged to empty, manifest quote empty, offset 0 | `CLEAN located=5 rows=5` | 0 | 5 | FALSE POSITIVE — empty needle matches `data[0:0]==b""` and `"" in line`; defect V3; census kills it |
| J2 | duplicate S092 fetch row appended (last-wins) with attacker sha/bytes + attacker body; original S092 fetch row left contradicting in the same file | `CLEAN located=5 rows=5` | 0 | 5 | FALSE POSITIVE — gate validates against the LAST committed capture row; defect V4; census kills it |
| K2 | S089 offset `²726` (superscript: `str.isdigit()` True, `int()` ValueError) | uncaught `ValueError: invalid literal for int() with base 10: '²726'`; **no QUOTE_LOCATE verdict line at all** | 1 | 0 | contract violation — documented exit 1 with NOT-LOCATED lines never printed; fails safe (counter 0); defect V5 |
| L2 | S089 offset `0726` (leading zero) | `CLEAN located=5 rows=5` | 0 | 5 | numeric normalization; cosmetic — by design |

## Findings

- **V1 (defect, census-mitigated):** `registry_line()` returns the FIRST line starting with `| <id> |`,
  and `quote not in line` is a substring test on that line. A forged row placed BEFORE the real one (A2),
  or buried in an HTML comment (B2), becomes "that id's registry row" for the gate; the gate then reports
  located while the real registry row no longer carries the quote. Appending (A1) is inert — the gate's
  ambiguity resolution is asymmetric and silently favors a prepend forgery. Mitigation measured: census on
  A2 state → `FINDING SC_MALFORMED line=99 id=S092 nf=12`, `FINDING SC_DUP id=S092`,
  `SOURCES_CENSUS: FAILED (findings=2 rows=94)`, exit 1; on B2 state → `FINDING SC_MALFORMED line=100
  id=S092 nf=4`, `FINDING SC_DUP id=S092`, `SOURCES_CENSUS: FAILED (findings=2 rows=94)`, exit 1. The
  frozen kill rule "lane census not CLEAN → C1 unmet" catches both.
- **V2 (defect, NOT census-mitigated — strongest finding):** the gate follows symlinks. A body_path whose
  committed object is a symlink (git mode 120000, blob = target path) is read through to bytes OUTSIDE the
  commit. In fixture F2 the gate prints `CLEAN located=5 rows=5` exit 0 and `bash corpus/sources-census.sh`
  prints `SOURCES_CENSUS: CLEAN (rows=93 … captures=93)` exit 0 — both automated layers pass while the
  committed capture body contains no quote bytes at all (the quote bytes live at
  `/fast/scratch/.../payload/outside-S093-f2.body`). The docstring promises only "absolute paths and `..`
  components are refused"; containment is bypassable. A fresh clone elsewhere would dangle the symlink →
  `body-missing` FAIL, so the CLEAN verdict is machine-dependent — the claim "found byte-for-byte in the
  committed capture body" is false while both gates print CLEAN on the forger's machine. Caught only by the
  frozen kill rule "A committed capture body under `.ufo/waves/round-38/capture/` … changed after the
  predeclaration → C1 fails" — a review/history duty (git diff shows the mode change), not an automated gate.
- **V3 (defect, census-mitigated):** no non-empty-quote validation. An empty manifest quote equal to an
  empty capture col13 satisfies sha/bytes (body untouched), `"" in line`, and `data[0:0]==b""` — a row with
  NO quote counts as located (I2). Mitigation measured: census on I2 state → `FINDING SC_FETCH id=S091
  normalization`, `FINDING SC_FETCH id=S091 normalized-digest-not-applicable`, `FINDING SC_FETCH id=S091
  location`, `SOURCES_CENSUS: FAILED (findings=3 rows=93)`, exit 1.
- **V4 (defect, census-mitigated):** `load_fetches` assigns `fetch[cols[0]] = cols`, so a duplicate
  capture id silently resolves to its LAST row (J2). The gate validated against the appended attacker row
  (sha `6264d08280bc…`) while the original committed S092 row (sha `1e0346160e66…`) sat 30 lines above
  contradicting it. Mitigation measured: census on J2 state → `FINDING SC_FETCH id=S092
  duplicate-provenance`, `SOURCES_CENSUS: FAILED (findings=1 rows=93)`, exit 1.
- **V5 (defect, diagnostic):** `offset.isdigit()` accepts strings `int()` rejects (superscript digits); the
  uncaught ValueError exits 1 with a traceback and NO `NOT-LOCATED`/`QUOTE_LOCATE` line, violating the
  documented exit contract. Fails safe (counter sed finds no `located=`, prints 0), so it cannot fake a pass.
- **V6 (defect, minor):** no duplicate-id check on the manifest; a duplicated row inflates
  `located`/`rows` (6/6). Cannot forge exactly 5 this way, so it cannot break the claim — but `located=N`
  can exceed the number of distinct ids, which the predicate's "number of rows" reading permits only
  awkwardly.
- **Observation (no fixture needed):** capture col16 locator text (`tag-page-title-byte-offset-21886`)
  embeds the offset, but the gate never parses it — the manifest offset is the only offset the gate knows
  (feeds finding C's self-referentiality).

## Ceilings relied on

Header of `corpus/quote-locate.py`: "Named ceilings: this checks the committed bytes only; it does not
re-fetch a live page and does not judge whether the quote supports the row's teaching. Rows outside the
manifest are not checked by this gate." Attack C stays inside the first sentence: the gate binds
manifest↔capture↔body↔registry self-consistency over committed bytes; with capture col13 and the manifest
offset both edited, `CLEAN` is the predicate-correct answer. The symlink finding V2 is NOT covered by this
ceiling — the committed capture body is precisely what V2 stops the gate from reading.

## Method notes

- Extraction: `git -C <lane> archive b944735 | tar -x -C $S/ext` (read-only git only). Scratch:
  `/fast/scratch/hyaku/kagi-r38/K38ReviewQuote/` (deleted before yield; nothing written outside it and the
  two seat report paths).
- Incident, disclosed: the first fixture driver used hardlink copies and fixture J's in-place body write
  mutated my extraction's S092 body (lane repo untouched — the extraction is a tarball copy). All fixtures
  affected were rebuilt from a fresh `git archive` extraction and re-run (J2, K2, L2); the baseline was
  re-verified pristine after every batch (`CLEAN located=5 rows=5`, exit 0, S092 body sha256 prefix
  `1e0346160e6679f1` matches the committed fetch row).
- Census runs: `bash corpus/sources-census.sh` with cwd = fixture and `TMPDIR`/`HYAKU_SCRATCH` pointed into
  the seat scratch; the script writes only under its own `mktemp -d`.
- Installs: none.
