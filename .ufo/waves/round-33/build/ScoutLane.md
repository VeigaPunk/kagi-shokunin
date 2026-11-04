# ScoutLane — round-33 data-walk (insertion points and formats)

Read-only. BASE `76f4eeae7aa9af4dbb9423f5632b55791824253a`; lane worktree tracked files are at BASE
(`git diff 76f4eea -- .` shows only `plans/` and `.ufo/` additions). Wrote nothing outside
`.ufo/waves/round-33/build/ScoutLane.md` and `/fast/scratch/hyaku/kagi-r33/ScoutLane/` (removed before yield).
No lane file edited; no git mutation; no vault contact; no network.

Every `file:line` below is a 1-based line in the BASE worktree. Quoted spans are contiguous and ≤20 words.

---

## 1. `SCORECARD.md`

| Item | Line | Value |
|---|---|---|
| `## Capabilities` heading | 696 | `## Capabilities` |
| table header row | 698 | `\| Capability \| What it can now do \| Evidence pointer \| First-working round \|` |
| separator | 699 | `\|---\|---\|---\|---\|` |
| last data row | 705 | `\| differential feed-token agreement gate \| import the live feed extractors and the shared token grammar` … final cell `\| 29 \|` |
| stale prose | 707 | `The latest first-working round in this table is 25 (release-clock observation).` |
| `## Saturation` heading | 709 | `## Saturation` |

- Table shape: **4 columns / 5 pipes**, no escaped pipe in rows 698–705 (verified per-line).
- `awk '/^## Capabilities$/,/^## Saturation$/'` window = **lines 696–709**, 14 lines, inclusive of both headings;
  696 and 709 are the only matches of the two patterns in the file.
- Insertion point for the C1 row: after **705**, before the blank at 706. New row shape:
  `| <capability> | <what it can do> | <evidence pointer> | 33 |`.
- Stale sentence is the **last sentence of line 707**; R32-4 records the same location as `32c35fe:707`
  (verified identical line: `git diff 32c35fe 76f4eea -- SCORECARD.md` = 28 insertions, all appended
  after line 1293, so 707 does not shift).
- The last table row already reads `29`, so line 707 contradicts the table one section above it.

Ran: `grep -n '^## ' SCORECARD.md`; `awk 'NR>=694 && NR<=712 {printf "%d: %s\n", NR, $0}' SCORECARD.md`;
`awk '/^## Capabilities$/,/^## Saturation$/' SCORECARD.md | nl -ba`;
`git show 32c35fe:SCORECARD.md | sed -n '707p'`; `git diff --stat 32c35fe 76f4eea -- SCORECARD.md`.

---

## 2. `corpus/QUALITY.md`

| Item | Line | Value |
|---|---|---|
| last criterion row | 166 | `\| QM33 \| A frontier-to-core move removes the frontier entry in the same round;` … |
| its table header | 164 | `\| id \| criterion \| weak signal \| lesson \|` |
| its separator | 165 | `\|---\|---\|---\|---\|` |
| last section heading | 162 | `## Criterion from the round-32 M32-1 mistake (landed round 32)` |

- Section shape is fixed: `##` heading, one blank line, 4-column table (`| id | criterion | weak signal | lesson |`
  + `|---|---|---|---|`), one row per criterion, optional unheaded prose after the table (QM33's is lines 168–172).
- Heading grammar (all 13 sections): plural **`## Criteria from …`** when the section carries several rows
  (lines 29, 51, 67, 89, 102, 114, 128); singular **`## Criterion from …`** when it carries one row
  (122, 138, 144, 150, 162). Round-tagged sections end `(landed round N)`; the round-21 `## Admission bar (round 21)`
  (line 12) is the only differently-worded heading.
- Header-cell variant: the round-21 admission bar (line 18) is `| id | criterion | weak-material signal | lesson |`;
  every later section, lines 37/57/69/95/104/116/124/130/140/146/152/164, is `| id | criterion | weak signal | lesson |`.
  **A QM34 row belongs in the `weak signal` variant.**
- Column-count exception: `corpus/QUALITY.md:148` (QM31) counts **5** pipes because its weak-signal cell carries
  a literal `\|` (the `($'\r'`, `\|`) pipeline text). All other 68 table rows are 4 columns. Any cell that must
  show a pipe uses `\|` and then reads as 5 to a naive counter.
