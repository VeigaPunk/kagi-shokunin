# RevS019 — round-23 falsification: S019 live re-measure

Seat: RevS019 (falsification). Date: 2026-10-21 (UTC). Base:
`d218603b74099ddca0bd8f869516fc41db0979bf` plus the uncommitted round-23 tree at
`/home/vgpnk/Projects/shokunin/kagi-shokunin`.

Artifact state pinned by sha256 at measurement time:

| path | sha256 |
|---|---|
| `corpus/SOURCES.md` | `06dde644801bee13736fca21d9ecadec83086ea1f5de77043394a62d2d525b29` |
| `corpus/source-fetches.tsv` | `ccc9ae6ec1b4bfa2ea8d879762a8fca18a84673145b54a04f39530de2d65a0af` |
| `corpus/sources-census.sh` | `80966e208321348aad0ae6dd5b65987bccc4901e99fcba9f94feedd150228781` |
| `corpus/lessons/round-23.md` | `d55209887c13825cdf4b0a423aed080830d0ffaaefbb980ce01d49cb9642c773` |

Host facts: bash `5.3.20(1)-release`, curl `8.23.0`. No installs, no host gates,
no git/jj mutation, no production edits. Scratch only under `/tmp/r23s019.RahVu7`;
this report is the only write inside the lane.

**Verdict.** The S019 provenance row reproduces exactly on every declared field:
registered URL, final URL, HTTP status, decoded byte count, raw sha256,
row-identity sha256, `rendered-text-v1` sha256, and the located quote. I found
**no wrong digest and no stale capture**. The pass, however, is established only
by this external re-measurement: the round's own `SC_FETCH` check never reaches
S019 because `corpus/sources-census.sh` aborts at line 242 before the fetch
block. Two surrounding defects are independently reproduced: the C2 gate is
inert on the tree (already reported at `RevS022.md:91`,
`MutFetchRemove.md:123`) and the round's "seven distinct URLs" is actually nine
(`RevS022.md:133`, `MutFetchRemove.md:143`). No S019-specific datum is falsified;
the S019 `location` label is a precision caveat, not a wrong-section claim.

---

## 1. Fetch with the declared profile

Profile definition: `corpus/source-fetches.tsv:12-13`
(`curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' <url>`).
Registered URL: `corpus/SOURCES.md:25`; provenance row: `corpus/source-fetches.tsv:39`.

```console
$ mkdir -p /tmp/r23s019.RahVu7 && cd /tmp/r23s019.RahVu7
$ curl -fsSL --compressed \
    -A 'kagi-shokunin-round23/1.0 (documentation verification)' \
    -o body.html -w 'final=%{url_effective}\nhttp=%{http_code}\nsize=%{size_download}\n' \
    https://www.1password.dev/brokered-access
final=https://www.1password.dev/brokered-access
http=200
size=166493
exit=0
$ sha256sum body.html
67f690e21116a3644be8cff57058293150b8b03fc305ffa15dc3af63fa43c312  body.html
$ wc -c < body.html
1199447
```

A second GET produced a byte-identical body (`cmp` exit 0; same sha256, same
1,199,447 bytes). A third GET captured headers:

```console
$ curl -fsSL --compressed -A '...' -D hdr.txt -o /dev/null \
    https://www.1password.dev/brokered-access
HTTP/2 200
content-encoding: br
etag: W/"z6d2q9klrgppcp"
age: 11996
cache-control: no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0
server: Vercel
vary: rsc, accept-encoding, Accept, User-Agent
x-vercel-cache: MISS
exit=0
```

`size_download=166493` is the wire (brotli) size; the declared `bytes` is the
decoded body (`corpus/source-fetches.tsv:15-16`), measured at 1,199,447 by
`wc -c`. That is the declared domain, so there is no byte-count mismatch. The
body contains asset URLs carrying `?dpl=dpl_8AUWT8nFRmT7D3RgoEGEPVymfFQP`, i.e.
the HTML is deployment-coupled even though three same-deployment GETs were
byte-identical.

