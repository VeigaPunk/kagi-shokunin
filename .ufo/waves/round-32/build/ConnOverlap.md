# ConnOverlap — round-32 sibling-overlap scan (read-only)

Seat: connector 1/1, wave `kagi-r32-build`, round 32. Lane `kagi-shokunin` at BASE
`32c35fe5ed44f2017d6a662c7fd13f7e63a7ce9b`; frozen claims contract `plans/round-32.md`
(commit 507dd9f), read first. No lane file, sibling file, or sibling gate was written or
executed; every path below is absolute and every command was a `grep`/`sed` read.

Scope: every `/home/vgpnk/Projects/shokunin/*-shokunin` except `kagi-shokunin` — 20 lanes.
`corpus/` exists in all 20; **`knowledge/` exists in none** (0/20), so command (b) recursed
over `corpus/` only and its `knowledge/` arm is empty by layout, not by measurement.

Counting command for `kagi` itself: none. This seat does not run another lane's gates and does
not run `corpus/self-description-sweep.sh` or `corpus/op-ref-probe.sh` (C1/C2 owners do).

## Measurement (receipts: `ConnOverlap-receipts.txt`, same directory)

Commands, all from `/home/vgpnk/Projects/shokunin`, all `exit=0` where noted:

| id | command | exit |
|---|---|---|
| A | `for f in PROVINCE.md README.md SKILL.md; do grep -l -iE 'moved to core\|explored, not held' <lane>/$f; done` | 0 (0 matches → `grep -l` exit 1 per file, expected) |
| A-count | `grep -c -iE 'moved to core\|explored, not held' <lane>/{PROVINCE,README,SKILL}.md` summed | 0 for the loop; `grep -c` exits 1 on a 0 count, which is the field `0` |
| B | `grep -rIn --exclude-dir=.git -E 'op (CLI )?2\.[0-9]+\.[0-9]+\|1password.*2\.[0-9]' <lane>/corpus <lane>/knowledge` (piped to `wc -l`) | 0 |
| C | `grep -rIn --exclude-dir=.git -iE 'citation[- ]gate\|citations? gate\|claim-ledger\.sh[[:space:]]+citations\|\bgate:?[[:space:]]*citations\b' <lane>/corpus` | 0 |
| C-files | same pattern, `grep -rIl` (file count) | 0 |

### Per-lane counts

`a` = tombstone-phrase lines in PROVINCE/README/SKILL; `b` = op/1Password version-pin lines in
corpus; `c` = citation-gate-name lines in corpus (files in parentheses).

| lane | a | b | c |
|---|---|---|---|
| audio-shokunin | 0 | 0 | 0 |
| chousa-shokunin | 0 | 0 | 0 |
| game-dev-2d-shokunin | 0 | 0 | 0 |
| game-dev-3d-shokunin | **1** | 0 | 0 |
| kaidoku-shokunin | 0 | **12** | 0 |
| kake-shokunin | 0 | 0 | **5** (4) |
| kama-shokunin | 0 | 0 | **1** (1) |
| kasegi-shokunin | 0 | 0 | 0 |
| kengaku-shokunin | 0 | 0 | **2** (1) |
| kotoba-shokunin | **3** | 0 | 0 |
| kotodama-shokunin | 0 | 0 | 0 |
| kumitate-shokunin | 0 | 0 | **7** (6) |
| lore-shokunin | 0 | 0 | 0 |
| mado-shokunin | 0 | 0 | 0 |
| mori-shokunin | 0 | 0 | 0 |
| revenger-shokunin | 0 | 0 | 0 |
| souji-shokunin | 0 | 0 | 0 |
| tabi-shokunin | 0 | 0 | **1** (1) |
| tameshi-shokunin | 0 | 0 | 0 |
| tsukuroi-shokunin | 0 | **14** | **3** (3) |
| **totals** | **4 lines / 2 files / 2 lanes** | **26 lines / 3 lanes** | **19 lines / 16 files / 6 lanes** |

11 of 20 lanes are zero on all three commands: audio, chousa, game-dev-2d, kasegi, kotodama,
lore, mado, mori, revenger, souji, tameshi.

## (a) Tombstone phrases — 4 lines, classification: adjacent

| lane / path:line | short quote | class |
|---|---|---|
| `game-dev-3d-shokunin/PROVINCE.md:63` | "CharacterBody3D floor-angle boundary — moved to core in r108 …; still frontier: other limits, the ceiling predicate" | **adjacent** |
| `kotoba-shokunin/PROVINCE.md:39` | "Explored, not held — the live list is `corpus/README.md` § Frontier:" | **adjacent** |
| `kotoba-shokunin/PROVINCE.md:41` | "MCP server `instructions` per client moved to Core; plugin surfaces … stay here" (three `moved to Core` clauses on the line) | **adjacent** |
| `kotoba-shokunin/PROVINCE.md:42` | "**Round 47:** the XML-token half moved to Core; the round-46 figures above are historical" | **adjacent** |

