# Round 68 — R68Revenger: the round-67 bypass battery against the widened census gate

Seat: revenger (attack, 1 of 15). Lane `kagi-shokunin`, branch master, claim BASE
`d3b2a4e8eed710277951e430efd3d27b5983033c`, frozen predeclaration
`23a8e0290d8d3a6f1de16eafce40fd1a189ef636`. Read-only on the lane: every mutation
ran on a scratch copy, every receipt below is a file this seat produced. The lane was
not edited, no git command mutated anything, nothing was committed, and no fleet path
was touched. Scratch root `/fast/scratch/hyaku/kagi-r68/R68Revenger` (deleted after
the receipts were copied here).

## 0. Bytes under test

| role | sha256 | note |
|---|---|---|
| BASE gate (`corpus/sources-census.sh` at `d3b2a4e`) | `e7aacecdfcf06ed6303f5272cd0d3bd6a20d16fdbf0f064a4c68aae940e1d10f` | round-67 gate; the BASE column of every row below |
| candidate gate (lane working tree, frozen for this battery) | `690b0c2ec2a469fee0424f56ccc35b52168d391e225cfa1142b183e4b02ea5c6` | selftest `PASS (98 cases)` |
| `corpus/source-fetches.tsv` (candidate, 158 data rows) | `c14bcd885df2ae446df4d49dde93c9c89ac5f2ec65629a84d77fe9987f7469af` | S166 recut, S167 added |
| `corpus/SOURCES.md` (candidate) | `688fbab4714988ea26e6dd5a3096b66ed767791b658d09ca1750cea8bef38ef1` | S166 col16 recut |
| `corpus/rendered-text-v1.py` | `14f6ca6ab742296f45a699548c31e6d49892f6baef36ed419c283d1a0511b8c9` | byte-identical to BASE |

Method. A snapshot (`.ufo/waves/round-68/w1/R68Revenger/fixtures/snap.py`) copies
`corpus/` and every `.ufo/waves/*/capture*` body — the census gate reads nothing else
(`$ROOT/corpus/SOURCES.md`, `$ROOT/corpus/knowledge/`, `$ROOT/corpus/source-fetches.tsv`,
`$ROOT/corpus/inrow-pins.tsv`, the col-16 bodies; grep of `$ROOT/` in the gate confirms).
Each case then copies the snapshot, mutates the copy, and runs
`bash corpus/sources-census.sh verify --root .` twice: once with the candidate gate and
once with the BASE gate swapped into `corpus/sources-census.sh`. **The gate bytes are
the only variable between the two columns.** 46 cases × 2 gates = 92 runs; every run's
verdict line and finding lines are in `receipts/results-final-690b0c2e.tsv`.

The gate moved during the wave: ten hashes were observed (`e7aacecd` at BASE, then
`cab6b632`, `79fb03f2`, `1f91d36d`, `fd3cb598`, `dd977de5`, `84725a7e`, `b93f0614`,
`e48fc6a7`, `690b0c2e`), and batteries or selftests were run against six of them. Every
number in this report is the frozen `690b0c2e` snapshot; no result is carried across a
gate revision, and the interim readings are in §4 as dead ends, not as class results.
The lane's gate at report time is `690b0c2e` (unchanged through the final battery).

## 1. Independent recount, and the anchor the counter will derive

Own code, not the gate's (`fixtures/indep.py`): classify every col-16 cell by the
frozen sentence, then recompute raw sha256, byte count, `rendered-text-v1 digest` and
`locate` from the file the cell names.

| tree | rows | class | path_rows | bound | located | prose | col15 recomputed==declared |
|---|---|---|---|---|---|---|---|
| BASE `d3b2a4e` content | 157 | path 36, prose 120, token 1 (S166 mixed) | 36 | 36 | 36 | 120 | 31 |
| candidate minus S167 ("recut-only") | 157 | path 37, prose 120 | 37 | 37 | 37 | 120 | 32 |
| candidate `690b0c2e` | 158 | path 38, prose 120 | 38 | 38 | 38 | 120 | 33 |