- Criteria are append-only (lines 8–10); a new QM34 section appends after line 172 (EOF).

Ran: `awk '{printf "%d: %s\n", NR, $0}' corpus/QUALITY.md`;
`awk 'NR>=18 && /^\|/ {n=gsub(/\|/,"|"); printf "%d cols=%d\n", NR, n-1}' corpus/QUALITY.md | sort | uniq -c`;
`grep -n '^| id |' corpus/QUALITY.md`; `grep -n '^## ' corpus/QUALITY.md`.

---

## 3. `corpus/claim-ledger.tsv`, `corpus/stamps.tsv`, `stamp` invocation

### 3a. Claim row schema (6 fields, note optional)

`corpus/claim-ledger.tsv:1`:

```
# claim-ledger.tsv — one row per durable claim: id <TAB> command <TAB> expect <TAB> exit <TAB> timeout <TAB> note
```

Representative claim row, `corpus/claim-ledger.tsv:89`:

```
R31-03	grep -c '^lane-status: ' SCORECARD.md	^1$	0	30	round 31 (considerthese 2026-10-26 proposal 2, mined): exactly one lane-status line in SCORECARD.md.
```

Last row, `corpus/claim-ledger.tsv:92`: `R31-06` (same 6-field shape). 92 lines = 4 leading `#` lines + 14
interleaved `#` comment lines + **74 claim rows** (`row-identity.sh ledger-ids count=74` agrees).

Loader contract (`corpus/claim-ledger.sh:543-553`): blank and `#`-leading lines are skipped; `split_tab`;
`TF_N` must be 5 or 6; `exit` must be `^[0-9]+$`; `timeout` `^[1-9][0-9]*$`; `expect` must contain a literal
(`[[ $expect =~ [^\^\$] ]]`, not just anchors); the ERE is matched against the **last non-empty** output line
(`claim-ledger.sh:616-624`) and the exit code must equal field 4.

### 3b. Stamp row schema (4 fields, no header row)

`corpus/stamps.tsv` has **no comment/header row**; line 1 is data. Representative stamp row,
`corpus/stamps.tsv:82` — the row for the file the L1 edits this round:

```
corpus/lessons/round-32.md	947d639eb2f7c6150009065f5865d598710e45469506a5fbb3a807e892ad338a	59	7420
```

Fields, from `corpus/claim-ledger.sh:14`: `path <TAB> sha256 <TAB> lines <TAB> bytes`. 104 data rows
(`grep -cvE '^(#|$)' corpus/stamps.tsv`). Rows are sorted (`sort -o` at `claim-ledger.sh:438`).

### 3c. How `stamp` is invoked

- Dispatch: `corpus/claim-ledger.sh:336` — `stamp) MODE="stamp"; shift ;;`; positional paths collect at `:351`.
  Invocation is `bash corpus/claim-ledger.sh stamp PATH…` (usage block line 19: `` `stamp PATH…` regenerates the WHOLE row set from the paths given ``).
- It **replaces** the file: "it replaces the file, it does not merge" (line 20); a run naming fewer paths than the
  file holds is refused — `refusing to shrink $out: '$old' is pinned and would be dropped` (line 413) — unless
  `--prune` is passed (line 343).
- `--out FILE` (line 342) resolves against **`$PWD`** when relative (`:386`), not against `--root`; the output file
  itself may not be stamped (lines 400/421–422).
- Refusals: absolute path (`:418`), whitespace (`:419`), tab (`:420`), `..` (`:423`), duplicate path in one run
  (`:424`), non-file/missing (`:427-428`), symlink escaping `--root` (`:431-432`).
- Verdict line: `printf 'STAMPED: n=%d out=%s\n' "${#POS[@]}" "$out"` (line 441).

