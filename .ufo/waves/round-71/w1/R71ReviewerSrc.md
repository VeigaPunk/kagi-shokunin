Author: R71ReviewerSrc (reviewer — non-author source spot-check)

# Round-71 source spot-check (registry delta): S173 admit, S170 used-by, entry quotes

Date: 2026-11-08. All reads absolute from /home/vgpnk/Projects/shokunin/kagi-shokunin.
Evidence: `.ufo/waves/round-71/w1/R71ReviewerSrc/receipts/` (copies cited by name below;
scratch copies were removed — only the wave-dir copies are citable).

## Live re-open

Both pages re-opened live with `curl -fsSL --compressed` and a browser user agent
(`Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 … Chrome/126.0`), into scratch, then
copied to `receipts/S173.live.body`, `receipts/S170.live.body`, headers beside them.

- S173 https://openbao.org/docs/secrets/pki/considerations/ → HTTP/2 200, decoded body
  96207 B, sha256 `42ef7582befb1d609c93fdefa9669af362b9b5c1ee5a64e3cea9b54b0905047a`.
  Committed capture `.ufo/waves/round-71/capture/S173.body` (96207 B) is byte-identical
  (same sha256) to the live body, and to the round-70 scout capture
  `.ufo/waves/round-70/w1/R70Scout/capture/S173-openbao-pki-considerations.body`
  (sha256 `42ef7582…5047a`, verified by sha256sum). `rendered-text-v1 digest` on the
  committed body: raw `42ef7582…5047a`, normalized `b0c82c39c53f296c4290888e5d9aa41…`
  38323 B — matches the S173 registry row and the source-fetches.tsv S173 row exactly.
- S170 https://openbao.org/docs/api/secret/pki/ → HTTP/2 200, decoded body 620683 B,
  sha256 `9fa7693967f32958aff9c96faf5835afa4d72894727a8d63c324e9145e5c1123`,
  byte-identical to the committed round-71 capture `S170.body` and to the round-70
  capture. `rendered-text-v1 digest`: raw `9fa76939…1123`, normalized
  `0419f2a3d02027386efc54a746e4ba7df502afbda6ab512802e111ff766eae93` 164032 B —
  matches the S170 registry row and the source-fetches.tsv S170 row exactly.
- Committed fetch receipts: `S173.fetch.txt` reads
  `http=200 size=22703 url=…/considerations/ / 2026-11-09T02:43:09Z / 42ef7582…  S173.body`;
  `S170.fetch.txt` reads only `http=200 size=68891`. Both `size=` values are the
  compressed transfer sizes (curl -w %{size_download} on the wire), not the decoded body
  sizes (96207/620683). That is consistent with a `--compressed` fetch receipt but the
  two receipts use different shapes (S173 carries the body sha256 in-file, S170 does
  not); neither is wrong, and both bodies verify independently against the registry
  rows by digest above.

`source-fetches.tsv`: S173 row is status `mined`, URL
`https://openbao.org/docs/secrets/pki/considerations/`, HTTP 200,
`curl-fsSL-compressed-v1`, `decoded-http-body-v1`, body sha256 `42ef7582…` (96207 B),
quote cell = the S173 registry verbatim quote, normalizer `rendered-text-v1`, normalized
sha256 `b0c82c39…`, capture path `.ufo/waves/round-71/capture/S173.body`. All 16 cells
present and consistent with the registry row and the live re-open.

## S173 registry row

`corpus/SOURCES.md` line 173: 11 cells, kind `docs`, tier A, status `mined`,
opened `2026-11-08`, recheck `180d`, used-by
`corpus/knowledge/openbao-pki-issuer-revocation-channels.md`. Anchor: `§Always configure
a default issuer` — that H2 exists in the committed body (verified by rendered-text
search). `teaches` carries the verbatim quote “For backwards compatibility, the default
issuer is used to service PKI endpoints without an explicit issuer (either via path
selection or role-based selection).” (23 words, ≤25) separated from the paraphrase
(“revocations of an issuer that left the mount go to the default CRL”), per QM42.

The quote was located against the committed body with the pinned tool:
`python3 corpus/rendered-text-v1.py locate .ufo/waves/round-71/capture/S173.body
'<quote>'` → `RENDERED_TEXT_V1_LOCATE: count=1`, rc 0. Registry S170 quote likewise:
`'if it is internal the private key will not be returned and cannot be retrieved
later'` → count=2 (16 words, ≤25).

## S170 used-by change

