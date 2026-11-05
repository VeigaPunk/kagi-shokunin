# K45ExecISO — C2 ISO/IEC 11770-3 re-open and located-quote gate

Seat: K45ExecISO. Date: 2026-11-05. Lane: /home/vgpnk/Projects/shokunin/kagi-shokunin.

## Sources re-opened

Staged entries read READ-ONLY:
- `.../iso-11770-3-2015-supersession-chain-r39.md` cites S159.
- `.../iso-11770-3-catalogue-record-and-lifecycle-r41.md` cites S170, S171, S172, S173.

URLs from `SOURCES.append.md`:
| id | URL |
|----|-----|
| S159 | https://webstore.iec.ch/en/publication/62160 |
| S170 | https://web.archive.org/web/20260212133408id_/https://www.iso.org/standard/60237.html |
| S171 | https://webstore.iec.ch/en/publication/71650 |
| S172 | https://webstore.iec.ch/en/publication/107179 |
| S173 | https://webstore.iec.ch/en/publication/21094 |

## Fetch results (2026-11-05, curl -L --max-time 30, Mozilla UA)

| id | http | raw bytes | raw sha256 | txt bytes | txt sha256 |
|----|------|-----------|------------|-----------|------------|
| S159 | 200 | 430686 | 8bd6e9691fd9b294da1d4b295b39320913a66f33769bc2c197f74c18e6a91ab5 | 3603 | 1e67796bfd088dfeac679f4e2084b03bdb33eab7f268c7c33d19c7bae98c0ac5 |
| S170 | 000 (curl 28 timeout) | — | — | — (supplementary live body in S170.txt, see note) | — |
| S171 | 200 | 434303 | f3d4813a04497605b22d93bd9b05742f9cf6159be206df4e3bcb49a9010fef2f | 5681 | 1655a1c305cc9a3647c1ca4fc52ace3202b03bbfd4221b590ef7e53c537b4856 |
| S172 | 200 | 429695 | 1079585f82f3536c8401f9c7a85657d540535db29f777de316c11550ac21696b | 3459 | 52da1a57ab31288a90894ff4da3fdf174b543a584ffa92a0d8879a7f34bba995 |
| S173 | 200 | 432311 | 34a9a4a34122134d86dffb42d4122646061091e8b686304540d1d9fabbd998f3 | 3591 | de71cedeeb6ece36668938282017dae99725396ef56e9a7b9a2459ff75ca433e |

Attempts for S170: three curl attempts to the archive URL (id_ + rewritten + http variants) all timed out after 30001 ms, http 000, no bytes. One `read` via the URL reader also timed out. No body was invented for S170.

Supplementary (not counted as S170 success): live `https://www.iso.org/standard/60237.html` fetched 2026-11-05 with a browser UA, http 200, 85615 bytes, sha256 2e4c1524ec05865536f819db68c56494d97fc67cb490df4f5d4b1ca85b7b0c80, saved as `captures/S170-live.raw`; its tag-stripped text (7468 bytes, sha256 961e018fe703c529741203afb2845ddad6a956a05ae438e6fdd02950b6d32195) is `captures/S170.txt`. The staged entry's own premise that the live page is Cloudflare-blocked no longer holds at this IP — the record is live. S170 archive quotes were located against this live body; the archive body itself remains unfetched.

## Located quotes

Quotes = double-quoted spans ≤25 words in the staged entries' cite lines, attributed to the cited id, searched verbatim after whitespace normalisation. Result file: `located-quotes.tsv`.

| id | quote | located | offset |
|----|-------|---------|--------|
| S159 | ISO/IEC 11770-3:2015/AMD1:2017 \| IEC | yes | 0 |
| S159 | A more recent version of this publication exists: ISO/IEC 11770-3:2021/AMD1:2025 | yes | 1825 |
| S170 | Withdrawal of International Standard | yes | 3418 |
| S170 | New version available: ISO/IEC 11770-3:2021 | yes | 1247 |
| S170 | does not cover certain aspects of key management, such as key lifecycle management, mechanisms to generate or validate asymmetric key pairs | yes | 2534 |

5/5 quotes located. 4/5 fetches succeeded; S170 archive fetch failed (recorded as failed with error text, not counted as success).

## Key field confirmations (from .txt bodies)

- S159 page: `Withdrawal date2021-10-22`, `Publication date2017-11-28`, `Edition3.0`, title block `ISO/IEC 11770-3:2015/AMD1:2017 Information technology - Security techniques - Key management - Part 3: Mechanisms using asymmetric techniques - Amendment 1: Blinded Diffie-Hellman key agreement` — matches the r39 entry.
- S171 page: `Publication date2021-10-22`, `Edition4.0`, `ICS 35.030`, `Pages90` — matches r41.
- S172 page: `Publication date2025-04-28`, `Edition4.0`, `Pages2` — matches r41 (amended once).
- S173 page: `Publication date1999-11-11`, `Edition1.0`, `Withdrawal date2008-07-02` — matches r41.
- S170 live page: status `Withdrawn (Edition 3, 2015)`, `New version available: ISO/IEC 11770-3:2021`, abstract exclusion verbatim — matches r41.

## Files written

- `captures/S159.raw/.txt`, `captures/S171.raw/.txt`, `captures/S172.raw/.txt`, `captures/S173.raw/.txt`
- `captures/S170-live.raw`, `captures/S170.txt` (supplementary live ISO body)
- `captures/fetch-log.tsv` (id, url, access_date, http_status, raw_bytes, raw_sha256, txt_bytes, txt_sha256, error)
- `located-quotes.tsv` (id, quote, located, offset, body_file)

No registry row, knowledge file, or lane file was written. No git/jj mutating command was run. No packages were installed (pacman untouched; no new tools needed).

## Risks / notes

- S170 archive host (web.archive.org) timed out repeatedly at this egress; the live ISO page now returns 200. If the gate requires the archive snapshot body specifically, it remains unlocated — the located S170 quotes are against the live page body.
- IEC webstore pages render via JS-heavy chrome; tag-stripped text contains nav boilerplate but product-detail fields are fully present and quote-identical.
- Offsets are into the whitespace-normalised `captures/*.txt` text.
