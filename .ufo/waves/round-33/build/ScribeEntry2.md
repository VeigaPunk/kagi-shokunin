# ScribeEntry2 — knowledge entry draft: `nist-key-management-parts-withdrawal.md`

- Wave: `kagi-r33-build` (round 33, v1 wave, 13 seats), leaf seat, no sub-spawns.
- Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`, frozen BASE `76f4eeae7aa9af4dbb9423f5632b55791824253a`.
- Claims contract read at lane HEAD: `plans/round-33.md` §C2 (frozen predicate `NIST_CORE: CLEAN`; no predicate or counter touched by this seat).
- Deliverable written (draft only — no lane file touched):
  `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-33/build/knowledge/nist-key-management-parts-withdrawal.md`

## Behavior

1. Read the staged entry `/home/vgpnk/Projects/shokuknow/merge/kagi/knowledge/corpus/knowledge/nist-key-management-parts-withdrawal.md` (read-only), the id map `.ufo/waves/round-33/assimilation/id-map.txt`, the plan §C2 and §Frontier step, and the lane entry shape (`corpus/knowledge/sops-age-key-rotation.md`, `oidc-federation-trust-policy.md`, plus the census/claim-ledger parsers `corpus/sources-census.sh` and `corpus/claim-ledger.sh`).
2. Re-opened the seven adopted URLs myself on 2026-11-04 (`curl -fsSL --compressed`, GET only) into scratch, and independently computed both the raw body sha256 and the `rendered-text-v1` digest; then re-located every quoted string in the normalized text (count=1 each).
3. Read ScoutNist's `build/nist-captures.tsv` (landed during the seat). It is keyed by **staged** ids; re-pointed by document per `id-map.txt` and cross-checked all seven normalized digests and the seven raw PDF/page digests: **all seven match this seat's captures exactly**. Its verdicts also match the corrections below (banner present on the Part 2/Part 3 pages; exact Part 3 date; 07/01/2025 review notes omitted by the staged rows; staged age arithmetic wrong).
4. Wrote the entry with lane ids only, then ran the shape checks listed under Gates; no lane file, registry row, capture row, PROVINCE/README bullet or lesson was edited.

Network scope: only the seven adopted NIST URLs listed in the plan's id map (S076-S082). No vault contact, no `op` invocation beyond none at all, no credential material read or printed.

## Citation list (final, in the deliverable)

`source:` line carries exactly **S076-S082** (one `source:` line, no continuation):

| id | document | URL | recorded digest |
|---|---|---|---|
| S076 | SP 800-57 Pt 2 (2005) CSRC page | https://csrc.nist.gov/pubs/sp/800/57/pt2/final | rendered-text-v1 `a4dad4f29c355b74` |
| S077 | SP 800-57 Pt 3 (2009) CSRC page | https://csrc.nist.gov/pubs/sp/800/57/pt3/final | rendered-text-v1 `1047a8228fc6392a` |
| S078 | Pt 2 legacy PDF, "Withdrawn" wrapper | https://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-57p2.pdf | raw `68266cb10868a1fe` |
| S079 | Pt 3 legacy PDF, "Archived" wrapper | https://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-57p3.pdf | raw `52b9a7d321ab0f81` |
| S080 | Pt 2 Rev. 1 page | https://csrc.nist.gov/pubs/sp/800/57/pt2/r1/final | rendered-text-v1 `810b05568ddcea52` |
| S081 | Pt 3 Rev. 1 page | https://csrc.nist.gov/pubs/sp/800/57/pt3/r1/final | rendered-text-v1 `c504bce605fd09ab` |
| S082 | SP 800-131A Rev. 2 page | https://csrc.nist.gov/pubs/sp/800/131/a/r2/final | rendered-text-v1 `ff257649b6da6458` |

Body citation outside the set: **S049 once** ("the lane's Rev. 6 row registers only its draft status").

No staged id token survives (`S083`-`S087` absent; staged `S061`/`S062`/`S063` absent), and there is no `[round-` token anywhere in the file.

## Corrected sentences (staged → delivered)

1. **Title.** Staged: "SP 800-57: two of the three parts are withdrawn, and the CSRC pages do not say so" → "SP 800-57: two of the three parts are withdrawn, and their CSRC pages still print \"(Final)\"". Reason: both re-opened pages now carry "Withdrawn on May 23, 2019" / "Withdrawn on January 22, 2015" plus a "Superseded by" link [S076][S077]; the surviving trap is the `(Final)` Document History line, not page silence.
2. **Part 2 table row, "CSRC page says".** Staged cell: revision history only, cited "[round-2 S079]" → history "08/25/05: SP 800-57 Part 2 (Final)" **plus** "Withdrawn on May 23, 2019" and "Superseded by SP 800-57 Part 2 Rev. 1" [S076].
3. **Part 3 table row, "CSRC page says".** Staged cell: revision history only, "[round-2 S080]" → history "12/28/09: SP 800-57 Part 3 (Final)" **plus** "Withdrawn on January 22, 2015" and "Superseded by SP 800-57 Part 3 Rev. 1" [S077].
4. **Part 3 withdrawal date.** Staged: "Withdrawal Date **January 2015**" from the wrapper only → "Withdrawal Date **January 2015** (the page carries the day: 22 January 2015)" [S077][S079]. The wrapper prints the month; the page prints 22 January 2015 (ScoutNist's capture reaches the same verdict).
5. **Age arithmetic.** Staged: "has been withdrawn for between eleven and twenty years" → "withdrawn in May 2019 and January 2015 respectively — more than seven years ago in both cases at this entry's verification date". The staged bound is false for Part 2 (May 2019 to 2026-11-04 is 7 y 5 m); the capture row independently flags the staged age arithmetic as wrong.
6. **Rev. 6 substitution.** Staged: "This matters because the Rev. 6 draft removes Part 1's own algorithm-approval time frames and points at SP 800-131A instead." → kept as a **premise carried from the staged draft and explicitly marked not established by the seven documents opened here**; the operational half (131A Rev. 2 is the final on record, its page's newest Rev. 3 signal is a 2024 initial public draft) is retained and cited [S082].
7. **Rev. 3 status.** Staged: "Rev. 3 exists only as a draft" → "Rev. 3 was an open draft as of that note [10/21/2024], and the page records no Rev. 3 final" [S082]. The note is dated; the page does not announce a Rev. 3 final, and the entry no longer claims a live state it cannot see.
8. **Part 1 baseline.** Staged: "Rev. 5 remains the final Part 1 (round-2 S082)" → "the Rev. 1 pages' \"Publication Parts\" field lists SP 800-57 Part 1 Rev. 5 [S080][S081], and this entry does not assess Part 1's own revision status". The captured pages list Rev. 5 as a part; they do not establish Rev. 5's finality.
9. **Added (staged omission).** Both Rev. 1 pages carry a Planning Note dated 07/01/2025: "This publication is currently being reviewed." [S080][S081] — recorded as a currency signal, with the caution that a review is not a withdrawal.
10. **`recheck:` command.** Staged wrote a `/tmp/p2.pdf` download; rewritten as a stdin pipe (`curl … | pdftotext -layout - - | grep -c …`), same counter, result `1` (ran 2026-11-04). No `/tmp` path remains.
11. **All staged id tokens.** `[round-2 S079]`, `[round-2 S080]`, `(round-2 S082)`, `[S083]`, `[S084]`, `[S085]`, `[S086]`, `[S087]`, `(lane row S049)`-style leftovers re-pointed to lane ids S076-S082 with one S049 body citation.

## Gates run (this seat only; L1 runs the full gates)

| check | command shape | result |
|---|---|---|
| one `source:` line | `grep -c '^source:'` | 1 |
| id set on `source:` | `grep '^source:' \| grep -oE '\bS[0-9]{3,}\b' \| sort -u` | exactly S076 S077 S078 S079 S080 S081 S082 |
| S049 body citations | `grep -oE '\bS[0-9]{3,}\b' \| uniq -c` | 1 |
| staged ids | `grep -oE '\bS0(8[3-9]\|9[0-9])\b'` | none |
| `[round-` tokens | `grep -c '\[round-'` | 0 |
| header fields | `grep -nE '^(verified-at\|recheck\|ground\|Reverify):'` | all four present, one each |
| `Reverify` row exists | `grep -c '^R31-02' corpus/claim-ledger.tsv` | 1 |
| credential regex (census `CRED_RE`) | `grep -cE -- "$CRED_RE"` | 0 |
| `op://` refs | `grep -cE 'op://\|onepassword://'` | 0 |
| quote lengths | quoted spans ≤25 words | longest source quote 19 words |
| locate every quote | `corpus/rendered-text-v1.py locate` / `pdftotext \| grep` | count=1 each |
| digest cross-check vs `build/nist-captures.tsv` | raw + normalized | all 7 match exactly |
| file hygiene | `file`, `grep -c ' $'`, tab count | UTF-8, LF, 0 trailing spaces, 0 tabs |

Not run by this seat: census, claim-ledger `cells`/`docs`, eol-sweep, self-description sweep, any build/lint. The entry's citations do not yet resolve because the ten registry rows are ExecCapture's and ScribeDocs's to land.

## Findings / limits

1. **`ground:` is a foreign artifact (kept per assignment, flagged).** It cites "Round-2 ledger item 7 — 'SP 800-57 Part 2 and Part 3 substance'". The lane has no `plans/round-2.md` and no `corpus/lessons/round-2.md`; the string appears nowhere in the lane outside this draft. This is the exact class round 31 mined as **F-K** (`corpus/lessons/round-31.md`: a staged ground line citing the merge package's internal round numbering has no lane record). The seat spec says keep the line, so it is unchanged; the round-33 lesson can re-ground it to the lane's own record or keep it knowingly.
2. **`Reverify: R31-02`.** Chosen because it is the lane's migration-managed census claim row that the round-31 entries point at and the round-32 lesson migrates (`rows71→72 …`). It exists today, so `claim-ledger.sh` parses. If round 33 lands a dedicated C2 census row instead, the L1 should re-point this line together with ScribeEntry1's sibling entry.
3. **`build/nist-captures.tsv` is keyed by staged ids** (S061/S062/S063/S079/S080/S083-S087), not lane ids. Kept as-is (ScoutNist's file, not mine); my citation ids follow `id-map.txt` and every digest matches.
4. **Raw CSRC page bodies are per-request unstable** (two fetches of the same URL differ byte-wise; normalized digests identical). The entry therefore records `rendered-text-v1` digests for the five pages and raw `fetch sha256` for the two PDFs, matching the capture TSV's own columns.
5. **PDF text layer artifact, unquoted:** the Part 3 wrapper's "Date updated" line renders as mojibake (`JuůǇϭϛ, 2015`) in `pdftotext -layout`; the same wrapper prints "as of July 15, 2015" in ASCII. Not used as evidence, not quoted.
6. **Staged structure preserved:** table, "What is actually current", the Rev. 6 substitution section, "The rule", "What this entry does not establish", plus an appended "Re-grounding notes (round 33)" listing the corrections.
7. No credential material, no secret reference, no vault contact; `op` was never invoked (handler absent is expected, not a defect). No tool installed or upgraded.

## Touched surfaces

- Written: `.ufo/waves/round-33/build/knowledge/nist-key-management-parts-withdrawal.md` (draft deliverable), this report `.ufo/waves/round-33/build/ScribeEntry2.md`.
- Scratch: `/fast/scratch/hyaku/kagi-r33/ScribeEntry2/` (created, used for fetches/normalized texts, removed before yield).
- Not touched: any lane-tracked file, `corpus/*`, `plans/*`, `considerthese/`, sibling `*-shokunin` repos, fleet-root files, `.ufo/state/`, `~/.local/bin`.

## Out of scope (other seats own)

Registry rows S076-S082 and their `used-by`/`status`/`recheck`/`scope` cells (ExecCapture/ScribeDocs), `corpus/source-fetches.tsv` capture rows (ExecCapture), `PROVINCE.md` Core bullet and Frontier-bullet removal in `PROVINCE.md`/`corpus/README.md` (ScribeDocs), the sibling entry `nist-key-management-guidance-status.md` (ScribeEntry1), the round lesson/QUALITY/SCORECARD drafts (ScribeDocs), the C1 gate and its red witness (ExecGate/ExecReplay).