Why adjacent and not overlap: all four lines qualify the tombstone with the surviving residual
("still frontier: …", "stay here", "historical"), and none is inside kagi's measured files.
kagi's SD1 is theme-scoped to `PROVINCE.md` Core-vs-Frontier for `OIDC workload-federation` /
`secret[- ]scanning`; SD2 is line-scoped to `corpus/README.md` under `## Frontier`. Neither
counter touches a sibling repo, and neither sibling line can enter either count.

Second-order note for the reviewers: a *phrase-level* fleet sweep would report 4 hits here, of
which 4 are qualified residuals, not stale tombstones. That is direct evidence that the frozen
line-scoped predicates (SD1 theme-name, SD2 `corpus/README.md` `## Frontier`) are the right
unit; a phrase sweep would produce false reds. Recorded, not proposed as a change.

## (b) op / 1Password version pins — 26 lines, classification: adjacent, with one live cross-check

Matched lines of substance (the rest are product/BETA strings or history rows):

| lane / path:line | short quote | class |
|---|---|---|
| `kaidoku-shokunin/corpus/knowledge/2026-10-20-r17-go-carrier-diagnostics.md:74` | "\| pro-op \| `/usr/bin/op` (1password-cli 2.41.0-1) \| `f4ac474f…` \| `go1.26.8` \|" | **adjacent** — Go-carrier diagnostic; pins a binary for `go version -m`, not a byte/behaviour contract |
| `kaidoku-shokunin/corpus/knowledge/2026-10-13-r4-10-real-version-pair.md:3,19` | "1password-cli `op` 2.34.1 → 2.40.0 … 41,210,040 → 43,475,106" | **adjacent** — cross-version binary compare of a historical pair |
| `kaidoku-shokunin/corpus/knowledge/2026-10-13-r2-version-diff-compare.md:16`, `2026-10-13-pacman-packages.md:57`, `2026-10-20-r14-go-version-diagnosis.md:10`, `corpus/README.md:179`, `corpus/evidence/round-44/controls/pos/tree/**` | same 2.34.1/2.40.0 family | **adjacent** — same unit as above; the `evidence/round-44/controls/pos/tree/` copies are fixture trees, not claims |
| `kaidoku-shokunin/corpus/knowledge/2026-10-13-r4-06-1password-asar.md:276,288` | "`@1password/oph@8.12.42-32.BETA`" / "`/opt/1Password/1password --version`" | **none** — desktop app, not the CLI |
| `tsukuroi-shokunin/corpus/knowledge/adjacency-handoffs-fleet-r1.md:130` | "`/usr/bin/op is owned by 1password-cli 2.40.0-2` (exit 0)" | **adjacent** — pacman ownership check |
| `tsukuroi-shokunin/corpus/knowledge/degraded-triage-r4.md:113` | "`/var/lib/pacman/local/1password-cli-2.40.0-2/install`" | **adjacent** — package-dir path |
| `tsukuroi-shokunin/corpus/knowledge/**` ×12 (`update-safety-note.md:29,280,544`, `update-safety-v2.md:58,80,118`, `update-safety-v3.md:178`, `census-closeout-receipt-r10.md:60`, `closeout-r11.md:55`, `pause-lift-gate-r24.json:15`, `degraded-triage-r4.md:663`, `host-health-report-r3.md:667`) | "`1password-beta 8.12.42_32.BETA-1`" | **none** — pattern false positives: the desktop-app version string contains `2.4`/`2.B`; not the CLI |

No lane names op **2.41.1**. The highest CLI version pinned anywhere in a sibling corpus is
`2.41.0-1` (kaidoku), i.e. one release behind the `2.41.1` that `plans/round-32.md` records from
`op --version`. No sibling owns a byte/behaviour contract for `op`; the fleet-level
`op-ref-probe`/`--dotenv-bytes` references outside `kagi-shokunin` are all `.ufo/` reports and
connector/reviewer artifacts **about** kagi (e.g.
`kumitate-shokunin/.ufo/waves/round-59/build/ConnectorSiblings/kagi.grep.objects.txt`,
`tameshi-shokunin/.ufo/evidence/round-17/coldread/traces/CR06/04-kagi-op-ref-probe-selftest.json`),
not competing claims.

Live cross-check worth one sentence in C2's receipt (see "Proposed move"): tsukuroi's
update-safety plane already recorded the transition this round measures —
`tsukuroi-shokunin/.ufo/waves/round-24/w2/RevP1Pending.md:24`:
`| 1password-cli (not in local -Qu) | 2.41.0-1 | none | 2.41.1-1 | omarchy | :2 |`.
That is a sibling **artifact** (wave output, not `corpus/`), dated round 24 — context only.

