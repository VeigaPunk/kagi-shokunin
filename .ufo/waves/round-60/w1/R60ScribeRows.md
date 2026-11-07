# R60ScribeRows — S123/S124 registry rows, fetch rows, round-60 Gate block

Seat: scribe, leaf member (no subagent dispatch). Lane `kagi-shokunin`, branch `master`, claim BASE
`a677c78ece8e3d3b4a43dda55254f2a7b33cc1d2`. No lane file was edited, no git/jj command was run.
All work is under `.ufo/waves/round-60/build/R60ScribeRows/`; scratch was
`/fast/scratch/hyaku/kagi-r60/R60ScribeRows/` (deleted before yield).

## Behavior

Read `plans/round-60.md` (frozen) and `corpus/lessons/round-59-verifier-spotcheck.md` first, then
`CORPUS.md` § SOURCES.md contract v1 and the S121/S122 rows as the shape model. The two captures
landed from the scout seat at `.ufo/waves/round-60/capture/S123.body` and `S124.body`; every number
in the three deliverables is derived from those bytes, not from the plan text:

- `sha256sum` → S123 `d16f639a0b0fff901707f56ad1b916f70665e7e0675197a6a40d6473e50c0187`,
  S124 `e663c1d0f956edea896db404bba7e92c7f248f74e98857a717ab063a7aae7207`.
- `wc -c` → 78543 B and 145203 B decoded body (the scout's `curl %{size_download}` 12566/14329 is
  the gzip transfer size and is deliberately not recorded as the byte count).
- `python3 corpus/rendered-text-v1.py digest` → normalized sha256 `4230771520…3b687a` (S123,
  normalized_bytes 12089) and `966641e895fb…3f65935` (S124, normalized_bytes 21214).
- `python3 corpus/rendered-text-v1.py locate` → all ten quotes `count=1`
  (`locate-receipt.txt`).

Row identity hashes are sha256 of `id<TAB>status<TAB>url<LF>`; the formula was validated by
reproducing S121's committed `812a0761cef7…` exactly before computing
`3a1a3af98cefd7973574d696fd71cd8a0e17ecb022858210c61ec03bd9f117ac` (S123) and
`f6050784fa222ce66850b0b666a53b1d4109350b4b06b0c6addda1fdbba385b4` (S124).

## Gates (acceptance)

| check | command | result |
|---|---|---|
| registry cell count | `awk -F'\|' '{print NR": NF="NF}' registry-rows.md` | 13, 13 → 11 cells each |
| fetch field count | `awk -F'\t' '{print NR": NF="NF}' fetch-rows.tsv` | 16, 16 = S121's field count |
| enums | awk over cells 4/5/9/10 | `kind=docs tier=A status=mined opened=2026-11-07` both |
| quote shape | `awk -F'\t' '{print $1, split($13,a," ")}'` | 12 and 17 words (≤25) |
| id reuse | `grep -c '\| S123 \|' corpus/SOURCES.md` (and S124) | 0, 0 |
| census on an appended copy | frozen six awk checks from `CORPUS.md` | 124 rows, 0 malformed, no dup id, no enum/tier-inflation violation, all 124 fetch rows 16 fields |
| capture identity | `sha256sum`/`wc -c` on the canonical capture paths | matches the rows |

The census copy was a scratch copy of `corpus/SOURCES.md` + `corpus/source-fetches.tsv` with the
two rows appended; its missing-`used-by` check reports
`corpus/knowledge/openbao-approle-secret-id-custody.md` (and every pre-existing entry, because the
scratch copy has no `corpus/knowledge/`), which is why the Gate states the entry lands with or
before the rows.

## Touched surfaces

- `.ufo/waves/round-60/build/R60ScribeRows/registry-rows.md` — two 11-cell rows (S123, S124).
- `.ufo/waves/round-60/build/R60ScribeRows/fetch-rows.tsv` — two 16-field rows.
- `.ufo/waves/round-60/build/R60ScribeRows/gate.md` — the lesson's `## Gate` block.
- `.ufo/waves/round-60/build/R60ScribeRows/locate-receipt.txt` — capture digests, renderer digests,
  ten `locate` lines.
- `.ufo/waves/round-60/w1/R60ScribeRows.md` — this report.

Not touched: `corpus/SOURCES.md`, `corpus/source-fetches.tsv`, any lesson, any knowledge entry, the
lane index, the fleet repo.

## Findings

1. **The assignment's second rejection slot has no page.** The scout opened exactly two pages
   (S123, S124) and neither anchors zero tested mechanics, so “any page the scout found that anchors
   no tested mechanic” is vacuous this round. The Gate records two real rejections instead — the
   concepts page as the T4 accessor anchor (0 occurrences of `secret-id-accessor` in the captured
   body) and both pages as the refused-login-shape anchor (S123's only `permission denied` is the
   user-lockout paragraph; S124 has 0 `permission denied` and 0 `error`) — and states the vacuous
   slot explicitly rather than inventing a page. The L1 may want the lesson to name the slot as
   empty.
2. **Column 16 of `source-fetches.tsv` is used as the capture path, not the header's “location”.**
   S117–S122 all end with `.ufo/waves/<round>/capture/S<id>.body`; the file header declares the
   column “section/heading the quote was located under”. I matched the rows (the assignment named
   them as the schema) and put the section names in the Gate, not in the row. This is a pre-existing
   header/row mismatch, not introduced here.
3. **`request_profile` is the lane's `curl-fsSL-compressed-v1` token although the fetch used a
   desktop browser UA**, exactly as S121/S122 did (their anchors also say “desktop browser user
   agent”). The census hard-requires that token (`corpus/sources-census.sh:286`). The exact UA is
   recorded in the Gate: `Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko)
   Chrome/126.0 Safari/537.36`. If the lane wants the UA in the TSV, that is a schema change, not a
   row change.
4. **Sequencing:** the rows are `mined` with `used-by=corpus/knowledge/openbao-approle-secret-id-custody.md`,
   which the entry scribe drafts this wave. If the rows land first, the census missing-`used-by`
   check flags that path. Land the entry with or before the rows.
5. **Secret hygiene:** neither captured response carried `Set-Cookie`/`Cookie` (the scout's
   `grep -in cookie` over both raw header files = 0 matches, reconfirmed against the canonical
   bodies' header files); no token, `secret_id` value, `hvs.`/`hvb.` string or request body appears
   in any deliverable. The page's example UUIDs were not copied into any row or quote.

## Out of scope / not done

- No edit to `corpus/SOURCES.md`, `corpus/source-fetches.tsv`, any lesson, any knowledge entry.
- No trial design, no counter work, no commit/push, no git/jj mutation anywhere.
- No tool install or upgrade was needed (no pacman, uv, npx or binary install).

## Artifact paths

- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-60/build/R60ScribeRows/registry-rows.md`
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-60/build/R60ScribeRows/fetch-rows.tsv`
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-60/build/R60ScribeRows/gate.md`
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-60/build/R60ScribeRows/locate-receipt.txt`
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-60/w1/R60ScribeRows.md`

SEAT-STATUS: complete