---

## 2. Row identity, digest, normalization, quote

`rendered-text-v1` recomputed from the decoded body with the algorithm declared
at `corpus/source-fetches.tsv:26-28` (strip `script`/`style` with contents, tags
to a single space, `html.unescape`, collapse `\s+`, trim, UTF-8):

```python
h = open('body.html', encoding='utf-8').read()
s = re.sub(r'<(script|style)\b[^>]*>.*?</\1\s*>', ' ', h, flags=re.I | re.S)
s = re.sub(r'<[^>]*>', ' ', s)
s = html.unescape(s)
s = re.sub(r'\s+', ' ', s).strip()
hashlib.sha256(s.encode('utf-8')).hexdigest()
```

| field | declared (`source-fetches.tsv:39`) | measured | result |
|---|---|---|---|
| status | `mined` | registry status `mined` (`SOURCES.md:25`) | equal |
| url | `https://www.1password.dev/brokered-access` | registered URL, same string | equal |
| final_url | same | `%{url_effective}` = same | equal |
| http_status | `200` | `200` | equal |
| request_profile | `curl-fsSL-compressed-v1` | exact command above | equal |
| fetched | `2026-10-21` | fetch date 2026-10-21 | equal |
| representation | `decoded-http-body-volatile-v1` | decoded body; see §4.6 | declared domain |
| sha256 | `67f690e21116a364…43c312` | `67f690e21116a364…43c312` | equal |
| bytes | `1199447` | `1199447` | equal |
| revision | `-` | URL is not a moving ref | applicable |
| quote | `administrators can set up a supported integration in their 1Password Business account` | exact substring, 1 occurrence | located |
| normalization | `rendered-text-v1` | same algorithm | applied |
| normalized_sha256 | `f3861c172c370dd1…38cc6e9` | `f3861c172c370dd1…38cc6e9` | equal |
| location | `Introduction` | 0 occurrences in page; see §4.2 | precision caveat |

Normalized text length: 6,019 characters. Quote index in the normalized text:
1508; the article's `Add an integration` H2 body offset is 2207, so the quote
precedes the first body section. The quote is visible article content, not a
script payload: in raw HTML it begins at offset 98,901 inside
`<div … id="content">` → `<span data-as="p">` → `…</a>, administrators can set up
a supported integration in their 1Password Business account …`.

Row identity recomputed exactly as the census does (`id<TAB>status<TAB>url<LF>`):

```console
$ printf 'S019\tmined\thttps://www.1password.dev/brokered-access\n' | sha256sum
6b60cca671eb812e3c63332a17262231a9b8d7dff6f5f53465232aba16567f9c  -
```

This equals field 3 of `corpus/source-fetches.tsv:39`. The row has 16 fields, no
embedded tabs, one occurrence in the file (no duplicate-provenance), and every
`SC_FETCH` predicate (`corpus/sources-census.sh:250-305`) replays cleanly for
S019 when applied by hand.

**S019 row result: verified; no falsifying datum.**

---

## 3. Findings

### 3.1 F1 — BLOCKER (operability): `SC_FETCH` never evaluates S019

```console
$ cd /home/vgpnk/Projects/shokunin/kagi-shokunin
$ bash corpus/sources-census.sh >/tmp/r23s019.RahVu7/census.stdout \
    2>/tmp/r23s019.RahVu7/census.stderr
exit=1
$ wc -c </tmp/r23s019.RahVu7/census.stdout
0
$ cat /tmp/r23s019.RahVu7/census.stderr
corpus/sources-census.sh: line 242: S007: unbound variable
```

- `corpus/sources-census.sh:107` sets `set -uo pipefail`.
- `corpus/sources-census.sh:229` declares `FURL`, `FINROW`, `FSEEN`, `FDIG`,
  `FNRM` with `declare -A`; `SUPERSEDED` is **not** declared.
