# RevS019 — round-23 falsification: S019 live re-measure

Seat: RevS019 (falsification). Date: 2026-10-21 (UTC). Base:
`d218603b74099ddca0bd8f869516fc41db0979bf` plus the round-23 tree at
`/home/vgpnk/Projects/shokunin/kagi-shokunin`.

The tree moved repeatedly while this seat measured (integrator commits
`ea5b734`, `b55e0e7`, `7af07b4`, `284d40e`, `638d44c`, `def9bc2e`, plus
working-tree edits). The S019 row is byte-identical in every state; the gate
and the provenance wording changed under the seat. Measurements are pinned to
the attacked state and to the write-time state; intermediate changes are named
where they bear on a finding. No lane edits by this seat; scratch only under
`/tmp`; this report is the only write.

| state | when | HEAD | `SOURCES.md` | `source-fetches.tsv` | `sources-census.sh` | `lessons/round-23.md` |
|---|---|---|---|---|---|---|
| A (attacked as delivered) | before 01:02 | `d218603` + dirty tree | `06dde644…` | `ccc9ae6e…` | `80966e20…` | `d5520988…` |
| D (final at write) | 2026-10-21T04:14Z | `def9bc2e` | `c6ea91ab…` | `6e26e140…` | `511deb27…` | `93df7d34…` |

Host: bash `5.3.20(1)-release`, curl `8.23.0`. At state D the S019-bearing
files (`SOURCES.md`, `source-fetches.tsv`, `sources-census.sh`) were clean;
`lessons/round-23.md` and `stamps.tsv` carried uncommitted integrator edits that
do not touch the S019 row. The S019 registry row (`SOURCES.md:25`) and provenance
row (`source-fetches.tsv:40`) are unchanged from state A in every field that
matters (status, URL, digests, quote).

**Verdict.** The S019 provenance row reproduces on every declared field —
registered URL, final URL, HTTP 200, decoded byte count, raw sha256,
row-identity sha256, `rendered-text-v1` sha256, and the located quote — against
three byte-identical fetches. **No wrong digest and no stale capture.** The
current gate evaluates S019: deleting the row yields `SC_FETCH id=S019
missing-provenance`; zeroing its row-identity digest yields `SC_FETCH id=S019
row-identity-digest-mismatch`; the pristine tree is `CLEAN (rows=26 …)`, exit 0,
and the 59-case selftest passes. State A had a real blocker (the census aborted
at its `SUPERSEDED` line before any `SC_FETCH` check), plus three
wording/accounting defects ("seven distinct URLs", "stable declared identity",
and later a "no cross-capture equality" claim contradicted by the gate); all
were repaired by the integrator during this seat's run and are recorded in §3.4
as historical, not current. Current findings: one LOW locator caveat (S019's
`location` is not present in the representation) and two INFO caveats
(W04/`kagi` reproducibility, D7 pointer existence vs execution).

---

## 1. S019 fetch with the declared profile

Declared profile: `corpus/source-fetches.tsv:12-13`
(`curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' <url>`).
Registered row: `corpus/SOURCES.md:25`; provenance row: `corpus/source-fetches.tsv:40`.

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

Two further GETs (`body2.html`, `body3.html`) produced identical bytes: same
sha256, same 1,199,447 B, `cmp` exit 0 each time. Headers from a third GET:

```text
HTTP/2 200
content-encoding: br
etag: W/"z6d2q9klrgppcp"
age: 11996
cache-control: no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0
server: Vercel
vary: rsc, accept-encoding, Accept, User-Agent
x-vercel-cache: MISS
```

`size_download=166493` is the wire (brotli) size; the declared `bytes` is the
decoded body (`corpus/source-fetches.tsv:15-16`), measured 1,199,447 by
`wc -c`. No mismatch. The body contains `?dpl=dpl_8AUWT8nFRmT7D3RgoEGEPVymfFQP`
asset URLs, so the HTML is deployment-coupled even though three
same-deployment GETs were byte-identical.

---

## 2. Row verification

### 2.1 Declared vs measured

`rendered-text-v1` recomputed with the algorithm declared at
`corpus/source-fetches.tsv:27-29` (strip `script`/`style` with contents, tags to
a single space, `html.unescape`, collapse Unicode whitespace, trim, UTF-8):

