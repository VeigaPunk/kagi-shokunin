# RevS014 — S014's supersession and the S025 correction

Seat: falsification/revenger, round 23. Scope: registry row **S014**, its
successor **S025**, the S025 provenance record in `corpus/source-fetches.tsv`,
and the C2 gate path that is supposed to carry the correction. Read-only on the
lane; the only lane write is this report. No installs, no host gates, no
vault/account action. Page text was treated as data.

## Snapshot (the tree moved during the audit)

The round-23 tree was edited by the integrator while I measured. Every result
below is tied to the bytes that produced it. Snapshot at measurement, with a
post-write recheck at the last revision I observed:

| artifact | sha256 | mtime (-0300) |
|---|---|---|
| `corpus/sources-census.sh` | `2d1bbbe36ed21c2755d604937dc10d91fa71645847c82124bf729f4c8e0b95bc` | 2026-10-21 01:16:11 |
| `corpus/SOURCES.md` | `c6ea91ab2468352263a7442a2ff7815084d68374c94433bbb6b4cccc639c632d` | 2026-10-21 01:11:27 |
| `corpus/source-fetches.tsv` | `6e26e14032729070f38b5e0cb90914385f04c0ef9f4fe1db210af6439191094d` | 2026-10-21 01:10:37 |
| `corpus/lessons/round-23.md` | `cfb4d5e9b49592fe0ce91119f5f3f723483f832674f7de52d479e4486d2cf0a7` | 2026-10-21 01:22:06 |

Revisions observed for `corpus/sources-census.sh` in ~18 minutes:
`80966e20…` (00:57:55) → `24d834cc…` (01:02:21) → `6d4190a7…` (01:08:48) →
`6f202fce…` (01:10:37) → `511deb27…` (01:10:59) → `2d1bbbe3…` (01:16:11). Two
hard failures were live in that window (§5); both were repaired before the
post-write recheck. At `2d1bbbe3…` the `SC_FETCH` shape checks are at the same
lines (`:252`, `:258`, `:267`, `:270`, `:274`, `:283`), `verify` is `CLEAN
(rows=26 …)` exit 0, and `--selftest` is `PASS (59 cases)` exit 0. The S025 row
and `SOURCES.md` bytes are identical across every revision I sampled, so the
S025 substance is not a moving target.

## Verdict

1. **S014 needed supersession for all three alleged reasons, and each is
   reproduced** (§2): its quote is not a case-sensitive substring of the served
   page, its anchor names two sections while its own consumer cites four, and
   its recorded digest matches none of eleven tested representations.
2. **S025 fixes each part in fact** (§3): the quote is a literal 1-occurrence
   substring of the live declared normalization; the anchor breadth covers the
   consumer's cited set (§JWT verification, §Bound claims, §Claims as metadata,
   §Configuration) and adds the parent §JWT authentication heading; the declared
   raw and normalized digests reproduce byte-exactly, as does the upstream
   `release/2.7.x` MDX pin.
3. **No evidence-bearing widening was found.** One wording overstatement
   ("authentication methods" plural) and one residual anchor omission (the H1
   that owns the quote is named in the teaches cell and the TSV location but
   not in the `anchor` cell).
4. **The fix is attested, not machine-enforced.** At the gate revisions I
   tested (`511deb27…`; the `SC_FETCH` checks are identical at `2d1bbbe3…`) the
   C2 gate stays `CLEAN` when S014's exact defective quote is grafted back into
   both the TSV and the registry row, and when S025's raw digest is replaced by
   `0…0` (§4). The lesson now states this shape-only bound
   (`corpus/lessons/round-23.md:194-198`); the C2 row and D7 wording must carry
   the same qualifier.
5. **Supersession is partial and prose-only.** S014 stays `mined`, is still
   covered by its own historical in-row pin, and is still the row cited by the
   sole knowledge consumer (`corpus/knowledge/vault-openbao-token-lease-lifecycle.md:3,33,40,144`).
   S025's `used-by` is the round-23 lesson, not that entry. Deleting S014's pin
   makes the gate fail `id=S014 missing-provenance`; S025 does not substitute.

