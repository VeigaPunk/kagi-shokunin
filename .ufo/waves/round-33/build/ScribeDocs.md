# ScribeDocs — round-33 prose artifacts (report)

Seat: `ScribeDocs` (scribe, leaf). Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`.
Frozen BASE: `76f4eeae7aa9af4dbb9423f5632b55791824253a`. Frozen claims contract
`plans/round-33.md` (commit `880824b1d3da5f70b2fe489a34fe866a47314672`), read first.
No lane-tracked file was written by this seat. No vault, account, handler, CDP or
`op` reference contact: `op --version` only (`2.41.1`, `/usr/bin/op`). No network
beyond the ten NIST URLs the plan names. No tool installed or upgraded.
Scratch `/fast/scratch/hyaku/kagi-r33/ScribeDocs/` removed before yield.

## Deliverables (7 prose artifacts + this report = 8 files)

All under `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-33/build/docs/`:

| file | state at hand-off |
|---|---|
| `round-33-lesson.md` | draft; Gate (5 candidates), Mistakes (M33-1..M33-3), Migrations (9 rows), Measurements, Self-evaluation |
| `quality-QM34.md` | row + heading + reconciliation note: QM34 is **already landed** in `corpus/QUALITY.md:174-181` under a different heading |
| `scorecard-round33.md` | pre-move (6 rows, 4 cols), post-move (6 rows, 4 cols), capability row (4 cols), R32-4 prose repair |
| `province-core-bullet.md` | delete line 90 (byte-exact), insert Core bullet, three landing checks |
| `readme-frontier-removal.md` | delete lines 115-117 (byte-exact), insert coverage-map sentence, four landing checks |
| `round32-captured-by.patch` | unified diff; `git apply --check` OK on a fresh shared clone; only the two `captured-by` cells change |
| `s072-scope-fix.md` | old (BASE) → new (landed in the working tree) |
| `ScribeDocs.md` | this report |

## What the lane already landed while this seat drafted (adaptations)

The L1/executors landed part of the build concurrently; the drafts were reconciled
to the live bytes rather than to my earlier reads:

- `corpus/SOURCES.md`: S072 `scope` already corrected; S073–S082 appended; one capture
  row per id in `corpus/source-fetches.tsv`.
- `corpus/knowledge/nist-key-management-guidance-status.md`,
  `…-parts-withdrawal.md`, `…prefreeze-controls.md` present (the first two carry
  `Reverify: R33-02`, the third `R33-01`).
- `corpus/prefreeze-control.sh` present (sha256 `c265a5d82a8b3b0dc588ba3c9e5b5cd887de092127be36835584ee7f8b381e59`,
  11,259 bytes, 256 lines); `corpus/QUALITY.md` already carries a QM34.
- Build receipts: `.ufo/waves/round-33/build/ExecGate.md`, `ExecReplay.md`,
  `ExecCapture.md`, `MutGate.md`, `ConnOverlap.md`, `assimilation/validate/`;
  final red witnesses `.ufo/waves/round-33/final/c1-red-witness.txt`,
  `c1-captures-red.txt`.
- My `round-33-lesson.md` was amended in place by another seat between my writes: an
  `M33-3` row appeared (the plan's `captures` error). I kept it, fixed its missing
  leading `|`, replaced its placeholder controls path with the real
  `build/captures-101.controls.tsv`, and reconciled the rest of the lesson to it.
  This is disclosed as a concurrent-write event, not claimed as my own finding.

## Evidence: the ten sources re-opened by this seat (2026-11-04)

`curl -fsSL --compressed --max-time 90`, no credentials, HTTP 200 for all ten.

| id | final URL | bytes | raw sha256 (this seat) |
|---|---|---|---|
| S073 | https://csrc.nist.gov/pubs/sp/800/57/pt1/r5/final | 47203 | `fd216d3037001607f8e4ea4e4f25b6a4ac2912ab32e8356dccaa07de75ac60de` |
| S074 | https://csrc.nist.gov/pubs/sp/800/133/r3/ipd | 45351 | `7587435e6e089adb4bb729cdc303f683df8f2b6b10820f662a053665318fcbdd` |
| S075 | https://csrc.nist.gov/pubs/sp/800/133/r2/final | 42741 | `abf52314e578d13cc3268c155a5f5ca220ae47606849a41d89b7639719a924a2` |
| S076 | https://csrc.nist.gov/pubs/sp/800/57/pt2/final | 44782 | `c36833f44611700de7172efa190634c9ea4a9e4770efd78349fd5b62242b2ffb` |
| S077 | https://csrc.nist.gov/pubs/sp/800/57/pt3/final | 44903 | `81dcbd0d1632c4fedc8394134cbe782ef4b2968d0649c5474b46e7f1d0c77865` |
| S078 | https://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-57p2.pdf | 622785 | `68266cb10868a1fee83fb8bcebbee9573fc738cee9141ee94d03649bad8538d5` |
| S079 | https://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-57p3.pdf | 663635 | `52b9a7d321ab0f8173032869290b3b4620dd1ced57e36c42e65e7e50ff38c3a3` |
| S080 | https://csrc.nist.gov/pubs/sp/800/57/pt2/r1/final | 49598 | `7faff667dfba4bbd261ad1d82614ccc1da121ee8c6014772ddd8144b4c50ed1e` |
| S081 | https://csrc.nist.gov/pubs/sp/800/57/pt3/r1/final | 45934 | `0f915d5cdfb3e687ca845d383b746b56f575680d7607e9d85acc59c3943a4b13` |
| S082 | https://csrc.nist.gov/pubs/sp/800/131/a/r2/final | 45595 | `d19603eadd61b264012e70c7ccabdcf6e0466dd964dfe954f631ca3cb5acf903` |

Located quotes (whitespace-normalized text; word counts by `split()`; all ≤25):

| id | anchor | quote | words |
|---|---|---|---|
| S073 | Document History | `05/04/20: SP 800-57 Part 1 Rev. 5 (Final)` | 8 |
| S073 | metadata | `Date Published: May 2020` | 4 |
| S073 | metadata | `Supersedes: SP 800-57 Part 1 Rev. 4 (01/28/2016)` | 8 |
| S074 | title | `(Initial Public Draft)` | 3 |
| S074 | metadata | `Date Published: April 17, 2026` | 5 |
| S074 | metadata | `Comments Due: June 16, 2026 (public comment period is CLOSED)` | 10 |
| S074 | Planning Note 06/30/2026 | `The public comments received are now available.` | 6 |
| S075 | Document History | `06/04/20: SP 800-133 Rev. 2 (Final)` | 6 |
| S076 | page alert | `Withdrawn on May 23, 2019` | 5 |
| S076 | page alert | `Superseded by SP 800-57 Part 2 Rev. 1` | 8 |
| S077 | page alert | `Withdrawn on January 22, 2015` | 5 |
| S077 | page alert | `Superseded by SP 800-57 Part 3 Rev. 1` | 8 |
| S078 | PDF p.1 Warning Notice | `The attached publication has been withdrawn (archived), and is provided solely for historical purposes.` | 14 |
| S078 | PDF p.1 Withdrawal Date | `Withdrawal Date May 23, 2019` | 5 |
| S078 | PDF p.1 Withdrawal Note | `SP 800-57 Part 2 is superseded in its entirety by the publication of SP 800-57 Part 2 Revision 1.` | 19 |
| S079 | PDF p.1 wrapper | `The attached publication has been archived (withdrawn), and is provided solely for historical purposes.` | 14 |
| S079 | PDF p.1 Withdrawal Date | `Withdrawal Date: January 2015` | 4 |
| S079 | PDF p.1 Withdrawal Note | `SP 800-57 Part 3 is superseded in its entirety by the publication of SP 800-57 Part 3 Revision 1 (January 2015).` | 21 |
| S080 | Document History | `05/23/19: SP 800-57 Part 2 Rev. 1 (Final)` | 8 |
| S080 | Planning Note 07/01/2025 | `This publication is currently being reviewed.` | 6 |
| S081 | Document History | `01/22/15: SP 800-57 Part 3 Rev. 1 (Final)` | 8 |
| S081 | Planning Note 07/01/2025 | `This publication is currently being reviewed.` | 6 |
| S082 | Document History | `03/21/19: SP 800-131A Rev. 2 (Final)` | 6 |
| S082 | Planning Note 10/21/2024 | `An initial public draft of Revision 3 has been posted for public comment through December 4, 2024.` | 17 |

Fetching nuance (measured, not inferred): the CSRC HTML pages are non-reproducing at
constant byte size — ScoutNist's raw sha256 and this seat's differ while the byte count
matches (47,203 / 45,351 / 42,741 for S073–S075 in both sets), which is why the entries
bind identity to `rendered-text-v1`. For the two legacy PDFs this seat's raw body hash
equals the capture row's **normalized** digest and the campaign pin
(`68266cb1…` / `52b9a7d3…`); the capture row's raw field differs (`5512fbdf…` /
`5f72ae83…`), so "byte-for-byte" is claimed only at the normalized identity.

## Measured findings (read from committed receipts, not re-run by this seat)

- C1: `PREFREEZE: CLEAN (controls=4 mismatch=0)` exit 0 (`build/prefreeze-33.txt`);
  `PREFREEZE: MISMATCH (controls=2 mismatch=2)` exit 1 naming `sd5 expect=3 measured=1`,
  `total expect=10 measured=8` (`build/prefreeze-32.txt`, `final/c1-red-witness.txt`);
  `PREFREEZE_SELFTEST: PASS (10 cases)` exit 0 (`build/prefreeze-selftest.txt`);
  mutation seat re-ran the pristine baseline on the same sha256 (`build/mut/MutGate.md`).
  C1's four frozen readings are therefore met on the delivered bytes; the fourth
  (capabilities-table count) becomes ≥1 only when the SCORECARD row lands.
- C2: the lane census at the landed tree prints
  `SOURCES_CENSUS: CLEAN (rows=82 A=79 B=1 C=2 queued=1 mined=78 rejected=3 entries_sourced=12 legacy=22 captures=82 inrow=16 inrow_only=0 inrow_nonreproducing=12)`
  exit 0 (`build/assimilation/validate/landed-tree-gates.txt`).
- **M33-3 / C2 kill rule fires.** The plan declares BASE `captures=101` and target
  `captures=111`; the census counter counts registry ids that carry a capture, so its
  maximum is the registry row count. BASE measured 72 — exactly what the lane's own
  `R21-02` BASE expected line said at `76f4eea` (`captures=72`), and the plan's named
  command (`scripts/sources-census.sh validate`) prints no `captures=` field at all.
  Measured pair: 72 → 82. The gate fires on the plan's figure
  (`final/c1-captures-red.txt`: `MISMATCH captures expect=101 measured=72`, exit 1).
  Read against the frozen kill rule, **C2 is not admitted**; the entries, the ten rows,
  the ten captures and the Frontier removal are still the round's landed artifacts, so
  the scorecard row is written as a partial coverage move, not as an admitted claim.
- Connector (`build/ConnOverlap.md`): 0 of 20 sibling lanes hold any NIST key-management
  source ground (C2 source ground sole); one capability-class neighbour for C1 —
  kasegi `corpus/instruments/freeze-check.py:2-12` states the same replay-predicate class.
  Reported in the lesson Measurements, the scorecard adjacency row and the PROVINCE
  landing checks; not absorbed or adjudicated.

## Undrafted without inventing evidence (for the L1)

1. The C2 four-reading receipt for `frontier NIST lines = 0` and the two-entry count:
   both depend on the L1 applying this round's `PROVINCE.md`/`corpus/README.md` edits;
   the lesson says so instead of asserting the reading.
2. The C1 capabilities-table count (`awk ... | grep -c prefreeze-control.sh`): it is 0
   until the scorecard row lands, so the SCORECARD draft names it as satisfied "once
   this section lands" rather than quoting a number.
3. Which QM34 heading survives: `corpus/QUALITY.md` already has QM34 under
   `## Criterion from the round-33 C1 capability (landed round 33)`; the assignment
   asks for `## Criterion from the round-33 build`. `quality-QM34.md` carries the
   landed row verbatim and states the two options (re-head, or keep the landed heading);
   it does not append a duplicate id.