- The gate's own clean line on the candidate is `SOURCES_CAPTURES: CLEAN (path_rows=38
  bound=38 located=38 prose=120)` and `SOURCES_CENSUS: CLEAN (rows=158 … inrow=16 …)`.
  My recount agrees on all four capture numbers and finds no per-row diff
  (`receipts/indep-snap-690b.txt`, no `DIFF` lines).
- The three readings corroborate Amendment A1 exactly: `36/31` at BASE, `37/32` on the
  recut-only tree, `38/33` on the candidate that also carries S167. A1.1's anchor
  derivation also reproduces: last pure-path row `S156` at BASE, last token row `S166`
  at BASE, `S167` at the candidate (`receipts/indep-base.txt`,
  `receipts/indep-recut-only.txt`, and the anchor print in `receipts/battery-log.txt`).
- **The seat text's "110 prose rows" is stale: the measured prose population is 120 on
  both BASE and candidate** (the round-67 gate printed 121 at BASE because it counted
  S166's mixed cell as prose; the frozen definition does not — a cell carrying a
  `.ufo/waves/` token is not prose, so 120 is the frozen count at both ends). The
  property the seat asks for holds — the unmodified candidate produces no `SC_CAPTURE`
  finding on any no-token row (baseline run, 0 findings,
  `receipts/results-final-690b0c2e.tsv` rows `c0-pure-control`).

## 2. Classes and their verdicts

Anchor: the derived last binding row, `S167`, cell
`.ufo/waves/round-68/capture/S167.body` (35491 B). The witness row for the round-67
bytes is `S113`, cell `.ufo/waves/round-55/capture/S113.body`.

### 2.1 CLOSED — BASE blind, candidate fails with the frozen reason

| # | class, exact input (escaped) | BASE gate | candidate gate | candidate reason | frozen target reachable |
|---|---|---|---|---|---|
| 1a | anchor col16 + `\x20` | CLEAN 37/37/37/121 | FAILED (defects=1, 38/37/37/120) | `SC_CAPTURE id=S167 capture-whitespace` | yes |
| 1b | anchor col16 with leading `\x20` | CLEAN 37/37/37/121 | FAILED (defects=1) | `capture-whitespace` | yes |
| 1c | interior `\x20`: `.ufo/waves/round-68/ capture/S167.body` | CLEAN 37/37/37/121 | FAILED (defects=1) | `capture-token` | yes (either reason allowed by the seat) |
| 1d | anchor col16 + `\r` | CLEAN 37/37/37/121 | FAILED (defects=1, findings=2) | `SC_FETCH cr-in-tsv` + `SC_CAPTURE id=S167 capture-whitespace` | yes (both) |
| 1e | anchor col16 `,` + same path again | CLEAN 37/37/37/121 | FAILED (defects=1) | `capture-whitespace` | yes |
| 1f | anchor col16 `//etc/passwd` | CLEAN 37/37/37/121 | FAILED (defects=1) | `capture-token` | yes |
| 1g | anchor col16 `~/S113.body` | CLEAN 37/37/37/121 | FAILED (defects=1) | `capture-token` | yes |
| 1h | eight spaces `\x20`×8 | CLEAN 37/37/37/121 | **CLEAN 37/37/37/121** | none | **legal, exact reason §2.4 S3** |
| 2 | whole `source-fetches.tsv` saved LF→CRLF | CLEAN **path_rows=0** | FAILED (defects=38, findings=39) | `SC_FETCH cr-in-tsv` + 38× `capture-whitespace`; **path_rows=38** | yes; the `path_rows=0` reading is gone |
| 3 | anchor col15 ← S017's digest (`2a39cb16…`) | CLEAN 38/38/38/120 | FAILED (defects=1) | `SC_CAPTURE id=S167 normalized-digest-mismatch` | yes |
| 4a | mixed prose: `see capture .ufo/waves/round-68/capture/S167.body for details` | CLEAN 37/37/37/121 | FAILED (defects=1) | `capture-token` | yes |
| 4b | S166's exact pre-recut cell: `§1.2 Concept Overview; capture .ufo/waves/round-67/capture/S166.body` | CLEAN 37/37/37/121 | FAILED (defects=1) | `SC_CAPTURE id=S166 capture-token` | yes |
| 4c | S166 after the recut: `.ufo/waves/round-67/capture/S166.body` | CLEAN (bound) | CLEAN (bound) | none | legal, pure path only |
| 6 | CR *inside* the cell: `.ufo/waves/round-55/capture/\r/S113.body` | CLEAN 37/37/37/121 | FAILED (defects=1) | `capture-token` + `SC_FETCH cr-in-tsv` | yes |

The round-67 C1 family is closed on the candidate: every stray-byte, comma, `//`,
`~`, mixed-prose and whole-file-CRLF shape that read `CLEAN` at BASE now reads
`FAILED` with a named reason, and the CRLF save no longer collapses the population to
`path_rows=0` (it is 38, with `bound=0` because every cell is a whitespace defect).

