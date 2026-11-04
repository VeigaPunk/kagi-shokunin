# ScribeEntry1 — round-33 C2 entry 1 (NIST key-management guidance status)

Seat: scribe, leaf. Assignment: draft `corpus/knowledge/nist-key-management-guidance-status.md`
re-grounded this round from the staged `merge/kagi` original.
Frozen BASE: `76f4eeae7aa9af4dbb9423f5632b55791824253a`. Lane HEAD at work: `880824b`
(`round-33: plan + frozen claims`). No lane-tracked file was written, edited, staged or committed.

## Behavior delivered

`knowledge/nist-key-management-guidance-status.md` (8200 B, 107 lines, 1293 words,
sha256 `b453fc9c8f686f2a73d02c171551285c013667ac210376f4f13348c311ddbd7a`): the admitted
entry, re-pointed from campaign ids S061/S062/S063 to lane ids S073/S074/S075, with the
staged S049 body citation kept. Structure follows the staged shape with the lane's `source:`
convention: exactly four front-matter lines (`source:`, `verified-at:`, `recheck:`, `ground:`),
blank line, H1, then `## The status table`, `## Reading the status signals`,
`## The operational rule`, `## What this entry does not establish`, `## Gate note (round 33)`,
`---`, and the required final `Gate:` line (byte-exact as specified).

## Gates run (and only these)

| check | command | result |
|---|---|---|
| front matter | first 4 lines start `source:` `verified-at:` `recheck:` `ground:` in order; line 5 blank; line 6 `# ` | PASS |
| citation set | `grep -oE '\bS[0-9]{3}\b'` | exactly `S049 S073 S074 S075`; nothing else |
| staged ids | `grep -E '\bS(06[0-9]\|08[0-9]\|07[6-9]\|082)\b'` | 0 hits |
| quotes | every `"..."` span word-counted | max 10 words (limit 25) |
| recheck probe | `curl -fsSL 'https://csrc.nist.gov/pubs/sp/800/133/r3/ipd' \| grep -c 'public comment period is CLOSED'` | `1` (ran 2026-11-04) |
| secrets | `op://` count | 0 |

Not run (L1's job): census, self-description sweep, lane gates, markdown lint, full suite.

## Citation list (as installed)

- `S073` — https://csrc.nist.gov/pubs/sp/800/57/pt1/r5/final — Date Published May 2020;
  Supersedes SP 800-57 Part 1 Rev. 4 (01/28/2016); Document History
  "10/08/19: … (Draft)" then "05/04/20: … (Final)".
  rendered-text-v1 sha256 `950ae8a8ad88da31`.
- `S074` — https://csrc.nist.gov/pubs/sp/800/133/r3/ipd — subtitle
  "(Initial Public Draft)"; Date Published April 17, 2026; "Comments Due: June 16, 2026
  (public comment period is CLOSED)"; Planning Note (06/30/2026) "The public comments
  received are now available."; Document History only "04/17/26: … (Draft)".
  rendered-text-v1 sha256 `955dd86653889462`.
- `S075` — https://csrc.nist.gov/pubs/sp/800/133/r2/final — Date Published June 2020;
  Supersedes SP 800-133 Rev. 1 (07/23/2019); Document History "03/05/20: … (Draft)" then
  "06/04/20: … (Final)". rendered-text-v1 sha256 `bb1cce593095f6c1`.
- `S049` — body-only, pre-existing row (opened 2026-10-21, recheck 90d, used-by
  `corpus/lessons/round-28.md`): SP 800-57 Part 1 Rev. 6 IPD (2025-12-05), comment period
  closed 2026-02-05. Not re-proposed; absent from `source:` by design; the entry says so in
  one sentence under the table and flags that its dates were not re-read this round.

Every id above resolves against `.ufo/waves/round-33/assimilation/id-map.txt`
(S061→S073, S062→S074, S063→S075).

## Sentences corrected against the captures

1. **"A CSRC publication page carries a status line under the title (Final / Initial Public
   Draft)"** — false for finals. Only the draft page carries the subtitle
   "(Initial Public Draft)"; the Rev. 5 and Rev. 2 `/final` pages go title → Date Published
   with no status label. Rewritten, and the identical-on-all-pages hidden
   `status` field `Final,Draft` is named explicitly as non-signal.
2. **"§Revision History"** — the served heading is **"Document History"** on all three
   pages. Corrected in the anchor description and in the prose.
