# SourceS019 — S019 Credential Broker integration eligibility

Seat: `SourceS019` (leaf, read-only). Axes: **calibration**, **freshness**,
**operability**. Scope: exact row `corpus/SOURCES.md:25` (S019), its canonical
public URL and anchor, its used-by pointers, and the planned C2 provenance
expectations for that row. S007 was read only for supersession; no other source
row was audited. Advisory report only, not admission. No production edit, no
gate execution, no account/vault/entitlement probe, no installs.

## 1. Observed revision and live-tree caveat

- HEAD: `d218603b74099ddca0bd8f869516fc41db0979bf` (`.git/HEAD` and
  `refs/heads/master` identical), read at 00:44 and 00:50 on 2026-10-21.
- `corpus/SOURCES.md` changed under the audit while round-23 rows were being
  integrated into the registry:
  - First read/hash: `a5e1c13e95bafbdd7cbfdf2352fda7a6ba76b620fc2873f93031700f5f99cc30`,
    22,843 B, 118 lines, 23 rows; `corpus/stamps.tsv:61` pinned exactly these bytes.
  - 00:47:40: `50dfd6c8…`, 24,241 B, 120 lines, 25 rows (S024, S025 appended).
  - 00:49:17: `06dde644801bee13736fca21d9ecadec83086ea1f5de77043394a62d2d525b29`,
    24,995 B, 26 rows (S026 appended).
- `corpus/stamps.tsv` (`febcdf46…`) still pins the first state, so the measured
  tree is dirty relative to its stamps. `corpus/lessons/round-23.md` is absent,
  while S024–S026 `used-by` cite it. These are flagged for L1, not audited here.
- **Row S019 is byte-identical in every observed state**: line 25 sha256
  `c11a1bd2dda069d3b7b7cb921e94757e13908bb3a4521753f2494ab40234619b`; its text
  matches the frozen 23-row population. I did not run `git status`/index
  operations; the byte hashes above are the direct observation.

## 2. Public reopen — `https://www.1password.dev/brokered-access`

Reopened 2026-10-21 (read/web only). HTTP 200, no redirect. The URL has two
representations:

| representation | bytes | sha256 | stability |
|---|---|---|---|
| `text/html` raw GET | 1,199,447 | `67f690e21116a3644be8cff57058293150b8b03fc305ffa15dc3af63fa43c312` | at least 8 fetches identical (consecutive GETs, five UA/Accept variants, `curl 8.23.0 -sSL`) |
| `text/markdown` alternate `/brokered-access.md` | 6,841 | `b4de0ea02db016ecaab7fe033f47a3b74b158626bcafcb41074b9865450f91e3` | 2 fetches identical; same byte count round 22 recorded |

HTML headers: `ETag: W/"z6d2q9klrgppcp"`, `Cache-Control: no-store`, but
`CF-Cache-Status: HIT`, `Age: 10768`, `Server: Vercel`,
`X-Matched-Path: /_sites/[subdomain]/[[...slug]]`,
`Vary: rsc, accept-encoding, Accept, User-Agent`. The `read` tool served the
**markdown alternate** for the canonical URL (its output records
“Method: alternate-markdown”), not HTML — material for C2, section 5.

Anchors verified in HTML:
- H1: “Set up 1Password Credential Broker to allow your team to access secrets in
  their workflows (public preview)” — H1 heading, reopened 2026-10-21, URL above.
- `h2 id="add-an-integration"` exists. “GitHub Actions” is a bold sub-label
  inside that section, not a heading id, so `§GitHub Actions requirements` is a
  descriptive anchor, recoverable but not a fragment. Round-22 F3's note still holds.
- No displayed version, no visible “Last updated”/date, no `<time>` element. The
  only date is JSON-LD `dateModified: 2026-08-17T22:36:47.823Z` (machine-only),
  unchanged from the round-22 record.

Located quotes (all ≤25 words; page has no displayed date, JSON-LD date 2026-08-17;
URL above; heading named):
- “a supported integration in their 1Password Business account” — Introduction (8 words).
- “Your GitHub organization must be hosted on GitHub.com.” — Add an integration → GitHub Actions (8 words).
- “GitHub organizations hosted on GitHub Enterprise Server or GitHub Enterprise Cloud with data residency aren't currently supported.” — same section (17 words).
- “If you use GitHub Free for organizations, your team won't be able to use this integration for workflows in private repositories.” — same section (21 words).

