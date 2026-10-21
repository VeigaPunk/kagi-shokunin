# CritNormalizer — `rendered-text-v1` reproducibility (round 23, falsify seat)

**Verdict: counterexample found. This is a fixable defect, not a tradeoff.** All ten recorded
`normalized_sha256` values can be reproduced, but only by an implementation that makes the
same undeclared choices as the author's unpublished code. I re-captured the same bytes: for 9 of
10 rows they are byte-identical to the recorded representation. On those bytes, two
`rendered-text-v1` implementations that both follow the prose produce different digests:

- **5/10 rows** at the final anchor `def9bc2e`: S017, S018, S019, S024 and S025. The cause is
  the HTML-comment rule.
- **7/10 rows** under the dispatched wording. Before `collapse Unicode whitespace (Python \s)`
  was added to the TSV header, the whitespace rule also split S022, S023 and S024.
- **10/10 rows** if "rendered" text is read as `<body>`-only.

`SC_FETCH` checks only the shape of `normalized_sha256`. It accepts the recorded value, a value
from another compliant implementation, and 64 zeros, and returns the same CLEAN line for all
three. The lane retains no capture bytes and no executable normalizer.

## 0. What was attacked; tree state (the lane moved during this audit)

The target was the prose definition at `corpus/source-fetches.tsv:27-29`, plus the same text
copied at `corpus/sources-census.sh:73-74` and `corpus/lessons/round-23.md:39-42`. I checked it
against the ten rows S017–S026 (`source-fetches.tsv:38-47`).

The lane was committed and re-edited several times while I worked:

| tree state | time | what changed |
|---|---|---|
| dispatch (uncommitted on `d218603b`) | ~03:5xZ | starting state |
| `ea5b734`, `b55e0e7`, `7af07b4` | 04:05–04:09Z | intermediate commits |
| `284d40e0` | 04:09Z | census had a same-URL normalized-equality check |
| `638d44c4` | 04:11Z | that check was removed; the TSV header pinned `Python \s` |
| **`def9bc2e`** | **04:11:47Z** | **final anchor** |

All final results below are anchored to a read-only `git archive def9bc2e corpus` snapshot. At
that snapshot:

- TSV `6e26e140…`
- census `511deb27…`
- lesson `49632920…`

The ten rows' digest columns (id, sha256, bytes, normalized_sha256) never changed across any
state I saw. Their projection hash was `77e5b1a4…` every time.

## 1. Re-capture: the recorded bytes are recoverable today for 9/10 rows

I ran the declared request profile once for each of the 9 distinct URLs at `2026-10-21T03:57:57Z`:

`curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' -D <k>.hdr -o <k>.body -w '%{url_effective}\t%{http_code}' <url>`

Every fetch returned rc=0 and HTTP 200, and every final URL equals the TSV `final_url`. S021 and
S026 share one URL.

| row | decoded bytes | raw sha256 vs TSV |
|---|---|---|
| S017 S018 S019 S021 S022 S023 S024 S025 S026 | equal | **equal** (byte-identical) |
| S020 | 190,261 = | ≠ (`db9cc70a…` vs `53dfeac5…`, Cloudflare per-response token, as the row declares) |

The lane itself holds no capture. Two checks show this:

- `find . -path ./.git -prune -o -type f \( -size 1215460c -o … -size 63046c \) -print` printed
  nothing (exit 0).
- No `.py`, `.sh`, `.js` or `.mjs` file implements the normalizer. `grep -rln -e 'html.unescape'
  -e 'unescape(' --include=…` matches only `corpus/sources-census.sh`, in its header comment
  (`:74`).

Reproduction is therefore possible only through a live re-fetch. It worked today because the
servers happened to still serve the same bytes, not because the lane retained anything.

## 2. Can each row's normalized_sha256 be independently reproduced? Yes, under one reading

The recorded values for all 10 rows are reproduced by this whole-document reading:

```python
t = body.decode("utf-8")                                              # strict; all 9 pages valid, no BOM
t = re.sub(r"(?is)<(script|style)\b[^>]*>.*?</\1\s*>", " ", t)        # '' gives the same result here
t = re.sub(r"<[^>]+>", " ", t)                                        # comments/doctype count as "tags"
t = html.unescape(t)
t = re.sub(r"\s+", " ", t).strip()                                    # Python \s: collapses U+00A0
sha256(t.encode("utf-8"))
```