Ran: `awk 'NR<=4 || NR>=89 {printf "%d: %s\n", NR, $0}' corpus/claim-ledger.tsv`;
`awk 'NR<=3 {…}' corpus/stamps.tsv`; `grep -cvE '^(#|$)' corpus/stamps.tsv`;
`grep -n 'stamp' corpus/claim-ledger.sh`; `awk 'NR>=300 && NR<=380 {…}' corpus/claim-ledger.sh`;
`awk 'NR>=381 && NR<=455 {…}' corpus/claim-ledger.sh`; `awk 'NR>=536 && NR<=560 && NR>=610 && NR<=630'` (two calls).

---

## 4. `corpus/sources-census.sh` — `SC_FETCH` and `corpus/source-fetches.tsv`

### 4a. Field order **proven from code**

The parser is `corpus/sources-census.sh:253` (row-shape check `NF!=16`) and `:255` (the read), gated by `:287`
(`NF==16`). The read order, with the per-field validation lines:

| # | Variable | Meaning | Code proof |
|---|---|---|---|
| 1 | `fid` | registry id | `:255`, `:259` |
| 2 | `fstatus` | status, must equal registry | `:260` |
| 3 | `frow` | row-identity digest | `:262-263` |
| 4 | `furl` | exact registered URL | `:261` |
| 5 | `ffinal` | final URL after redirects | `:264` |
| 6 | `fhttp` | HTTP status, 3 digits | `:265` |
| 7 | `fprof` | request profile, `curl-fsSL-compressed-v1` | `:266` |
| 8 | `ffet` | fetched date, `YYYY-MM-DD` | `:267` |
| 9 | `frep` | `decoded-http-body-v1` or `-volatile-v1` | `:268` |
| 10 | `fsha` | representation sha256, 64 hex | `:269` |
| 11 | `fbytes` | byte count, positive int | `:270` |
| 12 | `frev` | 40-hex revision or `-`; mandatory for moving-ref URLs | `:271-276` |
| 13 | `fquote` | quote, ≤25 words | `:277-278` |
| 14 | `fnorm` | `rendered-text-v1` or `raw-literal-v1` | `:279` |
| 15 | `fnsha` | 64 hex when rendered, `-` otherwise | `:280-284` |
| 16 | `floc` | location, ≥8 chars | `:285` |

Row-identity digest is **`sha256("id<TAB>status<TAB>url<LF>")`** (`:262`). Verified by recomputation:
`printf '%s\t%s\t%s\n' S072 mined https://app-updates.agilebits.com/product_history/CLI2 | sha256sum`
→ `10793c3f…bacc30`, equal to column 3 of the S072 row.

### 4b. `corpus/source-fetches.tsv` header

`corpus/source-fetches.tsv:6` — `# 16 tab-separated columns, no tabs inside a cell:`; the itemised names at
lines 7–35 are, in order: `id`, `status`, `row_identity_sha256`, `url`, `final_url`, `http_status`,
`request_profile`, `fetched`, `representation`, `sha256`, `bytes`, `revision`, `quote`, `normalization`,
`normalized_sha256`, `location` — **identical to the code order**. The file has **no** single header line:
43 leading/interleaved `#` comment lines, then 72 data rows at **lines 44–115**, ascending, `S017` first
(`:44`) and `S072` last (`:115`). Append the ten new rows after line **115**.

Ran: `awk 'NR>=230 && NR<=300 {printf "%d: %s\n", NR, $0}' corpus/sources-census.sh`;
`awk 'NR<=12 {…}' corpus/source-fetches.tsv`; `awk 'NR>=30 && NR<=43 {…}' corpus/source-fetches.tsv`;
`awk -F'\t' '$0!~/^#/ && NF==16 {n++} END{print n+0}' corpus/source-fetches.tsv` → 72;
`printf '%s\t%s\t%s\n' S072 mined <url> | sha256sum`.

---

## 5. `corpus/self-description-sweep.sh`

### 5a. `--root`

