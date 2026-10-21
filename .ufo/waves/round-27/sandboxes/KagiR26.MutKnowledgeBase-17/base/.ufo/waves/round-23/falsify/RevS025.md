# RevS025 — adversarial re-measurement of S025 fetch provenance (round-23 falsification)

Seat: RevS025 (falsification, round 23). Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`.
Base: `d218603b74099ddca0bd8f869516fc41db0979bf` plus the uncommitted round-23 tree.
Measured: 2026-10-21 01:03–01:19 -0300 (04:03–04:19 UTC), across concurrent lane edits
(01:04, 01:06:58, 01:10:37, 01:10:59, 01:11:27, 01:16:11, 01:16:35, 01:18:44). Read-only on the lane; the only lane write
is this file. No installs, no host gates, no secrets, no git mutation.

Pinned state at the final read (the tree changed underneath this seat mid-wave; see F1/F2).
S025's TSV row and its registry row were byte-identical in every read:

| file | sha256 | note |
|---|---|---|
| `corpus/source-fetches.tsv` | `6e26e14032729070f38b5e0cb90914385f04c0ef9f4fe1db210af6439191094d` | mtime 01:10:37; S025 row (line 45) unchanged across all reads |
| `corpus/SOURCES.md` | `c6ea91ab2468352263a7442a2ff7815084d68374c94433bbb6b4cccc639c632d` | mtime 01:11:27; S025 at line 31; append-only vs base (9 insertions, 0 removed rows) |
| `corpus/sources-census.sh` | `2d1bbbe36ed21c2755d604937dc10d91fa71645847c82124bf729f4c8e0b95bc` | mtime 01:16:11 |
| `corpus/lessons/round-23.md` | `4e971e3d4101d6e28b13d02acbef9adf3ccf16101cfe95831c243891d24029a5` | mtime 01:18:44; S025 at lines 28, 43, 74, 78, 121, 178 |

Line anchors below refer to these hashes; other seats edited the lesson and census during
this measurement.

Tools: curl 8.23.0 (OpenSSL 3.6.5, zlib 1.3.2), Python 3.14.8, bash 5.3.20.
Fetch profile used exactly as declared: `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' <url>`.

## Verdict

No falsification of S025's declared provenance. Every declared field — registered URL,
final URL, HTTP status, decoded-body digest, byte count, row-identity digest, located
quote, normalization, normalized digest, location — reproduces exactly from four
independent GETs (three curl including a cache-buster, one urllib/gzip) and the declared
rendered-text-v1 algorithm. Gate state at the pinned hashes: census exit 0 CLEAN,
selftest exit 0 PASS (59 cases), zero `SC_FETCH` findings.

One open claim-statement discrepancy (F2), one mid-wave artifact inconsistency that was
resolved before this report closed (F1), and two stated bounds (F3/F4) are recorded below.

## Field-by-field re-measurement (TSV row `corpus/source-fetches.tsv:45`)

