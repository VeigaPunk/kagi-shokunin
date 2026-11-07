# R59ScribeEntry — notes for the transit knowledge-entry draft

Seat: R59ScribeEntry (scribe). Round 59, attempt 1. Lane
`/home/vgpnk/Projects/shokunin/kagi-shokunin`. The lane HEAD when this seat started was
`af7b665` (the frozen predeclaration; the round-59 instruments and receipts did not exist on disk
yet). Claim BASE `5fa6e658f36bd9e440cb567fbbd2bfac88f868b6`. This seat wrote no git/jj command
and no registry row; only the files listed below.

## Artifacts written

| path | bytes | sha256 |
|---|---|---|
| `.ufo/waves/round-59/build/R59ScribeEntry/openbao-transit-engine.md` | 34432 | `0a3b27a38cd8d17d65a8a9a9b369eed720a9ef96ff7acc00fa7ac1fac4ebe015` |
| `.ufo/waves/round-59/build/R59ScribeEntry/quote-locations.md` | 8351 | `f98f92d3a0ed673a7c59779f99cd07d72ad9d855bf54c659660d06fd28aba3ea` |
| `.ufo/waves/round-59/build/R59ScribeEntry/capture/S121.body` | 48604 | `d8879a2a4d784cd734bc32b3b60a0d1180a9373bff2e9b7d76a3bb7bce7b0a19` |
| `.ufo/waves/round-59/build/R59ScribeEntry/capture/S122.body` | 267984 | `ad1a47d369be288c7091836fd1ebadc1534f33fb17780b9d7810d2ff808b657e` |

(the entry's digest is after the final edit of this seat; if the L1 lands the file it recomputes
on the landed bytes)

The draft is delivered at the build path, not at `corpus/knowledge/openbao-transit-engine.md`;
the L1 lands it after the trial's receipts exist. Its last line, `SEAT-STATUS: complete`, is this
seat's acceptance marker and is not part of the entry prose — strip it when landing (the peer
corpus entries carry no seat marker).

## Capture provenance

The round-59 scout's captures are `.ufo/waves/round-59/capture/S121.body` and `S122.body`. This
seat fetched both URLs independently (same desktop browser User-Agent recorded in the scout's
header files) and got byte-identical bodies — the raw sha256 values above are equal for the two
fetches, so the draft's quotes sit on the lane's canonical capture. The scout's header files
state the QM72 removals: no `set-cookie:`/`cookie:` line was present (0 removed), and the two
server-issued request-id header lines were replaced. The copies under this seat's `capture/` are
kept beside the draft so a reader of the build directory does not have to trust a path outside
it; they are the same bytes as the lane captures.

Normalization: `python3 corpus/rendered-text-v1.py digest <capture>` →
S121 raw `d8879a2a…` / normalized `3f49303cd3fe01869413193006b2a45e146115f5a80692f8b382f698a57503b6`
(14163 B); S122 raw `ad1a47d3…` / normalized
`a1636fb2ad54212a50bef35857a3ade11a6f65380a4986ca53439fa938193312` (62185 B).

## §Mechanics row → receipt line

All from `.ufo/waves/round-59/build/R59ExecTrial/`; the two real receipts are byte-identical
(sha256 `097798f1c0c36357cac9ae562e03b530eb941ada70a6ac83c8a23156abcbf40a`), so a row citing
`receipt-ref-real.txt` is also backed by `receipt-ref-real2.txt`.

