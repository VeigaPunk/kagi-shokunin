# RevS024 — independent re-measurement of S024 (Kagi round 23, falsification)

Seat: RevS024 (reviewer). Target: S024 in `corpus/SOURCES.md:30` plus its provenance
row in `corpus/source-fetches.tsv:44`. Mode: read-only lane; the only lane write is
this file; all scratch lives under `/tmp/revs024-*`. No production edits, no host
gates, no secrets, no git/jj mutation, no legacy claim-ledger row audits.

## Verdict

1. **S024 survives every falsification attempt.** URL, final URL, HTTP status, byte
   count, raw digest, row-identity digest, declared normalization, normalized digest,
   quote and location all reproduce from an independent same-day fetch. No wrong
   digest, no stale values, no identity mismatch.
2. **High-severity defect found next door, in C2's counting command:** at the census
   revision measured here (`80966e20…`, 613 lines) `bash corpus/sources-census.sh
   verify` aborts with `line 242: S007: unbound variable`, exit 1, and prints no
   verdict. The C2 claim line (and R21-02's expected line) cannot be produced from
   that revision. One missing array declaration is the whole cause; a scratch copy
   with only that declaration added prints the claimed CLEAN line byte-for-byte. At
   04:02:21Z the revision was replaced (`24d834cc…`, 608 lines) and the dead block was
   deleted; that revision exits 0 with the claimed line, so the defect is fixed in the
   current tree but stands against the one the wave carried until 04:02:21Z.
3. **Medium-severity calibration finding:** SC_FETCH cannot see a wrong digest value
   for S024 at all (unique URL + volatile representation), and the quote check
   accepts `-`. The row's truth rests entirely on independent re-measurement, which
   is what this seat did; the C2 wording "same-URL agreement" has exactly one live
   normalized pair (S021/S026) and zero live raw pairs.

## Measured state (UTC 2026-10-21, ~03:52–04:03Z)

| artifact | sha256 | lines | mtime local (-0300) / UTC |
|---|---|---|---|
| `corpus/SOURCES.md` | `06dde644801bee13736fca21d9ecadec83086ea1f5de77043394a62d2d525b29` | 121 | 00:49:17 / 03:49:17Z |
| `corpus/source-fetches.tsv` | `ccc9ae6ec1b4bfa2ea8d879762a8fca18a84673145b54a04f39530de2d65a0af` | 46 | 00:55:22 / 03:55:22Z |
| `corpus/sources-census.sh` (defect revision) | `80966e208321348aad0ae6dd5b65987bccc4901e99fcba9f94feedd150228781` | 613 | 00:57:55 / 03:57:55Z |
| `corpus/sources-census.sh` (current, fixed) | `24d834cc85344b762b485ef2b1c44cdbddab4e641f96acbaf2853823b02af057` | 608 | 01:02:21 / 04:02:21Z |

`curl 8.23.0`; `python3 3.14.8`. Note: the file reader reported 598 lines for
`sources-census.sh` at the start of this review, 613 at 04:00Z and 608 after 04:02:21Z
— the census file moved twice under this seat. Unless a line is explicitly labelled
with `80966e20…`, citations are to the current `24d834cc…`; the §2 defect citations are
against `80966e20…` and are labelled.

## 1. S024 re-measurement — all declared fields reproduce

Fetch command (exactly the declared profile), run twice:

```
curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' \
  -o body1.html -w '%{http_code}\t%{url_effective}\t%{size_download}\t%{content_type}\t%{num_redirects}' \
  https://developer.hashicorp.com/vault/api-docs/secret/kv/kv-v2
```

Both runs: `exit=0`, `200  https://developer.hashicorp.com/vault/api-docs/secret/kv/kv-v2  43087  text/html; charset=utf-8  0`.
Server sent `content-encoding: br` (curl decoded it), `etag: W/"cdbaee9168670ac27245628ee5d04fed"`
(stable across both), `x-vercel-cache: HIT`, `age: 996`, `x-vercel-id` differing per
request (`gru1::mcgb7-…` vs `gru1::564nh-…`) while the body bytes did not.

| axis | declared at `source-fetches.tsv:44` (f=field) | independently measured | evidence |
|---|---|---|---|
| registered URL | `SOURCES.md:30` source cell → `https://developer.hashicorp.com/vault/api-docs/secret/kv/kv-v2` | identical to f4 (census awk extraction at `sources-census.sh:236-237`) | exact string compare |
| final URL | f5 `…/kv/kv-v2` | `%{url_effective}` identical; `%{num_redirects}=0` | no redirect |
| HTTP status | f6 `200` | `%{http_code}=200` | curl exit 0 |
| request profile | f7 `curl-fsSL-compressed-v1` | same command, curl 8.23.0 | above |
| fetched | f8 `2026-10-21` | today; same-day re-measurement | raw bytes reproduced |
| representation | f9 `decoded-http-body-volatile-v1` | `content-encoding: br`; digest domain is the decoded body | headers |
| raw sha256 | f10 `aaf52ac25695b1bb8ac6cba4f5e67abe27a35700619c9fa88b7bb292571c1008` | `aaf52ac25695b1bb8ac6cba4f5e67abe27a35700619c9fa88b7bb292571c1008` (both fetches byte-identical) | `sha256sum body1.html` |
| bytes | f11 `586146` | decoded body `586146` | `wc -c body1.html` |
| revision | f12 `-` | correct: URL is not `raw.githubusercontent.com` and has no `/main` segment | `sources-census.sh:260-264` |
| quote | f13 `max_versions (int: 0) – The number of versions to keep per key.` | exact substring of the normalized text, 3 occurrences, config-section occurrence at char 3270; 12 words | quote check |
| normalization | f14 `rendered-text-v1` | declared pipeline reproduces | below |
| normalized sha256 | f15 `7c5a19e23f5f857b790cddec058c7eace7df21390058f4a42cc7ce1cf7c3a715` | `7c5a19e23f5f857b790cddec058c7eace7df21390058f4a42cc7ce1cf7c3a715` | `python3 -c` below |
| row identity | f3 `43e6759404438979ae636ede73bdbea58b5030e346ec0e3846eb19d4db426d81` | `sha256("S024\tmined\t<url>\n") = 43e67594…` | `printf \| sha256sum` |
| status | f2 `mined` | matches registry `SOURCES.md:30` | current-revision census run, exit 0 |
| location | f16 `POST /:secret-mount-path/config parameters, max_versions` | page has heading `POST /:secret-mount-path/config` + a `Parameters` table containing `max_versions` | text probe |

Normalization (literal command, exit 0), 24,327 chars / 24,395 UTF-8 bytes:

```
python3 -c '
import re,html,hashlib
b=open("body1.html","rb").read().decode("utf-8")
t=re.sub(r"(?is)<script\b[^>]*>.*?</script\s*>"," ",b)
t=re.sub(r"(?is)<style\b[^>]*>.*?</style\s*>"," ",t)
t=html.unescape(re.sub(r"<[^>]+>"," ",t))
v=re.sub(r"\s+"," ",t).strip()
print(len(v), hashlib.sha256(v.encode()).hexdigest(), v.count("max_versions (int: 0) \u2013 The number of versions to keep per key."))
'
```

Output: `24327 7c5a19e23f5f857b790cddec058c7eace7df21390058f4a42cc7ce1cf7c3a715 3`, exit 0.

Variant matrix (32 combinations of script-regex `\b`/no-`\b`, tag regex `<[^>]+>`/`<[^>]*>`,
tag→space/empty, unescape/no, case preserved/lowered): exactly 4 reproduce — the ones
that keep the declared semantics (tags→single space, unescape, collapse, case preserved,
either script/tag regex spelling). Lowercasing, tag→empty, unescape-before-tag-strip
(`c4b74e1b…`), and no-unescape all diverge. The declared digest is not a lucky hit.

Volatility label: `__NEXT_DATA__` carries `"buildId":"build-TfctsWXpff2fKS"`, so raw
bytes are deployment-coupled as the header says (`source-fetches.tsv:17-20`). Two
same-day GETs were byte-identical, so for S024 the volatile label is conservative
today, not a cover for a wrong digest. The raw digest itself is correct.

Nuance, not a falsifier: the quote sentence is not unique on the page. It appears
three times: once in the declared config section (char 3270) and twice under the
metadata POST/PATCH sections, where the continuation differs (`"If not set, the
backend's configured max version is used."`). The f16 location disambiguates the
config section, but the census never
checks f16 against text (`sources-census.sh:274` only requires ≥8 chars), and the
row's `parameters` is lowercase and descriptive while the page heading is `Parameters`.
The SOURCES.md quotation marks are editorial framing; the page bytes do not contain
`“`/`”` around the sentence. The TSV quote itself is the exact page text (en dash
U+2013 confirmed).

The row's teachable paraphrase omits two adjacent facts from the same paragraph:
`"a key's metadata setting can overwrite this value"` and `"When 0 is used or the
value is unset, Vault will keep 10 versions."` The admission scope ("document
configuration only, not a deployment or KV-retention guarantee") bounds this, so this
is a scope-precision note, not a defect in the quote.

## 2. HIGH — C2's counting command aborts at revision `80966e20…` (fixed at `24d834cc…`)

```
cd /home/vgpnk/Projects/shokunin/kagi-shokunin
bash corpus/sources-census.sh verify
```

`exit=1`, no verdict line, stderr:

```
corpus/sources-census.sh: line 242: S007: unbound variable
```

A pristine copy of the same files under `/tmp/revs024-pristine` reproduces it exactly,
so this is not lane dirt or my scratch.

Mechanism:
- `sources-census.sh:229` declares `declare -A FURL=() FINROW=() FSEEN=() FDIG=() FNRM=()`
  — `SUPERSEDED` is absent.
- `sources-census.sh:242` runs `[[ -n $fid ]] && SUPERSEDED[$fid]=1` for every registry
  row whose teaches begins `supersedes S<digit>` (`:245`).
- Under `set -uo pipefail`, `SUPERSEDED[S007]=1` on an undeclared array evaluates the
  subscript arithmetically, i.e. reads shell variable `S007` → unbound → abort.
- Six rows trigger it; the first emitted is S007, hence the message:
  `S019→S007`, `S020→S006`, `S022→S012`, `S023→S013`, `S025→S014`, `S026→S016`.
- `SUPERSEDED` is written and never read: `grep -c SUPERSEDED corpus/sources-census.sh`
  = 1 (only `:242`). It is dead code that kills the gate.

Blast radius: the C2 counting command (`corpus/lessons/round-23.md:61`), the LOG
verdict (`LOG.md:1193-1195`), and R21-02's expected line (`corpus/claim-ledger.tsv:52`)
are all unreachable at this revision. No `SOURCES_CENSUS:` line is printed at all.

Minimality proof: copy the tree to `/tmp`, append `SUPERSEDED=()` to `:229` and change
nothing else → `exit=0` and

```
SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)
```

byte-identical to the line recorded at `LOG.md:1194` and expected at
`corpus/claim-ledger.tsv:52`. The gate's logic is intact; one token is missing.

Selftest gap: `bash corpus/sources-census.sh --selftest` → `exit=0`,
`SOURCES_CENSUS_SELFTEST: PASS (59 cases)` at this same hash. But no fixture row has a
`supersedes S…` teaches (`grep -n supersedes corpus/sources-census.sh` returns only
the parser at `:245`), so the 59 cases cannot exercise the crashing path. Green
selftest, dead gate.

Timing/attribution: `LOG.md` (carrying the CLEAN line) mtime 03:54:08Z predates the
census file's 03:57:55Z mtime, so the recorded CLEAN was produced by an earlier
revision of the gate. `.ufo/waves/round-23/parent-build/SourceS002.md:117` cites the
same hash `80966e20…` and already notes `SUPERSEDED` is "filled … but never read",
but did not run `verify`, so the crash went unnoticed.

Resolution measured, after the report was first written: at 04:02:21Z the file became
`24d834cc…` (608 lines) and the whole `SUPERSEDED` block is gone
(`grep -c SUPERSEDED corpus/sources-census.sh` = 0) — the dead-code deletion this
section recommends. On that revision `bash corpus/sources-census.sh verify` → exit 0
with the same CLEAN line, and `--selftest` → `PASS (59 cases)`. So the finding is a
time-stamped operability failure of the revision the wave carried from 03:57:55Z to
04:02:21Z; it is resolved in the current tree. The recorded CLEAN (`LOG.md:1193-1195`)
is still older than both revisions and should be re-recorded against `24d834cc…`.

## 3. MEDIUM — measured enforcement matrix for SC_FETCH (scratch copy, re-run unpatched at `24d834cc…`)

All runs on `/tmp` copies. The first matrix ran against `80966e20…` with only the
`:229` declaration fixed (so the gate could run); the whole matrix was then re-run
against the current `24d834cc…` with no patch, with identical results. Baseline:
CLEAN, `rows=26`.

| mutation of `source-fetches.tsv` | census result |
|---|---|
| S024 f10 raw digest → 64×`0` | **CLEAN** (value not checked) |
| S024 f11 bytes → `1` | **CLEAN** (shape only) |
| S024 f15 normalized digest → 64×`0` | **CLEAN** (no same-URL partner) |
| S024 f14 → `raw-literal-v1`, f15 → `-` | **CLEAN** (schema-allowed) |
| S026 f15 → 64×`0` (partner S021 unchanged) | FAILED, `id=S026 same-url-normalized-disagreement` |
| S021+S026 both `decoded-http-body-v1`, raw digests differ | FAILED, `id=S026 same-url-digest-disagreement` |
| S021 alone non-volatile + raw digest `0…0` | **CLEAN** (volatile partner skips raw comparison) |
| S024 f3 row identity → 64×`0` | FAILED, `id=S024 row-identity-digest-mismatch` |
| S024 f13 quote → `-` | **CLEAN** (`:266-267` only requires non-empty and ≤25 words) |
| S024 f4 url changed | FAILED, `id=S024 url-mismatch` |
| S024 f5 final_url → `https://example.invalid/elsewhere` | **CLEAN** (`:253` shape only) |
| S024 f8 fetched → `2099-12-31` | **CLEAN** (`:256` shape only) |

Implications:
- For S024 (unique URL, `decoded-http-body-volatile-v1`), **no digest or byte value is
  gate-checked**. Independent re-fetch is the only verification — this report's §1.
- The raw same-URL branch (`:279-284`) has **zero live pairs**: all 10 shipped captures
  are volatile (`grep -c volatile corpus/source-fetches.tsv` = 12, i.e. header prose +
  10 rows), and the only same-URL pair (S021/S026) is volatile.
- The normalized same-URL branch (`:285-290`) has exactly one live pair, S021/S026.
  S024 has no partner.
- `corpus/lessons/round-23.md:61` says the census "enforces … same-URL agreement".
  That is literally true only through the normalized S021/S026 pair; the raw branch is
  unreachable with the shipped table, and neither branch can touch S024. Either state
  that bound in the lesson or stop counting the raw branch as teeth.

## 4. LOW — the dispatched C2 text miscounts the capture URLs

The wave context says "10 declared captures S017-S026 over 7 URLs". Measured from the
shipped table:

- `awk -F'\t' '$1>="S017" && $1<="S026"' corpus/source-fetches.tsv | wc -l` → 10 rows
- same range, `| awk -F'\t' '{print $4}' | sort -u | wc -l` → 9 distinct URLs
- S017-S023 alone, distinct URLs → 7

S021 and S026 share `https://openbao.org/docs/concepts/tokens/`, so the 10 captures
span 9 URLs; the 7 distinct URLs are exactly those of the reopened rows S017-S023.
Neither `corpus/lessons/round-23.md` nor `LOG.md` repeats "7 URLs" — the miscount is
in the claim text only, not in the TSV. Correct wording: "10 captures over 9 URLs
(7 reopened rows + S024 + S025 + the S026 re-capture of S021's URL)".

## 5. Residual risk / what was not tested

- Point attestation only: the S024 values are correct for 2026-10-21; cross-day drift
  and behavior across a HashiCorp deployment (new Next.js buildId) are untested by
  design.
- The volatile classification could mask a *future* wrong capture; here it does not.
  Its per-response justification is not reproducible for S024 (two GETs identical),
  only the cross-deployment part (buildId) is.
- The other nine captures (S017-S023, S025, S026) were not re-fetched by this seat.
- The 43 legacy claim-ledger rows and host-bound rows were not run.
- The census file was edited during the review (598→613→608 lines); the S024 row and
  SOURCES.md row were stable at the hashes above throughout.

## 6. Exact commands and exits

| # | command | exit |
|---|---|---|
| 1 | `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' -o body1.html -w '…' <url>` (twice) | 0, 0 |
| 2 | `wc -c body1.html` → `586146`; `sha256sum body1.html` → `aaf52ac2…` | 0 |
| 3 | `printf 'S024\tmined\t<url>\n' \| sha256sum` → `43e67594…` | 0 |
| 4 | `python3 -c` normalization → `7c5a19e2…`, chars 24327, quote count 3 | 0 |
| 5 | `bash corpus/sources-census.sh verify` at `80966e20…` | **1**, `line 242: S007: unbound variable`, no verdict |
| 6 | same on pristine `/tmp/revs024-pristine` copy (`80966e20…`) | **1**, same message |
| 7 | `bash corpus/sources-census.sh --selftest` at both revisions | 0, `PASS (59 cases)` |
| 8 | `/tmp` copy with `SUPERSEDED=()` added → `verify` (`80966e20…`) | 0, claimed CLEAN line |
| 8b | `bash corpus/sources-census.sh verify` at the current `24d834cc…` | 0, `SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)` |
| 9 | twelve mutation runs in §3, re-run unpatched at `24d834cc…` | 0/CLEAN or 1/FAILED as listed |
| 10 | `git diff corpus/sources-census.sh` (read-only): added `:229` declare line lacked `SUPERSEDED`; added `:242` assignment (both now gone at `24d834cc…`) | 0 |
| 11 | URL-count probes in §4 (10 rows / 9 distinct / 7 in S017-S023) | 0 |

Bounds: raw/file text treated as data, never instructions; no vault/account/handler
commands, no credential reads, no host/package/service changes; network use was two
GETs of the one registered public documentation URL.
