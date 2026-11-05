# K42ScoutS094 — round 42 (kagi, attempt 1), scout seat

Deliverable dir: `.ufo/waves/round-42/build/K42ScoutS094/`
(`notes.md`, `CORPUS-live.md`, `CORPUS-live.headers`, `curl-summary.txt`,
`curl-stderr.txt`, `receipts.txt`).
Scratch `/fast/scratch/hyaku/kagi-r42/K42ScoutS094` deleted on yield. Lane read-only:
no git mutation anywhere, no `corpus/` edit, no `corpus/SOURCES.md` edit, no
`corpus/source-fetches.tsv` edit, no claim-ledger verify, no self-counts.
Tooling installs: **none** (curl/sha256sum/cmp/grep/git/awk/sed already present).

## S094 re-open: MATCH, no drift

`curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' …`
exit **0**, stderr empty, `HTTP/2 200`,
final URL `https://raw.githubusercontent.com/VeigaPunk/shokunin/f47ad6ba8d306f8125597401cb2ce45c1297a593/CORPUS.md`
(`num_redirects=0`), decoded body **11296 bytes**,
sha256 **`88556402940e7a0f1dbbed3abef9e00c87a90db6f80eaed03269e371f50050b8`**,
access date **2026-11-05** (`date: Thu, 05 Nov 2026 16:55:44 GMT`).

Committed capture located by `find`/`git ls-files`: **`.ufo/waves/round-39/capture/S094.body`**
(tracked; round-40/round-41 capture dirs hold only S095/S096 and S097/S098).
`cmp` live-vs-capture → **exit 0, identical**. Capture sha/bytes equal the live body and
equal TSV cols 10/11 (`88556402…`, `11296`). Read-only cross-check:
`git -C /home/vgpnk/Projects/shokunin show f47ad6ba8d306f8125597401cb2ce45c1297a593:CORPUS.md | sha256sum`
= `88556402940e7a0f1dbbed3abef9e00c87a90db6f80eaed03269e371f50050b8` — fleet blob at the
pinned revision == live body == committed capture. **Verdict: MATCH, no drift.**

## The append-only rule — located and quoted

Row: `corpus/source-fetches.tsv` line 137, id `S094`, 16 columns (header at line 5).
url/final_url = the pinned raw URL above; http_status 200; request_profile
`curl-fsSL-compressed-v1`; fetched `2026-11-05`; representation `decoded-http-body-v1`;
sha256 `88556402…`; bytes `11296`; revision `f47ad6ba…`; quote
``Only `status`, `recheck` and `used-by` change in place``; normalization `raw-literal-v1`;
location `SOURCES.md Rules item 2, line 116`.
Row identity re-derived read-only: `printf 'S094\tmined\t<url>\n' | sha256sum` =
`2b8fec43b007b3c9fe0208051534708090f2ab21cb98a1d9702fe9f1f5b27ea7` = col 3. The row is
byte-identical at the claim BASE `e8265c0` and at lane HEAD `fdbb83d`
(`git diff --stat` empty for both `corpus/source-fetches.tsv` and `corpus/SOURCES.md`).

Rule location in the fetched body: `### Rules` at line 110, item **2** at **line 116**
(the `## SOURCES.md — where a shokunin learns` contract carried in CORPUS.md from
`.ufo/waves/kaika/SOURCES-CONTRACT-v1.md`).

Verbatim (line 116, continuation 117):

```
2. **Append-only.** Only `status`, `recheck` and `used-by` change in place, and each change
   is logged old→new in the round lesson. A correction is a new row whose `teaches` opens
```

**Quote (8 words, ≤25, verbatim, contains the words saying only status/recheck/used-by
change in place):**

> Only `status`, `recheck` and `used-by` change in place

- `grep -c -F` on that string → **1** (exit 0), unique in the body.
- `grep -b -o -F` → **byte offset 6172** (exit 0).
- Broader form `**Append-only.** Only …change in place` → count 1, offset 6155.
- `grep -n -F 'Append-only'` → line 116 only.
- The TSV col-13 declared quote equals this quote; col-16 declared location
  (`SOURCES.md Rules item 2, line 116`) matches the located line.
- Lane registry row (`corpus/SOURCES.md` line 101) is `own-work`/tier A/`mined`/opened
  2026-11-05/recheck `90d`/used-by `corpus/lessons/round-39.md` (path exists);
  `corpus/lessons/round-39.md` line 17 quotes the same 9-word located quote.

## Deletion verdict

**The rule forbids deleting a registry row.** Only `status`, `recheck` and `used-by`
change in place, and a correction must be a *new* row whose `teaches` opens
`supersedes S0NN —`; removing an existing row is therefore not a permitted in-place
change and violates the append-only discipline the rule states.

## Bearing on the frozen claims (no score moved by this seat)

- **C1 (calibration)** rests on this rule; the source is live, unchanged and the rule text
  is located, unique and verbatim — the sourced claim for F5 (`DELETED <ID>` refusal) still
  stands at the source on 2026-11-05.
- **C2 (freshness)** is a runner/derivation claim, not a source claim; this seat's re-open
  confirms the pinned source has not drifted (the C2 defect was a receipt that was not
  re-derivable from the revision it names, not a source-content drift).
- Nothing here edits `corpus/SOURCES.md`, any registry row, or any journal.

## Open items / observations (recorded, not fixed in the lane)

1. The pinned revision `f47ad6ba8d306f8125597401cb2ce45c1297a593` is **not an object in the
   lane repo** `kagi-shokunin` (`git cat-file -t` → `fatal: … could not get object info`);
   it exists in the fleet-root repo `/home/vgpnk/Projects/shokunin`. The TSV row's `revision`
   cell therefore names a fleet-root revision, not a lane revision. Read-only cross-check
   was run against the fleet-root repo; nothing was mutated. [calibration note — the
   `corpus/source-fetches.tsv` header does not declare which repository the `revision`
   column lives in.]
2. `size_download=5073` (gzip wire bytes) vs 11296 decoded bytes: the row's declared
   representation is `decoded-http-body-v1`, so the digest/byte attestation domain is the
   decoded body, which is what the live fetch and the committed capture agree on.
3. The rule's `## Rules` heading is at line 110 of the fetched CORPUS.md; the round-39
   lesson's `§Gate` cites "CORPUS.md §SOURCES.md, rule 2" and "line 116" — consistent with
   this re-open, but note the corpus contract is *carried into* CORPUS.md, so the file that
   literally holds the rule text is CORPUS.md while the section it belongs to is the
   SOURCES.md contract.

## Unresolved

None material to the seat's question: URL, final URL, status, date, bytes, sha256, match
verdict, quote, count and offset are all measured and receipted in
`.ufo/waves/round-42/build/K42ScoutS094/receipts.txt` and `notes.md`.
