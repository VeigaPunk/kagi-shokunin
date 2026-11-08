# R68ExecRecut — S166 col-16 recut

Seat: R68ExecRecut (executor). Lane `kagi-shokunin`, branch master. Sole writer of the S166 cells of `corpus/source-fetches.tsv` and `corpus/SOURCES.md`; no other cell, row, or file touched.

## What changed

`corpus/source-fetches.tsv` S166 col 16 (from `§1.2 Concept Overview; capture .ufo/waves/round-67/capture/S166.body` to `.ufo/waves/round-67/capture/S166.body`) — the pure capture path with no other bytes in the cell, all 16 fields kept, every other column byte-identical.

`corpus/SOURCES.md` S166 anchor (col 6): the section pointer `§1.2 Concept Overview` stays (moved from the TSV cell into registry prose), the anchor now names the pure capture path explicitly as the row's col-16 value, keeping byte count, sha256, quote count, and fetch receipt pointer. Id, tier, status, opened, recheck untouched; no new column.

## Old → new strings (verbatim, for the round lesson)

- TSV col16 OLD: `§1.2 Concept Overview; capture .ufo/waves/round-67/capture/S166.body`
- TSV col16 NEW: `.ufo/waves/round-67/capture/S166.body`
- SOURCES anchor OLD: ` §1.2 Concept Overview; capture \`.ufo/waves/round-67/capture/S166.body\` (67152 B, sha256 \`544dbb7d9afceafa8c9931d9924ca6cff2b4807274166d7ed2483342ef2cdd6a\`); opened live 2026-11-08 with a browser user agent (HTTP 200, 67152 B, same sha256; receipt \`.ufo/waves/round-67/capture/S166.fetch.txt\`, refetch byte-identical; quote locate count=1 under rendered-text-v1) `
- SOURCES anchor NEW: ` §1.2 Concept Overview; capture \`.ufo/waves/round-67/capture/S166.body\` — row col 16 recut to this pure path (67152 B, sha256 \`544dbb7d9afceafa8c9931d9924ca6cff2b4807274166d7ed2483342ef2cdd6a\`); opened live 2026-11-08 with a browser user agent (HTTP 200, 67152 B, same sha256; receipt \`.ufo/waves/round-67/capture/S166.fetch.txt\`, refetch byte-identical; quote locate count=1 under rendered-text-v1) `

## Eligibility proof (no gate verdict claimed)

- `awk -F'\t' '$1=="S166"' corpus/source-fetches.tsv | cat -A` → `S166^Imined^I8b120c456013d67fa77b40f71c506927e21b823adef69b6d29deb521e2f8eb2b^Ihttps://www.rfc-editor.org/rfc/rfc9530.txt^Ihttps://www.rfc-editor.org/rfc/rfc9530.txt^I200^Icurl-fsSL-compressed-v1^I2026-11-08^Idecoded-http-body-v1^I544dbb7d9afceafa8c9931d9924ca6cff2b4807274166d7ed2483342ef2cdd6a^I67152^I-^IReceivers can validate the digest for integrity purposes.^Irendered-text-v1^I652d311657f00e1eab513b15db807d773b42294d7032e179f63d04909943436b^I.ufo/waves/round-67/capture/S166.body$` (no trailing space/tab/CR; receipt `R68ExecRecut/cat-A-s166.txt`).
- sha256sum body: `544dbb7d9afceafa8c9931d9924ca6cff2b4807274166d7ed2483342ef2cdd6a` = col10; wc -c: `67152` = col11.
- `python3 corpus/rendered-text-v1.py locate .ufo/waves/round-67/capture/S166.body "Receivers can validate the digest for integrity purposes."` → `RENDERED_TEXT_V1_LOCATE: count=1` (col13 locates, count>=1).
- `python3 corpus/rendered-text-v1.py digest .ufo/waves/round-67/capture/S166.body` → `normalized_sha256=652d311657f00e1eab513b15db807d773b42294d7032e179f63d04909943436b` = col15 (ready for C1 col15 recompute).
- 16-field check: `NF=16`.
- Path resolves in-lane: realpath `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-67/capture/S166.body`, `-f` yes. No CR in TSV (`grep -c $'\r'` = 0).
- File hashes after: `corpus/source-fetches.tsv 682ef5455cabe79955e424ae67b8a977badd392945f9762a121ef97b4d494fd6`, `corpus/SOURCES.md 88990e062827f772b293a1ecfb17bc6a03a935c70feaa71b8e86757a12f902a0`, body `544dbb7d9afceafa8c9931d9924ca6cff2b4807274166d7ed2483342ef2cdd6a` (unchanged).
- Diff limited to S166 lines (2 files, 2 lines): receipt `R68ExecRecut/diff-s166.txt`; `git diff --stat` = `corpus/SOURCES.md | 2 +-`, `corpus/source-fetches.tsv | 2 +-`.

The census gate verdict was deliberately not run as proof (R68ExecGate's widened check had not landed); eligibility is proven by the above: pure path resolves, col10/11 match bytes, col13 locates, col15 recomputes.

## Tooling

No tool installed. Read `/home/vgpnk/.omp/agent/RULES.md` (operator rule, 2026-10-19). Used system `python3` (3.14.8, `/usr/bin/python3`) stdlib only for byte-level replacement and locate/digest; no package installation needed. pacman paused, not run.

## Risks

- The SOURCES anchor parenthetical "— row col 16 recut to this pure path" is new wording but preserves the contract-required evidence (byte count, sha256, quote count, receipt, section pointer); no gate parses anchor prose beyond row shape.
- S166 remains anchor for C1's six mutation legs (`S166` at candidate per `plans/round-68.md`); this seat did not run the counter.

Report: .ufo/waves/round-68/w1/R68ExecRecut.md
Receipts: .ufo/waves/round-68/w1/R68ExecRecut/ (diff-s166.txt, cat-A-s166.txt, sha256.txt, locate.txt)
