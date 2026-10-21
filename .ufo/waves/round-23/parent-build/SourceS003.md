# SourceS003 — S003 source-bound provenance audit (round 23, parent-build)

Axes: calibration · freshness · operability. This is a read-only advisory report with no admission
authority. S003 stays `mined`, and no rejected or queued row is touched.

## Observed revision

- `.git/HEAD` (file read; no Git/JJ command): `d218603b74099ddca0bd8f869516fc41db0979bf`, detached,
  equal to the `plans/round-23.md:3` Base.
- Frozen-population read at about 03:40Z: `corpus/SOURCES.md` `a5e1c13e…` 118 L / 22,843 B, equal to
  `corpus/stamps.tsv:61`. During the audit L1 integration moved the tree: SOURCES.md became `06dde644…`
  121 L (S024–S026 appended), `corpus/source-fetches.tsv` appeared (`ccc9ae6e…`), and
  `corpus/sources-census.sh` was rewritten three times (`ece39d32…` → `4e60d5e0…` → `80966e20…`).
  `corpus/lessons/round-23.md` is `d5520988…`. In-flight line cites below are at those hashes as of
  03:59Z and may move.
- S003 is `corpus/SOURCES.md:9` in both snapshots, byte-identical. sha256(line+LF) = `6ca8f899…bdfa`.
  sha256(line) = `0b29023a…437c`, which equals `.ufo/waves/round-22/registry-census-details.json:69` and
  the frozen-before row.
- The used-by file `corpus/knowledge/onepassword-machine-credentials.md` (E1) is `8380b359…` 91 L / 9,653 B,
  equal to `corpus/stamps.tsv:26`.

## Public opens (all succeeded; none skipped)

| UTC 2026-10-21 | request | result |
|---|---|---|
| 03:42:46 (HTTP `date`) | GET/HEAD `https://www.1password.dev/connect/get-started` (curl 8.23.0 default UA, `--compressed`, Chrome UA, Python urllib) | 200 with no redirect. `rel=canonical` points to itself; `rel=alternate type=text/markdown href=/connect/get-started.md` present. `no-store`, ETag `W/"zq0dcsqebetcoh"`, `x-served-version dpl_8AUWT8nFRmT7D3RgoEGEPVymfFQP`, `vary: rsc, accept-encoding, Accept, User-Agent` |
| same | GET `…/get-started.md`, and the canonical URL with `Accept: text/markdown` | 200 `text/markdown; charset=utf-8`; `last-modified` equals request time |
| same | `read` tool (alternate-markdown) | succeeded |
| about 03:45 | Wayback CDX `www.1password.dev/connect/get-started*` since 2026-08-01 | succeeded |

Quotes total 20 words. Page: *Get started with a 1Password Connect server*. It displays no date; the
non-displayed JSON-LD `dateModified` is 2026-10-19T21:23:28.013Z. Accessed 2026-10-21 at
https://www.1password.dev/connect/get-started.

- Q1, §Deployment › Step 1: Create a Secrets Automation workflow: “credentials necessary to deploy
  1Password Connect Server”. It is at md line 41 and is a raw literal in both md and HTML.
- Q2, §Get help: “To change the vaults a token has access to, issue a new token.” It is at md line 239.
- The registered §Step 3 sentence is at md line 213. It matches only after link-markup normalization and
  is found by rendered-text-v1. It is not a raw-byte substring of md or HTML. This confirms round-22
  F-RS03-5; it is not new.

## Row verdicts

| field | observation | verdict |
|---|---|---|
| tier A, scope “Connect deployment credentials versus client API tokens” | Vendor's primary setup guide for its own product. Step 1 lists both artifacts (md 41–42); Step 3 instructs one token per application (md 213) | **SUPPORTED** for that scope only |
| teaches | Roles and the instruction are documented. No per-app identity is enforced: tokens are per server (md 95), and token vault access is set when the token is issued (md 82, Q2) | **SUPPORTED**; “per-application” is an instruction, not enforced isolation |
| anchor `§Deployment, Step 1 and Step 3` | md headings at lines 33/37/211. HTML ids: `deployment`, `step-1` (short id), `step-3-set-up-applications-and-services-to-get-information-from-1password` | **SUPPORTED** (resolves) |
| “no displayed version/date” | Nothing is displayed. JSON-LD `dateModified`/`lastModified` 2026-10-19T21:23:28.013Z is hidden and did not change across the redeploy below | **SUPPORTED** literally; it is a build stamp, not an editorial date [INFERENCE] |
| release status | None is displayed and the row claims none. Raw HTML has 2 “Public Preview” hits, both in shared stylesheet/RSC strings. rendered-text-v1 finds 0 “preview”/“beta” | Correct to claim none. A status scan over raw HTML would report a false positive |
| eligibility | 0 “Business” or “Teams” in md and in rendered text | None. Do not import eligibility from linked pages |
| `mined` / used-by | E1 `source:` (line 2) cites S003 with the same anchor; used-by = E1 only | **SUPPORTED** (both directions agree) |
| opened 2026-10-19 / recheck 90d | Due 2027-01-17; today is +2 days | **FRESH** on its cadence |
| in-row `Fetch sha256: 7f6d3b49…` | Matches neither md nor HTML (see below). No public capture exists for 2026-10-19 | **HISTORICAL, UNREPRODUCIBLE**: neither “stale” nor “drift” |
| supersession | `supersedes S003` has 0 hits in both the base and the in-flight 26-row registry. Round-22's “S003b” proposal was never adopted | **None**: S003 is the active row |
| deployed-product proof | Docs only. The lane runs no Connect server: Connect text appears only in E1, `lessons/round-21.md` and SOURCES. E1 §How kagi uses this names only `op run` | None is claimed and none is supported |