3. **Planning Note** — staged said it "records that comments were received and published";
   replaced with the page's own sentence ("The public comments received are now available.").
4. **Staged `recheck:` command** — `grep -c 'Comments Due: June 16, 2026 (public comment
   period is CLOSED)'` returns **0** on today's page because `<strong>Comments Due:</strong>`
   splits the label from the value; replaced with the contiguous substring
   `public comment period is CLOSED` → 1. (A stale gate in the staged entry, caught by
   running it.)
5. **Staged "Rev. 6" clause attached to the Rev. 5 row** ("must not cite the Rev. 6 draft")
   — the Rev. 5 page names no Rev. 6 (ScoutNist's capture note flags this over-claim).
   The Rev. 6 status is now attached to S049 only, and the inference is labelled as an
   inference in "What this entry does not establish".
6. **Fetch identity** — the staged campaign sha256 prefixes do not reproduce as raw-body
   hashes. Three independent fetches of each page this round (ScribeEntry1, ScoutNist,
   ExecCapture) gave three different raw sha256 values at identical byte counts; the
   `rendered-text-v1` normalized sha256 was identical across all three. The entry now pins
   the normalized sha256 and states the measurement in `verified-at:` and in the Gate note.

No capture contradicted a date or supersession claim: May 2020, June 2020, 05/04/20,
06/04/20, 01/28/2016, 07/23/2019, April 17, 2026, June 16, 2026, 06/30/2026 and 04/17/26 all
re-locate verbatim in the re-opened bodies (all but 01/28/2016 also appear literally in
`nist-captures.tsv`; that one is stated with its own live grep in the Gate note).

## Touched surfaces

- `kagi-shokunin/.ufo/waves/round-33/build/knowledge/nist-key-management-guidance-status.md`
  (deliverable, written)
- `kagi-shokunin/.ufo/waves/round-33/build/ScribeEntry1-fetches.tsv` (receipt, written)
- `kagi-shokunin/.ufo/waves/round-33/build/ScribeEntry1.md` (this report)
- scratch `/fast/scratch/hyaku/kagi-r33/ScribeEntry1/` (created, then removed — see below)

Read-only reads: `plans/round-33.md`; `corpus/SOURCES.md` (S049 row); `corpus/knowledge/`
list and three sample entries for shape; `.ufo/waves/round-33/build/nist-captures.tsv`;
`build/src-open/normalize.py`; `build/knowledge/nist-key-management-parts-withdrawal.md`
(sibling, consistency only); staged `merge/kagi` entry and `SOURCES.append.md` rows.

## Out of scope (deliberately not done)

- No lane edit, no registry row, no `corpus/source-fetches.tsv` row, no PROVINCE/README/
  SCORECARD/QUALITY/lesson edit — all L1 installs.
- No git/jj mutation; no census, sweep, build, lint or test run.
- No vault contact; `op` not invoked at all. No secret value, token or reference printed.
- Network: only the three CSRC URLs above (subset of the ten the round allows), GET only.
- No tool installed or upgraded (nothing was needed).

## Findings for the round

- **F1 (calibration, reusable):** CSRC publication pages are non-reproducible at the byte
  level — fixed size, different sha256 on every response. Any capture scheme that pins a
  raw body hash for CSRC will look unstable; pin the normalized text instead. Evidence:
  `ScribeEntry1-fetches.tsv`, three-way comparison.
- **F2 (gate rot):** the staged entry's own `recheck:` command no longer returns 1. A
  recheck command is only a gate if it is executed at entry time; this one was not.
- **F3 (label asymmetry):** "Final" is never printed as a status label on a CSRC `/final`
  page; only drafts carry a subtitle. A rule that tells a reader to look for a "Final"
  label under the title cannot succeed.
- **F4 (over-claim in the staged registry cell):** S061's `teaches` cell ends with a
  Rev. 6 clause the Rev. 5 page does not support; S049 is the right home for it.
- **F5 (non-defect, recorded):** ScoutNist's capture row for S073 lists the page's
  "Publication Parts: SP 800-57 Part 2 Rev. 1 SP 800-57 Part 3 Rev. 1" line. This entry
  does not use it; Part 2/Part 3 status is the sibling entry's ground.

## Scratch discipline

`/fast/scratch/hyaku/kagi-r33/ScribeEntry1/` (bodies, tmp) was removed before yield; no
clone was made, no multi-GB tree, nothing written under `/tmp`.
