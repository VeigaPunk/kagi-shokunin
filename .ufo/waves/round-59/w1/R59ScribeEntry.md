# R59ScribeEntry — seat report (kagi round 59, attempt 1, w1)

Seat role: scribe (axes coverage, depth). Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`,
claim BASE `5fa6e658f36bd9e440cb567fbbd2bfac88f868b6`, lane HEAD at seat start `af7b665`
(frozen predeclaration). No git/jj command was run by this seat; no registry row and no corpus
path was written.

## Behaviour (what was produced)

`corpus/knowledge/openbao-transit-engine.md` is drafted at
`.ufo/waves/round-59/build/R59ScribeEntry/openbao-transit-engine.md` for the L1 to land after the
trial receipts exist. Shape:

- title line; `source:` naming S121 (https://openbao.org/docs/secrets/transit/) and S122
  (https://openbao.org/docs/api/secret/transit/) with the section anchors used;
  `verified-at:` the fetch/read/locate statement; `recheck: on-release` naming the trial;
  `Reverify: R21-02` (the live sources-census row used by the peer OpenBao entries) with the
  standard parenthetical;
- §Documented mechanics: T1–T5 table, each row a located page sentence plus the frozen §C2
  assertion; sub-sections on the prefix, rotation/rewrap/retirement, convergent encryption, key
  types and BYOK;
- §Mechanics (measured): one line per T1–T5 quoted from `receipt-ref-real.txt`, the summary line,
  the five shims, the no-`bao` fail-closed leg, and the clean-room leg with the second server's
  refusal text;
- §Docs-vs-binary: seven rows (D1 convergent request shape; D2 rewrap wording; D3 tamper
  detection; D4 cross-server portability; D5 the raise's rotate precondition; D6 the
  `min_decryption_version` default; D7 the `xchacha20-poly1305` page-to-page gap), plus a
  re-checked table of the scout's G1–G10 page gaps with the measured row that fills each, each
  page column a located quote (or an explicit locate `count=0` for the gap rows) and each binary
  column a receipt or the trial's code;
- §Bounds: signing/HMAC, key import/export/BYOK, the key-type matrix (only default
  `aes256-gcm96` exercised), stored-data re-encryption, `trim`, convergent internals, AAD/batch/
  `key_version`/nonce/auto-rotate/cache/request-size, one binary and one host;
- §Falsifiers: concrete break observations for each measured row, the clean-room leg, the shim
  set, the fail-closed leg, the prefix reading and the convergent reading;
- final line `SEAT-STATUS: complete` (seat marker; strip when landing).

The draft is 34432 B, sha256
`0a3b27a38cd8d17d65a8a9a9b369eed720a9ef96ff7acc00fa7ac1fac4ebe015`. No quote in it exceeds 25
words; all 65 double-quoted spans were re-located against the lane captures (0 unlocated, 0 over
25 words), and the two one-word spans are parameter names, not page sentences.

## Gates this seat could read and did read

- Page quotes: `python3 corpus/rendered-text-v1.py locate .ufo/waves/round-59/capture/S121.body|S122.body "<quote>"`
  for every quoted span in the draft → 0 failures; per-quote index at
  `.ufo/waves/round-59/build/R59ScribeEntry/quote-locations.md`.
- Captures: raw sha256 S121 `d8879a2a…7b0a19` (48604 B), S122 `ad1a47d3…8b657e` (267984 B);
  normalized digests `3f49303c…503b6` (14163 B) and `a1636fb2…93312` (62185 B). This seat's
  independent fetch of both URLs returned byte-identical bodies to the scout's captures
  (`cmp` equal), so the quotes sit on the lane's canonical capture.
- Receipts read (not re-run): `receipt-ref-real.txt` and `receipt-ref-real2.txt` are
  byte-identical (sha256 `097798f1…bf40a`) and both read
  `OPENBAO_TRANSIT_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2` with `rc=0`; the five shim
  receipts flip exactly their designated test; `receipt-none.txt` reads
  `OPENBAO_TRANSIT_TRIAL: SETUP no bao on PATH` with `rc=2` and no `TRIAL` line;
  `receipt-cleanroom.txt` shows a second server (distinct pid/port, own fresh storage) refusing
  the first server's ciphertext with `Code: 400. Errors:` / `* encryption key not found` and
  `CLEANROOM_DRIVER: PASS rc=0`.
- Secret discipline: scan of the eight receipt files and the draft for `hvs.`, `hvb.`, an
  `r59-<16+ hex>` marker and the word `root` → no match.
- Not run by this seat: the trial, the C1/C2 counters, any controls battery, any git/jj
  command. Verification beyond the quote/receipt reads is the L1's.

## Touched surfaces

| path | what |
|---|---|
| `.ufo/waves/round-59/build/R59ScribeEntry/openbao-transit-engine.md` | the entry draft |
| `.ufo/waves/round-59/build/R59ScribeEntry/notes.md` | seat notes: provenance, §Mechanics row → receipt-line map, findings F1–F11 |
| `.ufo/waves/round-59/build/R59ScribeEntry/quote-locations.md` | per-quote locate index |
| `.ufo/waves/round-59/build/R59ScribeEntry/capture/S121.body`, `S122.body` | byte-identical copies of the lane captures |
| `.ufo/waves/round-59/w1/R59ScribeEntry.md` | this report |

No `corpus/` file was written; no `plans/` file was written; no git/jj index was touched.

## Out of scope (not done, by design)

- Landing the entry at `corpus/knowledge/openbao-transit-engine.md`, appending S121/S122 to
  `corpus/SOURCES.md`, adding the stamps/ledger rows, committing or pushing: L1 only.
- Judging C1 or C2, running counters/controls, or mutating the trial: executors, reviewer,
  critic, mutation-tester and sentinel own those.
- Editing `plans/round-59.md`: frozen; defects and conflicts are routed below instead.

## Findings (routed to the L1, verbatim where a conflict)

- **F1 seat-count conflict**: this seat's assignment says "ONE v1 wave, 13 seats (run-15 band
  8-16)"; the frozen plan §Shape says 14 seats (with §A1's reason), and
  `.ufo/waves/round-59/w1.ready.dispatched` names 14 seats. No predicate, item, target, POP or
  kill rule changes; reported because the assignment text and the frozen plan disagree.
- **F2 unprinted measured constraint**: the trial header records that the API refuses
  `min_decryption_version > latest_version` (400), which is why T4 rotates first. No receipt line
  prints it; the draft's D5 names it as the trial author's record and keeps it out of §Mechanics.
  If C2's record should carry it, the trial needs a receipt line (L1 to route).
- **F3 T1 key is auto-created**: the trial never pre-creates `r59-t1`; the first encrypt upserts
  it with defaults. The draft records this only as a setup observation, not as a T-row (the
  frozen POP does not name upsert).
- **F4 ceiling wording**: the plan names `RSA/AES key types` unmeasured; the run uses only the
  default `aes256-gcm96` (no `type` passed). The draft states that precise reading and does not
  amend the plan.
- **F5 unresolved page default**: S122's config text says `min_decryption_version (int: 0)`
  while the read-key and decoded backup samples say 1; T4 reads the value only after setting it.
  Kept documented, not measured.
- **F6 page-vs-page key type**: S121's §Key types omits `xchacha20-poly1305`; S122 lists it
  (S121 locate → count=0, S122 → count=5, the AEAD sentence count=2). No binary test can
  arbitrate (one key type in the run).
- **F7 registry rows missing**: `corpus/SOURCES.md` holds 120 data rows; S121/S122 are not rows
  yet. The L1 must append both as `mined` with `used-by` naming the landed entry before the
  census/ledger gates read it.
- **F8 declaration row**: `Reverify: R21-02` is live now; a round-59 ledger row, if added, is a
  deliberate migration with a stamps row, not a silent rewrite.
- **F9 seat marker**: strip the draft's final `SEAT-STATUS: complete` line when landing it in
  `corpus/knowledge/`.
- **F10 clean-room counting**: the main run prints `TRIAL CLEANROOM HOLDS own-storage-refused=1`
  but `holds=5` counts T1–T5 only; a CLEANROOM BROKEN increments `broken`.
  `receipt-cleanroom.txt` is the separate driver transcript carrying the refusal error text.
- **F11 secret discipline**: verified clean (see Gates); the draft names no token, plaintext,
  context or ciphertext value.
- **F12 untracked corpus copy not written by this seat**: `corpus/knowledge/openbao-transit-engine.md`
  exists untracked (mtime 2026-11-07 14:04, 31869 B, sha256
  `f69c7259ff9f4f1617cfcdf378055456ef86449c80a1d02375bbc7c408e9b385`), an earlier snapshot of
  this draft plus a G1–G10 paragraph by its author, still carrying the `SEAT-STATUS` marker.
  This seat never wrote that path. Land from the final build draft (`0a3b27a3…`, 34432 B, now
  with the re-checked G1–G10 table) or reconcile deliberately; the untracked file was not
  edited or deleted here.

## Artifact paths

- `.ufo/waves/round-59/build/R59ScribeEntry/openbao-transit-engine.md`
- `.ufo/waves/round-59/build/R59ScribeEntry/notes.md`
- `.ufo/waves/round-59/build/R59ScribeEntry/quote-locations.md`
- `.ufo/waves/round-59/build/R59ScribeEntry/capture/S121.body`
- `.ufo/waves/round-59/build/R59ScribeEntry/capture/S122.body`
- `.ufo/waves/round-59/w1/R59ScribeEntry.md`

## Tooling

No tool installed or upgraded (no pacman, uv, npx, cargo, npm or binary download); only
`python3`, `curl`, `sha256sum`, `grep` and the lane's normalizer were used.

## Scratch

`/fast/scratch/hyaku/kagi-r59/R59ScribeEntry/` — deleted before this seat yields.

SEAT-STATUS: complete