## 1. What was attacked

- The exact S014 and S025 registry rows (`corpus/SOURCES.md:20,31`).
- The S025 provenance row (`corpus/source-fetches.tsv:46`) and its declared
  domain against the live page and the upstream MDX at `release/2.7.x`.
- The C2 gate's `SC_FETCH` checks (`corpus/sources-census.sh:252-283`) by
  mutation on throwaway `/tmp` copies of the corpus: quote, digest, location,
  registry quote/anchor, row identity, status, coverage, and same-URL agreement.
- The 59-case selftest and the real-tree `verify` at each script revision.

## 2. Why S014 needed supersession (evidence)

### 2.1 Quote not literal and truncated

Registry quote (`corpus/SOURCES.md:20`):
“The JWT auth method can be used to authenticate with OpenBao using OIDC”.

Live page, declared `rendered-text-v1` normalization (strip `script`/`style`,
tags→single space, `html.unescape`, collapse whitespace, trim, UTF-8):

| check | result |
|---|---|
| S014 quote, case-sensitive occurrences | **0** |
| S014 quote, case-insensitive occurrences | 1 |
| S025 quote occurrences | **1** |
| page markup | `<code>jwt</code>` lower-case; the sentence continues “or by providing a JWT” |

The page's rendered sentence is “The jwt auth method can be used to authenticate
with OpenBao using OIDC or by providing a JWT” (H1 section, offset 19,656 of the
raw HTML; H1 at 19,614, next H2 at 20,602). S014's capitalized, truncated form
is `normalized` at best, not a located literal quote. This matches the parent
audit (`.ufo/waves/round-23/parent-build/SourceS014.md:178-183`).

### 2.2 Anchor under-declared

| record | anchor set |
|---|---|
| S014 row (`SOURCES.md:20`) | §JWT/OIDC auth method; §JWT verification |
| S014 consumer (`vault-openbao-token-lease-lifecycle.md:3,33,40`) | §JWT verification; §Bound claims; §Claims as metadata; §Configuration |
| S025 row (`SOURCES.md:31`) | §JWT authentication → §JWT verification; §Bound claims; §Claims as metadata; §Configuration |

All five named headings exist on the live page (`jwt-authentication`,
`jwt-verification`, `bound-claims`, `claims-as-metadata`, `configuration`; one
hit each). The nesting is H2 §Configuration → H3 §Bound claims / §Claims as
metadata, and H2 §JWT authentication → H3 §JWT verification; the flat comma
list in S025 does not encode that, but it does not misname anything.

### 2.3 Digest unreproducible

Recorded `e94723241fbcbdd0b2741c569f6ce51befe39e526cd736cebe4023fbca1cb0b1`
matches **none** of the 11 distinct representations tested across my matrix and
the parent's (overlapping sets; union 11):

- raw decoded body, tags→space+unescape+collapse, tags→space without unescape,
  strip-without-space, unescape-then-strip, `<article>`-only, gzip(raw) (parent,
  `SourceS014.md:66-76`);
- rendered-lower, upstream-MDX raw, upstream-MDX collapsed, upstream-MDX
  lower-cased (mine).

The live declared values are:

| representation | value |
|---|---|
| raw decoded body | `449ef132ba380948398c03cd96b0a10f80572b734c381897e681b3609d1785d9`, 63,046 B |
| rendered-text-v1 | `ca496ad8f8226d848d2fefa4b1c66d3820e32cdf5d995ee508b44521e752a403`, 15,911 chars |
| upstream MDX `release/2.7.x`, `website/content/docs/auth/jwt/index.mdx` | `8d0aeba8cc43a4d1abe9e9eb0dacbefe7350847dcc6dca4167a2bac1593b0965`, 16,220 B |

The MDX sentence is line-wrapped across its lines 10-12 and renders to the S025
quote exactly once. The recorded S014 digest's actual domain remains unknown;
“unreproducible” here means no declared domain reproduces it, not that the
2026-10-19 bytes are proven different.

