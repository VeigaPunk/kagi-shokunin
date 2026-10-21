# RevS021 — S021 provenance re-measurement (round 23)

Seat: falsification, S021 (OpenBao token lifecycle). Read-only on the lane; scratch under
`/tmp/revs021.JngdzX/`. Times local `-0300`.

## Snapshot under review

Final measured state: HEAD `57776b2` ("round-23: W04 base/end wording, skip semantics, D4 tuple
names"), 2026-10-21 01:19:44; worktree clean except `.ufo` seat reports (`RevS019.md`,
`ScoutMigration.md`).

| blob | sha256 |
|---|---|
| `corpus/SOURCES.md` | `c6ea91ab2468352263a7442a2ff7815084d68374c94433bbb6b4cccc639c632d` (S021 at line 27) |
| `corpus/source-fetches.tsv` | `6e26e14032729070f38b5e0cb90914385f04c0ef9f4fe1db210af6439191094d` (S021 at line 42) |
| `corpus/sources-census.sh` | `2d1bbbe36ed21c2755d604937dc10d91fa71645847c82124bf729f4c8e0b95bc` |
| `corpus/closure-dispositions.py` | `d79b08a78cfe2c4954f246d4b450d3fbcb4178a48092b675eb6ade98cc5521c4` |
| `corpus/closure-dispositions.json` | `67ac1a42427eca7bc38a0f6785385a3b8039f1e61de24a1716ab76c8bbc5ff60` |
| `corpus/claim-ledger.tsv` | `ed125ca5aefb4bc60d445b018fc35c2ac876dc45d14252c3625b3bb9df779b38` |
| `corpus/lessons/round-23.md` | `4e971e3d4101d6e28b13d02acbef9adf3ccf16101cfe95831c243891d24029a5` |

The S021 provenance row bytes were identical in every blob observed during this review
(`846b2037…`, `ccc9ae6e…`, `7101bdd0…`, `6e26e14…`), and the S021 registry status/URL never
changed, so the verification below is commit-independent. HEAD advanced nine times while the
review ran (`e1884c6` → `ea5b734` → `b55e0e7` → `7af07b4` → `284d40e` → `638d44c` → `def9bc2` →
`58bd8d7` → `57776b2`); F5 records what changed and why a verdict must pin a commit.

## What I attacked and the exact commands

1. Registered URL: `corpus/SOURCES.md:27` → `https://openbao.org/docs/concepts/tokens/`.
2. Independent fetch with the exact declared profile, plus one control without `--compressed`:

```
curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' \
  -o /tmp/revs021.JngdzX/s021.html \
  -w 'final=%{url_effective} code=%{http_code} size=%{size_download}\n' \
  'https://openbao.org/docs/concepts/tokens/'
```
   exit 0 every run; `final=https://openbao.org/docs/concepts/tokens/`, `code=200`,
   `size_download=12527` (compressed transfer). All three GETs (01:03, 01:08:39, 01:08:55)
   produced the same body SHA-256; the control without `--compressed` produced the same body too.
3. `sha256sum s021.html` → `5229521866ce21fa8cd8f8ecf63d696877b8cb0a2ec25e89de683557b385f82c`;
   `wc -c` → `47384`. Equal to TSV columns 10 and 11.
4. Row identity:
   `printf 'S021\tmined\thttps://openbao.org/docs/concepts/tokens/\n' | sha256sum` →
   `c921ab096d16a013bedc04026e50594dc158cd719cebd194f26b78d1053d0860`, equal to TSV column 3.
   Recomputed from the census's own extraction (`$9` status, `$3` URL) — same digest.
5. `rendered-text-v1` normalization (strip `script`/`style`, tags → single space,
   `html.unescape`, collapse whitespace, trim, UTF-8) in Python 3.14 over the fetched bytes:
   - declared algorithm → `ed949658b434fa769b89c682160f77ad153f5c6657808706db5858506ce0d2e3`,
     equal to TSV column 15;
   - control without the script/style strip → `1c094b91d166c4fe3d9d6860447a67d58afbcc52e812e17d88d3b9271443a3af`
     (different), confirming the strip step is part of the declared digest;
   - `<[^>]*>` vs `<[^>]+>` tag regexes and unescape-before-tags all reproduce the declared digest.
6. Quote: `After the current TTL is up, the token will no longer function -- it, and its associated
   leases, are revoked.` occurs once in the raw body and in normalized text; 20 whitespace words
   (≤25). It lies under `<h2>Token Time-To-Live, periodic tokens, and explicit max TTLs</h2>` (the
   only h2 with that prefix). The section intro says "The features in the following sections all
   apply to service tokens", so the quote supports the row's service-token scope. TSV column 16
   records `Token Time-To-Live`, a prefix of the full heading (F3).