Independent engines that agree with the recorded values:

- Python `re`.
- BeautifulSoup 4.15.0 `get_text(" ")`, with both the `html.parser` and `lxml` builders.
- node v24.21.0 `t.replace(/\s+/g," ").trim()` as the whitespace step, run on S017, S020 and
  S022–S026; every result equals the recorded value.

S020's recorded `20b4fd86…` also reproduces from my non-identical capture. That confirms the
row's volatility claim.

Under every one of the 108 readings tested:

- The quote is present: at least 1 hit for all 10 rows. S017, S018 and S024 have 3 hits each.
- The text is NFC-stable.

## 3. Strongest counterexample: S025, the "corrected active locator" row

- The row (`source-fetches.tsv:46`) records raw `449ef132…`, 63,046 B and normalized `ca496ad8…`.
- My re-capture is **byte-identical** to it.
- The raw page contains `where "host<!-- -->:port<!-- -->" is the OpenBao server name …`, twice.
  These are React text separators.

Two implementations that both satisfy "strip script/style, tags -> single space, html.unescape,
collapse Unicode whitespace (Python \s), trim, UTF-8" disagree on these bytes:

| implementation | text produced | sha256 |
|---|---|---|
| regex `<[^>]+>` (treats a comment as a "tag") | `where "host :port " is the OpenBao server name` | `ca496ad8…` = **recorded** |
| Python stdlib `html.parser` tokenizer: start/end tags → `' '`; a comment is a comment token, not a tag | `where "host:port" is the OpenBao server name` | `90da1520ddb0bd5da0dffad501808048bce8845ac1c2ebd986fc133171227a9d` |
| libxml2 2.14.6 via lxml 6.1.3 (comments stripped, `itertext` joined with `' '`) | same as `html.parser` | `90da1520…` |

The HTML Standard tokenizes comments separately from tags, and a browser renders
`"host:port"`. The recorded digest therefore depends on an undeclared idiom, and it encodes text
the page does not render.

`SC_FETCH` cannot tell which value is correct. In scratch copies built from the `def9bc2e`
snapshot, `bash <snap>/corpus/sources-census.sh verify --root <scratch>` gives:

| variant | change made in the scratch copy | exit | output |
|---|---|---|---|
| base | none | 0 | `SOURCES_CENSUS: CLEAN (rows=26 …)` |
| m2 | S025 normalized → `90da1520…` (html.parser) | 0 | identical CLEAN line |
| m1 | S024 normalized → `463ddab2…` (GNU tr/sed reading) | 0 | identical CLEAN line |
| m3 | S024 normalized → 64×`0` | 0 | identical CLEAN line |

The reason is that `sources-census.sh:269-273` checks only `^[0-9a-f]{64}$`.

## 4. Every disagreement axis measured (byte-identical captures)

The scratch harness is `/tmp/kagi-r23-CritNormalizer/norm.py` (sha256 `714885ff…`). It ran
108 readings × 10 rows, exit 0, and wrote `matrix.json`.

The axes:

- **A. Is an HTML comment a "tag"?** Unpinned at `def9bc2e`. It splits S017, S018, S019, S024
  and S025:
  - S017–S019: `⌘<!-- -->K` becomes `⌘ K` in the recorded text but `⌘K` from the parser.
  - S024: `|<!-- -->:----------<!-- -->|` becomes `| :---------- |` in the recorded text but
    `|:----------|` from the parser.
- **B. Whitespace class.** Pinned in the TSV only at `638d44c4` (`source-fetches.tsv:28`). It
  splits S022, S023 and S024, because those pages contain U+00A0:
  - HashiCorp nav chrome: `Vault\xa0`.
  - S024 body text: `(Map: <required>) –\xa0The contents of the data map`.
  - GNU coreutils `tr` 9.12 `-s '[:space:]'` and GNU sed 4.10 multibyte `[[:space:]]`
    (glibc, `C.UTF-8`) both leave NBSP in place, as does HTML-Standard "ASCII whitespace".
    They give `37a4eaf1…`, `3410ba6d…` and `463ddab2…` instead of the recorded values.
  - Python, JS and Unicode `White_Space` readings collapse NBSP and match.
