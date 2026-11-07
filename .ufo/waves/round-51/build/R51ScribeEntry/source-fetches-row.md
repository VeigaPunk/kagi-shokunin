# S108 source-fetches.tsv row — draft (16 columns) and how each value was obtained

Row file: `source-fetches-row.tsv` (one line, 16 tab-separated fields, no comment — append-ready).

| # | column | value | how obtained |
|---|---|---|---|
| 1 | id | `S108` | next free id (registry at BASE ends at S107). |
| 2 | status | `mined` | must equal the registry row's status (`corpus/sources-census.sh` SC_FETCH). |
| 3 | row_identity_sha256 | `b7ed6ba7eed103207e3745a3b954a847b69476276bab94f3d3f05f84aede270f` | **computed**: `printf 'S108\tmined\thttps://openbao.org/docs/concepts/response-wrapping/\n' \| sha256sum` → `b7ed6ba7…aede270f` (the header's rule: sha256 of `id<TAB>status<TAB>url<LF>`). |
| 4 | url | `https://openbao.org/docs/concepts/response-wrapping/` | exact string from the registry row's source cell. |
| 5 | final_url | same | `curl -w '%{url_effective}'` → no redirect (receipt `receipts/s108-refetch.txt`). |
| 6 | http_status | `200` | same curl run (`%{http_code}`). |
| 7 | request_profile | `curl-fsSL-compressed-v1` | the declared profile, used verbatim. |
| 8 | fetched | `2026-11-07` | UTC date of the capture (`capture/S108.body` mtime 2026-11-06T21:23 -03 = 2026-11-07T00:23Z); the seat's own re-fetch ran 2026-11-07T00:33Z. |
| 9 | representation | `decoded-http-body-volatile-v1` | see the finding below. |
| 10 | sha256 | `a555301e8f61a407130515449309b05c4e2c7a936f8f1bdf1921e2f9cc32ed55` | `sha256sum .ufo/waves/round-51/capture/S108.body`. |
| 11 | bytes | `37186` | `stat -c %s` on the same file (and on the live re-fetch: identical). |
| 12 | revision | `-` | not a moving-ref URL (`raw.githubusercontent.com` / `*/main*`); the page's edit link points at `release/2.7.x`, not at a commit. |
| 13 | quote | `only a single party can ever unwrap the token and see what's inside` | located count=1 (`receipts/quote-locations.txt`); 13 words (`printf '%s' "$q" \| wc -w`), inside the ≤25-word shape. |
| 14 | normalization | `rendered-text-v1` | the one declared normalizer. |
| 15 | normalized_sha256 | `133496495ea72d2ac1fa7e1a8f04661beb2aa0df5e6b16e917f9e93432f4868a` | **computed**: `python3 corpus/rendered-text-v1.py digest .ufo/waves/round-51/capture/S108.body` → `RENDERED_TEXT_V1: raw_sha256=a555301e… bytes=37186 normalized_sha256=133496…4868a normalized_bytes=10424`. |
| 16 | location | `§Overview, malfeasance-detection bullet; OpenBao docs Version 2.7.x` | offsets: the quote sits at normalized char 2805, inside §Overview `[914, 3360)`; §Response-Wrapping tokens starts at 3360 (`receipts/section-attribution.txt`). |

## Finding F2 — the working-tree row's `location` names the wrong section

The row currently in the working tree ends `§Response-Wrapping tokens overview (malfeasance detection paragraph); OpenBao docs Version 2.7.x`. The quote is **not** in §Response-Wrapping tokens: `rendered-text-v1` puts it at char 2805, while the `Response-Wrapping tokens` heading starts at 3360 — it is in **§Overview**, bullet 2 ("It provides *malfeasance detection*…"). The draft above fixes the cell. No gate reads the location's meaning (the census only checks `length >= 8`), so this is a correctness fix for a human reader, not a green/red change.

## Finding F3 — representation class

All eight other `openbao.org` rows in `corpus/source-fetches.tsv` (S014, S015, S016, S021, S025, S026, S105) declare `decoded-http-body-volatile-v1`; the working-tree S108 row declares the stronger `decoded-http-body-v1`. Docusaurus HTML is deployment-coupled (content-hashed chunk filenames), and the only stability evidence this seat holds is a re-fetch **ten minutes** after the capture (byte-identical, same deployment) — which does not support the non-volatile class. Draft uses `volatile`. Either class passes the census (both are in the SC_FETCH enum; no cross-capture equality is enforced), so this is an evidence-class correction, not a gate change.