- `corpus/sources-census.sh:242` writes `SUPERSEDED[$fid]=1`. With no
  associative declaration the subscript is arithmetic; the first id emitted by
  the `supersedes S…` awk is `S007` (from `corpus/SOURCES.md:25`, i.e. **S019's
  own supersession edge**), so `$fid` expands as variable `S007`, which is
  unbound.
- Minimal repro: `bash -c 'set -u; FOO=(); foo=S007; FOO[$foo]=1'` → `S007:
  unbound variable`; with `declare -A FOO=()` the same script prints `ok`.
- `SUPERSEDED` is written but never read (only reference: line 242), so the
  loop is dead code whose only effect is the abort.
- The crash precedes the fetch block (`corpus/sources-census.sh:247`), so zero
  `SC_FETCH` checks run; stdout is empty and the "VERDICT (last line, always)"
  contract (`corpus/sources-census.sh:93`) and the verdict printers at
  `:337-343` are never reached.

Selftest remains green because no case exercises the path:

```console
$ bash corpus/sources-census.sh --selftest
...
SOURCES_CENSUS_SELFTEST: PASS (59 cases)
exit=0
```

The base fixture's teaches cells are `teaches one/two`, `lead three`, `product
four` (`corpus/sources-census.sh:353-376`) and the 59-case table
(`:510-570`) injects no `supersedes` cell; `grep -n supersedes` finds only lines
242 and 245. The green 59-case count is therefore not evidence for the
production path.

Diagnostic isolation (no lane edit): copy `corpus` to `/tmp`, add only
`SUPERSEDED=()` to the `declare -A` line of a copied script, and run
`verify --root` on the copy:

```console
$ sed 's/declare -A FURL=() FINROW=() FSEEN=() FDIG=() FNRM=()/& SUPERSEDED=()/' \
    corpus/sources-census.sh > /tmp/r23s019gate.*/census.patched