### S021 field-by-field result

| field | declared (TSV line 42) | measured | verdict |
|---|---|---|---|
| id/status | `S021` / `mined` | registry `S021` / `mined` (`SOURCES.md:27`) | match |
| row identity | `c921ab09…` | `c921ab09…` | match |
| url | `https://openbao.org/docs/concepts/tokens/` | same string | match |
| final_url | same | no redirect, same | match |
| http_status | `200` | `200` | match |
| request_profile | `curl-fsSL-compressed-v1` | exact command above | match |
| fetched | `2026-10-21` | 2026-10-21 (multiple GETs) | current same-day |
| representation | `decoded-http-body-volatile-v1` | decoded body 47384 B; label unevidenced (F2) | digest correct, label unbacked |
| sha256 | `52295218…` | `52295218…` | match |
| bytes | `47384` | `47384` | match |
| revision | `-` | not a moving-ref URL | match |
| quote | 20 words | present, raw + normalized | match |
| normalization | `rendered-text-v1` | declared algorithm reproduces | match |
| normalized_sha256 | `ed949658…` | `ed949658…` | match |
| location | `Token Time-To-Live` | full heading is longer; unique prefix | prefix, not false |

**S021 verdict: no falsification.** Every declared field reproduces from the live URL on the
declared fetch date; the row is not stale, the digests are not wrong, and the quote is located in
the claimed section.

## Findings

### F1 (declared limit, confirmed) — the gate cannot verify any digest against the page
At HEAD `57776b2` (census `2d1bbbe3`), replacing S021's normalized digest with 64 zeros in a
`/tmp` corpus copy leaves `bash sources-census.sh verify` at exit 0 `SOURCES_CENSUS: CLEAN
(rows=26 …)`. A 64-hex wrong digest is accepted. Row-identity and URL mutations do fire
(`FINDING SC_FETCH id=S021 row-identity-digest-mismatch` exit 1; `id=S021 url-mismatch` exit 1).
The lesson states this bound (`corpus/lessons/round-23.md:195`, `:210`), so this is an honest
saturation limit, not a false claim — but the only content guarantee for the S021 digest is this
external re-fetch.

### F2 (low) — `volatile` label for S021 has no recorded evidence
`corpus/source-fetches.tsv:42` declares `decoded-http-body-volatile-v1`. The lesson documents
volatility for S020 only (Cloudflare email-protection fragment, `round-23.md:47-54`). For S021 two
request profiles (with/without `--compressed`) returned byte-identical bodies (`522952…`,
47384 B), and S021/S026 share the same raw digest. Since HEAD `638d44c` the cross-capture equality
rule is removed (`sources-census.sh:65`; `round-23.md:53-54`), so the volatile label has no
operational effect for this pair. Fix: record observed variation or declare it non-volatile.

### F3 (low) — TSV `location` is a prefix, not the heading
`sources-census.sh:274` only enforces `location` length ≥ 8. The heading is `Token Time-To-Live,
periodic tokens, and explicit max TTLs`; the registry anchor (`SOURCES.md:27`) uses the full
heading. It resolves uniquely, but the column header claims "section/heading". Use the full heading.

### F4 (low) — selftest case name no longer matches its assertion
At HEAD `57776b2`, `fetch-disagree` expects 1 finding (`sources-census.sh:553`) and
`m_fetch_disagree` (`:426`) appends a second S002 provenance row; with the cross-capture rule
removed, the case no longer exercises disagreement. The 59-case count is real
(`--selftest` → `PASS (59 cases)`), but this case's name overstates its coverage.

### F5 (process) — the tree moved under measurement; transient states and their fixes
- HEAD `284d40e` (census `6d4190a7`) had `sources-census.sh:64-66` saying "no cross-capture
  equality is enforced" while the code still enforced it: a normalized-digest mutation produced
  `FINDING SC_FETCH id=S026 same-url-normalized-disagreement`, exit 1. Fixed by `638d44c`.
- HEAD `284d40e` lesson `:60` said `selftest 13 cases` while `--selftest` printed `PASS (14
  cases)` (the 14th, `pointer-symlink`, landed in `7af07b4`). Fixed; `:60` now says 14.