### 2.2 Regression controls — every shape that was LEGAL before is still legal

| # | shape, exact input | BASE gate | candidate gate | note |
|---|---|---|---|---|
| 5a | `./` prefix: `./.ufo/waves/round-68/capture/S167.body` | CLEAN 38/38/38/120 | CLEAN 38/38/38/120 | still **bound**, not merely legal |
| 5b | doubled slash: `.ufo//waves/round-68/capture/S167.body` | CLEAN 38/38/38/120 | CLEAN 38/38/38/120 | candidate normalises `//` for the class test; still bound |
| 5c | inner `./`: `.ufo/waves/round-68/capture/./S167.body` | CLEAN 38 | CLEAN 38 | bound |
| 5d | inner `../`: `.ufo/waves/round-68/capture/../capture/S167.body` | CLEAN 38 | CLEAN 38 | bound |
| 5e | in-tree symlink to an in-tree body (`R68Rev-alias.body` → the anchored body) | CLEAN 38 | CLEAN 38 | `stat -L` binding holds |
| 5f | absolute path inside the tree | FAILED `capture-outside-root` | FAILED `capture-outside-root` | policy unchanged |
| 5g | S099's exact cell shape `.ufo/prompts/kagi-round-44.md §6 item 9, line 561 (byte offset 52924)` | CLEAN | CLEAN | still prose, never read, no finding |
| 5h | 120 no-token rows on the unmodified tree | no finding | no finding | baseline run, 0 findings |

### 2.3 Six frozen legs on the derived anchor