- `corpus/self-description-sweep.sh:46` — `ROOT=.` (default).
- `:53-55` — `--root)` with `[ $# -ge 2 ] || die "missing value for --root"`.
- `:56-57` — `--root=*) ROOT=${1#--root=}`.
- `:68-69` — `[ -d "$ROOT" ] || die "root is not a directory: $ROOT"`, then `ROOT_ABS=$(cd -- "$ROOT" && pwd -P)`.

So both `--root DIR` and `--root=DIR` work; everything below reads under `ROOT_ABS`.

### 5b. Files each check reads, and existence at `32c35fe`

| Check | File read | Line | Exists at 32c35fe |
|---|---|---|---|
| SD1 | `PROVINCE.md` | 258 (`[ -f … ] || die`, 259) | yes |
| SD2 | `corpus/README.md` | 285 | yes |
| SD3 | `SHONEN.md` (tokens resolved under root) | 308 | yes |
| SD4 | `corpus/lessons/round-31.md` | 327 | yes |
| SD5 | `SCORECARD.md` | 339 | yes |
| SD6 | `corpus/claim-ledger.sh` (then the citations doc set) | 361 | yes |

Verified: `git ls-tree -r --name-only 32c35fe | grep -E '^(PROVINCE.md|SHONEN.md|SCORECARD.md|corpus/README.md|corpus/lessons/round-31.md|corpus/claim-ledger.sh|corpus/stamps.tsv|corpus/claim-ledger.tsv)$'`
printed all entered names; `git rev-parse 32c35fe` = `32c35fe5ed44f2017d6a662c7fd13f7e63a7ce9b`. All six checks read
a file that exists at 32c35fe; none dies on a missing input.

### 5c. Trigger conditions that matter for this round

- **SD1 theme list is exactly two entries**: `:260` — `themes=('OIDC workload-federation' 'secret[- ]scanning')`.
  **NIST is not in it**, so a NIST `Frontier` bullet left beside the new NIST `Core` bullet cannot raise SD1.
  The plan states this ("the sweep's theme list does not include NIST"), and it is correct. SD1 requires the theme in
  a line containing `Core` **and** in a bullet line containing `Frontier` (254–281); the Core trigger is the bare
  substring `*Core*`.
- **SD2 matches only the literal `moved to core`** inside a heading that is exactly `## Frontier` (`:291-303`).
  Removing `corpus/README.md:117` is safe; rewriting that bullet to say `moved to core` would **fire SD2**.
- **SD5 reads the LAST `## Round` section**: `:346` — `round_line=$(grep -nE '^## Round' "$score" | tail -n 1 | cut -d: -f1)`,
  and takes the first `| calibration |` row after it (`:350`, dies if absent `:351`). Appending a round-33
  section therefore makes **that** section authoritative; its calibration row must contain the three lane-status
  red ids (`R25-02`, `R29-01`, `R29-02`, parsed at `:344` from the parenthetical) or SD5 becomes 3. At BASE the last
  section is `SCORECARD.md:1307` (`## Round 32 — post-move …`) and its calibration row is line 1313, which names all
  three reds — that is why SD5=0 today.
- SD6 counts lines beginning `UNRESOLVED` in the citations gate run inside root (`:361-376`); new knowledge entries
  with an unresolved token raise SD6 above its BASE 2.

Ran: `awk 'NR<=80 {printf "%d: %s\n", NR, $0}' corpus/self-description-sweep.sh`;
`grep -n 'SD[1-6]\|PROVINCE.md\|corpus/README.md\|SHONEN.md\|round-31.md\|lane-status\|citations' corpus/self-description-sweep.sh`;
`awk 'NR>=255 && NR<=305 {…}'` and `awk 'NR>=336 && NR<=389 {…}' corpus/self-description-sweep.sh`;
`grep -nE '^## Round' SCORECARD.md | tail -6`; `git ls-tree -r --name-only 32c35fe`.

---

## 6. `corpus/lessons/round-32.md` — `## Mistakes`

