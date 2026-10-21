# RevS026 — round-23 falsification: S026 provenance re-measure

Seat: RevS026 (falsification). Date: 2026-10-21 (UTC), last measurement ~04:19Z
(core artifacts stable; `lessons/round-23.md` moved once more, re-hashed below).
Base: `d218603b74099ddca0bd8f869516fc41db0979bf` plus the uncommitted round-23 tree at
`/home/vgpnk/Projects/shokunin/kagi-shokunin`. Host tools used: bash 5.3.20(1), curl 8.23.0
(OpenSSL 3.6.5), python 3.14.8. No installs/updates this seat.

Final measured snapshot (hash every finding below to these bytes; the lane was edited
concurrently while this seat ran — see §4):

```
c6ea91ab2468352263a7442a2ff7815084d68374c94433bbb6b4cccc639c632d  corpus/SOURCES.md
6e26e14032729070f38b5e0cb90914385f04c0ef9f4fe1db210af6439191094d  corpus/source-fetches.tsv   (S026 at :47)
2d1bbbe36ed21c2755d604937dc10d91fa71645847c82124bf729f4c8e0b95bc  corpus/sources-census.sh
4e971e3d4101d6e28b13d02acbef9adf3ccf16101cfe95831c243891d24029a5  corpus/lessons/round-23.md
94a34c9fd0de49e8d0d6e79843335dc9cc6bb1479d4d84002e2b2297282fe331  SCORECARD.md
d052458cfc0854b1825efb6e9837061270e76443bb9c15aeebcf61ac0a2eced9  LOG.md
```