```python
h = open('body.html', encoding='utf-8').read()
s = re.sub(r'<(script|style)\b[^>]*>.*?</\1\s*>', ' ', h, flags=re.I | re.S)
s = re.sub(r'<[^>]*>', ' ', s)
s = html.unescape(s)
s = re.sub(r'\s+', ' ', s).strip()
hashlib.sha256(s.encode('utf-8')).hexdigest()
```

| field | declared (`source-fetches.tsv:40`) | measured | result |
|---|---|---|---|
| status | `mined` | registry `mined` (`SOURCES.md:25`) | equal |
| url | `https://www.1password.dev/brokered-access` | registered URL, same string | equal |
| final_url | same | `%{url_effective}` = same | equal |
| http_status | `200` | `200` | equal |
| request_profile | `curl-fsSL-compressed-v1` | exact command above | equal |
| fetched | `2026-10-21` | 2026-10-21 | equal |
| representation | `decoded-http-body-volatile-v1` | decoded body; deployment-coupled via `?dpl=` | declared domain |
| sha256 | `67f690e21116a364…43c312` | `67f690e21116a364…43c312` | equal |
| bytes | `1199447` | `1199447` | equal |
| revision | `-` | URL is not a moving ref | applicable |
| quote | `administrators can set up a supported integration in their 1Password Business account` | exact substring, 1 occurrence in normalized text | located |
| normalization | `rendered-text-v1` | same algorithm | applied |
| normalized_sha256 | `f3861c172c370dd1…38cc6e9` | `f3861c172c370dd1…38cc6e9` | equal |
| location | `Introduction` | 0 occurrences in the page; see §3.1 | precision caveat |

Normalized text length: 6,019 characters. Quote index: 1508; the article's
`Add an integration` H2 body offset is 2207, so the quote precedes the first
body section. The quote is visible article content, not a script payload: in
raw HTML it begins at offset 98,901 inside `<div … id="content">` →
`<span data-as="p">` → `…</a>, administrators can set up a supported integration
in their 1Password Business account …`. The raw HTML has three occurrences (one
visible, two inside the RSC script payload that `rendered-text-v1` strips); the
normalized text has exactly one.

### 2.2 Row identity

```console
$ printf 'S019\tmined\thttps://www.1password.dev/brokered-access\n' | sha256sum
6b60cca671eb812e3c63332a17262231a9b8d7dff6f5f53465232aba16567f9c  -
```

Equals field 3 of `corpus/source-fetches.tsv:40`. Sixteen fields, no embedded
tabs, one occurrence in the file (no duplicate-provenance).

### 2.3 The current gate enforces S019 (state D)

```console
$ bash corpus/sources-census.sh
SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)
exit=0

$ # /tmp copy of corpus only; production tree untouched
$ awk -F'\t' 'BEGIN{OFS="\t"} $1!="S019"' f.pristine > root/corpus/source-fetches.tsv
$ bash corpus/sources-census.sh verify --root "$w/root"
FINDING SC_FETCH id=S019 missing-provenance
SOURCES_CENSUS: FAILED (findings=1 rows=26)
exit=1

$ awk -F'\t' 'BEGIN{OFS="\t"} $1=="S019"{$3=sprintf("%064d",0)} {print}' f.pristine \
    > root/corpus/source-fetches.tsv
$ bash corpus/sources-census.sh verify --root "$w/root"
FINDING SC_FETCH id=S019 row-identity-digest-mismatch
SOURCES_CENSUS: FAILED (findings=1 rows=26)
exit=1
```