- HEADs `638d44c`/`def9bc2` printed `fixed=7 reported=2`; `58bd8d7` reclassified one disposition
  and prints `fixed=6 reported=3`, with `R23-02` (`claim-ledger.tsv:60`) updated to the same line.
  I verified the current regex matches the current output. The earlier counts were accurate for
  their commits; the change is a live reclassification, not a silent mismatch.
- An uncommitted census blob (`sha256 80966e20…`, mtime 00:57:55) crashed the real-tree gate:
  `bash corpus/sources-census.sh` → exit 1, `corpus/sources-census.sh: line 242: S007: unbound
  variable`, while `--selftest` still printed `PASS (59 cases)`. It was never committed and is
  gone, but it proves the 59-case selftest did not cover a registry row whose summary begins
  `supersedes S###`, nor any real-tree run. If supersession logic returns, add that fixture case
  (and a real-tree smoke case).
- Consequence: cite commit `57776b2` (or later) plus the blob hashes above. Do not cite
  `284d40e` or the earlier drafts.

### F6 (informational) — the brief's "10 captures over 7 URLs" is wrong
`awk -F'\t' 'NF==16 && $0!~/^#/{print $4}' corpus/source-fetches.tsv | sort -u | wc -l` → **9**
(S021 and S026 share `https://openbao.org/docs/concepts/tokens/`). 10 rows, 9 distinct URLs;
`round-23.md:180` now says nine. An earlier draft (blob `bce51c92…`, 01:02:56) said seven and was
corrected during review.

## Positive re-measurement of C1/C2/C3 at HEAD 57776b2

- **C2**: `bash corpus/sources-census.sh` → exit 0,
  `SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)`;
  `--selftest` → exit 0 `PASS (59 cases)`; `grep -c 'Fetch sha256:'` = 16, `grep -c '^S0'` = 10.
  Mutation matrix on `/tmp` copies (current blob): row identity → exit 1
  `row-identity-digest-mismatch`; URL → exit 1 `url-mismatch`; quote 26 words → exit 1 `quote`;
  location 3 chars → exit 1 `location`; bytes 0 → exit 1 `bytes`; http `20` → exit 1 `http-status`;
  duplicate row → exit 1 `duplicate-provenance`; missing row → exit 1 `missing-provenance`;
  64-hex wrong normalized digest → exit 0 (F1).
- **C1**: `python3 corpus/closure-dispositions.py` → exit 0, line exactly
  `CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=6 reported=3 operator_owned=1 no_action=5 rejected=0 pointers=15)`;
  `--selftest` → exit 0 `PASS (14 cases)`. The `R23-02` regex matches that line. The JSON pin
  `source_sha256` = `65a5b3dee667146c47c158d344dad7c2a9307d6997a0a9800d92b7dbb55869f7` equals
  `sha256sum corpus/lessons/round-22-verifier-spotcheck.md`.
- **C3**: exact
  `CELL_AUDIT: CLEAN (cells=6 row_pointed=6 stamp_pointed=1 uncited=0 missing_ids=0 rows_run=2 row_deferred=0 row_failures=0 stale_pointers=0 self_skipped=0 orphans=0)`,
  exit 0. Fixture is hermetic: 5 files including fixture-local `corpus/fx-ok.sh`; `R90-02` counts
  8 matching lines in fixture-local `corpus/adjacency.tsv`; both commands read only fixture-local
  paths. Mutation `false` in R90-01 → exit 2 `CELL_AUDIT: POLICY (cells=6 row_pointed=6
  stamp_pointed=1 policy=1)` (fails, as claimed). `R23-01` regex matches this output exactly.

## Residual risk / verification gaps

- Freshness is a single-day attestation: multiple GETs on 2026-10-21 only; no cross-day drift
  evidence. The digest is a point attestation (declared).
- I re-fetched only S021. The other nine provenance rows (S017-S020, S022-S026) were not re-opened
  here (sibling seats cover them); S026 shares the S021 URL and therefore the same live bytes.
- No raw transfer bytes retained: `decoded-http-body` is validated indirectly (curl reported
  `size_download=12527` for a 47384-byte decoded file), so I cannot recompute a compressed digest
  or inspect HTTP headers.
- The gate cannot verify digest content (F1); S021's correctness rests on this independent re-fetch.
- Tree churn (F5): "CLEAN" is commit-relative. The fleet `kagi`/W04 census and D1's seven W04 lines
  are outside this seat (RevW04); the lane census itself prints no W04 line.

Evidence retained under `/tmp/revs021.JngdzX/` (fetched pages, census/selftest outputs, mutation
trees); scratch, not lane state.