Header, `corpus/lessons/round-32.md:21`:

```
| id | class | evidence | captured-by | fix shown able to fail |
```

Separator, `:22`: `|---|---|---|---|---|` (5 columns).

`corpus/lessons/round-32.md:24` — M32-2. Its `captured-by` cell (field 4) is verbatim:

```
pre-freeze control duty was not fulfilled by the L1's estimate
```

`corpus/lessons/round-32.md:25` — M32-3. Its `captured-by` cell (field 4) is verbatim:

```
ownership boundary
```

These are the two cells the plan directs to `QM34` and `none`. The `fix shown able to fail` cells are fields 5;
R32-2 also faults M32-2's field 5 as "a disposition, not a fix shown able to fail"
(`corpus/lessons/round-32-verifier-spotcheck.md:133-136`) — the plan's stated edit covers only field 4.

Ran: `awk '{printf "%d: %s\n", NR, $0}' corpus/lessons/round-32.md`;
`awk 'NR>=126 && NR<=150 {printf "%d: %s\n", NR, $0}' corpus/lessons/round-32-verifier-spotcheck.md`.

---

## 7. `corpus/SOURCES.md` — registry shape

- Header row, `corpus/SOURCES.md:5`:
  `| id | source | kind | tier | scope | anchor | teaches | status | opened | recheck | used-by |`
- Separator, `:6`: `|---|---|---|---|---|---|---|---|---|---|---|`
- **11 columns / 12 pipes**; the census requires `NF==13` from `awk -F'|'` (leading and trailing pipe produce
  empty `$1`/`$13`) — `corpus/sources-census.sh:234,244`.
- Last row, `corpus/SOURCES.md:79`: `| S072 | 1Password CLI Release Notes — https://app-updates.agilebits.com/product_history/CLI2 | docs | A |` …
  (11 columns, 637 bytes, ends `| corpus/lessons/round-32.md |`).
- Registry span: header 5, separator 6, rows 7–79 = **72** rows (matches BASE); a blank line at **44** splits the
  markdown table visually but not for the census. Append S073–S082 after **79**, before the blank at 80.
  Next heading is `## Paths` at **81**.
- Row regex the census accepts: `^\|[[:space:]]*S[0-9][0-9][0-9]+[[:space:]]*\|` plus `NF==13`
  (`sources-census.sh:234,244`). No ordering or uniqueness check exists in the census — ascending ids are convention only.

Ran: `grep -n '^## ' corpus/SOURCES.md | head -8`; `awk 'NR>=5 && NR<=82 && !/^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|/ {…}' corpus/SOURCES.md`;
`awk 'NR>=5 && NR<=80 && /^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|/ {n++} END{print n+0}' corpus/SOURCES.md` → 72;
`grep -n '^| S072 ' corpus/SOURCES.md` + pipe count.

---

## 8. C2 removal / insertion points (not in the numbered Work list; needed to land C2)

| File:line | Current content (≤20-word verbatim span) |
|---|---|
| `PROVINCE.md:90` | `- **Frontier — explored, not held:** NIST key-management draft status` (`corpus/README.md` §Frontier; leads in …) |
| `PROVINCE.md:83` | `## Core / Frontier / Adjacent (round 21)` |
| `PROVINCE.md:89` | `- **Core, round 31 — OIDC workload-federation trust policy:**` … ends `the NIST leads stay leads.` |
| `corpus/README.md:111` | `## Frontier` |
| `corpus/README.md:117` | `- **NIST key-management draft status** — distinguish final guidance from IPDs before adopting controls;` |
| `corpus/README.md:119` | `## Known gaps` |

- The Core-bullet pattern to copy is `PROVINCE.md:88-89`: `- **Core, round <N> — <theme>:** <entry paths>; rows S… in \`corpus/SOURCES.md\`, every source re-opened <date>). <discharge sentence>`.
- `corpus/README.md` §Frontier window is lines **112–118**; the plan's counter
  `awk '/^## Frontier/{f=1;next} /^## /{f=0} f' corpus/README.md | grep -c 'NIST'` reads 1 today, from line 117 only.