## 3. Does S025 fix each part?

Independent measurement, not a read of the lane's own claims:

```text
curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' \
  -D /tmp/revs014.hdr -o /tmp/revs014.html \
  -w 'http=%{http_code} final=%{url_effective} size=%{size_download}\n' \
  https://openbao.org/docs/auth/jwt/
# exit 0; http=200; final=https://openbao.org/docs/auth/jwt/; size=13325 (compressed)
# response date: Wed, 21 Oct 2026 03:58:41 GMT; Last-Modified: Tue, 20 Oct 2026 07:50:18 GMT
# ETag: W/"6ad71d3a-f646" (f646 hex = 63,046 decoded bytes)
sha256sum /tmp/revs014.html   # 449ef132…  wc -c 63046
```

| part | S025 record | independent check | result |
|---|---|---|---|
| quote | TSV:46 and `SOURCES.md:31` | literal occurrences in rendered-text-v1 | 1; 18 words; includes “or by providing a JWT” |
| anchor breadth | `SOURCES.md:31` | heading/id existence on the live page | all five named headings present |
| digest | TSV:46: `decoded-http-body-volatile-v1`, raw `449ef132…`/63046, normalized `ca496ad8…` | recompute from the fetched bytes | both match exactly |
| row identity | TSV:46 `e91b8e3c…` | `printf 'S025\tmined\thttps://openbao.org/docs/auth/jwt/\n' \| sha256sum` | `e91b8e3c…`, match |
| URL/status/profile | TSV:46 | registry row / fetch headers | exact URL, `mined`, `curl-fsSL-compressed-v1`, HTTP 200, final URL identical |
| upstream pin | TSV header/lesson | fetch MDX at `release/2.7.x` | `8d0aeba8…`, 16,220 B, match |

`bash corpus/sources-census.sh verify` at the measured snapshot
(`511deb27…`; rechecked at `2d1bbbe3…`):

```text
SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)
# exit 0
```

### Widening check

- S025's scope adds the plural “authentication methods”. The page's H1 and the
  quote are singular (“The jwt auth method”), though the page documents OIDC and
  direct-JWT paths and three verification methods. This is a wording
  overstatement, not a factual leap.
- The teaches cell's “claim metadata and optionality live in §Claims as
  metadata” is supported: “Data from claims can be copied … by configuring
  claim_mappings” and “Claim mappings which do not begin with a / are optional”
  are both under the H3 `claims-as-metadata` (heading offset 50,940; optional
  sentence offset 53,286; next section boundary after it).
- S025 does not restate S014's substantive “configured signature verification
  and claim handling” claim; it is a locator/digest correction. No Vault claim,
  deployment proof, or new version claim is added; the page carries `Version:
  Version 2.7.x`.
- **Residual under-declaration:** the `anchor` cell (`SOURCES.md:31`) does not
  name the H1 that owns the quote. The teaches cell says “(§JWT/OIDC auth
  method, rendered text)” and the TSV `location` says “H1 JWT/OIDC auth
  method”, so the record collectively locates it; the `anchor` field alone does
  not, and no gate compares the registry anchor to the TSV location.

## 4. What the C2 gate actually enforces

Mutation runs on throwaway copies; the lane was never modified. At script
`24d834cc…` (TSV `846b2037…`, `SOURCES.md` `06dde644…`):

| mutation | gate result |
|---|---|
| control | `CLEAN`, exit 0 |
| S025 TSV quote → S014's exact non-literal quote | `CLEAN`, exit 0 |
| S025 raw digest → `0…0` | `CLEAN`, exit 0 |
| S025 normalized digest → `1…1` (24d834cc) | `CLEAN`, exit 0 |
| S025 registry quote → S014's exact non-literal quote | `CLEAN`, exit 0 |
| S025 registry anchor → S014's narrow anchor | `CLEAN`, exit 0 |
| row id `S025` → `S999` | `FAILED (findings=2)`, exit 1: `not-a-registry-row`, `missing-provenance` |
| S025 status `mined` → `queued` | `FAILED (findings=1)`, exit 1: `status=queued registry=mined` |
| S025 row-identity digest → `0…0` | `FAILED (findings=1)`, exit 1: `row-identity-digest-mismatch` |
| delete S014's in-row pin | `FAILED (findings=1)`, exit 1: `id=S014 missing-provenance` |