At BASE `e0e9603a` the S170 `used-by` cell reads only
`corpus/knowledge/openbao-pki-certificate-lifecycle.md`; at the candidate it reads that
plus `corpus/knowledge/openbao-pki-issuer-revocation-channels.md` (recheck unchanged at
`180d`). This matches the SOURCES.md rule that the registry's `used-by` must name the
entry that cites the row — the new entry's `source:` line names S170 and S173, and both
rows list it. No other S170 cell changed (quote, anchors, capture references all
identical).

## Entry quotes — Why section

All located in the committed bodies (`rendered-text-v1 locate`, receipt
`receipts/locate-evidence.txt`):

| entry quote | source | count | words |
|---|---|---|---|
| For backwards compatibility, the default issuer is used to service PKI endpoints without an explicit issuer (either via path selection or role-based selection) | S173 | 1 | 23 |
| Behavior of a leaf's NotAfter field during issuance | S170 | 1 | 8 |
| are unauthenticated endpoints | S170 | 5 (5 occurrences page-wide; the OCSP section's own occurrence confirmed in rendered-text context) | 3 |
| cannot be enumerated or revoked via serial number | S170 | 1 | 8 |
| Certificates may still be revoked via BYOC revocation | S170 | 1 | 8 |

Every §anchor the entry `source:` line names for S170 (Update issuer, Set revocation
configuration, OCSP request, Revoke certificate with private key, Create/Update role)
was found in the S170 body rendered text.

## Entry quotes — table column 4

All quoted fragments located (same tool, receipt above):

| entry quote | source | count | words |
|---|---|---|---|
| Not all values result in leaf certificates that can be validated through the entire validity period | S170 | 1 | 16 |
| does not update only the provided fields | S170 | 3 | 7 |
| Note that bao write uses POST | S170 | 2 | 6 |
| the OCSP responder will always respond with an Unauthorized OCSP response | S170 | 1 | 11 |
| Only a single serial number within the request will appear in the response (Does-not-establish) | S170 | 1 | 13 |
| When certificates are revoked and their issuer is no longer part of this PKI mount, OpenBao places them on the default issuer's CRL (the doc sentence the entry paraphrases as “S173 sends revocations to the default CRL only when the issuer has left the mount”) | S173 | 1 | 22 (doc sentence) |

Consequence-cell audit (one cell per table row, col 4):
- “issuer NotAfter policy”: S170-quoted (“Not all values…”) — sourced. The leading
  clause (“under `permit` a leaf outlives its issuer”) is the direct doc statement
  (“permit to allow this issuance to succeed with a NotAfter value exceeding that of
  this issuer”) paraphrased without an [INFERENCE] mark — fair paraphrase of a
  same-section sentence, not an unsourced inference.
- “updating one issuer field”: S170-quoted ×2 plus an `observed` error string
  (`unable to find PKI issuer for reference`) which is marked `observed` and, correctly,
  is not an S170 quote (locate of that string in S170 = count 0). Sourced + observed.
- “which CRL a revocation lands on”: explicit [INFERENCE] on the client-visible claim;
  the S173 half is the paraphrase verified above.
- “OCSP responder”: S170-quoted (“the OCSP responder will always…”) plus the unmarked
  clause “anyone can query status, which is the point of the channel”. That clause is
  NOT a located quote (locate count 0 in S170) and carries no [INFERENCE] marker. It is
  a gloss on the STATED doc fact (the endpoints are unauthenticated, located count 5)
  rather than a new domain claim, but by the entry's own stated rule (“is documentation
  (S170/S173) or the lane's own inference, marked as such”) it should have been marked.
  See SR-2.
- “revoking a no_store leaf”: explicit [INFERENCE]. Sourced-or-marked.

## S173 admit judgment

Admit — sound. Tier A is right: the page is the official OpenBao 2.7.x PKI docs
(`docs-version-2.7.x` class on the page), a primary vendor source carrying the
multi-issuer/default-CRL mechanism the entry measures, with an H2 anchor, a verbatim
quote separated from paraphrase (QM42), 11 cells, `mined`, `180d`, opened 2026-11-08,
and byte-identity to both today's live page and the round-70 scout capture. QA1 (tier-A
row for this scope + anchor), QA2 (release status in `knowledge/` scope line and the
source anchors), QA6 (located quote) all hold. The plan's frontier note flags the
byte-identity to the round-70 scout capture — noted, not a defect: two independent
fetches of the same page byte-agree, which is the strongest form of the recheck.

## rotation-primitives — admit or reject?

