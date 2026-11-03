# Round-30 C1 — doc-cell drafts (seat XD2Cells)

Tree measured: `b7482b4acc42413fbb3d49ab6e4f811fb18e9f0c` (frozen BASE `f67232c` + plan commit).
Host: Arch Linux, `python3` 3.14.8; the-janitor substrate absent (declared).
Read-only seat: no lane file was edited. All counts below were measured at this revision; the
draft lines were applied only to a scratch mirror (`/fast/scratch/hyaku/kagi-r30/XD2Cells/`) to
prove the gate regexes still capture the new values.

Population/method: `python3 corpus/self-counts.py` (C1's frozen counting command) names the
bound stale cells; every *unbound* current-tense count in the three target docs was then read
against its live source. Drafts change the current-tense number only. Round-dated history
clauses are untouched (§E). A count is never relaxed or unbound to force green.

Measured state at `b7482b4` (receipt `XD2Cells-before-selfcounts.txt`):
`SELF_COUNTS: POLICY (claims=62 stale=8 unlocated=0 ambiguous=0 policy=2 setup=1)` exit 2 —
**eight** stale cells, not the six the plan prose names (the extra two are §B).

---

## A. The six routed cells (4 lines, 6 cells)

### A1. `SKILL.md:46` — SC-SKILL-STAMPS + SC-SKILL-CLAIMS (2 cells, 1 line)

| field | value |
|---|---|
| cells | SC-SKILL-STAMPS (claimed 91) + SC-SKILL-CLAIMS (claimed 65) |
| live | stamps `94`, claim rows `67` |
| sources | `grep -c '[^[:space:]]' corpus/stamps.tsv` ⇒ `94`; `grep -cE '^R[0-9]+-[0-9]+' corpus/claim-ledger.tsv` ⇒ `67` |
| self-counts binding | `ledger:R12-03` (live row output) / `ledger:R21-04` (live row output) — both bindings exist; the *ledger pins* are separately stale (L1 scope) |
| EOL | file is CRLF at this revision (routed D5); write the line LF-only |

BEFORE (full line; ends `CRLF` at `b7482b4`):

```
| Re-run a claim this corpus makes / name the revision you read / cite an artifact / audit a score | `bash corpus/claim-ledger.sh verify` (91 stamps + 65 claims + claim ids; both counts bound to the ledger by `corpus/self-counts.tsv`) before citing; `… cells`; `… stamp PATH…` only after reviewed edits; `… citations` before adding a path reference | citing unstamped files; changing an expectation to force green; treating `STALE` as proof of defect; citing an undefined id; recursively auditing the audit; reading a lone clone's `INCOMPLETE` as a pass or as a defect | exit 0 `CLAIM_LEDGER: CLEAN (…)`; 1 `STALE`/`MISSING`/`MISSING-ID`/`FAIL`, or `LAYOUT-INCOMPLETE R11-08` + `CLAIM_LEDGER: INCOMPLETE (…)` when no fleet root sits beside the lane (`citations` alone: `FLEET-ABSENT` lines, `CITATION_GATE: INCOMPLETE`, exit 3); 2 `POLICY`/`SETUP`. |
```

AFTER (full line, LF ending):

```
| Re-run a claim this corpus makes / name the revision you read / cite an artifact / audit a score | `bash corpus/claim-ledger.sh verify` (94 stamps + 67 claims + claim ids; both counts bound to the ledger by `corpus/self-counts.tsv`) before citing; `… cells`; `… stamp PATH…` only after reviewed edits; `… citations` before adding a path reference | citing unstamped files; changing an expectation to force green; treating `STALE` as proof of defect; citing an undefined id; recursively auditing the audit; reading a lone clone's `INCOMPLETE` as a pass or as a defect | exit 0 `CLAIM_LEDGER: CLEAN (…)`; 1 `STALE`/`MISSING`/`MISSING-ID`/`FAIL`, or `LAYOUT-INCOMPLETE R11-08` + `CLAIM_LEDGER: INCOMPLETE (…)` when no fleet root sits beside the lane (`citations` alone: `FLEET-ABSENT` lines, `CITATION_GATE: INCOMPLETE`, exit 3); 2 `POLICY`/`SETUP`. |
```

Substitution only: `(91 stamps + 65 claims ` → `(94 stamps + 67 claims `.

### A2. `PROVINCE.md:73` — PV-STAMPS + PV-CLAIMS (2 cells, 1 line)

| field | value |
|---|---|
| cells | PV-STAMPS (claimed 91) + PV-CLAIMS (claimed 65) |
| live | `94` revision stamps, `67` claim rows (same sources as A1) |
| self-counts binding | `ledger:R12-03` / `ledger:R21-04` |
| EOL | LF |

BEFORE (full line):

```
- `corpus/claim-ledger.sh` — calibration gate: `verify` (91 revision stamps + 65 claim rows; since round 24 host/substrate rows are HOST-SKIPped by default and run only with `--allow-host-rows`), `citations` (durable evidence; `.ufo/` resolves lane-first; since round 25 a lone clone prints `FLEET-ABSENT` and ends `INCOMPLETE` exit 3, and `verify` reports `LAYOUT-INCOMPLETE`), `cells` (policy/host classification before recursion skips), `docs` and reviewed `stamp`. Exit 0/1/2 (3 = citations incomplete in a lone layout); `--selftest` declares 170 cases (121 at round 23; 151 at round 24; fourteen round-25 layout cases and one network-mode refusal). Only executed output verifies the count. Script expansion, attached external pattern-file operands and symlinked script ancestors are refused; the host-free fixture invocation is a closed vector, not a prefix.
```

AFTER (full line):

```
- `corpus/claim-ledger.sh` — calibration gate: `verify` (94 revision stamps + 67 claim rows; since round 24 host/substrate rows are HOST-SKIPped by default and run only with `--allow-host-rows`), `citations` (durable evidence; `.ufo/` resolves lane-first; since round 25 a lone clone prints `FLEET-ABSENT` and ends `INCOMPLETE` exit 3, and `verify` reports `LAYOUT-INCOMPLETE`), `cells` (policy/host classification before recursion skips), `docs` and reviewed `stamp`. Exit 0/1/2 (3 = citations incomplete in a lone layout); `--selftest` declares 170 cases (121 at round 23; 151 at round 24; fourteen round-25 layout cases and one network-mode refusal). Only executed output verifies the count. Script expansion, attached external pattern-file operands and symlinked script ancestors are refused; the host-free fixture invocation is a closed vector, not a prefix.
```

Substitution only: `` `verify` (91 revision stamps + 65 claim rows; `` → `` `verify` (94 revision stamps + 67 claim rows; ``.
The `170 cases (121 at round 23; 151 at round 24; …)` clause is round-dated history and is correct as written (PV-LEDGER-SELFTEST live 170).

### A3. `corpus/README.md:64` — RD-LEDGER-ROWS (1 cell)

| field | value |
|---|---|
| cell | RD-LEDGER-ROWS, claimed 65 |
| live | 67 rows matching `^R[0-9]+-[0-9]+` (`corpus/claim-ledger.tsv`; file total 85 lines incl. comments/blank) |
| self-counts binding | `ledger:R21-04` |
| EOL | LF |

BEFORE (full line):

```
| Ledger rows (data) | `corpus/claim-ledger.tsv` | 65 rows (39 at round 21, 35 after round 18; round 25 added `R25-01..04`): runnable checks for the shipped gates, fixed count guards, score-cell audit, round-17 breadth assertions `R17-01..03`, round-18 substrate-deferral pins `R18-01..03`, and the round-21 byte-contract and source-census rows; expectations are anchored and time-bounded; a row tagged `substrate` defers (never fails) when the handler is absent |
```

AFTER (full line, primary — minimal current-tense fix):

```
| Ledger rows (data) | `corpus/claim-ledger.tsv` | 67 rows (39 at round 21, 35 after round 18; round 25 added `R25-01..04`): runnable checks for the shipped gates, fixed count guards, score-cell audit, round-17 breadth assertions `R17-01..03`, round-18 substrate-deferral pins `R18-01..03`, and the round-21 byte-contract and source-census rows; expectations are anchored and time-bounded; a row tagged `substrate` defers (never fails) when the handler is absent |
```

OPTIONAL history anchor (only if the L1 wants the delta visible; the parenthetical is history, so
the primary draft leaves it untouched): append inside the parenthetical
`; round 29 added `R29-01..02`` so it reads `… round 25 added `R25-01..04`; round 29 added `R29-01..02`)`.

### A4. `corpus/README.md:65` — RD-STAMPS (1 cell)

| field | value |
|---|---|
| cell | RD-STAMPS, claimed 91 |
| live | 94 non-blank rows in `corpus/stamps.tsv` (`wc -l` is also 94: no trailing blank row) |
| self-counts binding | `ledger:R12-03` |
| EOL | LF |

BEFORE (full line):

```
| Revision stamps (data) | `corpus/stamps.tsv` | 91 rows (89 at round 26, 88 at round 25, 63 at round 21, 56 after round 18, 54 at round 17): every cited in-repo artifact, checked as `path sha256 lines bytes`; regeneration is a reviewed `stamp` commit, never an automatic re-pin |
```

AFTER (full line, primary):

```
| Revision stamps (data) | `corpus/stamps.tsv` | 94 rows (89 at round 26, 88 at round 25, 63 at round 21, 56 after round 18, 54 at round 17): every cited in-repo artifact, checked as `path sha256 lines bytes`; regeneration is a reviewed `stamp` commit, never an automatic re-pin |
```

OPTIONAL history anchor: insert `91 at round 28, ` after `(` so it reads
`94 rows (91 at round 28, 89 at round 26, …)`. The three round-29 additions are
`corpus/feed-token-agree.py`, `corpus/knowledge/feed-token-boundaries.md`, `corpus/lessons/round-29.md`.

---

## B. Two further stale cells on the same surface (not among the routed six)

The plan prose says "six STALE cells"; the committed prior state is **eight**. Both extra cells
are on `corpus/README.md:67` and are inside the plan's own R14-01 migration scope
(`docs entries=25/row_linked=22→current`), so they are not a scope addition — only the count in
the plan text is wrong.

### B1. `corpus/README.md:67` — RD-DOCS-ROWLINKED + RD-DOCS-ENTRIES (2 cells, 1 line)

| field | value |
|---|---|
| cells | RD-DOCS-ROWLINKED (claimed 22) + RD-DOCS-ENTRIES (claimed 25); RD-DOCS-BYHAND stays 3 |
| live | `bash corpus/claim-ledger.sh docs` ⇒ `DOC_AUDIT: CLEAN (entries=26 row_linked=23 by_hand=3 undeclared=0 missing_ids=0 unpinned=0 duplicate_reasons=0)` |
| self-counts binding | `ledger:R14-01` (live row output) |

BEFORE (full line):

```
| Knowledge-entry declarations (data) | `corpus/knowledge/*.md` + `claim-ledger.sh docs` | one `Reverify:` line per entry: 22 row-linked / 3 by-hand / 25 pinned (21/3/24 at round 21, 18/3/21 after round 18, 20/17/3 at round 17); the floor is `ceil(entries/2)`, by-hand reasons are unique, and every entry is revision-stamped (ledger `R14-01`) |
```

AFTER (full line):

```
| Knowledge-entry declarations (data) | `corpus/knowledge/*.md` + `claim-ledger.sh docs` | one `Reverify:` line per entry: 23 row-linked / 3 by-hand / 26 pinned (21/3/24 at round 21, 18/3/21 after round 18, 20/17/3 at round 17); the floor is `ceil(entries/2)`, by-hand reasons are unique, and every entry is revision-stamped (ledger `R14-01`) |
```

Substitution only: `22 row-linked / 3 by-hand / 25 pinned` → `23 row-linked / 3 by-hand / 26 pinned`.
The parenthetical is round-dated history and stays.

Cause: round 29 added `corpus/knowledge/feed-token-boundaries.md` (S052 used-by back-reference in
`49d1d46`), which raises entries 25→26 and row_linked 22→23.

---

## C. One further stale current-tense number with NO self-counts binding

### C1. `PROVINCE.md:36` — `rows=51` (unbound; gate-invisible)

| field | value |
|---|---|
| claim | `sources-census validate (CLEAN rows=51)` |
| live | `bash corpus/sources-census.sh` ⇒ `SOURCES_CENSUS: CLEAN (rows=52 A=50 B=0 C=2 queued=1 mined=48 rejected=3 entries_sourced=5 legacy=21 captures=52 inrow=16 inrow_only=0 inrow_nonreproducing=12)` |
| self-counts binding | **none** — no `self-counts.tsv` row binds the registry row count, which is exactly why the cell survived round 29 |
| provenance | introduced in `fc65112` (the round-29 commit that added S052); `SOURCES.md` already had 52 registry rows in that commit ⇒ the number was stale when written, not round-dated history |

BEFORE (line 36; the sentence spans lines 34–37):

```
sources-census validate (CLEAN rows=51), release-clock default replay
```

AFTER (line 36 only):

```
sources-census validate (CLEAN rows=52), release-clock default replay
```

Note: the same sentence's other counts are correct — `checklist-run (34 cases)` (live 34),
`op-ref-probe (36 cases)` (R12-02 pin 36), release-clock `116 cases` (live 116). `CLEAN30` is a
receipt name, not a count. "after round 29" is round-dated and stays.

Recommendation (not a draft): either bind the registry row count in `self-counts.tsv`
(`rows:`-style binding is not available for a *gate output*; a `ledger:R21-02` binding with
extract `rows=([0-9]+)` would work) or drop the number from this sentence. Without a binding the
next registry row re-opens the same drift silently.

---

## D. Sweep — other current-tense numbers, checked and unchanged (no edit)

Every number below was read against its declared live source at `b7482b4`. "binding" names the
`self-counts.tsv` row where one exists (`—` = unbound).

| file:line | number(s) | live | binding | verdict |
|---|---|---|---|---|
| `SKILL.md:35` | 35 census rows | 35 (`surface-census.tsv` data rows) | SC-SCOPE-ROWS | unchanged |
| `SKILL.md:36` | surface-census selftest cases | 16 (R11-03 pin) | SC-CENSUS-SELFTEST (`expect:`) | unchanged |
| `SKILL.md:47` | self-counts 48 cases | 48 | SC-SELFCOUNTS-SELFTEST | unchanged |
| `SKILL.md:48` | release-clock 116 cases | 116 | SC-CLOCK-SELFTEST | unchanged |
| `SKILL.md:49` | sources-census 70 cases | 70 | SC-SOURCES-SELFTEST | unchanged |
| `SKILL.md:140` | 16 cases | 16 (R11-03 pin) | (code-block, pinned text) | unchanged |
| `SKILL.md:142` | 35 rows | 35 | SC-SCOPE-ROWS | unchanged |
| `SKILL.md:183` | drift selftest 13 cases | 13 (consistent with `PROVINCE.md:30` "FAILs 2/13") | — | unchanged |
| `SKILL.md:188` | drift symbols 20 rows | 20 (`drift-symbols.tsv`) | KN-CENSUS-DRIFT-SYMBOLS | unchanged |
| `SKILL.md:222` | 6 of 15 files | 6 (`-` hash) of 15 rows | KN-DRIFT-BOUND-FILES (`rows:`) | unchanged |
| `SKILL.md:245` | ledger selftest 170 cases | 170 | SC-LEDGER-SELFTEST | unchanged |
| `SKILL.md:428` | 9 runnable items | 9 runnable / 16 rows (`checklist.tsv`) | — | unchanged |
| `SKILL.md:751` | closure 14 cases | 14 | SC-CLOSURE-SELFTEST | unchanged |
| `SKILL.md:752` | rendered-text 22 cases | 22 | SC-RENDERED-SELFTEST | unchanged |
| `PROVINCE.md:35` | checklist 34 / op-ref 36 cases | 34 live / 36 pin | PV-CHECKLIST-SELFTEST / PV-OPREF-SELFTEST | unchanged |
| `PROVINCE.md:37` | release-clock 116 cases | 116 | PV-CLOCK-SELFTEST | unchanged |
| `PROVINCE.md:67` | surface census 35 rows, state 22 rows | 35 / 22 | PV-CENSUS-ROWS / PV-STATE-ROWS | unchanged |
| `PROVINCE.md:68` | 15 files / 20 claims | 15 / 20 | PV-DRIFT-FILES / PV-DRIFT-SYMBOLS | unchanged |
| `PROVINCE.md:71` | checklist 16 items, 34 cases | 16 / 34 | PV-CHECKLIST-SELFTEST | unchanged |
| `PROVINCE.md:74` | self-counts 48 cases | 48 | PV-SELFCOUNTS-SELFTEST | unchanged |
| `PROVINCE.md:76` | feed-token 12 shapes, 4 cases | pins `shapes=12` / `(4 cases)`; live receipt from seat XD1Rows `AGREE (shapes=12 disagreements=0)` / `PASS (4 cases)` | PV-FEEDTOKEN-SHAPES / PV-FEEDTOKEN-SELFTEST (**POLICY: live row unreachable from self-counts**) | unchanged |
| `PROVINCE.md:77` | sources-census 70 cases | 70 | PV-SOURCES-SELFTEST | unchanged |
| `PROVINCE.md:78` | rendered-text 22 cases | 22 | PV-RENDERED-SELFTEST | unchanged |
| `corpus/README.md:33` | 16 items, 34 cases | 16 / 34 | RD-CHECKLIST-SELFTEST + PV-CHECKLIST-SELFTEST | unchanged |
| `corpus/README.md:36` | drift 13 cases | 13 (see `SKILL.md:183`) | — | unchanged |
| `corpus/README.md:37` | 15 host files, 6 private `-` | 15 / 6 | PV-DRIFT-FILES + KN-DRIFT-BOUND-FILES | unchanged |
| `corpus/README.md:40` | 16 cases | 16 (R11-03 pin) | (see SC-CENSUS-SELFTEST) | unchanged |
| `corpus/README.md:41` | 35 rows (20 asset / 15 runtime), 4 `# scan`, 1 `mode = -` | 35 (20/15), 4, 1 | RD-CENSUS-ROWS | unchanged |
| `corpus/README.md:42` | 22 rows | 22 | RD-STATE-ROWS | unchanged |
| `corpus/README.md:43` | 61 cases, 18/18 mutations | 61 / 18 | RD-SCOPE-SELFTEST + KN-SCOPE-MUTATIONS | unchanged |
| `corpus/README.md:63` | selftest 170 cases | 170 | RD-LEDGER-SELFTEST | unchanged |
| `corpus/README.md:66` | "30 bounds" | 30 numbered items in `knowledge/claim-ledger.md` §Bounds | — | unchanged |
| `corpus/README.md:69` | op-ref 36 cases | 36 | RD-OPREF-SELFTEST | unchanged |

Deliberately out of population (`self-counts.tsv` header: host measurements and explicitly
round-dated clauses are out by rule), therefore **not** draft cells:

- `corpus/README.md:44` / `PROVINCE.md:72` breadth ratios `20/4, 105/2, 4/1, 53/1` and
  `5 owned prefixes (27 census rows)`. Declaration-derived parts are current (5 `# own`,
  4 group rows, 8 no-enumerate, 4 breadth pins, 35 census rows, 27 = 35−8). The **child counts
  are host state measured with the substrate present** and they differ on this host:
  live `~/.config/opencode=5` (pin 20), `~/.local/bin=112` (pin 105), `~/.agents=3` (pin 4),
  `chrome-profile` **absent** (pin 53) — receipt `XD2Cells-breadth-host.txt`. Their ledger rows
  `R16-01`/`R17-01` are `[substrate]`-tagged and DEFER with the handler absent, so this is a
  correct host output, **not** a doc drift; do **not** re-pin them from this host.
- `corpus/knowledge/*.md` cells: all 62 self-counts claims are evaluated; only the eight above are
  stale.
- `SKILL.md:37` (`files=N symbols=M` template), `SKILL.md:46` `claim ids` (no count),
  `corpus/README.md:147` prose: no bindable count.

## E. Round-dated history lines deliberately untouched

`SKILL.md:187` ("15 files as of round 9"), `SKILL.md:198` ("2 of 13 files", round-9/12 audit),
`SKILL.md:253` ("18 rows as of round 14"), `SKILL.md:620` / `:631` / `:632` / `:633` (Round-10 and
Round-11 repro blocks: `ok=34`, `claims=11 stamped=28`, `cites≈505 docs=39`, `39 cases`),
`SKILL.md:654`–`656` (Round-14 block: `entries=17 row_linked=14`), `README.md:35` ("`15-item`
scorecard cell"), `README.md:64` parenthetical (39/35/R25), `README.md:65` parenthetical
(89/88/63/56/54), `README.md:67` parenthetical (21/3/24, 18/3/21, 20/17/3),
`PROVINCE.md:30`–`33` (round-29 cross-host debt), `PROVINCE.md:37` ("after round 29"),
`PROVINCE.md:73` ("121 at round 23; 151 at round 24"), `corpus/README.md:76`–`78` ("read
2026-10-19").

## F. Machine-checkable receipt of the drafts

Applied to a scratch mirror of `b7482b4` with CR removed (C2 simulated), then
`python3 corpus/self-counts.py`:

```
POLICY PV-FEEDTOKEN-SHAPES ledger:R29-02 command not allowlisted
POLICY PV-FEEDTOKEN-SELFTEST ledger:R29-01 command not allowlisted
SELF_COUNTS: POLICY (claims=62 stale=0 unlocated=0 ambiguous=0 policy=2 setup=0)
```

i.e. **stale 8 → 0** with these drafts and no other binding disturbed; the two remaining rows are
the raw `python`-first-token rows in the ledger (C1's own scope), not doc cells. Exact text diff:
`XD2Cells-cell-diff.txt` (6 changed lines, 9 changed numbers, no other line touched).

Both OPTIONAL history anchors in §A3/A4 were applied on a second scratch mirror and re-measured:
`SELF_COUNTS: POLICY (claims=62 stale=0 unlocated=0 ambiguous=0 policy=2 setup=0)` — the
`self-counts` regexes still capture `67` / `94`, so either variant is gate-safe.

Before the drafts, on the same mirror: `stale=8 setup=0 policy=2`; on the lane tree itself
(receipt `XD2Cells-before-selfcounts.txt`): `stale=8 setup=1 policy=2` (the SETUP row is
`KN-CHECKLIST-FALSIFY-FLOOR`, C2-coupled — see the report §F3).

## G. Post-integration verification the L1 should run

```
python3 corpus/self-counts.py                      # expect stale=0; POLICY persists until R29-01/02 are python3-first-token
grep -n '(94 stamps + 67 claims' SKILL.md
grep -n '`verify` (94 revision stamps + 67 claim rows' PROVINCE.md
grep -n '| 67 rows (39 at round 21' corpus/README.md
grep -n '| 94 rows (89 at round 26' corpus/README.md
grep -n '23 row-linked / 3 by-hand / 26 pinned' corpus/README.md
grep -n 'sources-census validate (CLEAN rows=52)' PROVINCE.md
```