$ bash /tmp/.../census.patched verify --root /tmp/.../root
SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)
exit=0
```

No `S019` line appears in that output: once the dead loop is neutralized, the
S019 provenance row produces no finding. The failure is the gate, not S019's
data.

Consequence for this seat: the round's claimed evidence command
(`corpus/lessons/round-23.md:61`) and its end-of-round statement "census at
round end must exit 0 with the same W04 warnings and `rows=26`"
(`corpus/lessons/round-23.md:168-170`) are not reproducible. S019's provenance
was never machine-verified by the shipped command; the verification in §1-2 is
external. Independently reproduced; same defect already reported at
`RevS022.md:91` and `MutFetchRemove.md:123`.

### 3.2 F2 — LOW (locator precision): S019 `location` is not in the fetched representation

The field is defined as "section/heading the quote was located under"
(`corpus/source-fetches.tsv:30`). For S019 it declares `Introduction`. The
substring `introduction` occurs **0 times** in the raw 1,199,447-byte body and
0 times in the 6,019-character normalized text (no heading, no id, no anchor,
no text). The rendered headings are:

```text
H1  Set up 1Password Credential Broker to allow your team to access secrets in their workflows (public preview)
H2  Add an integration
H2  Delete an integration
H2  Learn more
```

The quote is in the untitled lead paragraph directly beneath the H1, so
"Introduction" names the correct region semantically; it is **not** a
wrong-section label of the S022 kind. But it is the only row whose `location`
is not an actual heading/H1: `page title/H1` (S017/S018), `New in this
release`, `Token Time-To-Live`, `JWT verification, Vault 1.17 note`, `Lease,
renew, and revoke`, `POST /:secret-mount-path/config parameters, max_versions`,
`H1 JWT/OIDC auth method`, `Token hierarchies and orphan tokens`. The inherited
registry anchor repeats the label (`corpus/SOURCES.md:25`). The census only
checks `${#floc} -ge 8` (`corpus/sources-census.sh:280`), so this cannot be
caught by the gate. Scope: precision only; no effect on the digest, quote text,
or claim.

### 3.3 F3 — INFO (freshness accounting): "seven distinct URLs" is nine

```console
$ awk -F'\t' '!/^#/ && NF==16 {print $4}' corpus/source-fetches.tsv | sort -u | wc -l
9
$ grep -c '^S0' corpus/source-fetches.tsv
10
$ awk -F'\t' '$1 ~ /^S01[7-9]$/ || $1 ~ /^S02[0-3]$/ {print $4}' corpus/source-fetches.tsv | sort -u | wc -l
7
```

Ten rows cover nine distinct URL strings; only `https://openbao.org/docs/concepts/tokens/`
is repeated (S021/S026). The wording "10 declared provenance rows (S017-S026)
over seven distinct URLs" (`corpus/lessons/round-23.md:164-165`) uses the
S017-S023 subset count. Registry-side counts are correct: 26 rows, 19 distinct
URLs (`corpus/lessons/round-23.md:162-163`; independently counted). No counting
command accompanies the seven. Independently reproduced; also reported at
`RevS022.md:133-155` and `MutFetchRemove.md:143-150`.

### 3.4 F4 — INFO (calibration): D7 "fixed" is pointer existence, not execution

`python3 corpus/closure-dispositions.py` → exit 0,
`CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=7 reported=2 operator_owned=1 no_action=5 rejected=0 pointers=15)`.
D7 (`corpus/closure-dispositions.json:91`) is `fixed` with pointer
`corpus/source-fetches.tsv`, which exists. The gate's own docstring bounds this
as pointer resolution only (`corpus/closure-dispositions.py:41-44`: "A `fixed`
pointer proves a reviewed record exists at that path, not… admission"). So C1
CLEAN must not be read as proof that the C2 runtime check listed in the same
round actually runs; F1 shows it does not. This is a calibration caveat about
reading the disposition, not a defect in C1's stated contract.

### 3.5 F5 — INFO (evidence provenance): the five W04 lines are not reproducible or verbatim on this host

`command -v kagi` → absent (exit 1); `kagi ok …/corpus/SOURCES.md` → exit 127
(`bash: kagi: command not found`). No in-repo script emits `W04`:
`grep -rn W04 --include=*.sh corpus/` → no matches. The only retained source of
the warning text is the round-22 capture
`.ufo/waves/round-22/final-verification.json` (`additional/6/stdout`):

```text
kagi\tW04\tS019 duplicate url www.1password.dev/brokered-access across scopes
kagi\tW04\tS020 duplicate url 1password.com/blog/1password-credential-broker-public-preview across scopes
…
kagi\tok\t/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/SOURCES.md
```

`corpus/lessons/round-23.md:66-72` claims to quote these "verbatim" but prints
`W04 S019 duplicate url …` with the `kagi\t` framing removed. The warning body
text matches; the verbatim claim and the present-tense "the census prints"
(`:66`) are not reproducible this round. This is a provenance-of-evidence
caveat around the S019 line, not a defect in S019's row.

### 3.6 F6 — INFO (representation wording): `volatile` is defensible; "stable identity" is overstated

S019 carries a deployment id (`?dpl=dpl_8AUWT8nFRmT7D3RgoEGEPVymfFQP`), so the
`decoded-http-body-volatile-v1` label is defensible under the header's
"deployment/response-coupled" definition (`corpus/source-fetches.tsv:17-21`),
even though three same-day GETs were byte-identical. The lesson's concrete
evidence for volatility is written only for S020
(`corpus/lessons/round-23.md:45-50`), while all ten rows carry the label. The
header's "the normalized digest is the stable declared identity"
(`corpus/source-fetches.tsv:19-20`) reads as invariance, but the lesson itself
says page chrome moved S017's normalized digest between days
(`corpus/lessons/round-23.md:52-54`), and S019's normalized text includes
navigation/TOC text (`Documentation Index`, `On this page`, `Copy page Copy
page`). "Stable" must therefore mean "the declared comparison identity", not
"unchanged across chrome changes". No S019 digest is falsified; this bounds what
the normalized digest can prove.

---

## 4. Residual risk and verification gaps

- Point attestation only: three GETs are consistent with one Vercel deployment
  object (`age: 11996`, weak ETag, `x-vercel-cache: MISS`, `cache-control:
  no-store`, `vary: User-Agent`). Origin drift between captures is untested; a
  matching digest proves equality with this serving path now, not vendor truth
  or future content.
- The gate does not re-fetch and does not verify quote presence or that the
  declared normalization was applied; it checks shape, row identity and
  same-URL agreement only (`corpus/sources-census.sh:250-305`; quote bound and
  location length at `:272`, `:280`). The live verification in §1-2 is the only
  check that the S019 quote and normalization actually reproduce.
- The normalized digest includes page chrome and nav, so the same-URL
  normalized-agreement check would fire on a sidebar/TOC change; the lesson
  concedes this for S017. It is not evidence of article drift.
- `decoded-http-body-volatile-v1` disables the raw same-URL agreement check for
  S019; there is only one S019 capture in this table, so neither raw nor
  normalized same-URL comparison is exercised for this URL.
- `kagi` is absent on this host, so the five W04 lines could not be
  re-measured this round; their only retained source is the round-22
  verification artifact.
- The line-242 repair was validated only in a `/tmp` copy; the lane was not
  modified. S019's row, the TSV, the census script and the lesson bytes were
  unchanged by this seat (`tmp` copy discarded by scope).

---

## 5. Exact reproduction

```sh
lane=/home/vgpnk/Projects/shokunin/kagi-shokunin
work=/tmp/r23s019.RahVu7; mkdir -p "$work"; cd "$work"

# 1. declared fetch profile
curl -fsSL --compressed \
  -A 'kagi-shokunin-round23/1.0 (documentation verification)' \
  -o body.html -w 'final=%{url_effective} http=%{http_code} size=%{size_download}\n' \
  https://www.1password.dev/brokered-access
sha256sum body.html; wc -c <body.html
# 67f690e2…43c312 / 1199447

# 2. row identity
printf 'S019\tmined\thttps://www.1password.dev/brokered-access\n' | sha256sum
# 6b60cca6…f67f9c

# 3. rendered-text-v1
python3 - <<'PY'
import re, html, hashlib
h = open('body.html', encoding='utf-8').read()
s = re.sub(r'<(script|style)\b[^>]*>.*?</\1\s*>', ' ', h, flags=re.I | re.S)
s = re.sub(r'<[^>]*>', ' ', s)
s = html.unescape(s)
s = re.sub(r'\s+', ' ', s).strip()
print(len(s), hashlib.sha256(s.encode('utf-8')).hexdigest())
q = 'administrators can set up a supported integration in their 1Password Business account'
print('quote_count', s.count(q), 'quote_index', s.find(q), 'introduction_count', s.count('Introduction'))
PY
# 6019 f3861c17…38cc6e9 ; quote_count 1 ; introduction_count 0

# 4. production gate (fails)
cd "$lane"
bash corpus/sources-census.sh >/tmp/r23s019.RahVu7/census.stdout 2>/tmp/r23s019.RahVu7/census.stderr
echo "gate_exit=$?"            # 1
wc -c </tmp/r23s019.RahVu7/census.stdout   # 0
cat /tmp/r23s019.RahVu7/census.stderr      # line 242: S007: unbound variable

# 5. selftest (green but blind)
bash corpus/sources-census.sh --selftest | tail -1   # PASS (59 cases), exit 0

# 6. cardinality
awk -F'\t' '!/^#/ && NF==16 {print $4}' corpus/source-fetches.tsv | sort -u | wc -l   # 9
```
