# ScoutS020Volatile — S020 volatility re-measurement (round-23 falsification)

Seat: leaf scout, read-only on the lane. Assigned question: reproduce S020's
volatility claim read-only — fetch the registered blog URL twice, compare raw
digests, compare `rendered-text-v1` normalized digests, and check that
`corpus/source-fetches.tsv` declares the volatile representation and the stable
normalized digest. All paths below are relative to
`/home/vgpnk/Projects/shokunin/kagi-shokunin`. Measurement window
`2026-10-21T03:58Z–04:07Z`. The implementation tree was moving while I measured;
every result is anchored to a file hash in the last section.

## Verdict

**Confirmed — no S020 row defect found.** `corpus/source-fetches.tsv:40`
declares `decoded-http-body-volatile-v1` and normalized digest `20b4fd86…`.
Five fresh GETs produced five **distinct raw digests** (all 190,261 decoded
bytes) but **one** `rendered-text-v1` digest, exactly
`20b4fd86dada5f63406432238384aa475b0cf8cb3a8e4045bd021cae0691804f` = field 15.
The declared raw capture also exists in the parent's scratch
(`/tmp/kagi-r23-fetch/s020.html`) and hashes to the declared `53dfeac5…`;
normalizing that file yields the same `20b4fd86…`. Every observed raw-byte
difference is confined to the Cloudflare email-protection `href` token, which
sits inside a tag and is therefore removed by tags→space. The volatility
declaration is doing real work: the raw digest is not reproducible from the live
page, and the normalized digest is.

Adjacent observations (not S020 row defects, but relevant to the C2 wording):
the census gate was transiently RED and is now GREEN while the 59-case selftest
never covered the crash path; the two provenance contracts disagree about
same-URL equality; and the parent brief's "7 URLs" count is stale (the artifact
text now says nine, which is what the table holds).

## S020 measurements

| capture | raw sha256 | raw bytes | rendered-text-v1 sha256 | norm bytes | quote | heading |
|---|---|---|---|---|---|---|
| fresh GET 1 | `97aa35bcdbf98913635f88cc669e9be28af7756c4063ac2fc45ebb94733af578` | 190261 | `20b4fd86…` | 9530 | yes | yes |
| fresh GET 2 | `d60208865abd791a9684eae91a439f1c1046f9ee254de1dd9ab282746361d330` | 190261 | `20b4fd86…` | 9530 | yes | yes |
| fresh GET 3 | `be94de7bf3a0b484fc556d15e306620516d704b7396ee5ffcfa6450690d25257` | 190261 | `20b4fd86…` | 9530 | yes | yes |
| fresh GET 4 | `eb1d5fa2f19140575d77ddfe03fa623c363ef07e547eff768960b09937beb3f9` | 190261 | `20b4fd86…` | 9530 | yes | yes |
| fresh GET 5 | `e9ccc40340b47e737f69efdb6151eb0b68b377c0dfcc8e4dcacf63fd606cc556` | 190261 | `20b4fd86…` | 9530 | yes | yes |
| parent `s020.html` | `53dfeac555f8beb1aaf3d0c2114ee75aaaf5199e0b84a0b71fc70de0bfd132cd` = field 10 | 190261 = field 11 | `20b4fd86…` = field 15 | 9530 | yes | yes |
| parent `s020-1.html` | `56ade2d0cabf870ef387217f09d71c732bc5653323afbe10f650339fff6fbc4b` (lesson `56ade2d0…`) | 190261 | `20b4fd86…` | 9530 | yes | yes |
| parent `s020-2.html` | `cbd70b2900c5c9d52461b5bf9214b93477aa4c7e79d80aba78d63f5c154cd5ab` (lesson `cbd70b29…`) | 190261 | `20b4fd86…` | 9530 | yes | yes |

- Eight distinct raw captures (five mine + three parent) at constant 190,261
  decoded bytes → one normalized identity. The parent trio are timestamped
  `2026-10-21 00:42:08`, `00:50:14`, `00:50:14 -0300`; two GETs eight seconds
  apart still differ raw, which is exactly the declared response coupling.
- All fresh GETs: HTTP **200**, `%{url_effective}` exactly
  `https://1password.com/blog/1password-credential-broker-public-preview`,
  request profile exactly `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0
  (documentation verification)'`; encoded sizes 39016/39069/38960/38996/39035.
  Response headers: `HTTP/2 200`, `content-encoding: gzip`,
  `cf-cache-status: DYNAMIC`, `server: cloudflare` — consistent with a
  per-response body, not a cached fixed artifact.