## (c) Citation-gate names — 19 lines / 16 files, classification: adjacent (label collision, disjoint namespace)

| lane | lines (files) | sample | class |
|---|---|---|---|
| kumitate-shokunin | 7 (6) | `corpus/lessons/round-6-aggregator-audit.md:112` "the lane's citation gate goes red on aggregator-owned lessons" | **adjacent** |
| kake-shokunin | 5 (4) | `corpus/SOURCES.md:194` "run the lane citation gate" | **adjacent** |
| tsukuroi-shokunin | 3 (3) | `corpus/lessons/round-62.md:78` "a path-citation gate cannot see it" | **adjacent** |
| kengaku-shokunin | 2 (1) | `corpus/evidence/round10-fleet/r10-connector.md:58` "`scripts/cite-check.mjs` validates source citations … but different province" | **adjacent** |
| kama-shokunin | 1 (1) | `corpus/lessons/round-19.md:75` "a 'machine-checkable' citation gate that accepts the token in any default doc" | **adjacent** |
| tabi-shokunin | 1 (1) | `corpus/lessons/round-43.md:55` | **adjacent** |

Ownership of the *gate scripts* (checked separately, `find <lane>/scripts -iname '*cite*' -o -iname '*ledger*'`):
`kake/scripts/citation_lint.py`, `kake/scripts/ledger_latest_check.py`,
`kumitate/scripts/cite-check.mjs`, `kumitate/scripts/cite-sources.mjs`,
`kumitate/scripts/routed-ledger.mjs`, `tabi/scripts/check-cited-receipts.mjs`,
`tabi/scripts/check-cited-receipts-v2.mjs`. No sibling contains `claim-ledger.sh`; only three
lanes (kake, kumitate, tabi) track any `scripts/` directory at all.

Label collision, recorded explicitly: kumitate's `scripts/cite-check.mjs`, `scripts/claims-check.mjs`,
`scripts/round-gate.mjs`, `scripts/make-dispatch-actual.mjs` and tabi's
`scripts/check-release-pins.mjs` **emit the token `UNRESOLVED`** (grep over `<lane>/scripts`).
So the word is not unique to kagi's `claim-ledger.sh citations` emission. SD6 counts only the
lines printed by `bash corpus/claim-ledger.sh citations` in this lane, so the namespaces cannot
mix; but any future fleet-wide `grep UNRESOLVED` reading would double-count kumitate's and
tabi's emissions. Adjacent, not overlap.

## Verdict (one line)

**No sibling claims either ground**: no lane pins the 1Password CLI byte contract or op 2.41.1
(highest sibling pin is `2.41.0-1`, as an unrelated Go-carrier/ownership observation), and no
lane sweeps Frontier-vs-Core themes or README tombstones — tabi's two gates read
`SCORECARD.md`/`LOG.md`/`corpus/README.md` and knowledge-entry `frontier:` headers, with zero
`PROVINCE` references (`grep -c PROVINCE` = 0 in both), so SD1/SD2 and the new
`self-description-sweep.sh` stand alone.

## Proposed move (one, bounded)

Affected axes: freshness (C2) only. Calibration untouched; no predicate, counter, kill rule,
target or SOURCES row changes.

Add **one sentence** to C2's new `### 11.1` (or to the C2 receipt, whichever the scribe owns):
that the 2.41.1 reading is corroborated outside the lane by tsukuroi's update-safety record of
`1password-cli` installed `2.41.0-1` with `2.41.1-1` as the omarchy candidate
(`tsukuroi-shokunin/.ufo/waves/round-24/w2/RevP1Pending.md:24`, round-24 artifact), so
`op --version` → 2.41.1 is a released-version observation rather than a local misread.

Why it is non-obvious and cheap: the §11 byte contract has only ever been self-witnessed by
this lane's own probe; the sibling row is an independent, already-committed witness of the same
version transition, and it costs one line to cite.

Risks: (i) the row is a **wave artifact, not a `corpus/` surface** — cite it as a sibling artifact
path and label it context, never as byte evidence; (ii) it is dated round 24, so it must not be
written as "installed today"; (iii) it must not be added to `corpus/SOURCES.md` — S072 stays the
single sourced row for C2, or the census count moves off 72. If (i)–(iii) cannot be honoured,
drop the sentence: C2 does not need it to pass.

## Files written (absolute)

- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-32/build/ConnOverlap.md`
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-32/build/ConnOverlap-receipts.txt`

Scratch `/fast/scratch/hyaku/kagi-r32/ConnOverlap/` created via `mkdir -p` and removed at exit;
no fixtures, no clones, no git or jj command at all, no `TMPDIR` writes needed (grep-only seat),
nothing to copy back. Tooling: none installed or upgraded.