Repeated at script `511deb27…` (the `SC_FETCH` checks are identical at
`2d1bbbe3…`): control `CLEAN` exit 0; combined TSV
+ registry quote reverted to S014's text `CLEAN` exit 0; raw digest `0…0`
`CLEAN` exit 0; S014 pin deleted → `id=S014 missing-provenance` exit 1.

The live checks are shape/identity only:

- `corpus/sources-census.sh:252` row-identity digest equality;
- `:258` raw digest is 64 hex; `:270` normalized digest is 64 hex;
- `:267` quote is non-empty and `wc -w` ≤ 25;
- `:274` location is ≥ 8 chars;
- `:275` duplicate row; `:283` coverage (`in-row Fetch sha256:` or one TSV row).

Nothing recomputes a digest, compares a quote to the page, validates a heading,
or compares the registry row's quote/anchor to the TSV row. The lesson now says
this explicitly (`corpus/lessons/round-23.md:194-198`: “quote text and location
are not checked against the page … only ASCII word count and a non-empty
location are shape-checked”).

## 5. Defects found

### D1 — Hard gate failure at `80966e20…` (transient, fixed)

At 00:57:55 the script contained an undeclared `SUPERSEDED[$fid]=1` assignment
(line 242) fed by the `supersedes S0xx` teaches cells (S019→S007 first). Under
`set -u` the subscript is evaluated arithmetically:

```text
$ bash corpus/sources-census.sh
corpus/sources-census.sh: line 242: S007: unbound variable
# exit 1, no verdict line
$ bash corpus/sources-census.sh --selftest
SOURCES_CENSUS_SELFTEST: PASS (59 cases)      # exit 0
```

The 59-case selftest passed while the real-tree `verify` could not run, because
no selftest fixture row carries a `supersedes` teaches cell. A one-line
`declare -A SUPERSEDED=()` in a copy produced `CLEAN (rows=26 …)` exit 0. The
block was removed at 01:02:21 (`24d834cc…`). The `SUPERSEDED` array was also
never read anywhere in the script: supersession was parsed but unused.

### D2 — Selftest red at `6f202fce…` (transient, fixed)

At 01:10:37 the same-URL comparison block was deleted to match the new header
“no cross-capture equality is enforced”, but the selftest case `fetch-disagree`
still expected two findings:

```text
case fetch-disagree: FAIL (exit 1 want 1; want SC_FETCH findings=2; last=SOURCES_CENSUS: FAILED (findings=1 rows=4))
SOURCES_CENSUS_SELFTEST: FAIL (59 cases, 1 failed)   # exit 1
```

At 01:10:59 (`511deb27…`) the case was updated and `--selftest` is
`PASS (59 cases)` exit 0. This is the third revision in the window whose
green/red state changed without the frozen claim changing.

### D3 — S025's correction is not machine-enforced (persistent, now admitted)

The final lesson states the bound explicitly (D7 `:110-123`: “a declared quote
(shape-checked only, not verified against the page)”; bounds `:194-198`). The
C2 row's “enforces shape, identity, URL and row-identity digest”
(`round-23.md:61`) is accurate only under that qualifier; the claim must use
“declared/attested, verified only by out-of-band reopen”, not
“checked/verified”. The mutations in §4 are the evidence.

### D4 — Supersession is prose-only and does not reach the consumer (persistent)

- The script no longer parses `supersedes` at all (`grep -n supersedes
  corpus/sources-census.sh` → no hits at the last revision I checked).
- S014 remains `mined` and gate-covered by its own historical pin; deleting
  that pin fails `id=S014 missing-provenance` even though S025 exists.