All four are present in the rendered HTML projection (script/style/svg removed,
entities decoded, whitespace collapsed, ’→'). Three are **not** contiguous substrings
of the raw `.md` source because inline link markup splits them. The rendered HTML
DOM contains no “(public beta)”; that string occurs once in embedded navigation
JSON and is a visible Related-topics link label in the `.md` representation.

## 3. Field-by-field verdicts

| field | observation | verdict |
|---|---|---|
| URL canonical | 200, no redirect; H1/body load | **SUPPORTED** |
| scope: Business setup + GitHub deployment restrictions, not uniform status | intro requires a Business-account integration; GitHub bullets require GitHub.com, exclude Enterprise Server/Enterprise Cloud data residency, and condition private-repo use on GitHub Free | **SUPPORTED** |
| anchor | H2 `add-an-integration` plus bold GitHub Actions sub-label; `§GitHub Actions requirements` descriptive | **SUPPORTED**, precision note |
| teaches / supersedes S007 | guide-level H1/badge is “public preview”; S007's status/eligibility reading is replaced; S007's configured-claim, workflow-duration and integration-key mechanisms remain present today (“All configured claims must match”; “only remain accessible for the duration of the workflow”; integration-key sentence — S007 row quotes, same page, reopened 2026-10-21, URL above) | **SUPPORTED**; supersession scope matches `corpus/SOURCES.md:72` |
| status `mined` | quotes/digest live in `corpus/lessons/round-22.md:19` and `corpus/feature-claims.json:146–157`; the registry row itself carries no in-row quote or fetch digest | **SUPPORTED**, but C2 gap |
| tier A, kind docs | vendor primary documentation for its own setup/eligibility | **SUPPORTED** |
| opened 2026-10-20 | retrieval stamp, not content date; reopened 2026-10-21 | **SUPPORTED** |
| recheck `on-release` | unversioned live docs; feature-release trigger | **SUPPORTED** |
| used-by | `corpus/lessons/round-22.md:1` and `corpus/knowledge/feature-bound-credential-review.md:1` exist and carry S019 | **INCOMPLETE** (finding F3) |

No row explicitly supersedes S019. S019 supersedes S007 only on uniform-status/
eligibility; S020 supersedes S006; S017/S018 are separate feature anchors; S022/
S023 correct other rows. The S007 row is intact (`corpus/SOURCES.md:13`, fetch
`e4aef238…`, opened 2026-10-19).

**Deployed-product proof: none.** S019 documents a preview setup flow and its UI
labels; it does not prove entitlement, live availability for any account, or that
the documented UI matches a deployed tenant. The active review already states
this (`feature-bound-credential-review.md` §How to use the review). No account
probe was performed or authorized.

## 4. Historical bytes vs current semantic support

Same URL, three recorded raw-HTML responses on three days:

| recorded at | source | sha256 | bytes |
|---|---|---|---|
| 2026-10-19 | S007 row, `corpus/SOURCES.md:13` | `e4aef238bb5c93080bc0e1cc2156d0f8d19c9291dbbee60193bd42485686f818` | not recorded |
| 2026-10-20 | S019 pin, `corpus/feature-claims.json:149` | `896c780b243ebd1659dea22d6e46a1d4b2b74639adfde7ed22d8b362fc3b4a9f` | 1,199,099 |
| 2026-10-21 | this audit | `67f690e21116a3644be8cff57058293150b8b03fc305ffa15dc3af63fa43c312` | 1,199,447 |

`prior_registry_sha256` at `corpus/feature-claims.json:150` matches S007's
2026-10-19 digest `e4aef238…`, so the lineage is recorded, not invented.

- **Current semantic support: SUPPORTED.** H1, all four S019 quotes, S007's
  duration/claims quotes, and JSON-LD `dateModified` are unchanged. The `.md`
  alternate is still 6,841 B.
- **Cross-day byte identity: REFUTED.** The 2026-10-20 pin is not the 2026-10-21
  body; the delta is +348 B. Cause is **UNRESOLVED**: old bytes are not stored,
  the Wayback availability API returned HTTP 429, and the round-22 record kept no
  build marker. Today's HTML embeds `deploymentId: 68a8af9a517ab813d3b84097`;
  build/deploy churn is the plausible cause, not a quoted-content change.
- **Volatility class:** per-deploy/build, not per-response — at least eight
  fetches within today are byte-identical. This differs from S020's per-response Cloudflare
  email-protection fragment. A changed S019 digest is therefore weak drift
  evidence; a semantic check must use H1/quotes/dateModified.

## 5. C2 provenance expectations for S019 (proposal)

`corpus/source-fetches.tsv` should carry a row **keyed by row id S019**, not by
URL (S007 shares the URL), with:

| field | exact expectation |
|---|---|
| url | `https://www.1password.dev/brokered-access` (no fragment; fragments are client-side) |
| representation | one of `text/html` **or** `text/markdown`; explicit, because `read` silently returns the `.md` alternate |
| fetch_date | `2026-10-21` |
| sha256 / bytes | `67f690e2…` / `1,199,447` for HTML, **or** `b4de0ea0…` / `6,841` for markdown — never mix |
| anchor | `h2#add-an-integration` + bold `GitHub Actions`; for the `.md` representation use the visible heading text, since the alternate has no HTML ids |
| located quote | “a supported integration in their 1Password Business account” (8 words) or the GitHub.com sentence (8 words); ≤25 words |
| location check | resolve the quote in the **declared representation's** rendered projection: strip script/style/svg, decode entities, collapse whitespace, map ’→', strip markdown link markup for `.md` |
| excluded evidence | navigation JSON `(public beta)`, `.md` Related-topics labels, page `<title>`/shared nav status words |
| hash semantics | point attestation with fetch date and build marker (`ETag`, `deploymentId`); equality only against a duplicate fetch of the same capture; never a cross-day expected value |

**One real contradiction.** The stored S019 digest `896c780b…` (1,199,099 B,
2026-10-20) and `feature-claims.json:17`'s “W2 reproduced S017, S018, S019 …”
(also `corpus/SOURCES.md:101`) do not match today's stable bytes `67f690e2…`
(1,199,447 B), while H1, all four quotes, and `dateModified` are identical; the
same URL already had a third digest (`e4aef238…`) on 2026-10-19. A C2 equality
check against the stored digest would false-fail on a build change; the plan's
own rule (“point attestations … never content-drift pins”, `plans/round-23.md:20–31`)
is the correct policy, and this observation demonstrates it.

**Minimal failing fixture proposal (not executed).** One valid control row for
S019 (`text/html`, digest `67f690e2…`, 1,199,447 B, quote `S019-business`,
anchor `#add-an-integration`) and mutants: (a) URL replaced with
`.../brokered-access.md`; (b) digest uppercase/short; (c) quote absent from the
declared representation; (d) anchor absent. Each mutant must exit non-zero with a
distinct `SC_FETCH` finding; the control must pass. This is a proposal, not a run.

## 6. Findings

1. **F1 — medium, freshness/C2.** Stored S019 bytes are not reproducible across
   days (`896c780b…` → `67f690e2…`) with unchanged semantics; three digests over
   three days for one URL. **Fix:** record representation + date + build marker;
   keep `896c780b…`/`e4aef238…` as historical point observations; never re-bless
   today's digest as the expected value.
2. **F2 — medium, operability/representation.** The canonical URL has HTML
   (1.2 MB) and markdown (6,841 B) representations; `read` returns the latter; the
   markdown carries a visible “(public beta)” Related-topics label absent from the
   HTML DOM; three quotes are split by link markup in the raw markdown. **Fix:**
   declare representation and run quote checks on a rendered projection, not raw
   bytes; exclude navigation/related-topic status words.
3. **F3 — low, pointer completeness.** `corpus/knowledge/onepassword-machine-credentials.md`
   cites S019 at lines 42, 49, 51 and 63 in its current round-22 erratum, but
   S019's `used-by` omits it and that file's `source:` line still lists
   S001–S004 and S006–S007 (not S019).
   **Fix:** either add the file to S019's `used-by` **and** S019 to that file's
   `source:` line (otherwise `SC_USEDBY_NOCITE` fails), or record an explicit
   rationale for treating errata citations as non-consumers.
4. **F4 — low, precision (pre-existing).** The row compresses the Free-plan
   condition to “private-repository requirements” and the page's “aren’t
   **currently** supported” to a snapshot; the active review restores both. No
   false admission; optional wording fix only.
5. **F5 — info, live tree (outside S019).** `SOURCES.md` moved through three
   states during the audit (`a5e1c13e` → `50dfd6c8` → `06dde644`), `stamps.tsv:61`
   is stale, `corpus/lessons/round-23.md` is absent, and `plans/round-23.md:20`'s
   “seven mined rows” is now ten (S017–S026 lack `Fetch sha256:`). S019's row is
   unchanged. L1 must reconcile counts and re-stamp before gate checks.
6. **F6 — info, deployed-product proof.** None claimed; documentation of a
   preview setup flow only. No live entitlement or tenant behavior follows.

## 7. Bottom line

S019 is **SUPPORTED as scoped**: today's page still teaches the Business-account
setup requirement and the GitHub.com/Enterprise/Free-private-repository
restrictions; the guide-level “public preview” label still does not determine
custom-workflow status; tier A, `mined`, `on-release`, and the S007 supersession
scope are calibration-correct. The row is not refuted and is not superseded.
One medium freshness fact remains: its recorded raw bytes are a point observation,
not a reproducible content identity, and its `.md`/HTML representation split must
be explicit in C2. The used-by list is incomplete but the row's cited consumers
are accurate.

## 8. Limits

- No account, vault, SDK, workflow, or entitlement probe; no live UI check.
- No gate, census, ledger, or build execution; no git status/index operations;
  no installs. `read` served the markdown alternate; raw HTML was fetched with
  public GETs (urllib and curl 8.23.0) with recorded headers.
- The 2026-10-19/20 bytes were not available, so the 348-byte delta's cause
  remains unresolved; Wayback returned 429. Semantic checks cover H1, the four
  S019 quotes, S007's two mechanism quotes, and the machine date, not every
  sentence of the page.
- The working tree changed during the audit; all citations use the measured
  snapshots above, and S019's row line hash is identical across them.
