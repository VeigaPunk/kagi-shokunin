# FRecapS016 — C2 source recapture

Frozen revision: `c5ef9e92201b6c36396301f12b23740565bf86a0`; original BASE: `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`.
Axes: operability, freshness, calibration. Bounds: S016 only, its named registry/capture/classification/receipt, the C2 plan, and the declared normalizer; one public URL reopened. No population-wide claim.
Result: PASS for S016 metadata, quote, and reproduction of the declared round-24 capture; FAIL (low-severity interpretation overclaim) in the build receipt; UNKNOWN for the original legacy pin's representation/validity.

## Observed evidence
- `corpus/SOURCES.md:22` records `https://openbao.org/docs/concepts/tokens/`, status `mined`, historical date `2026-10-19`, pin `c083fdca8645f6248a3c42a8c0b912b356de281dc2da0099668a7850ba348380`.
- `corpus/source-fetches.tsv:69` records a `2026-10-21` HTTP-200 capture, `decoded-http-body-volatile-v1`, normalization `rendered-text-v1`, 47,384 decoded bytes, raw `5229521866ce21fa8cd8f8ecf63d696877b8cb0a2ec25e89de683557b385f82c`, normalized `ed949658b434fa769b89c682160f77ad153f5c6657808706db5858506ce0d2e3`.
- `corpus/inrow-pins.tsv:22` copies the registry pin and capture date exactly. Its `non-reproducing` verdict is correct: that pin equals neither recorded digest; it is neither `reproduces-raw` nor `reproduces-normalized`.
- Row identity recomputation yielded `0162a916441e5f602393cb312cb4d1b16cdf4b91672a323660b3c02879b5ac2b`, matching the capture row's binding of id/status/URL.
- The fresh fetch reproduced BOTH recorded capture digests and byte count, not merely metadata consistency. This independently reproduces the declared round-24 representation; it does not reproduce or invalidate the original 2026-10-19 pin.
- Fresh body `S016-current.html:77-85` places the quote under `Token hierarchies and orphan tokens`, with the orphan-token qualification immediately following. Lines 124-134 support TTL/renewal scope; line 4 declares Version 2.7.x.
- The registered quote occurs once under the declared normalizer: “When a parent token is revoked, all of its child tokens -- and all of their leases -- are revoked as well.” See public source: https://openbao.org/docs/concepts/tokens/ .
- `corpus/rendered-text-v1.py:61-79,95-117` defines the transform and its digest/locate callers. `xd://lsp` returned `No such tool`; no LSP server route is available. Definition/caller inspection used literal source search/read only, not semantic-reference proof.

## Falsifier and interpretation
- FAIL, low severity, high confidence: `.ufo/waves/round-24/build/RecapS016.md:37` concludes “The legacy digest pin is stale despite the recorded scope/teaches remaining supported.” Its preceding experiment establishes only inequality with two declared representations. Because the legacy representation is undocumented, that does not establish content drift or that the original capture was false. This exceeds `corpus/inrow-pins.tsv:5-6`, which explicitly says non-reproduction is not evidence the page changed.
- No undocumented representation is explicitly called current in the named records: `source-fetches.tsv:17-23,37-43` declares the current capture domain and labels legacy pins historical/undocumented; `SOURCES.md:32` (S026) specifies rendered-text-v1 and the current decoded-body digest. The unsupported “stale” sentence is an interpretation defect, not a wrong S016 classification or a reproduced current-capture failure.
- UNKNOWN: the original pin's input bytes and transformation are not provided by the named evidence. Matching today's capture to the round-24 digests cannot resolve that gap. No later page drift was observed or used as a falsifier.

## Bounded commands and receipts
Sandbox: `/fast/scratch/kagi-r24-recovery/FRecapS016-9` (called S below; notation only).
Every executed process used `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r24-recovery/FRecapS016-9/.empty-home`; HOME was isolated (initially absent, then created empty). No host gate, host configuration, credentials, or production execution.
Setup, cwd `/fast/scratch`: `git clone --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin /fast/scratch/kagi-r24-recovery/FRecapS016-9`; then `mkdir -m 700 /fast/scratch/kagi-r24-recovery/FRecapS016-9/.empty-home`; then `git -C /fast/scratch/kagi-r24-recovery/FRecapS016-9 checkout --detach c5ef9e92201b6c36396301f12b23740565bf86a0`.
Setup exit 0; git reported `done.` and `HEAD is now at c5ef9e9 round-24: late seat report IdentR1605 (BASE survival, matches C3 before)`.
All remaining command bodies ran with cwd S and the same environment prefix:
```sh
curl -fsSL --compressed --max-time 30 -A 'kagi-shokunin-round23/1.0 (documentation verification)' 'https://openbao.org/docs/concepts/tokens/' -o /fast/scratch/kagi-r24-recovery/FRecapS016-9/S016-current.html -w 'S016_REOPEN: final_url=%{url_effective} http_status=%{http_code}\n'
```
Exit 0; stdout: `S016_REOPEN: final_url=https://openbao.org/docs/concepts/tokens/ http_status=200`.
```sh
python3 corpus/rendered-text-v1.py digest S016-current.html
```
Exit 0; stdout: `RENDERED_TEXT_V1: raw_sha256=5229521866ce21fa8cd8f8ecf63d696877b8cb0a2ec25e89de683557b385f82c bytes=47384 normalized_sha256=ed949658b434fa769b89c682160f77ad153f5c6657808706db5858506ce0d2e3 normalized_bytes=14608`.
```sh
python3 corpus/rendered-text-v1.py locate S016-current.html 'When a parent token is revoked, all of its child tokens -- and all of their leases -- are revoked as well.'
```
Exit 0; stdout: `RENDERED_TEXT_V1_LOCATE: count=1`.
Identity pipeline (same environment prefix on BOTH processes): `printf 'S016\tmined\thttps://openbao.org/docs/concepts/tokens/\n' | sha256sum`.
Exit 0; stdout: `0162a916441e5f602393cb312cb4d1b16cdf4b91672a323660b3c02879b5ac2b  -`.
No full harness/census, unrelated rows, or C1/C3 gates exercised. No installs or upgrades. Production files unchanged; only this assigned report written in the lane.