| draft row | receipt file | receipt line quoted in the draft |
|---|---|---|
| T1 | `receipt-ref-real.txt` | `TRIAL T1 HOLDS roundtrip=1 prefix-v1=1 no-pt-in-ct=1 tamper-refused=1` |
| T2 | `receipt-ref-real.txt` | `TRIAL T2 HOLDS fresh-v2=1 latest=2 old-v1-decrypts=1 new-v2-decrypts=1` |
| T3 | `receipt-ref-real.txt` | `TRIAL T3 HOLDS rewrapped-v2=1 changed=1 rewrapped-decrypts=1 rewrapped-decrypts-after-min2=1 old-v1-refused-after-min2=1` |
| T4 | `receipt-ref-real.txt` | `TRIAL T4 HOLDS pre-v1=1 min-after-raise=2 v1-refused-named-error=1 min-after-lower=1 v1-re-enabled=1` |
| T5 | `receipt-ref-real.txt` | `TRIAL T5 HOLDS equal-ctx-byte-identical=1 diff-ctx-differs=1 nonconv-plain-differs=1` |
| run summary | `receipt-ref-real.txt`, `receipt-ref-real2.txt` | `OPENBAO_TRANSIT_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2` (then `rc=0`) |
| shim SH1 | `receipt-shim-SH1.txt` | `TRIAL T1 BROKEN … tamper-refused=0`; summary `holds=4 broken=1 error=0` |
| shim SH2 | `receipt-shim-SH2.txt` | `TRIAL T2 BROKEN … old-v1-decrypts=0 …`; summary `holds=4 broken=1 error=0` |
| shim SH3 | `receipt-shim-SH3.txt` | `TRIAL T3 BROKEN … old-v1-refused-after-min2=0`; summary `holds=4 broken=1 error=0` |
| shim SH4 | `receipt-shim-SH4.txt` | `TRIAL T4 BROKEN … v1-refused-named-error=0 …`; summary `holds=4 broken=1 error=0` |
| shim SH5 | `receipt-shim-SH5.txt` | `TRIAL T5 BROKEN … diff-ctx-differs=0 …`; summary `holds=4 broken=1 error=0` |
| no-`bao` PATH | `receipt-none.txt` | `OPENBAO_TRANSIT_TRIAL: SETUP no bao on PATH`, `rc=2`, no `TRIAL` line |
| clean-room | `receipt-cleanroom.txt` | server A pid/port, server B distinct pid/port/own fresh storage, `clean-room decrypt attempt: REFUSED (rc=2)`, `Code: 400. Errors:`, `* encryption key not found`, `CLEANROOM_DRIVER: PASS rc=0`; the main run additionally prints `TRIAL CLEANROOM HOLDS own-storage-refused=1` |

No number in §Mechanics comes from a page. The documented side of the entry (§Documented
mechanics and §Docs-vs-binary's page column) is the pages' sentences, each located in
`quote-locations.md`.

## Findings for the L1 (report, not fix)

- **F1 — seat count conflict, verbatim.** This seat's assignment says "ONE v1 wave, 13 seats
  (run-15 band 8-16)", while the frozen `plans/round-59.md` §Shape says 14 seats and its §A1
  amendment explains the four disjoint write sets; `.ufo/waves/round-59/w1.ready.dispatched`
  names 14 seats. No predicate, item, target, POP or kill rule is affected; the conflict is
  reported because the plan is frozen and the assignment text does not match it.
- **F2 — a measured constraint with no receipt line.** `corpus/openbao-transit-trial.sh`'s header
  records that the API refuses `min_decryption_version > latest_version` with a 400, which is why
  T4 rotates before raising. No receipt prints that refusal, so the draft's D5 keeps it out of
  §Mechanics and says so. If C2's record should carry it, the trial needs a receipt line (a plan
  extension for the L1 to route, not a scribe edit).
- **F3 — the T1 key is auto-created.** The trial never pre-creates `r59-t1`; the first encrypt
  upserts it with defaults (the documented create-capability path). This is not in the frozen
  POP's five tests, so the draft records it only as a setup observation ("What the trial's setup
  itself shows"), not as a T-row.
- **F4 — the ceiling's wording.** `plans/round-59.md` §Named ceilings names `RSA/AES key types`
  as unmeasured. The run's keys are all the default `aes256-gcm96` (the create calls pass no
  `type`), so the precise reading is "one symmetric AES-256-GCM type exercised; the type matrix
  is not compared". The draft states that precise version and does not amend the plan.