- Line 113 (`- **Observable release clocks** …`) is also inside that window but contains no `NIST`.
- Cross-reference risk: `PROVINCE.md:89` ends `the NIST leads stay leads` and `PROVINCE.md:88` says
  `The frontier bullet below keeps its history.` — the bullet that sentence refers to (secret scanning) was already
  removed in round 32, so line 88 is dangling at BASE; neither sentence is covered by SD1–SD6.

Ran: `grep -n 'NIST' PROVINCE.md corpus/README.md`; `awk 'NR>=83 && NR<=92 {…}' PROVINCE.md`;
`awk '/^## Frontier/,/^## [^F]/ {…}' corpus/README.md`.

---

## 9. Formats the L1 must match (yield list)

1. **SCORECARD capability row** — 4 columns, `| <capability> | <what it can do> | <evidence pointer> | <first-working round> |`,
   inserted after line 705; first-working-round cell `33`.
2. **QUALITY criterion row** — new `## Criterion from … (landed round 33)` section after EOF, one 4-column table
   `| id | criterion | weak signal | lesson |` + `|---|---|---|---|`, row id `QM34`, lesson cell pointing at
   `corpus/lessons/round-32.md` (and, if used, the round-33 lesson).
3. **Claim row** — 6 tab-separated fields `id⇥command⇥expect⇥exit⇥timeout⇥note`; expect = ERE over the **last non-empty**
   line, must contain a literal; exit numeric; timeout positive int. Append after `R31-06` (line 92) as `R33-…`.
4. **Stamp row** — 4 tab-separated fields `path⇥sha256⇥lines⇥bytes`, no header row, sorted; produced only by
   `bash corpus/claim-ledger.sh stamp <every existing path> <additions>` (whole-set replacement; `--prune` to shrink).
5. **Fetch provenance row** — exactly **16 tab-separated fields** in the §4a order, `NF==16`; row-identity digest =
   `sha256(id⇥status⇥url⏎)`; `revision` = `-` unless the URL is a moving ref; `normalized_sha256` = `-` unless
   `normalization=rendered-text-v1`. Append after line 115.
6. **Registry row** — 11 columns / 12 pipes (`NF==13` to the census), regex `^\|\s*S[0-9]{3,}\s*\|`, status `mined`,
   `used-by` an existing regular file whose column-1 `source:` line carries the id; append after line 79.
7. **Knowledge entry header** — `# Title`, blank, exactly one column-1 `source: S… (url, anchor, opened DATE)` line,
   `verified-at:`, `recheck:`, and a `Reverify:` line (`R…` list or `by-hand: <class> — <reason ≥24 chars>`);
   every entry needs a stamps row (`corpus/claim-ledger.sh` header §entry, lines 67–79).
8. **Mistakes cell** — `captured-by` must be a criterion id or `none`; 5-column table, separator `|---|---|---|---|---|`.
9. **PROVINCE Core bullet** — `- **Core, round 33 — <theme>:** …` after line 89; Frontier bullet at line 90 removed.
10. **README Frontier** — bullet at line 117 removed; do **not** replace it with text containing `moved to core`.

---

## 10. Comment-header vs code contradictions

1. **`corpus/sources-census.sh:60-63` contradicts the code's field order.** The header says
   `it declares request profile, final URL, HTTP status, representation, digest` (fields 7, 5, 6, 9, 10), while the
   parser at `:255` reads `final URL, HTTP status, request profile, fetched, representation, …` (fields 5, 6, 7, 8, 9).
   The header also omits `fetched` (field 8) from its enumeration entirely, never names `revision` (field 12) or
   `quote` (field 13) as columns, and fuses fields 13–14 into "quote normalization". Only the enumeration order is
   wrong; the set is otherwise present. `corpus/source-fetches.tsv:6-35` states all 16 names in the correct order.
2. **`SCORECARD.md:707` contradicts `SCORECARD.md:705`** — prose says the latest first-working round is 25, the table's
   last row says 29. This is the R32-4 defect, still present at BASE.