- **C. Scope.** Unpinned. The recorded digests are whole-document, including `<head><title>`.
  A `<body>`-only ("rendered") reading differs on **10/10** rows; for example S025 gives
  `05bd3227…` and S021/S026 give `6d6c132a…`.
- **D. Step order.** `html.unescape` before tag stripping differs on 7/10 rows (S017, S018,
  S019, S020, S022, S024, S025). This is the weakest axis, because the list order implies a
  sequence; RevS017 found the same.
- **E. Another implementation already in the evidence trail.** The parent auditor's own
  projection for S019 strips `svg` and maps `’` to `'`
  (`.ufo/waves/round-23/parent-build/SourceS019.md:63-64,133`). It does **not** reproduce S019's
  recorded `f3861c17…` (10 `’` in the text). It also fails for S017, S018, S020 and S024.
- **Did not diverge on these captures:**
  - script/style replaced with `''` vs `' '`, and case-sensitive matching;
  - `<[^>]+>` vs `<[^>]*>`;
  - input decoding (all 9 pages are strict UTF-8 with no BOM; the decoding is still undeclared);
  - NFC.

Per-row results:

| row | ordered whole-document digests at `def9bc2e` (Python `\s` pinned) | plus dispatched whitespace ambiguity |
|---|---|---|
| S017, S018, S019, S025 | 2 (axis A) | 2 |
| S022, S023 | 1 | 2 (axis B) |
| S024 | 2 (A) | 4 (A × B) |
| S020, S021, S026 | 1 | 1 |

## 5. Consequences observed at intermediate states

At `284d40e0`, the census enforced same-URL normalized equality
(`git show 284d40e:corpus/sources-census.sh`: the block at lines 275-290, normalized check at
:285-290). Even so, its own header (`:64-66`) and the TSV (`:21`) said "No cross-capture
equality is enforced."

I added a scratch row S027 for S025's URL, with the identical decoded body and the html.parser
digest. Result:

- exit 1, `FINDING SC_FETCH id=S027 same-url-normalized-disagreement url=https://openbao.org/docs/auth/jwt/`
- The control row carrying the recorded-reading digest passed with exit 0.

So an honest second capture failed the gate with no change in content. `638d44c4` removed the
check; at `def9bc2e` the same pair exits 0/0. If any equality check is reintroduced before the
normalizer is executable, this false failure comes back.

## 6. Duplicate authorities, now divergent

There are three prose copies of one definition:

| location | whitespace wording |
|---|---|
| `source-fetches.tsv:27-29` | `collapse Unicode whitespace (Python \s)` |
| `sources-census.sh:73-74` | `collapse whitespace` |
| `lessons/round-23.md:39-42` | `collapse whitespace` |

Parent audits had already asked for a deterministic rule, a `quote_sha256`, or committed text:

- `parent-build/SourceS018.md:136-138`
- `parent-build/SourceS005.md:166-169`: "`normalized_sha256` alone cannot prove quote presence"

The census selftest never computes a normalized digest:

- Its fixtures carry the synthetic digests `$(rep 1 64)` and `$(rep 2 64)`
  (`sources-census.sh:376-377`).
- `fetch-normsha` only blanks the field (`:416`, `:549`).

The lesson's "Falsification bounds" (`lessons/round-23.md:181-193`) contain no
normalizer-underdetermination bound.

## Impacted axes

- **freshness (C2/D7), primary.** For all 10 rows, which are `decoded-http-body-volatile-v1`,
  the normalized digest is the declared stable identity. Any re-check made with an independent
  implementation will report drift on 5/10 rows (7/10 under the dispatched wording) even though
  no byte changed. The alternative is to tune the implementation until it matches.
- **calibration.** "Declared normalization" reads as reproducible provenance. In fact it is
  reproducible only by reverse-engineering undeclared choices, and three copies of the
  definition disagree.
- **operability.** No command in the lane computes `rendered-text-v1`, so an operator cannot
  re-verify any row without writing a normalizer.

## Smallest safe correction

