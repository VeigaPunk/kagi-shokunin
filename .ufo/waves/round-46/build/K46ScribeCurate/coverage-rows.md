# Round 46 — coverage-map rows (DRAFT, prose only)

Addresses spotcheck §5 item 1 (`corpus/lessons/round-45-verifier-spotcheck.md:102`,
under the heading `:100`) for the two entries named there. No file under `corpus/`
is edited by this draft; the rows below are for the landing seat to insert.

## Table shape and insertion point

- Header and separator: `corpus/README.md:17-18`
  (`| Area | Entry | Source basis (read 2026-09-28) |` / `|---|---|---|`).
- Current last row: `corpus/README.md:98` (`| Round-35 lesson | ...`), blank
  `corpus/README.md:99`, next section `corpus/README.md:100`.
- **Insert both rows after `corpus/README.md:98`,** keeping the append order the
  round-33/34/35 entry rows use (`corpus/README.md:93-94`, `:96-98`).
- Existing rows alternate the entry cell between `corpus/knowledge/...` and
  `knowledge/...` (`corpus/README.md:93` vs `:96`); the rows below use the
  `corpus/`-prefixed form, matching `corpus/README.md:93` and the paths the
  assignment names.

## Row 1 — ISO/IEC 11770-3 edition status

```
| ISO/IEC 11770-3 edition status (entry, round 45) | `corpus/knowledge/iso-11770-3-edition-status.md` | the 2015 edition is withdrawn and the 2021 edition (edition 4.0) is the one in force; the 2017 amendment is withdrawn too (S100–S102; the ISO catalogue record needs a browser user agent, the default agent gets HTTP 403), all three sources opened 2026-11-05 |
```

## Row 2 — feed token extraction boundaries

```
| Feed token extraction boundaries and the extractor agreement gate (entry, round 29) | `corpus/knowledge/feed-token-boundaries.md` | an Atom `atom:title` is a Text construct, so a trailing period is content and not a token boundary; the extractors' right boundary is `STABLE_TOKEN_RE`'s lookahead and never a `$` anchor, and the extractors must agree with the canonicality judge (S045, S052; row-linked to `R29-01`/`R29-02`), sources opened 2026-10-31 |
```

## Claim-by-claim pointers for row 1

| claim in the row | pointer |
|---|---|
| entry exists, under the named path | `corpus/knowledge/iso-11770-3-edition-status.md:1` (`source:` line) |
| the round that added it is 45, C2 (coverage) | `corpus/knowledge/iso-11770-3-edition-status.md:4` (`ground: round 45 C2 (coverage) …`); commit `072bb0b`, `git log -- corpus/knowledge/iso-11770-3-edition-status.md`, dated 2026-11-05, subject `round-45: candidate …` |
| registry rows S100, S101, S102 | `corpus/SOURCES.md:107` (S100), `:108` (S101), `:109` (S102); each row's last column is `corpus/knowledge/iso-11770-3-edition-status.md` |
| 2015 edition withdrawn; 2021 edition in force (4.0) | `corpus/knowledge/iso-11770-3-edition-status.md:14-20` (withdrawal stage, `[S101]`), `:22-26` (2021 edition, edition 4.0, 2021-10-22, `[S102]`) |
| 2017 amendment withdrawn | `corpus/knowledge/iso-11770-3-edition-status.md:28-35` (`## The 2017 amendment is withdrawn too` and its paragraph) |
| browser user agent required, default agent 403 | `corpus/SOURCES.md:108` (`the default user agent receives HTTP 403`); `corpus/knowledge/iso-11770-3-edition-status.md:3` (the declared `recheck:` curl with the browser UA) |
| all three sources opened 2026-11-05 | `corpus/knowledge/iso-11770-3-edition-status.md:2` (`verified-at: 2026-11-05`); `corpus/SOURCES.md:107-109` (`mined | 2026-11-05`) |
| no coverage row existed before this draft | `grep -c 'iso-11770-3-edition-status' corpus/README.md` → `0` (measured 2026-11-06) |