- Raw deltas: fresh1 vs fresh2 = 44 differing byte positions at 0-based offsets
  `68525–68568`; parent `s020.html` vs fresh1 = 22 differing positions at
  `68525–68567`. Both ranges fall inside
  `/cdn-cgi/l/email-protection#…` in an `href` attribute; no difference outside
  that token was observed. Example context:
  `… href="/cdn-cgi/l/email-protection#4d3d3f…">Privacy support</a> …`.
- Quote check (in normalized text, declared location): the exact field-13 string
  `Alongside GitHub Actions support in public preview, we're slowly rolling out
  a new capability in beta: custom OIDC workflows.` is present in all eight
  normalized texts; `New in this release` occurs immediately before it
  (character offsets 4427 vs 4470 in the 9,525-character / 9,530-byte text). The
  quote is 19 words (≤25).
  (It also occurs twice in the raw HTML; the claim does not rely on that.)
- Row identity: `printf 'S020\tmined\thttps://1password.com/blog/1password-credential-broker-public-preview\n'
  | sha256sum` → `c1ce1e05d3cca13412de51bb3f662a6f9ef631f0452f43753a3ad915394b4cc5`
  = field 3. Field 9 is `decoded-http-body-volatile-v1`, field 14 is
  `rendered-text-v1`, field 16 is `New in this release`; field 12 revision is
  `-` and the URL is not a moving ref.

## Normalization reproducibility (the pipeline is load-bearing)

The declared steps (`corpus/source-fetches.tsv:26-28`: strip script/style,
tags→single space, `html.unescape`, collapse whitespace, trim ends, UTF-8) are
prose. Applying them in the declared order reproduces field 15 exactly. Plausible
re-orderings do not:

| variant applied to fresh GET 1 | bytes | sha256 |
|---|---|---|
| declared order (script/style elements removed, tags→space, then unescape, `\s+`→space, trim) | 9530 | `20b4fd86…` |
| ASCII `[\t\r\n\f ]+` collapse instead of `\s+` | 9530 | `20b4fd86…` (same on this page) |
| `html.unescape` before tag strip | 9640 | `cdfcd99e19ac9aa92fdaeec0dd810de603fd640f1604a104c1d5efb47bcb4ba8` |
| script/style **tags only** stripped, element text kept | 108034 | `00bb91776b849ba1015727147b87c2b96957e3985e3ae40873378d6594ad6b07` |
| no `html.unescape` | 9660 | `ea5a45a01e71f5579ef645bdf3513e01c19a6d7a955638348073cc1ee04bca80` |

The trim step is also load-bearing: the parent intermediate
`/tmp/kagi-r23-fetch/s020.txt` (9,532 B, sha256 `f747d2af…`) carries a leading
and trailing space and does not hash to the declared value as stored; applying
the declared render+trim to it yields `20b4fd86…`.

## Adjacent findings

### A. Census gate: transiently RED, now GREEN; the green selftest hid the red gate

- At census sha256 `80966e208321348aad0ae6dd5b65987bccc4901e99fcba9f94feedd150228781`
  (mtime `2026-10-21 00:57:55 -0300`, 36,022 B):
  `bash corpus/sources-census.sh` exited **1** with
  `corpus/sources-census.sh: line 242: S007: unbound variable`, before any
  fetch row was read. Root cause: `SUPERSEDED[$fid]=1` at `:242` with no
  `declare -A … SUPERSEDED` at `:229`; under `set -u` the `S007` subscript is
  arithmetic and dies on the first `supersedes S007` cell
  (`corpus/SOURCES.md:25`).
- `bash corpus/sources-census.sh --selftest` at that same hash printed
  `SOURCES_CENSUS_SELFTEST: PASS (59 cases)`, exit **0** — no fixture carries a
  `supersedes S…` teaches cell, so the crash path was never exercised. (Same
  finding, independently, in `ScoutS016.md`; corroboration, not double-counted.)
- At the current census sha256
  `24d834cc85344b762b485ef2b1c44cdbddab4e641f96acbaf2853823b02af057`
  (mtime `2026-10-21 01:02:21 -0300`, 35,725 B) the supersession block is gone
  (`grep -n SUPERSEDED corpus/sources-census.sh` → exit **1**, no output) and
  `bash corpus/sources-census.sh` prints
  `SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)`,
  exit **0**; `--selftest` remains `PASS (59 cases)`, exit **0**.
