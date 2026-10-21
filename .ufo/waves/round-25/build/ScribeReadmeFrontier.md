# ScribeReadmeFrontier — round-25 README draft (C1 / C2 / C3)

Scope: draft only. `corpus/README.md` NOT edited (lane file, read-only for this seat).
Base read: `4587c61a348e4528717404a68912c373f3ef4d03` (README 166 lines; `## Frontier` at :106, bullets :110-112, blank :113).
Commands run (read-only): `grep -c on-release corpus/SOURCES.md` → 28; `grep -c 'recheck: on-release' corpus/SOURCES.md` → 0; `grep -o 'S0[0-9][0-9]' corpus/SOURCES.md | sort -u | tail` → max S032; `ls corpus/self-counts.* corpus/release-clock*` → all absent; `sed -n 46p SKILL.md` → "63 stamps + 39 claims + claim ids, round 21" (D1 still present); `ls .ufo/waves/round-25/tools/` → empty. No gate run, no tool installed.

## Findings

1. Plan wording `recheck: on-release` is not a literal in SOURCES.md; the cell value is `on-release`. `grep -c on-release` = 28 matches the plan. Draft carries no hard-coded 28 (README numbers would be unbound prose).
2. S033+ do not exist yet (max S032). Draft cites no S033+ row as present.
3. Not yet on disk: `corpus/self-counts.py`, `corpus/self-counts.tsv`, `corpus/release-clock.py`, `corpus/release-clocks.tsv`, `lessons/round-25.md`, `.ufo/waves/round-25/tools/c1-measure.sh`, `c3-measure.py`. Draft is paste-after-land. Output strings below are the plan's contract strings; if implementation differs, update the draft to match the gate's real output before pasting.
4. Existing README :165-166 says the coverage map and frontier are "intentionally unchanged". Round 25 changes both, so that sentence goes stale → edit C below.
5. C2 touches a 768+ char existing row (:63). Draft adds a new row instead of rewriting it (format-preserving, no re-stamp of the old row).

## Insertion A — Coverage map (3 rows)

Insert after README line 86 (`| Round-21 lesson | ...`), before the blank line 87. Table is 3 columns; no `|` inside cells.

```
| Self-count binding gate (C1) | `corpus/self-counts.py` + `corpus/self-counts.tsv` | current-tense numeric self-descriptions in committed docs, each bound to one live source (`rows:<path>` or `ledger:<ID>`); per-claim `OK`/`STALE`/`UNLOCATED`/`AMBIGUOUS`; verdict `SELF_COUNTS: CLEAN` or `STALE` (exit 0/1, POLICY/SETUP exit 2); `--selftest`, `--root DIR`; explicitly round-dated historical numbers are out of population by rule |
| Release-clock binding gate (C3) | `corpus/release-clock.py` + `corpus/release-clocks.tsv` | every `on-release` row in `corpus/SOURCES.md` bound to one clock: `feed` (an official release feed opened as its own SOURCES row, plus the version its anchor names) or `rendered-quote` (unversioned live docs; quote re-located under `rendered-text-v1`); offline `RELEASE_CLOCK: CLEAN` verdict; `--observe` writes dated receipts; fired rows are re-verified and recorded, not re-pinned |
| Lone-clone citation layout (C2) | `corpus/claim-ledger.sh` (`citations`, `verify`) + `[fleet]` tag on ledger row `R11-08` | lone clone is detected and printed as `CITATION_LAYOUT: lone-clone`; unresolved `ufo`/`sibling` cites count as `FLEET-ABSENT` (`fleet_absent=N`), never `unresolved`, and the gate ends `CITATION_GATE: INCOMPLETE` (exit 1), never CLEAN; `[fleet]` rows print `LAYOUT-SKIP` and count `layout_skipped=N`, never passing; lane-local misses stay `UNRESOLVED` |
```

Optional, only if `lessons/round-25.md` exists at paste time (not in the paste set now):

```
| Round-25 lesson | `lessons/round-25.md` | current-tense self-count drift (SKILL.md:46), lone-clone layout made explicit, release clocks bound and observed |
```

## Insertion B — Frontier (1 bullet)

Insert after README line 112 (the NIST bullet), before the blank line 113 and `## Known gaps`.

```
- **On-release recheck clocks** — every registry row whose `recheck` is `on-release` must name a release identity the clock can observe; `corpus/release-clocks.tsv` binds each row to an official release feed (opened as its own SOURCES row) or to a rendered-quote check, and `corpus/release-clock.py` verifies the bindings offline. Open: which feeds publish the version an anchor names, and whether unversioned live docs keep the quoted sentence under `rendered-text-v1`; see `SOURCES.md` (feed rows opened in round 25).
```

## Insertion C — Replace stale sentence (README :165-166)

Replace the final sentence of the round-24 section. Old text (`... append links the executable counters. The knowledge coverage map and the` / `OIDC/scanning/NIST frontier list above are intentionally unchanged.`) becomes:

```
append links the executable counters. As of round 24 the knowledge coverage
map and the OIDC/scanning/NIST frontier list were unchanged; round 25 changes
both (see `## Round-25 active contracts`).
```

## Insertion D — New section (append at end of file, after :166)

Leave one blank line, then paste:

```
## Round-25 active contracts

Three round-25 contracts are indexed above: the self-count binding gate
(`corpus/self-counts.py`), the lone-clone citation layout in
`corpus/claim-ledger.sh`, and the release-clock binding gate
(`corpus/release-clock.py`). Current-tense numbers in committed docs are
bound to the live value they describe; a stated count goes red when its source
moves. Explicitly round-dated historical numbers are outside that population.

A lone clone (no fleet siblings, no `.ufo` tree) is an explicit, counted
outcome: `citations` reports `CITATION_LAYOUT: lone-clone` and ends INCOMPLETE,
and `[fleet]` ledger rows print `LAYOUT-SKIP`. Neither is a pass. The fleet
layout is unchanged.

`corpus/release-clock.py --observe` records a dated receipt per bound clock;
a fired row is re-verified and recorded, not silently re-pinned. The
round-25 feed rows in `corpus/SOURCES.md` (S033 onward) are the release
identities the `feed` clocks cite.
```

## Paste checklist (for main agent, after C1/C2/C3 land)

- A: after :86; B: after :112; C: replace :165-166 final sentence; D: EOF. Apply bottom-up (D, C, B, A) so line numbers stay valid.
- Verify each cited filename exists and each output string appears in the gate's real output (`--selftest` or a fixture run) before paste.
- Run `bash corpus/claim-ledger.sh verify` after paste: a README edit adds no stamped file, but confirm no `STALE` appears on `corpus/README.md` if it is stamped.
- UNRUN by this seat: all gate runs, `claim-ledger.sh` verify, and `c1-measure.sh`/`c3-measure.py`.