3. **`plans/round-33.md:113,116,134,135` declares `captures=101` / target `captures=111`, the measured value is 72.**
   The lane census at BASE prints
   `SOURCES_CENSUS: CLEAN (rows=72 A=69 B=1 C=2 queued=1 mined=68 rejected=3 entries_sourced=10 legacy=21 captures=72 inrow=16 inrow_only=0 inrow_nonreproducing=12)`.
   `n_capt` counts registry ids with ≥1 provenance row (`sources-census.sh:316-317`), so it is bounded by `rows`;
   with 72 capture rows in `source-fetches.tsv` it cannot be 101. `captures=101`/`111` occur nowhere else in
   `plans/`, `corpus/lessons/` or `SCORECARD.md` — the value was never measured. By the plan's own +10 accounting the
   reachable target is `captures=82`, so the written target `111` is unmet by construction and, read literally,
   kills C2 at the kill rule. Reported, not changed; measured as written.
4. **The committed START receipt carries no census tuple.** `.ufo/waves/round-33/controls/census-start.txt` holds only
   `W04` duplicate-url lines, one `ok <path>` line and `exit=0` — no `SOURCES_CENSUS:` line. The plan's BASE tuple
   therefore has no committed measurement behind it (the M32-2 class recurring in the round that closes it).
5. `corpus/sources-census.sh:25` (`11-column shape is broken (NF!=13)`) is **not** a contradiction: 11 real columns
   yield `NF=13` under `awk -F'|'`.

---

## 11. Calibration risks for the L1 (observed, not predicated)

- **SD5 flips to 3 if the round-33 section's calibration row omits the reds.** The sweep reads the *last*
  `## Round` section. A round-33 section appended with a `| calibration |` row that does not name `R25-02`,
  `R29-01`, `R29-02` changes `SD5=0` to `SD5=3` and the total from 2 to 5.
- **C1's capability-row counter cannot tell a row from prose**: `awk '/^## Capabilities$/,/^## Saturation$/' … | grep -c 'prefreeze-control.sh'`
  also counts line 707 or any prose inside the window. A single table row satisfies it; a prose mention would too.
- **`grep -c` exits 1 when it counts 0.** The round-33 control `frontier_nist` expects `0` after the fix and its
  command is a `grep -c`; a gate implementation that treats a nonzero command exit as SETUP would fail its own
  post-fix control. The gate must read the last non-empty stdout integer independently of the command's exit code.
- **The gate's controls do not include `captures`**, so `captures=101` passes `plans/round-33.controls.tsv` — the
  gate proves declared-vs-measured only for the declarations it is given (the plan's own named ceiling).
- **Re-stamping is mandatory and wide**: editing `corpus/lessons/round-32.md` invalidates `corpus/stamps.tsv:82`
  (`947d639e…`), and the two new entries add rows; `R24-05` pins `ROW_IDENTITY: stamps count=104 sha256=5c453cd1…`
  (`corpus/claim-ledger.tsv:68`), so the membership pin migrates too. Round 32 regenerated under `LC_ALL=C`
  (`corpus/lessons/round-32.md:55`).
- **`corpus/source-fetches.tsv` rows are 72, not 101** — the ten new rows land at 82 registry-side captures only if
  each new registry id is `mined` and each gets exactly one row; `FSEEN` counts ids, not rows (`:317`).

---

## Evidence

Scratch: `/fast/scratch/hyaku/kagi-r33/ScoutLane/` (empty; no clone needed — all reads are `git show`/`ls-tree` and
worktree reads). No tool installed or upgraded. No scratch dir left behind.

Commands run (all read-only): `git -C … log/rev-parse/ls-tree/show/diff/status`; `grep`/`awk`/`wc`/`cut`/`sha256sum`
over the files cited above; one lane-gate execution `bash corpus/sources-census.sh` (exit 0) and one fleet census
`bash /home/vgpnk/Projects/shokunin/scripts/sources-census.sh validate --root … kagi` (exit 0).