| leg | mutation | candidate gate line | expected reason present |
|---|---|---|---|
| M1 | anchor col16 + `\x20` | `SC_CAPTURE id=S167 capture-whitespace` | yes |
| M2 | anchor col16 `,`+dup | `SC_CAPTURE id=S167 capture-whitespace` | yes |
| M3 | whole TSV LF→CRLF | `SC_FETCH cr-in-tsv` (+ 38 id'd `capture-whitespace`, S167 among them); rc 1 | yes, **file-level, no id** |
| M4 | one hex digit of anchor col10 flipped | `SC_CAPTURE id=S167 capture-digest-mismatch` | yes |
| M5 | anchor col15 ← another rendered row's digest | `SC_CAPTURE id=S167 normalized-digest-mismatch` | yes |
| M6 | one byte appended to the anchor body | `SC_CAPTURE id=S167 capture-bytes-mismatch` + `capture-digest-mismatch` | yes |

`caught=6/6` is reachable on `690b0c2e`. Two notes for the counter (not defects):
M3 emits no `id=` line of its own — the plan's own leg table names `SC_FETCH cr-in-tsv`
for it, so the counter must accept the file-level finding; and M6 emits two findings,
so the counter must accept more than one per row (round 67 had the same requirement).

### 2.4 What SURVIVED, with exact inputs

Full escaped bytes: `receipts/survivor-inputs.txt`.

| id | class, exact input | BASE | candidate | why it survives |
|---|---|---|---|---|
| S1 | **symlinked directory alias**: S113's cell written as `.ufo/wv/round-55/capture/S113.body`, with `.ufo/wv` a symlink to `waves` (in-tree) | CLEAN **path_rows=38 bound=38** | CLEAN **path_rows=37 bound=37, prose=121** | the class decision is lexical; normalize only collapses `//` and `/./`. A token that resolves to the bound body but spells the directory another way falls to frozen `prose` and is never read. This is round-67 C1's silent disengage, reachable through the filesystem instead of through stray bytes. |
| S2 | **case variant**: `.UFO/waves/round-55/capture/S113.body` | FAILED `capture-missing` | CLEAN path_rows=37, prose=121 | same lexical test. On a case-insensitive mount this cell binds the same body with no token; the workstation is case-sensitive, so today the read fails *silently as prose* instead of loudly as missing. |
| S3 | **all-whitespace cell** `\x20`×8 (anchor and S113) | CLEAN | CLEAN | frozen-legal: names no `.ufo/waves/` token, so it is prose. The row simply stops declaring a capture; nothing is left to bind. Refusing it needs a rule change, not an implementation fix. |
| S4 | **shaped non-waves path**: anchor col16 = `corpus/quote-bodies.tsv` | FAILED (bytes+digest: row was read) | CLEAN path_rows=37, prose=121 (not read) | the population is `.ufo/waves/`-scoped by the round's own definition. Legal by the frozen sentence, but a real narrowing: a capture declared anywhere else is unverified. |
| S5 | in-tree hardlink to an out-of-tree body (round-67 C2) | CLEAN 38/38/38 | CLEAN 38/38/38 | point-in-time attestation unchanged. |
| S6 | one-token quote `the` (round-67 C5) | CLEAN | CLEAN (located 90×) | evidentiary-strength ceiling unchanged. |
| S7 | normalizer that forwards `digest` to the real script and always answers `locate count=1` (round-67 C4) | CLEAN | CLEAN 38/38/38, no finding | the instrument beside the gate still decides `located`. |

Rounding: the round-67 C4 class is **narrowed, not closed** — a normalizer that lies
only about `locate` is still invisible; one that also lies about `digest` is now caught
by the new col-15 recompute (33 rows, `defects=33`; see §2.5).

### 2.5 Over-capture (the candidate fails cells the frozen sentence calls prose)

| exact input | BASE | candidate |
|---|---|---|
| prose row S017 col16 = `see //example.org/x for details` | CLEAN 38/38/38/120 | FAILED (defects=1) `SC_CAPTURE id=S017 capture-token` |
| prose row S017 col16 = `home ~/notes/x` | CLEAN 38/38/38/120 | FAILED (defects=1) `SC_CAPTURE id=S017 capture-token` |

The frozen one-sentence rule calls both cells prose (no `.ufo/waves/` token); the frozen
reason set calls a `//` form and a `~/` form `capture-token`. The gate implements the
reason set. No current row trips it (clean run 0 findings), but a future prose cell that
quotes a URL or a home path will fail the census. This is the one place the plan's two
sentences disagree, and the implementation chose the reason set — the right choice for
the seat's expected bytes (`//etc/passwd`, `~/S113.body`), stated here so the lesson can
pin it.

### 2.6 Ceilings re-measured

- **C4 (normalizer)** — two variants measured. Naive (lies about both answers):
  BASE CLEAN, candidate **FAILED** with 33× `SC_CAPTURE … normalized-digest-mismatch`
  (the new col-15 recompute). Smart (forwards `digest`, lies about `locate`):
  BASE CLEAN, candidate CLEAN. So the gate now catches a normalizer that corrupts the
  digest, not one that only inflates `locate`.
- **C2 (hardlink)** and **C5 (one-token quote)**: unchanged, both CLEAN on both gates.
- **C8 (summary line vs census verdict)**: still reachable. Measured on the candidate:
  append one `\r` to a *prose* row's col 16 (S017) and the gate prints
  `SOURCES_CAPTURES: CLEAN (path_rows=38 bound=38 located=38 prose=120)` beside
  `SOURCES_CENSUS: FAILED (findings=1 rows=158)` with `SC_FETCH cr-in-tsv`
  (`receipts/c8-summary-clean.txt`). The verdict is FAILED, so no pass is reachable, but
  a consumer that reads only the `SOURCES_CAPTURES:` line would call the capture class
  clean while the file holds a CR. Unchanged from round 67's C8.

## 3. What this means for the claims

- **C1 freshness.** The mechanism the round claims is real and *measurably better than
  BASE* on every class the round names: six of the seven stray-byte/`~/`/`//` shapes
  (trailing, leading and interior space, comma-join, `//`, `~/`, plus the CR cell), the
  whole-file CRLF save (with `path_rows` no longer 0), the borrowed col-15 digest, and
  the mixed-prose cell all flip from `CLEAN` at BASE to `FAILED` with a frozen reason at
  the candidate; the seventh (eight spaces) is frozen-legal prose. The six frozen legs
  each produce their expected reason for the derived anchor `S167`; `caught=6/6` is
  reachable.
- **The number delta is Amendment A1's, confirmed independently.** Frozen `37/32` is
  the recut-only tree; the candidate with the round's own S167 row reads `38/33`
  (`receipts/indep-recut-only.txt` vs `receipts/indep-snap-690b.txt`). The kill rules
  are lower bounds (`verified < 37`, `col15 < 32`), so neither reading misses.
- **C2 calibration.** The gate's selftest is `PASS (98 cases)` (≥ 89), and the gate's
  clean line and my independent recount agree on 38/38/38/120. Four selftest cases were
  red at interim revisions (`capture-symlink-escape`, `capture-whitespace-cr`,
  `capture-token-slashslash`, plus an earlier `capture-normalized-mismatch`); all are
  green on `690b0c2e` and the reasons I measured for them are folded into §2 (the
  `//`-form reason, the CR-cell reason).
- **The silent-disengage class is not fully closed.** S1/S2 (a resolving alias that
  contains no literal `.ufo/waves/` token) and S3 (a cell that declares nothing) read
  `CLEAN` while a row that used to be read stops being read. Under the frozen sentence
  these are legal prose; under the round-67 lesson ("a stray byte must not disengage the
  binding") they are the same escape with a different instrument. The honest statement
  for the report and the entry is therefore "every cell that *names* a `.ufo/waves/`
  file is bound or refused; a cell that resolves to one while naming something else is
  prose by construction", not "the binding cannot be disengaged".
- **S4 narrows the population** to `.ufo/waves/` by design; any capture declared outside
  that directory is now prose. The plan's S099 sentence is the deliberate instance; the
  consequence for any future non-waves capture path is worth one line in the entry.
- **Over-capture** (§2.5) is the cost side: prose cells carrying `//`/`~/` tokens now
  fail. No current row trips it.

## 4. Dead ends measured (so the next round does not repeat them)

- The gate was a moving target for ~45 minutes (ten hashes observed, six exercised). Two
  interim revisions reported the `//` form as `capture-outside-root` and the CR cell as
  `cr-in-tsv` only (`1f91d36d`, `fd3cb598`); the executed revisions fixed both before
  `690b0c2e`. Every interim run is kept, none is reported as a class result. The final
  battery is pinned to `690b0c2e` and re-reads the gate hash in `SNAPSHOT.json` before
  it runs.
- An early battery selected the col-15 donor as the whole row rather than its digest
  field, writing the string `mined` into col 15; that produced a spurious
  `SC_FETCH normalized-digest` on both gates. Fixed in `fixtures/battery3.py`
  (`donor[14]`), and the corrected probe shows the honest BASE blindness for M5
  (`CLEAN 38/38/38`, no finding) and the candidate's single
  `normalized-digest-mismatch`.
- A mutation driver that opened `file + '.new'` with `"ab"` replaced a 35491-byte body
  with a 1-byte file; every `m6` SETUP in the interim runs is that bug, not the gate's.
  Fixed the same way (read, append, replace).
- An absolute-path probe on a prose row is not the S099 shape: the gate classifies any
  leading-slash cell as `path` and reports `capture-outside-root` on both gates. S099's
  actual relative cell (with `§` and prose) is the one that stays prose (row 5g).

## 5. Receipts

```
.ufo/waves/round-68/w1/R68Revenger.md                        this report
.ufo/waves/round-68/w1/R68Revenger/receipts/results-final-690b0c2e.tsv   92 runs: case, side, rc, verdict line, findings
.ufo/waves/round-68/w1/R68Revenger/receipts/results-final-690b0c2e.json  same, with the snapshot hashes and anchors
.ufo/waves/round-68/w1/R68Revenger/receipts/battery-log.txt             the battery's own stdout, verbatim
.ufo/waves/round-68/w1/R68Revenger/receipts/selftest-690b.txt           SOURCES_CENSUS_SELFTEST: PASS (98 cases)
.ufo/waves/round-68/w1/R68Revenger/receipts/indep-base.txt              36/36/36/120, col15=31 (own code)
.ufo/waves/round-68/w1/R68Revenger/receipts/indep-recut-only.txt        37/37/37/120, col15=32 (own code)
.ufo/waves/round-68/w1/R68Revenger/receipts/indep-snap-690b.txt         38/38/38/120, col15=33, no DIFF (own code)
.ufo/waves/round-68/w1/R68Revenger/receipts/snapshot-690b.json          the four input hashes of the tested tree
.ufo/waves/round-68/w1/R68Revenger/receipts/survivor-inputs.txt         exact escaped bytes of every survivor and over-capture
.ufo/waves/round-68/w1/R68Revenger/receipts/c8-summary-clean.txt        §2.6 C8: captures CLEAN beside census FAILED, measured
.ufo/waves/round-68/w1/R68Revenger/receipts/table.md                    the generated class table (raw)
.ufo/waves/round-68/w1/R68Revenger/fixtures/battery3.py                 the battery (mutation + two-gate run)
.ufo/waves/round-68/w1/R68Revenger/fixtures/snap.py                     the lean snapshot builder
.ufo/waves/round-68/w1/R68Revenger/fixtures/indep.py                    the independent recount
.ufo/waves/round-68/w1/R68Revenger/fixtures/run*.sh                     the fixture probes for the three interim selftest failures
```

Tooling: none installed or upgraded this seat (python3 3.13.7, bash 5.3.3, coreutils,
git 2.51 — all pre-existing).

Report: .ufo/waves/round-68/w1/R68Revenger.md