| # | declared | independently observed | verdict |
|---|---|---|---|
| id / status | `S025` / `mined` | matches registry row `corpus/SOURCES.md:31` (status cell 9 = `mined`) and census `ST[]` extraction | PASS |
| url (col 4) | `https://openbao.org/docs/auth/jwt/` | census's own awk extractor on `SOURCES.md` prints `EXTRACTED=[https://openbao.org/docs/auth/jwt/]`; string-equal to col 4 | PASS |
| final_url (col 5) | `https://openbao.org/docs/auth/jwt/` | curl `%{url_effective}` = same; urllib `geturl()` = same | PASS |
| http_status (col 6) | `200` | curl and urllib both 200 | PASS |
| row_identity_sha256 (col 3) | `e91b8e3c…d8481` | `printf 'S025\tmined\thttps://openbao.org/docs/auth/jwt/\n' \| sha256sum` = `e91b8e3c1bd4b981e82d0f76c7362c4bc3622165355800972da569f6496d8481` | PASS |
| representation (col 9) | `decoded-http-body-volatile-v1` | `Content-Encoding: gzip`; wire 13,325 B sha256 `131d692a…d120` ≠ declared; decoded body 63,046 B sha256 `449ef132…5785d9` = declared → digest domain is the decoded entity body, as the header states | PASS |
| sha256 (col 10) | `449ef132ba380948398c03cd96b0a10f80572b734c381897e681b3609d1785d9` | `sha256sum body.html` (curl+`--compressed`) and Python `gzip.decompress` both yield exactly this | PASS |
| bytes (col 11) | `63046` | `wc -c < body.html` = 63046; `len(body)` = 63046 | PASS |
| fetched (col 8) | `2026-10-21` | capture is current-day; response `last-modified: Tue, 20 Oct 2026 07:50:18 GMT`, `date: Wed, 21 Oct 2026 03:59:29 GMT` | PASS |
| revision (col 12) | `-` | URL is not raw.githubusercontent/main-shaped; `-` is correct | PASS |
| quote (col 13) | “The jwt auth method can be used to authenticate with OpenBao using OIDC or by providing a JWT” | byte-equal to `SOURCES.md` row quote and to the lesson quote; present exactly once in the declared normalized text (count 1) | PASS |
| normalization (col 14) | `rendered-text-v1` | declared order applied (strip script/style incl. content → tags to single space → `html.unescape` → collapse whitespace → trim → UTF-8) | PASS |
| normalized_sha256 (col 15) | `ca496ad8…a403` | `ca496ad8f8226d848d2fefa4b1c66d3820e32cdf5d995ee508b44521e752a403` over the full normalized text (15,911 chars / 15,942 UTF-8 bytes) | PASS |
| location (col 16) | `H1 JWT/OIDC auth method` | raw HTML: `<h1>JWT/OIDC auth method</h1></header>` immediately precedes `<p>The <code>jwt</code> auth method…` (h1 @19614, paragraph @19653); in normalized text the H1 occurrence is at 619 and the quote at 640, before the next H2 (`OIDC authentication`). Page carries `docs-version-2.7.x` and the banner `Version: Version 2.7.x`, supporting the row's `Version 2.7.x` | PASS |

Additional checks:

- Stability: the body is byte-identical across GET #1, GET #2 (`cmp` → `IDENTICAL`),
  urllib/gzip GET (same decoded sha256), and a `?revs025=1` cache-buster with
  `Cache-Control: no-cache` (`IDENTICAL_AFTER_QUERY_NO_CACHE`). So the "volatile"
  declaration is conservative today, not false (F4).
- Order sensitivity: applying `html.unescape` before tag-stripping yields a different
  digest (`0741ebf7…`), so the declared operation order is load-bearing and the declared
  value is exactly the declared order's output, not an accident of an alternative parser.
- Cross-row consistency (adjacent, not my seat): re-fetching S026's URL reproduces its
  declared raw digest `52295218…` (47,384 B) and normalized digest `ed949658…`, which
  confirms that `normalized_sha256` is page-wide text, not quote-level. S026 itself is
  another seat's target.
- Quote-level counterfactual: the sha256 of the quote string alone is `b960feb2…`; it
  appears nowhere in the lane. The declared value is the page-level digest (F3).
- S014 immutability: `git diff --stat d218603… -- corpus/SOURCES.md` = 9 insertions,
  0 removed rows (three new rows plus a lead-disposition note); S014 (`corpus/SOURCES.md:20`)
  is unchanged at base. S025 supersedes without rewriting.
- Shape/identity: TSV row 45 has NF=16, one S025 row (`FSEEN` ≤ 1); quote 18 words ≤ 25;
  location length 23 ≥ 8; `grep -c '^S0' corpus/source-fetches.tsv` = 10.

Gate runs on the pinned state:

- `bash corpus/sources-census.sh` → exit 0,
  `SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)`, zero `SC_FETCH` findings.
- `bash corpus/sources-census.sh --selftest` → exit 0, `SOURCES_CENSUS_SELFTEST: PASS (59 cases)`;
  12 fetch cases at `corpus/sources-census.sh:542-553`.

## Findings

### F1 — resolved in-flight: the volatile header contradicted the code at 01:06:58; the 01:10 edit withdrew the cross-capture rule