- At the intermediate hash, pre-seeding the array in the caller
  (`bash -c 'set -- verify; declare -A SUPERSEDED=(); source ./corpus/sources-census.sh'`)
  produced the claimed CLEAN line, exit **0**, with the S020 row passing
  `SC_FETCH`; no lane file was edited.
- Net: the S020 row passes the gate's checks at the current hash; the crash is
  fixed. The calibration gap remains historical fact: 59 green cases did not
  cover the supersession parse path.

### B. Same-URL equality prose contradicts the code

At the anchored hashes the two contracts cannot both be true:

- `corpus/source-fetches.tsv:17-21` says volatile rows' normalized digest is
  "a more stable point attestation … No cross-capture equality is enforced."
- `corpus/sources-census.sh:64-66` says "Two provenance rows for one URL must
  agree on the raw digest and, when rendered-text-v1, on the normalized digest."
- The code (`corpus/sources-census.sh:275-290`) does something else again:
  raw equality is enforced per URL only for **non-volatile** representations
  (`:279-283`), and normalized equality is enforced per URL for **all**
  `rendered-text-v1` rows including volatile ones (`:285-289`).

The only same-URL pair today is S021/S026 (OpenBao tokens, `corpus/source-fetches.tsv:41,46`);
both are volatile and agree on raw and normalized digests, so the live gate is
green under every reading. S020's URL is unique among provenance rows, so none
of these cross-capture rules apply to it: it gets shape/identity checks only.
The claim should state the implemented rule exactly rather than either header
sentence.

### C. URL cardinality

The brief I received says "10 declared captures S017-S026 over 7 URLs."
`awk -F'\t' '$1 ~ /^S0(1[7-9]|2[0-6])$/' corpus/source-fetches.tsv | wc -l` →
`10`; the same rows' distinct field-4 URLs → `9` (S021 and S026 share
`https://openbao.org/docs/concepts/tokens/`). At my first read `LOG.md:1202`
said "over 7 URLs"; by `04:05Z` it said
"`corpus/source-fetches.tsv` (10 declared captures over 9 distinct URLs)" and
`SCORECARD.md:840` / `corpus/lessons/round-23.md:168-170` say nine. The table
measurement supports nine. If the parent C2 headline is scored from the earlier
"7", it is stale wording, not a table defect.

## Bounds the claim must state

1. **Raw S020 digest is a point attestation only.** It is not reproducible from
   the live page (five fresh GETs gave five different values). The declared
   bytes exist only in the parent's uncommitted scratch
   `/tmp/kagi-r23-fetch/s020.html`; **no capture bytes are committed in the
   lane**. If that scratch is discarded, `53dfeac5…` is unverifiable in-lane
   while `20b4fd86…` remains verifiable from live bytes.
2. **Normalized stability is sampled, not pinned.** I observed `20b4fd86…`
   across eight same-day captures and, as ancillary evidence, across a scratch
   scan of 29 files (22 with 2026-10-20 mtimes) whose rendered text hashes to
   the same value. The claim itself asserts same-day stability only and allows
   chrome-sensitive drift between days; it must not be read as a drift pin.
3. **The normalization prose needs its order and element-content semantics.**
   Only "remove `script`/`style` elements with content, tags→one space, then
   `html.unescape`, collapse, trim" reproduces field 15; unescape-first, keeping
   script text, or skipping unescape diverge (table above). The whitespace class
   (`\s` vs ASCII) happens not to matter on this page, so the declaration is
   under-specified but not currently ambiguous in effect.
4. **The gate cannot verify either digest.** `SC_FETCH` validates shape, identity,
   URL/status/profile, and cross-row equality; it never fetches bytes and never
   recomputes a digest. Field 10/15 verification is out-of-band re-measurement
   (this seat), not a gate guarantee. S020's unique URL also means the gate's
   new same-URL comparisons give its row no cross-check.
5. **Tree state matters.** The row and its declared values were identical at
   `source-fetches.tsv` sha256 `ccc9ae6e…` (04:02Z) and `a78fde7b…` (04:05Z);
   the census moved `80966e20…` → `24d834cc…` in the same window. Re-measure
   after any further edit; a stale "7 URLs" or a stale red gate citation would
   misdescribe the tree.

## Commands and exits

