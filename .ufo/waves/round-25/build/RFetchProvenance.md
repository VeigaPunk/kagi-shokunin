# RFetchProvenance: C3 fetch conventions and feed-row capture procedure (round 25)

Seat KagiR25.RFetchProvenance-2. BASE 4587c61a348e4528717404a68912c373f3ef4d03; live HEAD is 4587c61a (`git rev-parse HEAD`). The BASE clone's `corpus/source-fetches.tsv` has sha256 prefix 2e21e649, matching the stamp at `corpus/stamps.tsv:72`. Measured 2026-10-21 10:30-10:50Z in `/fast/scratch/kagi-r25/KagiR25.RFetchProvenance-2` (BASE clone and `ov-*` overlays only; the lane was read, never written). Tools: none installed or updated (curl 8.23.0, Python 3.14.8, coreutils).

## 1. Conventions and round-24 capture (file:line)
- 16 TAB columns: id, status, row_identity_sha256, url, final_url, http_status, request_profile, fetched, representation, sha256, bytes, revision, quote, normalization, normalized_sha256, location. Header `corpus/source-fetches.tsv:1-43`; round-24 rows S027-S032 at `:70-75`.
- Profile `curl-fsSL-compressed-v1` is one command: `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' <url>` (`:14-15`). Representations `:17-23`; quote shape-only, at most 25 words (`:27-30`); normalization `rendered-text-v1` (declared only in `corpus/rendered-text-v1.py:10-43`) or `raw-literal-v1` (`:31-34`); digests are point attestations, never pins (`:37-38`).
- Row identity = `printf 'id\tstatus\turl\n' | sha256sum` (`sources-census.sh:262`). Reproduced: S027 `211042525346...` (= `:70`), S032 `4fb68760311f...` (= `:75`).
- Round-24 Gate (`corpus/lessons/round-24.md:40-43`, table `:47-51`): the declared curl line, then `python3 corpus/rendered-text-v1.py digest <body>` and `locate <body> '<quote>'`. S032 receipt (`.ufo/waves/round-24/recovery-source-S032.json:2-41`): digest prints `RENDERED_TEXT_V1: raw_sha256=67f690e2... bytes=1199447 normalized_sha256=f3861c17... normalized_bytes=6049` (`:29`); locate prints `RENDERED_TEXT_V1_LOCATE: count=2` (`:41`). S027-S031 have only prose reports (`.ufo/waves/round-24/build/Src*.md`, `falsify/FSource*.md`), no capture receipt.
- Round 24 labelled all six S027-S032 volatile (`:70-75`). Volatility was measured on one row only: S020 (`corpus/lessons/round-23.md:45-54`).
- Census SC_FETCH (`sources-census.sh:236-287`) checks shape only. Profile must equal v1 (`:266`). http_status may be any 3-digit code (`:265`). Moving-ref revision is required only for `raw.githubusercontent`, `/main/` and `/main` (`:274-276`). Quote is word-counted only (`:277-278`). It never fetches a body or locates a quote.

## 2. Same-day measurements (two GETs each, declared UA; committed = TSV)
| id | committed raw / norm | today raw / norm | locate | verdict |
|---|---|---|---|---|
| S027 | d85d77e3 / 37cd15c2 | 453e9e17 x2 / bcee6611 | 1 | drifted |
| S028 | b4594556 / 7a19837f | cd1a74e6 x2 / 279f549c | 1 | drifted |
| S029 | 9d2b36d0 / fb3a4889 | identical x2 | 1 | reproduces |
| S031 | 04b65bf0 / f8974683 | identical x2 | 1 | reproduces |
| S032 | 67f690e2 / f3861c17 | identical x2 | 2 | reproduces |
- Bytes equal in every row. S027 with the round-25 UA gives 453e9e17, identical to the round-23 UA.
- S027 and S028 normalized text keeps the visible stamp `Last updated on Oct 21, 2026 (07:27 UTC)`, so normalized digests move with the docs build. [INFERENCE: the committed bodies predate the 07:27 build; they were not stored.]
- GitHub release HTML (`releases/latest`, final `/releases/tag/v3.13.3`): raw differed on all 4 GETs (a1622acc, 2f840029, 0294fdac, c106bb5d); normalized was 8bc419cae0ca5c77 on the 3 GETs printed. This is the S020 pattern.
- Atom `releases.atom`: raw 47a224ad x3. HashiCorp `vault/index.json` (2,691,686 B): raw 85a2c038 x3. S008-S011 (v1 labelled): raw and normalized identical to committed.