## Bytes: historical, current, transport and deploy

| representation | bytes | sha256 | note |
|---|---|---|---|
| R21 in-row (2026-10-19, representation unrecorded) | ? | `7f6d3b49ac3019073c37360c4771ebad2bad43a0f87ce314eb94bb0e0debe7ff` | Historical point observation; cannot be re-derived |
| md (`.md`, or the canonical URL with `Accept: text/markdown`) | 14,652 | `66831901561602872d7dba73a4a0ed52fd374d6a6f62fb823ae4a78be17092c6` | Identical in 5 fetches today (2 UAs, a query string, content negotiation). Equals the 2026-10-20 value (`round-22/build/Source03.md:13`, `falsify/ReopenSource03.md:33`) |
| HTML decoded body | 1,369,709 | `2e697420d1d63ed12a32e204501914a7861cbdff3dec432ee382510f306c00c5` | Identical in 6 fetches today (identity and `--compressed`, 2 UAs). Differs from 2026-10-20: `0daffd88…`, 1,369,361 B, ETag `W/"97ausnh5grtcet"` |
| HTML rendered-text-v1 | 11,258 chars | `915a222d374324128b3f00ee88484b2713b0e23f04a6e8f1233c4ed02fe3902d` | My own reimplementation, validated by reproducing the TSV's S025 normalized `ca496ad8…` from today's 63,046 B page. Same result with ASCII or Unicode whitespace and with either tag-case setting (this page has no NBSP) |

- **Transport:** the decoded digest does not depend on encoding (identity equals `--compressed`).
- **Deploy:** the HTML changed (+348 B, new ETag, new `dpl_…`) while the md and `dateModified` did not.
  So the raw-HTML digest is a deployment artifact, and `dateModified` follows neither deploys nor content.
  The `buildId` `6ad68a298cdc29c1c7fdf7e9` equals the value recorded on 2026-10-20 for the S004 page
  next to `dpl_CTd5b4pFwfRrzK28Ja6L7zK5VbfH` (`round-22/build/Source04.md:15`). That suggests a redeploy
  without a rebuild still changes the HTML bytes [INFERENCE: assumes site-wide ids; compared across two
  pages].
- **Chrome:** the rendered text starts with the title, docs-index boilerplate and a site-wide
  promotional banner for Credential Broker, and ends with footer and assistant text. Two consequences:
  - The normalized digest changes with site chrome.
  - A rendered-text locator not limited to the article could attribute a Broker statement to this
    Connect page. That is the QA9/QA10 cross-product risk. The registered quotes are inside the article,
    at offsets 2,839 and 10,306.
- **Historical:** Wayback has HTML captures only for 08-15, 08-30 (×2) and 08-31. The October entries
  (10-09 to 10-17) are `?_rsc=` `text/x-component` payloads. Nothing exists for 10-19, so the R21 bytes
  cannot be recovered and `7f6d3b49…` cannot be tested.

## C2 expectations for S003

S003 currently satisfies `SC_FETCH` only through the in-row branch (`sources-census.sh:299-303`).
`source-fetches.tsv` has no S003 row, which matches the plan's S017–S026 scope. If a row is ever
declared, these are the exact values under the in-flight 16-column schema:

`S003 · mined · row_identity_sha256 5c9e2761503028c25ea7ecd21a59f4e38e8de4047c619194258f393506833116`
(sha256 of `S003<TAB>mined<TAB>https://www.1password.dev/connect/get-started<LF>`; the census changed
convention mid-audit, and the earlier line+LF form would be `6ca8f899…`)
`· url = final_url https://www.1password.dev/connect/get-started · 200 · curl-fsSL-compressed-v1 ·
2026-10-21 · decoded-http-body-volatile-v1 · 2e697420… · 1369709 · - · quote Q1 · rendered-text-v1 ·
915a222d… · §Deployment › Step 1: Create a Secrets Automation workflow (#step-1)`.

Limits on those values:
- I did not run the profile's custom UA. Two other UAs returned identical bytes.
- The next deploy will change the raw digest.
- Chrome edits will change the normalized digest.

Better representation (optional schema extension): fetch md with `Accept: text/markdown` at the
registered URL.
- It keeps URL equality.
- It excludes nav, footer and banner.
- It stayed byte-identical across the observed redeploy.

The current enums cannot express it. `request_profile` is fixed. `raw-literal-v1` fails the Step 3 quote
because of link markup. `rendered-text-v1` is HTML-only. It would need an `…-accept-markdown-v1` profile
and a markdown link-text normalization. The md has a site-generated index preface, so its digest is
still a point attestation.