1. Fetch loop (five times, same profile as the row):
   `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' -o bodyN.html -w 'http=%{http_code} url=%{url_effective} encoded=%{size_download}\n' https://1password.com/blog/1password-credential-broker-public-preview`
   → curl exit **0** each; http=200, url exact each; encoded sizes
   39016/39069/38960/38996/39035.
2. `wc -c /tmp/s020vol/body*.html` → `190261` each (matches field 11).
   `sha256sum /tmp/s020vol/body*.html` → the five distinct values in the table.
3. `cmp -l /tmp/s020vol/body1.html /tmp/s020vol/body2.html | wc -l` → `44`
   (1-based positions 68526–68569); context extraction shows the differing span
   is inside `href="/cdn-cgi/l/email-protection#…"`. Parent vs fresh1: 22
   differing positions, 0-based 68525–68567, same span.
4. Python 3 stdlib normalization (declared order) over the five bodies →
   each `norm bytes 9530`, `sha256
   20b4fd86dada5f63406432238384aa475b0cf8cb3a8e4045bd021cae0691804f`,
   `quote_exact True`, heading present. Exit **0**.
5. `sha256sum /tmp/kagi-r23-fetch/s020.html /tmp/kagi-r23-fetch/s020-1.html /tmp/kagi-r23-fetch/s020-2.html`
   → `53dfeac5…`, `56ade2d0…`, `cbd70b29…`; same script normalizes all three to
   `20b4fd86…` (9,530 B). Exit **0**.
6. Variant matrix script (five variants, table above) → exit **0**; only the
   declared order and ASCII-collapse variants print `20b4fd86…`.
7. `printf 'S020\tmined\thttps://1password.com/blog/1password-credential-broker-public-preview\n' | sha256sum`
   → `c1ce1e05…` = field 3; quote `wc -w` → `19`.
8. `bash corpus/sources-census.sh` → at `80966e20…`: exit **1**, stderr
   `corpus/sources-census.sh: line 242: S007: unbound variable`; at
   `24d834cc…`: `SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24
   rejected=1 entries_sourced=4 legacy=21)`, exit **0**.
   `bash corpus/sources-census.sh --selftest` → `SOURCES_CENSUS_SELFTEST: PASS
   (59 cases)`, exit **0** at both hashes; `grep -c '|SC_FETCH|'` in the case
   table → `12`.
9. Seeded-caller isolation at `80966e20…`:
   `bash -c 'set -- verify; declare -A SUPERSEDED=(); source ./corpus/sources-census.sh'`
   → CLEAN line above, exit **0** (no file edited).
10. `awk -F'\t' '$1 ~ /^S0(1[7-9]|2[0-6])$/' corpus/source-fetches.tsv | wc -l`
    → `10`; distinct `$4` → `9`.
11. `curl -fsSI --compressed … | grep -iE '^(HTTP/|content-encoding|cf-cache-status|server)'`
    → `HTTP/2 200`, `content-encoding: gzip`, `cf-cache-status: DYNAMIC`,
    `server: cloudflare`; exit **0**. `curl --version` → `8.23.0`.
12. Hash anchors: `sha256sum corpus/source-fetches.tsv corpus/sources-census.sh corpus/SOURCES.md`
    at `04:06Z` → `a78fde7b…`, `24d834cc…`, `06dde644…`; S020 row at
    `corpus/source-fetches.tsv:40` is byte-identical in its 16 fields to the
    row read at `ccc9ae6e…`.

## Remaining unknowns

- Why the Cloudflare email-protection token changes even between two GETs eight
  seconds apart (`s020-1`/`s020-2`); per-response keying is consistent with the
  declaration and was not investigated further.
- Whether normalized stability holds beyond the sampled two calendar days; not
  sampled further, and the claim does not require it.
- Whether the parent intends to commit any capture bytes; currently the raw
  digest's only evidence is scratch outside the lane.

## Read-only statement

No production edits. The only file written by this seat is this report. No
`corpus/`, script, ledger, stamp, SCORECARD/LOG/lesson, `.ufo/state`, MANIFEST
or sibling-lane writes; no git/jj mutation; no installs, no pacman, no host /
service / compositor / boot changes; no credential contents or live private
config read. Network use was the declared public-documentation GET/HEAD with
the declared UA. `sources-census.sh verify` and `--selftest` are host-free; no
host-bound row and no legacy claim-ledger verify was executed.