## 3. GitHub releases API JSON: which representation applies
- Live API UNRUN: `HTTP/2 403`, `x-ratelimit-limit: 60`, `x-ratelimit-remaining: 0`, reset `1792581901` = 2026-10-21T11:25:01Z; still 403 at 10:43:11Z. Unauthenticated access is unusable from this host, and auth is forbidden. The 403 body is compact JSON (no spaces after colons).
- Answer: digest domain is the decoded body. Label `decoded-http-body-volatile-v1`, because release assets carry `download_count` (docs.github.com/en/rest/releases/releases, page sha256 prefix 1ed00b47: `download_count&quot;: 42`), which moves with no release. `latest` is "the most recent non-prerelease, non-draft release" (same page): a moving pointer that excludes prereleases.
- Normalization `raw-literal-v1`, normalized `-`. `rendered-text-v1` is an HTML-to-text step. On the Atom feed (XML) it changes 253,037 to 199,559 normalized bytes; the tag-bearing quote `<title>v3.13.3</title>` locates 1x raw and 0x rendered.
- Quote = byte-exact fragment with count 1. The success-body format is UNVERIFIED; L1 must locate it on a live body.

## 4. Procedure for new feed rows (tested)
Candidate script `/fast/scratch/kagi-r25/KagiR25.RFetchProvenance-2/capture-feed.sh` (sha256 c45b41cb...3178, 2518 B; sandbox file, not a lane file). Run from a clean clone at the candidate revision:
1. Representation: two GETs, `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' -o b$i -w '%{url_effective} %{http_code}\n' "$URL"`, then `sha256sum b$i`.
2. Row: `env -i PATH=/usr/bin:/bin HOME=$SB/home bash capture-feed.sh SID queued "$URL" "$REP" "$NORM" "$QUOTE" "$LOC" >> row.tsv` (`queued` for a probe; `mined` only after step 3). It refuses on curl >= 400 (exit 22), a content-type/normalization mismatch, a quote over 25 words, and locate count 0.
3. Registry row (11 cells) in `corpus/SOURCES.md`. A `mined` row needs a used-by lesson or knowledge file whose `source:` line cites the id (`sources-census.sh:221-233`).
4. `bash corpus/sources-census.sh` must print `SOURCES_CENSUS: CLEAN (... captures=N ...)` with exit 0.
Observed: Atom, raw-literal: `RAW_LITERAL_LOCATE: count=1`, exit 0. Atom with rendered-text-v1: `REFUSE content-type=application/atom+xml; charset=utf-8 requires raw-literal-v1`, exit 1. GitHub HTML: `RENDERED_TEXT_V1_LOCATE: count=25`, exit 0. HashiCorp JSON: count=1, exit 0. API: `FETCH_FAILED curl_exit=22 ... 403`, exit 1.
Census on overlays: BASE `SOURCES_CENSUS: CLEAN (rows=32 ... captures=32 ...)` exit 0; BASE plus the three procedure rows S033-S035 `CLEAN (rows=35 ... captures=35 ...)` exit 0.
Rules. REP: `volatile` for HTML with a build stamp, a per-response token or a counter (S020, S027/S028, GitHub HTML; API JSON by schema). `v1` is allowed only when two GETs agree and a later same-day GET agrees (measured: S008-S011, Atom, HashiCorp index; the T1 row used volatile, the conservative choice). NORM: `rendered-text-v1` iff content-type contains `html`, else `raw-literal-v1`. Freshness clock: re-run `locate` on the stored quote against a fresh fetch; count 0, or a changed final_url, means fired. Digests are same-day attestations, never pins.

## 5. Findings
- F1 calibration, medium: S027/S028 no longer reproduce. The round-24 falsifier printed raw 453e9e17 and norm bcee6611 (`.ufo/waves/round-24/falsify/FSourceS027.md:19,24`) and did not compare them with TSV `:70`. Quotes still locate. Re-capture as dated observations; do not edit history.
- F2 operability, medium: the round-25 UA cannot be declared under v1. An overlay with `curl-fsSL-compressed-v2` gives `FINDING SC_FETCH id=S033 request-profile`, exit 1. Bytes do not depend on the UA. Decision for L1: keep the round-23 string for new rows.
- F3 calibration, high: the census accepts a 403 body as provenance (overlay: CLEAN, captures=33). Fix: require `http_status == 200` at `:265`.
- F4 calibration, medium: the census never checks a quote against its body (quote-absent overlay: CLEAN). Only `locate` checks it, and round-24's "count 1 each" was never machine-checked.
- F5 calibration, medium: `releases/latest` with revision `-` passes (overlay: CLEAN). `:274-276` flags only raw and `/main` URLs.
- F6 calibration, medium: normalization is not bound to content type (Atom under rendered-text-v1: CLEAN). The script refuses it.
- F7 operability, high: `api.github.com` is unusable for fleet captures (unauthenticated 60/h quota, 0 remaining). Feed clocks must use github.com Atom or HTML, or a non-GitHub JSON index.
- F8 documentation, low: `volatile` is defined only for HTML deployment or response coupling (`:19-23`). Add counter and data coupling.
- F9 evidence, low: S027-S031 have no capture receipt, so their committed digests can only be re-tested by re-fetching.
- Census edits (F3-F6) are lane-owner changes; this seat made none.

## 6. Bounds
UNRUN: the live GitHub API success body; `--selftest` on any candidate tree; census or verify on the lane tree (sandbox overlays only). Public bodies are not stored, as designed.