## Claim-by-claim pointers for row 2

| claim in the row | pointer |
|---|---|
| entry exists, under the named path | `corpus/knowledge/feed-token-boundaries.md:1` (title), `:3` (`source:` line) |
| the round that added it is 29 | `corpus/knowledge/feed-token-boundaries.md:9` (`## The extraction contract (round 29 C1)`) and `:28` (`## The agreement invariant (round 29 C2)`); commit `fc65112`, `git log -- corpus/knowledge/feed-token-boundaries.md`, dated 2026-11-01, subject `round-29: C1 feed-token right boundary via frozen recipe (S052) + agreement-gate bookkeeping` |
| registry rows S045 and S052 | `corpus/SOURCES.md:52` (S045; last column `corpus/lessons/round-28.md, corpus/knowledge/feed-token-boundaries.md`), `:59` (S052; last column `corpus/knowledge/feed-token-boundaries.md`) |
| `atom:title` is a Text construct, trailing punctuation is content | `corpus/knowledge/feed-token-boundaries.md:11-16`; `corpus/SOURCES.md:59` (§4.2.14 quote) |
| right boundary is `STABLE_TOKEN_RE`'s lookahead, never a `$` anchor | `corpus/knowledge/feed-token-boundaries.md:16-17` |
| extractors must agree with the canonicality judge | `corpus/knowledge/feed-token-boundaries.md:28-32`; `corpus/SOURCES.md:52` (S045 item 2) |
| row-linked to `R29-01`/`R29-02` (a declaration, not an execution claim) | `corpus/knowledge/feed-token-boundaries.md:6` (`Reverify: R29-01, R29-02`) |
| sources opened 2026-10-31 | `corpus/knowledge/feed-token-boundaries.md:4` (`verified-at: 2026-10-31`); `corpus/SOURCES.md:59` (`mined | 2026-10-31`) |
| no coverage row existed before this draft | `grep -c 'feed-token-boundaries' corpus/README.md` → `0` (measured 2026-11-06) |

## Landing cautions (not part of the drafts)

- The two rows change no pinned count: no `corpus/self-counts.tsv` row matches a
  coverage-map row (`corpus/self-counts.tsv:47-57` bind the `Surface declaration`,
  `Runtime shape pins`, `Ownership + breadth`, `Claim ledger`, `Ledger rows`,
  `Revision stamps`, `Knowledge-entry declarations`, `op.env` probe and checklist
  rows). Line `corpus/README.md:67` (`32 row-linked / 3 by-hand / 35 pinned`) is
  round-33 context and is not touched by these insertions.
- No gate consumes the coverage map by row count: `corpus/claims-declared.sh`
  reads `corpus/claims-declared.tsv` against `plans/round-*.md` headings only
  (grep for `README` in that script: no match).
- `corpus/README.md` **is** a stamped row (`corpus/stamps.tsv:96`,
  `833d4b39…`, 252 lines, 34462 bytes). Inserting the two rows makes that row
  stale; the landing seat must re-pin it with a reviewed
  `corpus/claim-ledger.sh stamp corpus/README.md` run (the row-set replacement
  guard described at `corpus/README.md:63` applies — pass every path the row set
  should keep, or `--prune` deliberately), and record the old/new values as the
  round-45 lesson's E45-1 requires (`corpus/lessons/round-45.md:40`).
- Out-of-scope but adjacent: `corpus/knowledge/iso-11770-3-edition-status.md`
  carries no `Reverify:` line (`grep -c '^Reverify:'` → 0) and is not a
  `corpus/stamps.tsv` row (35 `corpus/knowledge/` rows for 36 entries;
  `grep -c 'iso-11770' corpus/stamps.tsv` → 0, also at `072bb0b`). Row 1 above
  does not claim otherwise. See the seat report for the static reading of
  `corpus/claim-ledger.sh docs` and ledger row `R14-01`.