At the 01:06:58 state, `corpus/source-fetches.tsv:17-21` said of
`decoded-http-body-volatile-v1`: “the normalized digest is a more stable point attestation,
still chrome-sensitive, never a drift pin. **No cross-capture equality is enforced.**”
That sentence was false against the code then in the tree: `SC_FETCH` enforced same-URL
normalized-digest equality for every `rendered-text-v1` row regardless of representation
(the agreement block was at `corpus/sources-census.sh:285-290`; its comment said volatile
raw HTML “is compared through its normalized digest instead”).

Mutation proof against that 01:06:58 gate, on a `/tmp` copy of `corpus/` (lane untouched):
appending a duplicate **S021** row (volatile, `rendered-text-v1`, same tokens URL) with a
different 64-hex `normalized_sha256` produced exit 1 and
`FINDING SC_FETCH id=S021 same-url-normalized-disagreement url=https://openbao.org/docs/concepts/tokens/`
plus `FINDING SC_FETCH id=S021 duplicate-provenance` (findings=2); a duplicate **S025** row
with a different 64-hex raw digest produced only `duplicate-provenance` (findings=1).

The 01:10:37–01:10:59 edits then removed both the raw and the normalized agreement checks.
In the final gate each row ends at `duplicate-provenance`
(`corpus/sources-census.sh:275`; no `same-url` finding exists in the file), and the header
(`corpus/source-fetches.tsv:21`), the lesson (`corpus/lessons/round-23.md:52-54`), the C2 row
(`corpus/lessons/round-23.md:61`), and M23-1 (`corpus/lessons/round-23.md:151`) now all state
that captures are point attestations with no cross-capture equality. Re-running both
mutations against the no-agreement gate (then hash `511deb27`; the current `2d1bbbe3`
retains the same row checks) gives findings=1 (`duplicate-provenance` only) in each case,
confirming the withdrawal. Final state is internally consistent; no open defect. Residual: the
`fetch-disagree` selftest case is now duplicate-detection only
(`corpus/sources-census.sh:553`, expected findings 1).

### F2 — claim-statement numeral is wrong; the tree was corrected in-flight (no open artifact defect)

The C2 statement supplied to this seat says “10 declared captures S017-S026 over 7 URLs.”
Measured: **9** distinct registered URL strings and **9** distinct final URLs among the ten
rows (`awk -F'\t' '!/^#/ && NF==16 {print $4}' corpus/source-fetches.tsv | sort -u | wc -l`
→ 9; same for column 5). The “7” is the size of the reopened S017–S023 set, not the capture
set. At my measurement the lane artifacts say **nine** — `corpus/lessons/round-23.md:180`,
`LOG.md:1202`, `SCORECARD.md:840` — which matches measurement. The earlier wording (“over
seven distinct URLs”) was edited mid-wave at 01:04; the pre-fix text survives only in the
stale claim statement and in `ScoutAppendOnly.md:110-116`. Consequence: do not book “7
URLs”; the current artifacts are arithmetically correct. No open defect in the pinned
files, but the assignment/claim text must be updated before integration.

### F3 — Bound, no defect: `normalized_sha256` is page-wide and the quote is not substring-checked

`SC_FETCH` is shape-and-identity, not content verification: the quote check is
`[[ -n $fquote && $words -le 25 ]]` (`corpus/sources-census.sh:266-267`) and the normalized
digest is a 64-hex regex (`corpus/sources-census.sh:269-270`). The column sits next to
`quote`/`normalization` (`corpus/source-fetches.tsv:25-29`) without saying “page text”, while
the digest is over the whole normalized document (it includes `<title>` text and nav chrome;
the heading string occurs twice in normalized text, at 0 from `<title>` and at 619 from the
H1). The lesson states the page-wide domain at `corpus/lessons/round-23.md:45-54`, and the
final lesson states the bound explicitly at `corpus/lessons/round-23.md:186-196` (quote text
and location are not checked against the page; only ASCII word count and a non-empty
location are). No false value in S025: I verified the quote
is present once under the H1. Residual risk is that a well-formed page digest plus a
fabricated quote would pass the host-free gate; the row's truth was established here by
network re-measurement, not by the gate.

### F4 — Bound, no defect: S025's volatile label is conservative, with weaker evidence than S020's