Both mutants are killed by the current script (`511deb27…`), so S019 is in the
gate's scope, not silently exempt. The 59-case selftest passes (`PASS (59
cases)`, exit 0; three consecutive runs plus a fourth after the final commit).

---

## 3. Findings

### 3.1 F1 (current, LOW) — S019 `location` is not in the fetched representation

`corpus/source-fetches.tsv:40` declares `Introduction`; the field is defined as
"section/heading the quote was located under" (`:31`). The substring
`introduction` occurs 0 times in the 1,199,447-byte raw body and 0 times in the
6,019-character normalized text (no heading, id, anchor, or text). Rendered
headings:

```text
H1  Set up 1Password Credential Broker to allow your team to access secrets in their workflows (public preview)
H2  Add an integration
H2  Delete an integration
H2  Learn more
```

The quote sits in the untitled intro block beneath the H1, so the label names
the right region semantically — this is not the S022 wrong-section case. But it
is the only row whose location is not an actual heading/H1 (`page title/H1`,
`New in this release`, `Token Time-To-Live`, `JWT verification, Vault 1.17
note`, `Lease, renew, and revoke`, `POST /:secret-mount-path/config parameters,
max_versions`, `H1 JWT/OIDC auth method`, `Token hierarchies and orphan
tokens`). The label is inherited from `corpus/SOURCES.md:25`. The gate checks
only `${#floc} -ge 8` (`corpus/sources-census.sh:274`), and the round now
declares that bound (`corpus/lessons/round-23.md:191-192`: "quote text and
location are not checked against the page"). Scope: locator precision only;
the digest and quote are correct, and the gate's shape-only bound is honest.

### 3.2 F2 (current, INFO) — the five W04 lines are not reproducible or verbatim here

`command -v kagi` → absent (exit 1); `kagi ok …/corpus/SOURCES.md` → exit 127
(`command not found: kagi`). No in-repo script emits `W04`
(`grep -rn W04 --include=*.sh corpus/` → no matches, exit 1). The only retained
source of the warning text is the round-22 capture
`.ufo/waves/round-22/final-verification.json` (`additional/6/stdout`, line 679):

```text
kagi\tW04\tS019 duplicate url www.1password.dev/brokered-access across scopes
kagi\tW04\tS020 duplicate url 1password.com/blog/1password-credential-broker-public-preview across scopes
…
kagi\tok\t/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/SOURCES.md
```

`corpus/lessons/round-23.md:66-72` claims to quote these "verbatim" but prints
`W04 S019 duplicate url …` with the `kagi\t` framing removed; `:178-180`
conflates them with the in-repo gate's `rows=26` verdict. The warning body text
matches; the "verbatim" and present-tense "the census prints" claims are not
reproducible this round. Evidence-provenance caveat around the S019 line, not a
defect in S019's row.

### 3.3 F3 (current, INFO) — D7 "fixed" is pointer existence, not execution

`python3 corpus/closure-dispositions.py` → exit 0,
`CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=7 reported=2 operator_owned=1 no_action=5 rejected=0 pointers=15)`.
D7 (`corpus/closure-dispositions.json:91`) is `fixed` with pointer
`corpus/source-fetches.tsv`, which exists. The script's own bound
(`corpus/closure-dispositions.py:41-44`) says a `fixed` pointer proves a reviewed
record exists at that path, not admission. In state D the C2 gate also runs, so
pointer and behavior agree; the caveat is that the closure gate alone could not
have detected state A's inert gate.

### 3.4 Historical (states A-C) — real then, repaired in flight

Not current findings; recorded because the attack target as delivered failed
here. Line numbers refer to the state named in each bullet.

- **State-A blocker.** `bash corpus/sources-census.sh` → exit 1, stdout 0 bytes,
  stderr `corpus/sources-census.sh: line 242: S007: unbound variable` (state-A
  script `80966e20…`). `SUPERSEDED` was assigned at line 242 but not included in
  the `declare -A` at line 229; under `set -u` (line 107) the subscript `S007`
  was arithmetic and unbound. The abort preceded every `SC_FETCH` check (line
  247), so S019's provenance was never machine-verified by the shipped command.
  The 59-case selftest stayed green because the fixture teaches cells were
  `teaches one/two`, `lead three`, `product four` (state-A lines 353-376) and no
  case injected a `supersedes` cell. Cause confirmed by a minimal repro:
  `bash -c 'set -u; FOO=(); foo=S007; FOO[$foo]=1'` fails, while
  `declare -A FOO=()` passes. Repaired before `ea5b734`; state D has no
  `SUPERSEDED` reference (`grep` exit 1) and the gate is CLEAN.
- **"Seven distinct URLs".** Measured 10 rows over 9 distinct URL strings (only
  `https://openbao.org/docs/concepts/tokens/` repeats, S021/S026); state-A
  lesson line 165 said seven. State-D lesson `:174-175` says nine;
  `SCORECARD.md:840` says nine. Repaired.
- **"Stable declared identity".** State-A header said the normalized digest "is
  the stable declared identity" while the lesson conceded chrome can move it
  between days. State-D header `:19-21` says "a more stable point attestation,
  still chrome-sensitive, never a drift pin". Repaired.
- **"No cross-capture equality" vs the gate.** At state C (`24d834cc…`, and
  briefly `6d4190a7…`) both headers said "no cross-capture equality is
  enforced" while the gate still enforced same-URL raw/normalized agreement
  (state-C lines 275-290, `same-url-normalized-disagreement`). Commit `638d44c`
  ("remove cross-capture equality") deleted those checks: state-D
  `grep -n 'same-url\|cross-capture'` returns only the header phrase
  (`no cross-capture equality`), with no `same-url-*` finding id, and the
  header/code now agree. Repaired.

---

## 4. Residual risk and verification gaps

- Point attestation only: three GETs match one Vercel deployment (`age: 11996`,
  weak ETag, `x-vercel-cache: MISS`, `cache-control: no-store`, `vary:
  User-Agent`). A matching digest proves equality with this serving path now,
  not vendor truth or future content; origin drift between captures is untested.
- The gate does not re-fetch and does not verify quote presence, quote text, or
  that the declared normalization was applied; it checks shape, row identity,
  URL/status equality and one-row-per-id
  (`corpus/sources-census.sh:242-277`; quote bound `:266-267`, location length
  `:274`). The live check in §1-2 is the only proof that the S019 quote and
  normalization reproduce. The round now states this bound explicitly
  (`corpus/source-fetches.tsv:25-26`, `corpus/lessons/round-23.md:191-192`).
- The normalized digest includes nav/TOC chrome (`Documentation Index`, `On this
  page`, `Copy page Copy page`), so a future chrome change would move it; the
  round concedes this and no longer enforces cross-capture equality.
- S019 is volatile, so raw same-URL agreement is skipped by design; with one
  S019 row, no same-URL comparison is exercised for this URL.
- `kagi` is absent, so the five W04 lines could not be re-measured; their only
  retained source is the round-22 verification artifact.
- One selftest invocation during the concurrent rewrite reported `FAIL (59
  cases, 1 failed)`; four subsequent runs on the settled script (`511deb27…`)
  pass 59/59. Not reproducible; attributed to reading the script while it was
  being rewritten, not recorded as a finding.
- The tree moved during the seat (`d218603`+dirty → `ea5b734` → `b55e0e7` →
  `7af07b4` → `284d40e` → `638d44c` → `def9bc2e`); state-A hashes/line numbers
  are recorded so the historical findings are replayable. S019 row bytes are
  identical across states.

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

# 4. current gate (state D)
cd "$lane"
bash corpus/sources-census.sh; echo "gate_exit=$?"
# CLEAN (rows=26 …), exit 0
bash corpus/sources-census.sh --selftest | tail -1
# PASS (59 cases), exit 0

# 5. S019 enforcement mutants (on a /tmp copy of corpus only)
w=$(mktemp -d /tmp/r23s019cur.XXXXXX); mkdir -p "$w/root"
cp -a corpus "$w/root/corpus"; cp "$w/root/corpus/source-fetches.tsv" "$w/f.pristine"
awk -F'\t' 'BEGIN{OFS="\t"} $1!="S019"' "$w/f.pristine" > "$w/root/corpus/source-fetches.tsv"
bash corpus/sources-census.sh verify --root "$w/root"   # id=S019 missing-provenance, exit 1
cp "$w/f.pristine" "$w/root/corpus/source-fetches.tsv"
awk -F'\t' 'BEGIN{OFS="\t"} $1=="S019"{$3=sprintf("%064d",0)} {print}' "$w/f.pristine" \
  > "$w/root/corpus/source-fetches.tsv"
bash corpus/sources-census.sh verify --root "$w/root"   # id=S019 row-identity-digest-mismatch, exit 1

# 6. cardinality
awk -F'\t' '!/^#/ && NF==16 {print $4}' corpus/source-fetches.tsv | sort -u | wc -l   # 9
```