- The knowledge entry still cites S014 with the same URL and anchors
  (`vault-openbao-token-lease-lifecycle.md:3,33,40,144`); S025 is cited only by
  `corpus/lessons/round-23.md:1`.
- The old non-literal quote survives in `corpus/lessons/round-21.md:68`
  (historical, bounded by D7, but a reader following that lesson sees the
  defective text).

The bounded reading — “S025 is the corrected active locator alongside the
retained historical row” — is true. The strong reading — “S025 is now the row
the consumer resolves” — is false. The final lesson's bounds section now states
this too (`round-23.md:210-212`: `supersedes` is not parsed; the Vault/OpenBao
entry still cites S012-S016 under historical pins). M8 is the gate-level proof.

### D5 — Residual anchor-field omission

The `anchor` cell (`SOURCES.md:31`) omits the H1 `§JWT/OIDC auth method`, which
is the quote's own section (`source-fetches.tsv:46` location). The teaches cell
names it, so the row is not silent; but a field-level consumer of `anchor` gets
an incomplete locator, and no check compares `anchor` to `location`.

### D6 — Wording: “authentication methods” plural

Minor; the page documents one auth method with two credential paths and three
verification methods. If precision matters, use “JWT/OIDC authentication (OIDC
and direct-JWT paths)”.

### D7 — W04 attribution (observation, not a defect at the final lesson)

The final lesson correctly attributes the W04 lines to the “fleet census
wrapper” (five at base, seven at round end; `round-23.md:66-77`). The lines are
not emitted by `corpus/sources-census.sh` (`grep -n 'W04\|duplicate url'
corpus/sources-census.sh` → no hits), so the C2 counting cell
`bash corpus/sources-census.sh` cannot produce them; the round-end condition
(`round-23.md:183-185`) is checkable only through the fleet wrapper. Name that
command in the C2 counting cell. No contradiction remains in the lesson text.

### D8 — “No cross-capture equality” vs the code (resolved mid-audit)

At `24d834cc…` the header still required same-URL agreement and lines 282/288
enforced it; mutating S026's normalized digest produced
`id=S026 same-url-normalized-disagreement` exit 1 (M10). At `6d4190a7…`
(01:08:48) the header was changed to “no cross-capture equality is enforced”
while the code was unchanged, so the declaration and the gate disagreed for
about two minutes. At `6f202fce…` (01:10:37) the code was deleted to match the
header, but the `fetch-disagree` selftest case still expected two findings, so
the selftest went red (D2) until `511deb27…`. The post-write state (`2d1bbbe3…`)
is consistent (code removed, test updated); the lesson's sentence must be read
against the pinned revision, because it was false at `6d4190a7…`.

## 6. Bounds the claim must state

1. **Revision pin.** State the `sources-census.sh` / `SOURCES.md` /
   `source-fetches.tsv` / lesson hashes with the claim. Two of the five script
   revisions in this window were red (D1, D2); a hash-free “green” is not
   reproducible.
2. **S025 is attested, not gate-verified.** The quote, anchor, and digest are
   values in the TSV/registry; the gate checks shape and identity only. A
   `0…0` digest, a blank/foreign quote, and an S014-style uppercase quote all
   pass. Only an out-of-band reopen verifies content.
3. **Digest domain.** `decoded-http-body-volatile-v1`: the raw digest is a
   point attestation of the decoded body; the normalized digest is a more
   stable but still chrome-sensitive point attestation, never a drift pin.
   S025 is a singleton per URL, so no same-URL agreement check applies to it.
4. **Partial, prose-only supersession.** S014 stays `mined`, keeps its
   historical pin and its consumer citations; S025 is a correction row cited by
   the round-23 lesson, not a migration of the knowledge entry. The old quote
   remains in the round-21 lesson.
5. **Anchor completeness.** S025's `anchor` cell omits the H1 that owns the
   quote; the teaches cell and the TSV `location` name it. Do not claim the
   anchor field alone is complete.
6. **Selftest coverage.** 59 cases exercise the declared-provenance branch; the
   16-row in-row branch is exercised only by the real-tree run (the lesson's
   own bound, `round-23.md:213-215`). The selftest count is not evidence that
   `verify` runs on the real registry (D1 is the counterexample).