## The one real contradiction (also sent to KagiR23): QM3 versus the SC_FETCH legacy branch

- `corpus/QUALITY.md:41` QM3: every unverified branch is counted in the verdict line or fails the run.
  The precedent is round-10's `UNVERIFIED` verdict (`lessons/round-21.md:13`, M3).
- `corpus/sources-census.sh:98-99` still says “Nothing is skipped … no `skipped=` count to carry
  (QUALITY.md QM3)”.
- That conflicts with three things in the same file:
  - `:67-69` says legacy in-row digests are “required for coverage, never compared to captures”.
  - `:299-303` accepts any 64-hex in-row value and `continue`s.
  - The CLEAN line (`:338`; R21-02 expects `rows=26 A=24 … legacy=21`) has no count of rows covered
    only this way. Its `legacy=` field counts legacy knowledge entries, not pins.
- S003 is a measured instance. `7f6d3b49…` reproduces under no representation, on two days, across a
  redeploy, and no archive capture exists.
- `lessons/round-23.md:141` M23-1 names only S012/S013/S014/S016. S003 is the same class and stays green
  without being counted. `:166` says SC_FETCH “covers every registry row”.
- Overlap: SourceS009/S013/S016/S022 already flagged the “in-row or row” disjunction. This adds the
  QM3/header self-contradiction and the S003 measurement only.

**Fix (pick one):**
- (a) Add `fetch_declared=D fetch_inrow_only=I` to the CLEAN line, rewrite `:98-99`, and migrate R21-02
  with a QM14 old/new record. Reading the code, I=16 on the in-flight tree, including queued S005 and
  rejected S008.
- (b) Emit a non-CLEAN verdict or finding for mined rows whose only provenance is in-row (the siblings'
  stricter path).

**Synthetic minimal failing fixture (proposal; not executed):** in `base_fixture` (`sources-census.sh:350`),
append ``Fetch sha256: `<64×"0">` `` to S001's teaches cell (`:360`) and drop S001's fixture provenance
row (`:397`).
- Expected under (a): `SOURCES_CENSUS: CLEAN (rows=4 A=1 B=2 C=1 queued=1 mined=2 rejected=1
  entries_sourced=1 legacy=1 fetch_declared=3 fetch_inrow_only=1)`.
- Expected under (b): exit 1 with `SC_FETCH id=S001 inrow-only`.
- From the code, today's gate prints the unchanged CLEAN line with exit 0, so this mutant survives and
  both proposed cases fail now.

## Smaller notes (no corpus change required)

- **Prior-round misreading:** `round-22/build/Source03.md:57` says S003 does not establish vault-access
  scope. The page does tie a token's vault access to its issue: Q2 at md 239, `--vault` at md 82, and
  per-server token sets at md 95. The md bytes on 2026-10-20 were identical, so this was a misreading,
  not a page change. It was never integrated into the corpus (0 hits).
- **C1 latent pointer hazard:** `^\| S003 ` matches three lines:
  - `corpus/SOURCES.md:9`, the real docs/A/mined row.
  - `corpus/lessons/round-21.md:57`, a 4-column quote table.
  - `corpus/sources-census.sh:362`, a community/C/queued fixture decoy.

  No closure obligation points at S003 (0 hits in the round-22 spot-check and in
  `closure-dispositions.json`). Any S-id resolver must parse only the 13-field rows of
  `corpus/SOURCES.md` §Registry.
- **E1 pointers checked:**
  - Line 2's locator and line 4's “90d for S001–S004” match the row.
  - Item 3 (line 14) is preserved, and its appended [INFERENCE]/attribution notes (lines 74-77, 84-86)
    match today's text.
  - The falsifier at line 30 (Connect setup still separates the two credentials) is not triggered.
  - Line 3 (“recorded their fetched-byte digests”) is historically true and claims no reproducibility.

## Limits

- I reopened only S003's URL (md and HTML; RSC not fetched). I also fetched the S025 URL, solely to
  validate my normalizer; I audited no other row.
- I ran no gate, census, selftest or ledger command and did not execute the TSV `request_profile`.
  Git state comes from reading `.git/HEAD` only.
- In-flight files changed while I worked; the line cites are at the hashes above.
- md and HTML values are point observations from 03:42–03:50Z.
- Tools: preinstalled curl 8.23.0 and Python urllib. No installs or updates, so RULES.md was not needed.

## Checks for L1 after integration

1. `sed -n 9p corpus/SOURCES.md | sha256sum` → `6ca8f899…`; `grep -c 'supersedes S003' corpus/SOURCES.md` → 0.
2. `curl -sSL -H 'Accept: text/markdown' https://www.1password.dev/connect/get-started | sha256sum` →
   `66831901…` (14,652 B), unless the vendor edits the page. The HTML digest is expected to change per deploy.
3. If (a) or (b) lands: add the S001 in-row-only mutant to the census selftest, record R21-02/R21-03
   migrations per QM14, and count those rows separately in the round-23 §Source accounting.