1. **Commit the normalizer.** Add `corpus/rendered-text-v1.py`: the six stdlib lines in §2
   (strict UTF-8, whole document, comments and doctype treated as tags, Python `\s`, listed
   order). Point `source-fetches.tsv:27-29`, `sources-census.sh:73-74` and
   `lessons/round-23.md:39-42` to it by path and sha256, so there is one authority and three
   pointers.
2. **Add one conformance vector to `--selftest`.**
   - Input: `<html><head><title>T</title><style>s{}</style></head><body>⌘<!-- -->K a&nbsp;b &lt;c&gt;<script>x</script></body></html>`
   - Expected text: `T ⌘ K a b <c>`, sha256 `40484996b72d2a9faf849d02806c7a8aad96ba7436c5e760cc66f055a4b10d09`.
   - It distinguishes every rival reading:

     | rival reading | digest |
     |---|---|
     | comments not tags | `97baac64…` |
     | ASCII whitespace | `da171c6a…` |
     | `<body>` only | `1a619fdc…` |
     | unescape first | `c5e930d5…` |

3. **State the bound.** Add to the TSV header and the lesson bounds: "normalized_sha256 is
   reproducible only with that file; SC_FETCH checks its shape, never its value; capture bytes
   are not retained."
4. **Fix the name, or bound it.** "rendered" is inaccurate: the text includes `<title>` and
   inserts spaces at comment and inline boundaries (`"host :port "`, `⌘ K`). Either supersede the
   name or state this as a bound.

What the judge can credit at `def9bc2e`:

- the raw digest and byte count for 9/10 rows (byte-exact today);
- S020's normalized reproduction;
- quote presence.

It should not credit "declared normalization" as reproducible provenance until items 1–2 land.

## Commands and exits

| # | command | exit / result |
|---|---|---|
| 1 | `curl …` ×9 (§1) | rc=0 ×9 |
| 2 | `python3 /tmp/kagi-r23-CritNormalizer/norm.py` | 0 |
| 3 | `LC_ALL=C.UTF-8 /usr/bin/tr -s '[:space:]' ' ' < pre-S0xx.txt \| LC_ALL=C.UTF-8 /usr/bin/sed -E 's/^ +//; s/ +$//' \| sha256sum` | 0 |
| 3 | `LC_ALL=C.UTF-8 /usr/bin/sed -zE 's/[[:space:]]+/ /g; s/^ +//; s/ +$//' pre-S0xx.txt \| /usr/bin/tr -d '\000' \| sha256sum` | 0; same digests as the `tr` pipeline |
| 4 | `node -e '…t.replace(/\s+/g," ").trim()…'` | 0 |
| 5 | `bash corpus/sources-census.sh` (lane, several states) | 0, CLEAN |
| 5 | `bash corpus/sources-census.sh --selftest` | `SOURCES_CENSUS_SELFTEST: PASS (59 cases)`, exit 0 |
| 5 | the same two at the `def9bc2e` snapshot | 0 / 0 |
| 6 | `git archive def9bc2e corpus \| tar -x` (read-only export), then `python3 mk_scratch.py <snap> <root> <variant>` (sha256 `d6323096…`) and `bash <snap>/corpus/sources-census.sh verify --root <root>` | base / m1 / m2 / m3 / m4-control / m4-parser: 0 / 0 / 0 / 0 / 0 / 0 |
| 6 | the same with `284d40e`'s census | m4-parser exit 1 (§5) |

The bash tool's built-in `tr`/`sed` (versions 0.8.0 and 0.1.1) were used in a first pass. All
shell results cited above were re-run with `/usr/bin` GNU binaries. The built-in `sed -z` left
newlines in its output, so its result was discarded.

## Bounds and non-actions

- Writes went only to this report and to the scratch directory `/tmp/kagi-r23-CritNormalizer/`,
  which holds the bodies, `matrix.json`, the scripts and the census copies.
- No edit to the lane, no git mutation, no install.
- No reads of host, vault or credentials.
- No legacy verify and no claim-ledger row was run.
- "Rendered by a browser" is [INFERENCE] from HTML comment semantics; no browser was run.
- Raw byte identity holds for the 03:57Z capture only.