- **F5 — a page-internal default the run did not resolve.** S122's config parameter text says
  `min_decryption_version (int: 0)` while the read-key sample and the decoded backup sample both
  say 1. T4 reads the value only after setting it. The draft marks the discrepancy documented,
  not measured.
- **F6 — a page-vs-page key-type gap.** S121's §Key types list omits `xchacha20-poly1305`, which
  S122's create-key and import lists include (S121 `locate xchacha20-poly1305` → count=0; S122
  → count=5, the AEAD sentence itself count=2). No binary test can arbitrate because the trial
  never creates a second key type.
- **F7 — registry rows for S121/S122 are not yet present.** `corpus/SOURCES.md` holds 120 data
  rows at BASE; neither transit URL is a row yet. The entry's `source:` names both ids, so the
  L1 must append both rows as `mined` with `used-by` naming
  `corpus/knowledge/openbao-transit-engine.md` before the census/ledger gates read the landed
  entry.
- **F8 — the declaration row.** The draft declares `Reverify: R21-02`, the live sources-census
  row 11 peer entries already use. If the L1 appends a round-59 ledger row and prefers it here,
  that is a deliberate migration (and a stamps row), not a silent rewrite.
- **F9 — strip the seat marker.** The draft's final `SEAT-STATUS: complete` line is this seat's
  marker; remove it when landing the file in `corpus/knowledge/`.
- **F10 — the clean-room leg is inside the main run plus a driver receipt.** The main trial's
  `cleanroom()` starts the second dev server itself and prints `TRIAL CLEANROOM HOLDS
  own-storage-refused=1`; the summary's `holds=5` counts T1–T5 only (CLEANROOM HOLDS does not
  increment it, while a CLEANROOM BROKEN does increment `broken`). `receipt-cleanroom.txt` is a
  separate driver transcript that adds the refusal error text. A reader should not expect
  `holds=6`.
- **F11 — secret discipline checked, not assumed.** A scan of the eight receipt files and the
  draft for `hvs.`, `hvb.`, an `r59-<16+ hex>` marker or the word `root` returned no match; the
  trial's request bodies travel on stdin and its receipts print no token, plaintext, context or
  ciphertext value.
- **F12 — an untracked corpus copy that this seat did not write.** `corpus/knowledge/openbao-transit-engine.md`
  exists untracked (mtime 2026-11-07 14:04, 31869 B, sha256
  `f69c7259ff9f4f1617cfcdf378055456ef86449c80a1d02375bbc7c408e9b385`). It holds an earlier
  snapshot of this draft (old `## Measured`/`## Docs vs binary` headings, the pre-split 35-word
  D1 quote, the older placeholders) plus a G1–G10 paragraph written by its author, and it still
  carries the `SEAT-STATUS` marker. This seat never wrote that path; its writes are the build
  paths listed above. The L1, as sole committer, should land from the final build draft
  (`0a3b27a38cd8…`, 34432 B), which now contains the re-checked G1–G10 gap table, or reconcile
  the two deliberately. The untracked file was not edited or deleted by this seat.

## What this seat ran (and did not run)

Ran: the two fetches (bodies byte-identical to the scout's), `rendered-text-v1.py digest/locate`
over every quoted span in the draft, the receipt reads, the receipt hashes, the byte-identity
comparison of the two real receipts, the secret-shape scan, and the `xchacha20-poly1305`
absence check in S121. Did **not** run: `corpus/openbao-transit-trial.sh`, the C1/C2 counters,
any controls battery, or any git/jj command — those belong to the executors and the L1, and this
seat does not re-run work to decorate its report.

## Tooling

No tool was installed or upgraded for this seat (no pacman, uv, npx, cargo, npm or binary
download). `python3`, `curl`, `sha256sum`, `grep` and the lane's own normalizer were the only
tools used.

## Scratch

Scratch: `/fast/scratch/hyaku/kagi-r59/R59ScribeEntry/` (fetch bodies, normalized text, quote
index source). It is not citable evidence and is deleted before this seat yields.

SEAT-STATUS: complete