The raw body is byte-stable across four GETs today and contains no per-response token
(`grep -c 'data-cfemail\|email-protection' body.html` = 0). Volatility is defensible only
through deployment-coupled build-hash class names (e.g. `tocCollapsible_IWwj`,
`codeBlockContainer_wX5d`, `lastUpdated_bHH4`) and daily chrome, i.e. a rebuild changes the
bytes even when the article does not. This is less concrete than S020's documented
per-response Cloudflare fragment (`corpus/lessons/round-23.md:46-51`). Consequence: the
final gate performs no same-URL comparison at all (`corpus/sources-census.sh:262-276`);
S025 is the only capture of its URL in the table, so no comparator exists today and neither
raw nor normalized cross-capture equality binds it. No false claim is made by the row; the
volatile label is conservative.

## Residual risk and verification gaps

- Quote location was verified in server-rendered HTML plus the declared normalization; no
  headless-browser DOM render was performed. The quote is static in the served body, so this
  is not a practical gap.
- All digests depend on the public CDN's current object; four identical
  GETs (including a cache-buster with `Cache-Control: no-cache`, `x-cache: HIT`, `age: 12`,
  `last-modified` 2026-10-20) are the evidence. Digest values remain point attestations.
- No host-bound or legacy claim-ledger row was run, per lane bounds. Only the named C2 gates
  (`sources-census.sh`, `--selftest`) were executed; S026 was fetched solely as a
  digest-domain consistency check and is owned by another seat.
- Mutation evidence lives under `/tmp/r25a` and `/tmp/r25b` (removed after this report); the
  commands in the appendix reproduce it.

## Appendix — exact commands and exits

1. `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' -o body.html -w 'final_url=%{url_effective}\nhttp=%{http_code}\nwire_bytes=%{size_download}\nctype=%{content_type}\n' https://openbao.org/docs/auth/jwt/` → exit 0; `final_url=https://openbao.org/docs/auth/jwt/`, `http=200`, `wire_bytes=13325`, `ctype=text/html; charset=utf-8`.
2. `sha256sum body.html; wc -c < body.html` → `449ef132…1785d9`, `63046`.
3. Second GET to `body2.html`; `cmp body.html body2.html` → `IDENTICAL`.
4. `curl … '?revs025=1' -H 'Cache-Control: no-cache'` → 200, same sha256/bytes; `cmp` → `IDENTICAL_AFTER_QUERY_NO_CACHE`.
5. Python urllib + `gzip.decompress`: wire 13,325 B sha256 `131d692a…`; decoded 63,046 B sha256 `449ef1…`; normalized `ca496ad8…`.
6. `printf '%s\t%s\t%s\n' S025 mined https://openbao.org/docs/auth/jwt/ | sha256sum` → `e91b8e3c1bd4b981e82d0f76c7362c4bc3622165355800972da569f6496d8481`.
7. Normalization (declared order): 15,911 chars / 15,942 bytes → `ca496ad8…a403`; quote count 1 at idx 640; H1 at 619; `html.unescape`-first variant → `0741ebf7…`.
8. `printf '%s' "<quote>" | wc -w` → 18; `printf '%s' "H1 JWT/OIDC auth method" | wc -c` → 23.
9. `bash corpus/sources-census.sh` → exit 0, `SOURCES_CENSUS: CLEAN (rows=26 …)`, SC_FETCH findings = 0 (final gate hash `2d1bbbe3…`).
10. `bash corpus/sources-census.sh --selftest` → exit 0, `SOURCES_CENSUS_SELFTEST: PASS (59 cases)`; 12 fetch cases at `corpus/sources-census.sh:542-553`.
11. `git diff --stat d218603b74099ddca0bd8f869516fc41db0979bf -- corpus/SOURCES.md` → `9 +++++++++`, removed S-rows = 0; S014 (`corpus/SOURCES.md:20`) unchanged.
12. Mutation A against the final gate (`/tmp/r25a`): duplicate S025 with raw digest `aaaa…` → exit 1, findings=1 (`duplicate-provenance` only).
13. Mutation B against the final gate (`/tmp/r25b`): duplicate S021 with normalized digest `bbbb…` → exit 1, findings=1 (`duplicate-provenance` only). Against the earlier 01:06:58 gate the same mutation produced 2 findings including `same-url-normalized-disagreement` (F1).