**Verdict. S026 reproduces exactly on two independent fetches: URL, final URL, HTTP status,
decoded-byte count, raw digest, row-identity digest, rendered-text-v1 normalized digest, quote
and located section all match the declared row. No wrong digest found.** Three residual issues:
one claim-brief cardinality error (the brief says seven URLs; measured nine — the tree's own text
has already been corrected to nine), one low test-naming/coverage defect (`fetch-disagree` now
only proves duplicate-id detection), and one low naming ambiguity ("corrected locator" when the
URL is byte-identical to the superseded row). Two mid-seat defects (a doc/code contradiction I
measured, and the peers' `SUPERSEDED` census crash) were repaired in the
tree while this seat ran; they are recorded in §4 as superseded, not as current findings.

Lane posture: read-only. Every scratch write went to `/tmp/revs026`; the only lane write is this
report. (One initial report write resolved against the session CWD into the parent workspace
`/home/vgpnk/Projects/shokunin/.ufo/...`; it was moved into the lane immediately and the empty
stray tree removed — net write outside the lane: none.) No `git`/`jj` mutation, no
installs/pacman, no host/package/compositor/service changes,
no vault/account commands, no credential contents. `bash corpus/sources-census.sh` is host-free
(it reads only `$ROOT/corpus`) and is the named C2 gate; no claim-ledger row or host-bound check
was executed.

---

## 1. S026 re-measurement

Registry row: `corpus/SOURCES.md:32`. Provenance row: `corpus/source-fetches.tsv:47` (16 fields,
no embedded tabs). Registry extraction uses the census's own awk (status `$9`, URL from `$3`):
`id=S026 status=mined url=https://openbao.org/docs/concepts/tokens/`.

### 1.1 Fetch with the declared profile

```console
$ mkdir -p /tmp/revs026 && cd /tmp/revs026
$ curl -fsSL --compressed \
    -A 'kagi-shokunin-round23/1.0 (documentation verification)' \
    -D s026.headers -o s026.body https://openbao.org/docs/concepts/tokens/
exit=0
$ wc -c s026.body
47384
$ sha256sum s026.body
5229521866ce21fa8cd8f8ecf63d696877b8cb0a2ec25e89de683557b385f82c  s026.body
```

Response headers: `HTTP/2 200`; `content-type: text/html; charset=utf-8`;
`content-encoding: gzip`; `content-length: 12527`;
`last-modified: Tue, 20 Oct 2026 07:50:18 GMT`; `etag: W/"6ad71d3a-b918"`.
One header block only (no redirect hop).

Second independent GET, with final-URL instrumentation:

```console
$ curl -fsSL --compressed \
    -A 'kagi-shokunin-round23/1.0 (documentation verification)' \
    -D s026b.headers -o s026b.body \
    -w 'http=%{http_code} final=%{url_effective} redirects=%{num_redirects} size=%{size_download}\n' \
    https://openbao.org/docs/concepts/tokens/
http=200 final=https://openbao.org/docs/concepts/tokens/ redirects=0 size=12527
exit=0
$ sha256sum s026b.body
5229521866ce21fa8cd8f8ecf63d696877b8cb0a2ec25e89de683557b385f82c  s026b.body
$ cmp -s s026.body s026b.body && echo IDENTICAL
IDENTICAL
```

The 12,527-byte gzip wire body decodes to 47,384 bytes; the declared digest/byte count are of
that decoded body, matching the `decoded-http-body-volatile-v1` digest domain.

### 1.2 Field-by-field result

A ten-check script (registry extraction + TSV parse + independent normalization, `/tmp` only)
printed `ALL_PASS 10` with the file hashes stable across the run:

| # | field | declared (`source-fetches.tsv:47`) | measured | result |
|---|---|---|---|---|
| f2 | status | `mined` | registry `mined` (`SOURCES.md:32` f9) | PASS |
| f3 | row_identity_sha256 | `0be2cff9…aa2ee` | `sha256("S026\tmined\thttps://openbao.org/docs/concepts/tokens/\n")` = `0be2cff9…aa2ee` | PASS |
| f4 | url | `https://openbao.org/docs/concepts/tokens/` | registry extraction, byte-equal | PASS |
| f5 | final_url | same string | `%{url_effective}` = same, `redirects=0` | PASS |
| f6 | http_status | `200` | `HTTP/2 200` | PASS |
| f7 | request_profile | `curl-fsSL-compressed-v1` | exact declared command/UA used | PASS |
| f8 | fetched | `2026-10-21` | fetch date 2026-10-21 (server `date` 04:03:46Z) | PASS |
| f9 | representation | `decoded-http-body-volatile-v1` | gzip 12,527 → decoded 47,384; digest of decoded body | PASS |
| f10 | sha256 | `52295…f82c` | `5229521866ce21fa8cd8f8ecf63d696877b8cb0a2ec25e89de683557b385f82c` | PASS |
| f11 | bytes | `47384` | `47384` | PASS |
| f12 | revision | `-` | URL is not a moving-ref URL | PASS (n/a) |
| f13 | quote | `When a parent token is revoked, … as well.` | one occurrence, 22 words | PASS |
| f14 | normalization | `rendered-text-v1` | declared pipeline reproduces f15 | PASS |
| f15 | normalized_sha256 | `ed9496…d2e3` | `ed949658b434fa769b89c682160f77ad153f5c6657808706db5858506ce0d2e3` | PASS |
| f16 | location | `Token hierarchies and orphan tokens` | h2 immediately before the quote | PASS |

Row identity command exactly as the census computes it (`corpus/sources-census.sh:249-252`):

```console
$ printf 'S026\tmined\thttps://openbao.org/docs/concepts/tokens/\n' | sha256sum
0be2cff96b982a3557e21dcbd0e768b57ecdc1f8b02b085ce25bb556516aa2ee  -
```

### 1.3 `rendered-text-v1` recomputation

Implementation of the declared order at `corpus/source-fetches.tsv:27-29` (strip
`script`/`style` with contents, tags → one space, `html.unescape`, collapse `\s+`, trim, UTF-8):

```python
t = re.sub(r'(?is)<(script|style)\b[^>]*>.*?</\1\s*>', ' ', s)
t = re.sub(r'(?s)<[^>]*>', ' ', t)
t = html.unescape(t); t = re.sub(r'\s+', ' ', t).strip(); b = t.encode('utf-8')
```

```console
norm_bytes 14608
norm_sha256 ed949658b434fa769b89c682160f77ad153f5c6657808706db5858506ce0d2e3
quote_index 4921
quote_occurrences 1
quote_words 22
prev_h2: Token hierarchies and orphan tokens
next_h2: Token accessors
```

The quote is under `h2 Token hierarchies and orphan tokens` with no intervening `h3`
(the h2 runs 29,019–30,648 in the raw body; the quote begins at raw 29,523; the next heading is
`h2 Token accessors` at 30,648). The declared `location` is the heading text with the page's
U+200B heading-anchor character removed; `Token hierarchies and orphan tokens` is exact.

Discriminating check: removing the `script`/`style` strip while keeping tag stripping yields
15,558 bytes / `1c094b91…3a3af`, i.e. the declared digest is not insensitive to the declared
algorithm. On this page `html.unescape` is a no-op after tag stripping (variant digest identical),
so the digest does not by itself attest the unescape/order steps — see §5.

---

## 2. Findings

### Finding 1 (medium, claim brief only) — the C2 brief's "seven distinct URLs" is false; measured nine

Measured at the final snapshot:

```console
$ grep -c '^S0' corpus/source-fetches.tsv
10
$ awk -F'\t' '!/^#/ && NF==16 {print $4}' corpus/source-fetches.tsv | sort -u | wc -l
9
$ awk -F'\t' '$1 ~ /^S01[7-9]$/ || $1 ~ /^S02[0-3]$/ {print $4}' corpus/source-fetches.tsv | sort -u | wc -l
7
$ awk -F'\t' '$1 ~ /^S02[4-6]$/ {print $4}' corpus/source-fetches.tsv | sort -u | wc -l
3
```

Ten rows cover nine distinct URL strings: S021 and S026 share
`https://openbao.org/docs/concepts/tokens/` (identical raw digest `52295218…` and identical
normalized digest `ed9496…`). `seven` is the distinct count of the S017–S023 subset alone;
S024–S026 contribute three rows over three URL strings, one of which (S026) duplicates S021.
The tree's own text is already correct: `corpus/lessons/round-23.md:180` ("nine distinct URLs"),
`SCORECARD.md:840` ("the 10 captures cover nine distinct URLs"), `LOG.md:1202`. The parent C2
framing and this seat brief still say seven, so a literal scoring of the brief is false. This is
the same conclusion independently reached by RevS022 §3; I reproduce it rather than claim novelty.
No data row is wrong.

### Finding 2 (low, current) — `fetch-disagree` no longer tests disagreement; it only proves duplicate-id detection

At the final census hash, the cross-capture checks are gone (`corpus/sources-census.sh:229`
declares only `FURL/FINROW/FSEEN`; no `FDIG`/`FNRM`) and the file says so
(`sources-census.sh:65`, `source-fetches.tsv:21`). The selftest case is now:

```bash
# corpus/sources-census.sh:426-431
m_fetch_disagree() {
  local f sha
  f=$(FETCH_F "$1")
  sha=$(rep 9 64)
  awk -F'\t' -v OFS='\t' -v sha="$sha" '$1=="S002" {$10=sha; print; exit}' "$f" >>"$f"
}
# corpus/sources-census.sh:553
"fetch-disagree|m_fetch_disagree||1|SC_FETCH|1"
```

The mutation appends a *second S002 row* with a different raw digest. With no same-URL
comparison, the only reachable finding is `duplicate-provenance`
(`corpus/sources-census.sh:275`); the harness asserts finding id + `findings=1`
(`:556-585`). Proof on a copy of the final tree (baseline CLEAN):

```console
$ # copy of the final tree; S026 f15 := 64 zeros (no duplicate row)
SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)   exit 0
$ # copy of the final tree; duplicate S026 row with f10 := 64 nines
FINDING SC_FETCH id=S026 duplicate-provenance
SOURCES_CENSUS: FAILED (findings=1 rows=26)                                                            exit 1
```

At the earlier census `24d834cc`, the same mutation triggered the duplicate check plus the
same-URL raw comparison and the case table expected `SC_FETCH|2`; the expectation was lowered
to `1` when the two same-URL branches were removed. The case count stayed 59, so "59 cases" no
longer includes any case named for — or exercising — cross-capture disagreement. The case still
guards duplicate detection; only its name/coverage claim is stale. Not a data defect. Exact
wording suggestion (not applied): rename to `fetch-duplicate-digest` or delete it (a
duplicate-only case already exists at `:552`).

### Finding 3 (low, naming) — "corrected locator" for S026, but its URL is byte-identical to the superseded row's

`corpus/SOURCES.md:32` titles S026 `Tokens, corrected locator — https://openbao.org/docs/concepts/tokens/`.
The census extraction of the superseded row `corpus/SOURCES.md:22` (S016) returns the identical
string `https://openbao.org/docs/concepts/tokens/` (same for S025 vs S014). The actual correction
is the declared representation/normalization and the scope basis, not the locator string;
`corpus/lessons/round-23.md:77` itself says the correction rows are "over URLs already
registered". If "locator" means the registered URL, the label misleads; if it means "the active
row that locates the source", it is merely ambiguous. Text-only; no digest impact.

### Observation (not scored) — S021's location is a prefix, not the heading

S021 (`source-fetches.tsv:42` at this hash) declares `Token Time-To-Live`; the actual h2 is
`Token Time-To-Live, periodic tokens, and explicit max TTLs` (raw 32,584). The field definition
is "section/heading the quote was located under" (`source-fetches.tsv:31`). S026's own location
is exact, so this is an adjacent-row consistency note, not an S026 finding. If the convention is
the full heading (as S016's basis uses), S021 should carry the full text.

---

## 3. Claim-level re-measure (C2/D7 only; C1/C3 not audited here)

| claim as briefed | measured | verdict |
|---|---|---|
| `source-fetches.tsv` present with 10 declared captures S017–S026 | 10 rows, S017–S026, all 16 fields | holds |
| …over 7 URLs | 9 distinct URL strings (7 for S017–S023 + 2 new for S024/S025; S026 duplicates S021) | **false as briefed; tree text now says 9** |
| declared representation/normalization | every row has f9/f14; S026 reproduces under the declared pipeline | holds |
| `SC_FETCH` with 59-case selftest | `bash corpus/sources-census.sh` exit 0, `CLEAN (rows=26 …)`; `--selftest` exit 0, `PASS (59 cases)` | holds |
| registry coverage | 16 in-row pins + 10 provenance = 26 registry rows; census `missing-provenance` loop finds none | holds |

Exact gate run at the final snapshot (hashes stable across the run):

```console
$ bash corpus/sources-census.sh
SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)
exit=0
$ bash corpus/sources-census.sh --selftest
SOURCES_CENSUS_SELFTEST: PASS (59 cases)
exit=0
```

The CLEAN line is byte-identical to the literal expected by ledger row `R21-02`
(`corpus/claim-ledger.tsv:52`, read only; the row itself was not executed).

---

## 4. Superseded mid-seat observations (moving target)

The lane was edited by others while this seat ran. Two defects were measured during this seat
(one here, one by peers); the final snapshot no longer has either. They are recorded so the
synthesis does not attribute them to the final bytes, and so the repaired state is traceable.

1. **D7 header/code contradiction (fixed).** At `sources-census.sh 24d834cc` and
   `source-fetches.tsv 846b2037`, the file declared "No cross-capture equality is enforced"
   (`source-fetches.tsv:21`) while the code still compared same-URL raw digests
   (`FDIG`, `:282`) and normalized digests (`FNRM`, `:288`). Proof at that hash: setting S026
   f15 to 64 zeros in a `/tmp` copy produced
   `FINDING SC_FETCH id=S026 same-url-normalized-disagreement url=https://openbao.org/docs/concepts/tokens/`
   (exit 1). At the final `sources-census.sh 2d1bbbe3` the branches and the `FDIG`/`FNRM`
   declarations are removed, and both the census doc (`:65`) and the TSV header (`:21`) are now
   true. `corpus/lessons/round-23.md:151` records the rationale ("a cross-capture equality rule
   punished honest recaptures"). Finding 2 is the residue of that removal.
2. **Census crash on `supersedes` (fixed).** Peers measured `S007: unbound variable` at
   `sources-census.sh:242` (undeclared `SUPERSEDED` array under `set -u`) on the earlier
   revision. At the final hash that dead loop is gone; `bash corpus/sources-census.sh` exits 0
   with the CLEAN line above. The repair deleted the dead code rather than declaring the array,
   so `supersedes S…` remains documentation-only (nothing enforces the lineage).

Observed artifact-hash churn during this seat (all by concurrent writers, not by me):
`source-fetches.tsv` a78fde7b → 846b2037 → 7101bdd0 → 6e26e140; `sources-census.sh`
24d834cc → 6d4190a7 → 511deb27 → 2d1bbbe3; `SOURCES.md` 06dde644 → c6ea91ab;
`lessons/round-23.md` 2f53cf69 → 93df7d34 → 4e8ab66f → ae29c16c → 4e971e3d. Any finding above must be
re-measured if the integration hash differs from §0's snapshot.

---

## 5. Residual risk and verification gaps

- **Digest values are not gate-checked.** The census validates digest *shape* only; at the final
  hash, setting S026 f15 to 64 zeros leaves the gate `CLEAN` (exit 0). The declared raw and
  normalized digests are verified here only by independent re-fetch — which passes — not by
  `SC_FETCH`. This is consistent with "point attestation" (`source-fetches.tsv:19-21`,
  `sources-census.sh:65`); the header itself now says the quote is "shape-checked only … not
  verified against the page bytes or the location" (`source-fetches.tsv:25-26`). The C2 claim
  should not be read as digest-value or quote-content verification.
- **Capture independence is not evidenced.** The format records only a date, not a per-capture
  timestamp/ETag; S021 and S026 carry byte-identical raw digests and byte counts. Two genuine
  fetches and a copy-forward are indistinguishable in the artifact. My two GETs did produce
  identical bytes, so the declared S026 values are right, but the artifact alone cannot prove
  two captures.
- **The volatile label is conservative for this page.** `last-modified` 2026-10-20T07:50:18Z,
  weak ETag `W/"6ad71d3a-b918"`, no per-response token found, and two GETs byte-identical.
  `decoded-http-body-volatile-v1` is not falsified (daily chrome could rotate), but after the
  cross-capture checks were removed the volatile/non-volatile distinction affects no gate
  behavior at all; it is documentation of the digest domain only.
- **Point attestation, not drift pin.** The row attests the served bytes on 2026-10-21 only; the
  origin may change. My fetches hit the same CDN object (same ETag/Last-Modified), so agreement
  shows current served bytes, not origin independence.
- **`html.unescape`/order are not discriminated by this page.** Dropping `html.unescape`, or
  unescaping before tag stripping, yields the same normalized digest; only the script/style
  strip changes it. The digest is a valid attestation of the declared algorithm's *output*, but
  this page does not exercise every declared step.
- **Checks not run:** C1 closure dispositions and C3 fixture/`CELL_AUDIT` (sibling seats); the
  parent's claim-ledger row audits; any host-bound/fleet check. No claim-ledger row was executed.
- The "stale Read-only at `/home/vgpnk/Projects/shokunin/kagi-shokunin`" phrase in the seat brief
  is the frozen contract line in `.ufo/waves/round-23/falsify-spec.json`, not a filesystem
  marker: no read-only marker exists at the lane, and the tree is a live dirty worktree
  (HEAD `d218603`, round-23 files uncommitted) that concurrent writers modified. I kept every
  write outside the lane except this report.