4. The L1's stamp/ledger/census projections (`claim-ledger.sh stamp/verify/cells`,
   `self-counts`, `sources-census`) are not asserted in the lesson; only the receipts
   that exist at draft time are named.

## Scope compliance

- Wrote only `build/docs/*` and this report (both under
  `.ufo/waves/round-33/build/`); no lane-tracked file, no `considerthese/`, no fleet-root
  tracked file, no sibling repo, no `~/.local/bin`.
- Read-only git only: `rev-parse`, `show`, `log`, `diff`, `status`, `clone --shared`,
  `archive` (inside the reviewed gate receipts). No add/commit/stash/checkout/reset/pull/
  push, no mutating jj.
- The one fixture repo used for the patch check was a `git clone --shared` at
  `/fast/scratch/hyaku/kagi-r33/ScribeDocs/check3`; `rev-parse --show-toplevel` printed
  that path before `git apply --check`, which exited 0.
- Ten fetches, all `GET`, no credentials; `op --version` only.

## Result

The seven draft artifacts exist and are structurally valid: the lesson has the five
named sections; QM34 is a 4-column row; both SCORECARD tables are 4 columns with six
rows each (the same shape as the round-32 sections); the captured-by patch applies
cleanly to a fresh clone and changes exactly the two `captured-by` cells; the S072
old→new is the exact landed text. C1's capability is measured and its row is ready;
C2 is recorded as not admitted under its frozen kill rule, with the plan's arithmetic
error (M33-3) named and witnessed.