Opened live (receipt `receipts/rotation-primitives.live.body`, headers beside it):
HTTP/2 200, 64986 B, sha256 `406c85ecc8bab721796d791035341ee2acb7752ce450edacd62e0b2517671d2e`,
`docs-version-2.7.x`, normalized `f38a88a4…` 23514 B. The URL is NOT in SOURCES.md and NOT
in source-fetches.tsv. A located quote (rendered-text-v1, count=1, 22 words):

“By using the certificate types below, rotation can be accomplished in various
situations involving both root and intermediate CAs managed by OpenBao.”

Judgment: **would admit as tier A** for the scope “OpenBao PKI CA rotation primitives
(cross-signing, intermediate rotation)”, and it would be genuine mechanism authority
for a follow-on entry. But it is NOT admissible for THIS entry: the round-71 claim is
the issuer/NotAfter/CRL/OCSP/revoke-with-key mechanics (T6–T9), none of which this page
certifies; the entry already states intermediate CA / cross-signing behaviour is
explicitly out of scope under “Does not establish”. There is no gap in the landed entry
that this page fills. Admit later for a rotation entry (e.g. “By using the certificate
types below, rotation can be accomplished in various situations involving both root and
intermediate CAs managed by OpenBao.” + X.509-field sections), with its own capture row
in source-fetches.tsv — exactly as S173 was admitted this round. Do not add it to this
entry.

## Census runs (stdout/stderr/rc saved separately in receipts/)

- `bash corpus/sources-census.sh` → stdout `SOURCES_CAPTURES: CLEAN (path_rows=44
  bound=44 located=44 prose=120)` / `SOURCES_CENSUS: CLEAN (rows=164 A=146 B=2 C=16
  queued=3 mined=142 rejected=19 entries_sourced=30 legacy=21 captures=164
  inrow=16 inrow_only=0 inrow_nonreproducing=12)`, stderr empty, rc 0.
- `/home/vgpnk/Projects/shokunin/scripts/sources-census.sh validate --root
  /home/vgpnk/Projects/shokunin kagi` → 27× W04 duplicate-url warnings (incl.
  `kagi W04 S170 duplicate url openbao.org/docs/api/secret/pki across scopes`) + final
  `kagi ok …/corpus/SOURCES.md`, stderr empty, rc 0. (W04 warnings are pre-existing
  cross-scope duplicates; the validator exits 0 and prints `kagi ok`.)

## Checks against QUALITY.md

- QA1/QA6/QM39/QM42 pass: tier-A rows, located quotes (count ≥1, ≤25 words), verbatim /
  paraphrase separation, stamp row for the entry (`corpus/knowledge/openbao-pki-issuer-
  revocation-channels.md 6cf12542… 76 9116`, verified sha256/lines/bytes match the file).
- The `observed` issuer-name reset error string is correctly NOT presented as an S170
  quote (it does not locate in S170) — QM42-clean.
- Stamps: the new trial script `corpus/openbao-pki-issuer-trial.sh` has NO row in
  `corpus/stamps.tsv`, while the round-70 sibling `corpus/openbao-pki-trial.sh` does
  (line 175, present at BASE and now). QM5 requires an artifact to land with its stamp
  and claim row in the same commit. This is the one structural gap in the delta. See
  SR-1.

## Residual risk / verification gaps

- Live re-open proves today's bytes equal the captures; it does not prove the L1
  fetch-time bytes (same-uid ceiling the plan already names). The round-70 scout
  byte-identity for S173 closes most of this for S173; S170's round-70 → round-71
  byte-identity likewise anchors both.
- I did not run the frozen counter (`plans/round-71-c1.sh`) or the trial; this seat is
  the source spot-check only. The count claim (value=4) is out of my scope.
- The `are unauthenticated endpoints` entry quote has count=5 page-wide; I confirmed
  the OCSP-section occurrence in rendered-text context, but the locate count alone does
  not disambiguate among the 5 occurrences — the H2 anchor does.

FINDING SR-1 falsifies-wording missing stamp row for corpus/openbao-pki-issuer-trial.sh (QM5; round-70 sibling openbao-pki-trial.sh is stamped) — land it or document the exemption
FINDING SR-2 falsifies-wording OCSP consequence clause “anyone can query status, which is the point of the channel” is an unmarked inference (locate count 0) against the entry's own sourced-or-marked rule
FINDING SR-3 neutral S173/S170 fetch receipts' size= fields are compressed transfer sizes, not decoded body sizes (96207/620683); bodies verify by digest regardless — no action, note for future receipts
SEAT-STATUS: complete source spot-check done; S173 admit endorsed, rotation-primitives ruled defer-to-rotation-entry