7. **W04.** Those lines are fleet-wrapper output (five at base, seven at round
   end), not `corpus/sources-census.sh` output; name the fleet wrapper in the
   counting cell.
8. **No widening beyond the locator.** S025 adds no deployment, Vault, or
   version claim; “authentication methods” is wording, and “optionality” is
   claim-mapping optionality under §Claims as metadata.

## 7. Commands and exits (evidence log)

```text
# live page (declared request profile)
curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' \
  -D /tmp/revs014.hdr -o /tmp/revs014.html -w 'http=%{http_code} final=%{url_effective} size=%{size_download}\n' \
  https://openbao.org/docs/auth/jwt/
# exit 0; http=200; final=https://openbao.org/docs/auth/jwt/; size=13325 (compressed)
sha256sum /tmp/revs014.html        # 449ef132…; wc -c = 63046

# declared normalization + quote counts (Python)
# rendered 15911 chars, sha256 ca496ad8…; S025 quote count 1;
# S014 quote count 0 case-sensitive, 1 case-insensitive.

# upstream MDX pin
curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' \
  -o /tmp/revs014-index.mdx \
  https://raw.githubusercontent.com/openbao/openbao/release/2.7.x/website/content/docs/auth/jwt/index.mdx
# exit 0; 16220 B; sha256 8d0aeba8…; sentence at MDX lines 10-12.

# row identity
printf 'S025\tmined\thttps://openbao.org/docs/auth/jwt/\n' | sha256sum   # e91b8e3c…

# gate / selftest at measured snapshot
bash corpus/sources-census.sh                # CLEAN (rows=26 …), exit 0
bash corpus/sources-census.sh --selftest     # PASS (59 cases), exit 0

# gate at 80966e20… (transient)
bash corpus/sources-census.sh                # line 242: S007: unbound variable, exit 1
bash corpus/sources-census.sh --selftest     # PASS (59 cases), exit 0

# gate at 6f202fce… (transient)
bash corpus/sources-census.sh --selftest     # FAIL (59 cases, 1 failed), exit 1
# case fetch-disagree: FAIL (… want findings=2; last=… findings=1)

# mutation runs (throwaway /tmp copies; script revision where stated)
# control                                         CLEAN, exit 0
# TSV+registry quote → S014 text                  CLEAN, exit 0
# raw digest → 0…0                                CLEAN, exit 0
# row id → S999                                   FAILED (2), exit 1
# status → queued                                 FAILED (1), exit 1
# row-identity digest → 0…0                       FAILED (1), exit 1
# delete S014 in-row pin                          FAILED (1: id=S014 missing-provenance), exit 1
# S026 normalized digest → 0…0 (24d834cc…)        FAILED (1: same-url-normalized-disagreement), exit 1

# cardinalities at my measurement
grep -c 'Fetch sha256:' corpus/SOURCES.md        # 16
grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|' corpus/SOURCES.md   # 26
awk -F'\t' '!/^#/ && NF==16' corpus/source-fetches.tsv | wc -l         # 10
awk -F'\t' '!/^#/ && NF==16 {print $4}' corpus/source-fetches.tsv | sort -u | wc -l  # 9
```

The lesson at one earlier revision said “seven distinct URLs”; at the final
snapshot it says “nine” (`round-23.md:180`), which matches the count above.

## 8. Confidence

- **High** for the live-page quote/digest/anchor measurements and for every
  mutation exit code at the hashes named above.
- **High** that S025 fixes the three S014 defects in fact, and that the fixes
  are not machine-enforced by `SC_FETCH` at the revisions I tested.
- **Medium-high** for the transient-failure narrative: the tree changed under
  me, but each failure is tied to a recorded sha256 and mtime, and the repair
  revision is identified.
- **Unknown and not claimed:** which representation produced S014's original
  `e9472324…`; whether the 2026-10-19 page differed from today's. The honest
  statement is “no declared representation reproduces it”.
