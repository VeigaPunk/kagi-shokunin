# SourceS007 — S007 provenance recheck (round 23)

Seat: SourceS007, leaf, read-only. No subagents, no gate/census execution, no account,
workflow, SDK or vault action, no archive mutation. No tool installed. One file written:
this report.

Observed revision: `d218603b74099ddca0bd8f869516fc41db0979bf` (`git rev-parse HEAD`).

| file read | worktree sha256 | HEAD blob |
|---|---|---|
| `corpus/SOURCES.md`, audit start | `a5e1c13e95bafbdd7cbfdf2352fda7a6ba76b620fc2873f93031700f5f99cc30` | same |
| `corpus/SOURCES.md`, write time | `06dde644801bee13736fca21d9ecadec83086ea1f5de77043394a62d2d525b29` | changed by peers/L1 |
| `corpus/knowledge/onepassword-machine-credentials.md` | `8380b35927e96b89fc0da7832516ecaff2a8e097660b47c599f560344709cf48` | same |

At audit start `corpus/SOURCES.md` had 23 `S###` registry rows and 16 `Fetch sha256:`
strings. During the audit L1/peers added S024–S026 concurrently, so at write time it has
26 rows. The S007 and S019 rows themselves are byte-identical to HEAD (line sha256
`f9905ea9…` and `c11a1bd2…` respectively); S007 stays at line 13. The three new rows are
out of this seat and were not audited. `plans/round-23.md` is untracked peer/L1 work; it was
read for the C2 plan only and is not treated as source evidence.

## 1. Row under audit (exact frozen fields)

| field | value (`SOURCES.md:13`) |
|---|---|
| id / kind / tier | S007 / `docs` / `A` |
| URL | `https://www.1password.dev/brokered-access` |
| scope | Public-preview workflow identity verification, configured-claim matching, workflow-duration access, integration-key handling |
| anchor | Page title (public preview), introduction, §GitHub Actions and §Custom Workflow (OIDC); no displayed version/date, opened 2026-10-19 |
| teaches | all configured OIDC claims must match; workflow-duration access; GitHub organization secret for the integration key |
| record shape | quotes from introduction, Custom Workflow, GitHub Actions |
| status / opened / recheck | `mined` / 2026-10-19 / `on-release` |
| used-by | `corpus/knowledge/onepassword-machine-credentials.md` |

Legacy pin: `Fetch sha256: e4aef238bb5c93080bc0e1cc2156d0f8d19c9291dbbee60193bd42485686f818`
(no representation, request or byte count recorded).

## 2. Opens and transport facts

All requests were plain `curl -sS -L` GETs of public pages on 2026-10-21, no JavaScript
execution, no browser, no interaction with the tab controls. The fragment targets were
inspected directly in the fetched DOM.

| representation | result |
|---|---|
| `https://www.1password.dev/brokered-access` raw HTML | HTTP 200, `text/html; charset=utf-8`, `date: Wed, 21 Oct 2026 03:42:33 GMT`, 1,199,447 bytes, sha256 `67f690e21116a3644be8cff57058293150b8b03fc305ffa15dc3af63fa43c312` |
| response markers | `etag: W/"z6d2q9klrgppcp"`, `cf-cache-status: HIT`, `age: 10714`, `x-served-version: dpl_8AUWT8nFRmT7D3RgoEGEPVymfFQP`, `buildId: 6ad68a298cdc29c1c7fdf7e9`, JSON-LD `dateModified: 2026-08-17T22:36:47.823Z`; **no** `Last-Modified`, **no** displayed page date |
| `https://www.1password.dev/brokered-access.md` (vendor text) | HTTP 200, `text/markdown; charset=utf-8`, `date: Wed, 21 Oct 2026 03:43:36 GMT`, 6,841 bytes, sha256 `b4de0ea02db016ecaab7fe033f47a3b74b158626bcafcb41074b9865450f91e3` |
| `.md` freshness header | `last-modified` equals the request second (regenerated), so it is not a content clock |

Repeatability inside this deployment: six HTML fetches today (initial, three default-UA,
one Chrome UA, one `--compressed`) all returned the same 1,199,447 bytes and the same
sha256, `67f690e2…`. The raw HTML is stable for this deployment and cache variant now.

No open failed (all HTTP 200). No Wayback/archive request was attempted this round, so no
claim is made that 2026-10-19 or 2026-10-20 bytes were recovered. No skipped reopen is
reported as a success.

### Transport/digest volatility, isolated

| observation | 2026-10-20 (round-22 report) | 2026-10-21 (this seat) |
|---|---|---|
| raw HTML bytes / sha256 | 1,199,099 / `896c780b243ebd1659dea22d6e46a1d4b2b74639adfde7ed22d8b362fc3b4a9f` | 1,199,447 / `67f690e2…` |
| raw HTML `ETag` | `W/"11vu9hu72scpp31"` | `W/"z6d2q9klrgppcp"` |
| vendor `.md` bytes / sha256 | 6,841 / `b4de0ea02db016ecaab7fe033f47a3b74b158626bcafcb41074b9865450f91e3` | **identical** |
| JSON-LD `dateModified` | 2026-08-17T22:36:47.823Z | **identical** |
| Next `buildId` | `6ad68a298cdc29c1c7fdf7e9` | **identical** |

The 2026-10-20 column is the prior report's recorded observation, not a re-fetch here; the
old bytes are unavailable, so this is a digest/size/ETag comparison, not a byte diff. The
combination — same build id, same content clock, same vendor text — while raw HTML changes
digest, size and ETag — is direct evidence that a raw-HTML SHA-256 is sensitive to
deployment/transport chrome and is not a content pin. [INFERENCE] the delta is non-content
chrome (serialized RSC/nav/assistant state), but it was not byte-localised.

Additional representation trap observed now: the same quote strings occur multiple times in
the raw HTML, including in the serialized `self.__next_f` payload around offsets 1.17–1.19 M,
outside the rendered article. A bare substring test over raw bytes can pass on serialized
data even if the rendered section changed.

## 3. Scoped teaches, rechecked against current public text

Clock below is the vendor-declared JSON-LD `dateModified` 2026-08-17T22:36:47.823Z; all were
opened 2026-10-21 at the named URL. Quotes are ≤25 words.

| # | location | quote | verdict |
|---|---|---|---|
| Q1 | introduction, `brokered-access.md:17` | "Secrets are only accessible after a workload has been verified, and only remain accessible for the duration of the workflow." | supported (20 words) |
| Q2 | Add an integration → GitHub Actions, step 2, `.md:42` | "The token value is your integration key, which is required to decrypt secrets in your team's workflows." | supported (17 words), **but see §7 case contradiction** |
| Q3 | Add an integration → Custom Workflow (OIDC), step 3, `.md:48` | "All configured claims must match to verify the workload's identity." | supported (10 words) |
| Q4 | GitHub Actions step 2, `.md:42` | "Set the secret name to OP_INTEGRATION_KEY and the value to your integration key." | supported (13 words) |
| Q5 | page H1/title, `.md:5` | "Set up 1Password Credential Broker to allow your team to access secrets in their workflows (public preview)" | supported guide-level label (17 words) |
| Q6 | subtitle under H1, `.md:7` | "supported integration in 1Password Business" | supported eligibility (5 words) |

URL for Q1–Q6: `https://www.1password.dev/brokered-access`.

Current scope mapping:

- **Identity verification:** Q1, plus "1Password validates the identity of the workload
  using an OIDC token" (introduction).
- **Configured-claim matching:** Q3, in the Custom Workflow (OIDC) panel only, not a
  guide-wide rule.
- **Workflow-duration access:** Q1, introduction.
- **Integration-key handling:** Q2/Q4; key is `OP_INTEGRATION_KEY`; GitHub path stores it as
  a secret "for your GitHub organization"; the Custom OIDC path configures it as a runtime
  secret (e.g. GitLab CI/CD variable).
- **Public-preview status:** true of the guide title/H1 and navigation label; not evidence
  of a uniform per-feature status. S019 supersedes that reading.

Tier `A` is appropriate for primary vendor setup documentation of the listed mechanics. It
is **not** deployed-product proof: no account, workflow, SDK, environment or secret was
exercised. Q1/Q3/Q4 are vendor statements of documented behavior, not observed runtime
results.

## 4. Status and explicit supersession

- `corpus/SOURCES.md:25` S019: "supersedes S007 — the guide-level preview label does not
  determine custom-workflow status; Business setup and GitHub.com/private-repository
  requirements remain separate qualifiers."
- The round-22 supersession note at `corpus/SOURCES.md:75-77` is explicit: S019 replaces
  **only** the uniform-status and eligibility reading, not the still-supported
  integration-key, configured-claim-matching or workflow-duration mechanisms.
- Therefore S007 stays `mined` and tier `A` for mechanics. No status, tier, recheck or
  used-by change is justified by this audit.
- Current guide evidence agrees with the supersession rationale: the raw HTML contains
  exactly one `(public beta)` string, the navigation title for the custom-workflow link,
  and the tags-stripped text contains zero. That is the method artifact behind the earlier
  false negative. S017/S018/S020 content was not re-audited here; only this sidebar string
  and the S019 row text were used.
- No rejected or queued row is touched. S008 remains `rejected`; this report is not an
  admission and does not re-curate any row. S024–S026 were added concurrently during this
  audit and are out of this seat; they were not opened or judged here.

## 5. Historical bytes versus current semantic support

The legacy pin `e4aef238…` was not reproduced by any representation fetched today:

| candidate | sha256 |
|---|---|
| raw HTML, 1,199,447 bytes | `67f690e21116a3644be8cff57058293150b8b03fc305ffa15dc3af63fa43c312` |
| vendor `.md`, 6,841 bytes | `b4de0ea02db016ecaab7fe033f47a3b74b158626bcafcb41074b9865450f91e3` |
| text projection v1 (tags→space; 6,019 chars) | `f3861c172c370dd10ef8a9289857b0b59c5b07a9d16f2f7cf25aeb02738cc6e9` |
| text projection v2 (tags→empty; 5,915 chars) | `63513006dbbea1da48de1000d159cb9240e6beebb880e8f98aaa2ccae5502a8d` |

Disposition: **unreproduced / representation undocumented**, not content drift and not a
verified match. The vendor content clock (2026-08-17) predates the 2026-10-19, 2026-10-20
and 2026-10-21 openings, the `.md` digest is identical across the last two, and `buildId`
is unchanged. There is no observed content change over that interval; only the raw HTML
envelope moved. Retain `e4aef238…` verbatim as a historical point value; do not delete,
re-stamp or treat it as the expected current value.

## 6. Used-by pointer

`corpus/knowledge/onepassword-machine-credentials.md` is a real regular file and carries
`S007`:
- `:2` source line includes S007 (with S001–S004, S006), so the census used-by/cite contract
  is satisfied for S007.
- `:16` uses S007 for the combined status sentence plus claim matching, workflow duration
  and integration key; `:25` uses S007 for the retained CI-held key; `:61` retains the key
  requirement.
- The round-22 erratum at `:47-52` corrects the combined status using S017/S018, and `:58`
  cites S020; `:35` preserves the historical "not reproduced" text.

One live wiring gap remains, already reported in round 22 and still present: the erratum
depends on S017–S020, but the entry's `source:` line still lists only S001–S004, S006,
S007, and S017–S020's `used-by` lists `corpus/lessons/round-22.md` and
`corpus/knowledge/feature-bound-credential-review.md`, not this entry. `SC_ENTRY_CITE`
parses only the `source:` line, so the active round-22 correction is outside the census.
This does not weaken S007's mechanism evidence, but it is a machine-provenance gap C2 must
address: either append S017–S020 to the entry's `source:` line (and their `used-by`), or
record an explicit machine-checked correction pointer. The preserved historical sentence at
`:35` must not be read as the active custom-OIDC status.

## 7. Planned C2 (`corpus/source-fetches.tsv` + `SC_FETCH`) — exact expectations

The plan (`plans/round-23.md` item 2) requires, for every `mined` row, the reopened URL,
fetch date, representation, SHA-256, byte count and a located ≤25-word quote, with a
fail-closed `SC_FETCH`. Concrete acceptance rules, using S007 as the worked case:

**7.1 Record shape.** One tab-separated row per source, header plus comment lines like the
claim ledger:

```text
id  url  fetched_at  representation  http_status  bytes  sha256  anchor  quote  quote_words  content_clock  deploy_id  note
```

- `fetched_at` in UTC ISO-8601 with seconds; `bytes` and `sha256` must describe the same
  buffer.
- `representation` is a closed enum, not prose: `md` = GET `<url>.md`; `raw-html` = GET
  `<url>` with content decoding done before hashing; `text-v1` = the named projection
  (remove `script`/`style`, replace tags with one space, HTML-unescape once, collapse
  whitespace, hash UTF-8).
- `content_clock` is the vendor-declared `dateModified` (S007:
  `2026-08-17T22:36:47.823Z`); `deploy_id` is the deployment/build stamp (S007:
  `dpl_8AUWT8nFRmT7D3RgoEGEPVymfFQP` / `6ad68a298cdc29c1c7fdf7e9`), auxiliary only, never
  part of the digest identity.

**7.2 Anchor must resolve, not merely be named.** The row's `§GitHub Actions` and
`§Custom Workflow (OIDC)` are **not headings** in either current representation:
- raw HTML has no article H2/H3 with those names; the article H2s are "Add an integration",
  "Delete an integration" and "Learn more" (plus the chrome headings "Documentation Index"
  and "On this page"). The labels are tab controls:
  `li#github-actions[role=tab]` + `div#panel-github-actions-0[role=tabpanel]`, and
  `li#custom-workflow-oidc[role=tab]` + `div#panel-custom-workflow-oidc-1[role=tabpanel]`.
  The custom panel is not the initially selected tab; a fragment `#custom-workflow-oidc`
  targets the tab button, not the quote's panel.
- vendor `.md` renders them as bold labels at `:32` and `:44`; the later `### GitHub
  Actions` (`:54`) and `### Custom workflow` (`:60`) are "Learn more" related-topic cards,
  not the setup sections. A heading-slug resolver would anchor the wrong content.

`SC_FETCH` must therefore require a resolvable selector (HTML `id` plus tag/role, or the
panel id reached via `aria-controls`) or an exact `.md` line span / bold-label match. A bare
`§` label is not admissible. If the anchor is a tab, the quote must be verified inside its
`aria-controls` panel.

**7.3 Quote.** Exact, case-sensitive, contiguous substring of the chosen representation,
verified **inside the anchored node/line span**, ≤25 words. No case, punctuation,
apostrophe or whitespace normalization unless a normalization tag is recorded. One quote is
bound to one representation: HTML uses typographic apostrophes (`workload’s`, `team’s`),
`.md` uses straight ones (`workload's`, `team's`), so a cross-representation check is not
valid. Entity decoding is allowed only as a declared part of `text-v1`.

**7.4 Hash semantics and fail-closed findings.** Hash the exact response body bytes after
HTTP decoding; `bytes` must equal the hashed length; never hash a re-rendered DOM, a second
fetch or a normalized derivative unless it is the declared representation. `SC_FETCH` must
find: missing row for a `mined` id; unknown representation; URL mismatch; malformed or short
digest; byte-count mismatch; absent anchor; absent quote; quote >25 words; and a legacy
in-row digest with no representation. The last is important: the plan's wording "in-row
`Fetch sha256:` or a complete provenance row" would accept S007's stale `e4aef238…` as
satisfying C2. That is a false pass. A legacy in-row value without representation/date/bytes
must be reported as `legacy-unreproduced`, not counted as provenance. A mined row with only
the in-row value still needs a complete provenance row.

**7.5 Historical/rejected/superseded distinction.** Only `mined` rows require provenance;
`rejected` (S008) and any `queued` row are exempt and must not be upgraded. For S007 the
provenance `note` must name S019 and state that the supersession covers status/eligibility
only; active mechanism evidence remains S007. The preserved historical sentence in the entry
(`:35`) is not active evidence, and S019's label must not be reused as a per-feature status.

**7.6 One real contradiction (observed now).** The row's recorded quote is lowercase:

- `corpus/SOURCES.md:13`: `“the token value is your integration key”`
- current `brokered-access.md:42` and `:50`: `The token value is your integration key`
- current raw-HTML visible text: same capital `The`; lowercase form occurs zero times.

An exact C2 substring check fails today. Case-insensitive matching would pass, but silently
folding case weakens quote provenance. Recommended disposition: L1 appends a correction
(quote starts "The"), then records the quote against the `.md` representation; retain the
historical row text. [INFERENCE] the lowercase form is a transcription slip, since the
round-22 report already quoted the capital form and the content clock has not moved; the
original 2026-10-19 bytes are unavailable, so this cannot be proven.

**7.7 Minimal failing fixture proposal (for L1, not executed here).** Under
`corpus/fixtures/source-fetches/`:
- a mini `SOURCES.md` with one `mined` row whose in-row `Fetch sha256:` is a legacy value;
- a `source-fetches.tsv` row pointing at a committed 6,841-byte `.md` snapshot with sha256
  `b4de0ea0…`, anchor `md:42`, quote `the token value is your integration key`;
- expected: `SC_FETCH` emits a quote finding (for example `SC_FETCH_QUOTE`) and exits
  non-zero.
- control: same snapshot/anchor with `The token value is your integration key` → no finding,
  exit zero.
- mutation: flip one byte of the snapshot without updating `sha256` → digest finding.
- legacy case: in-row value only, no provenance row → `legacy-unreproduced` finding.
These are proposed expected failures, not fabricated passes.

## 8. Recommendations to L1 (append-only; no admission)

1. Keep S007 `mined`, tier `A`, `on-release`; the four mechanism elements remain supported.
   Do not turn S019's status correction into a row rewrite.
2. When C2 lands, add a provenance row for S007 using the vendor `.md` representation:
   `https://www.1password.dev/brokered-access.md`, 2026-10-21, 6,841 bytes,
   `b4de0ea02db016ecaab7fe033f47a3b74b158626bcafcb41074b9865450f91e3`, content clock
   `2026-08-17T22:36:47.823Z`, deploy `dpl_8AUWT8nFRmT7D3RgoEGEPVymfFQP`; retain
   `e4aef238…` in the note as historic/unreproduced.
3. Append a correction to S007's quote case (`The token value…`) or explicitly declare the
   normalization; do not silently lower-case in the checker.
4. Record anchors as `#github-actions`/`#panel-github-actions-0` and
   `#custom-workflow-oidc`/`#panel-custom-workflow-oidc-1`, or the `.md` bold labels at
   lines 32/44 with the quote lines 42/48; never as bare `§` prose.
5. Close the entry citation gap: append S017–S020 to
   `corpus/knowledge/onepassword-machine-credentials.md:2` and their `used-by`, or add a
   machine-checked correction pointer; otherwise C2's active-evidence coverage stops at
   S007 while the entry's current status reading depends on S017/S018/S020.
6. Do not require provenance from rejected/queued rows; S008 stays rejected. No new source
   row is needed for S007.

## 9. Limits and unresolved

- Documentation only: no deployed-product proof, no account/workflow/SDK/vault, no secret
  value or credential example handled.
- Raw HTML is deployment/transport-volatile; only one prior digest/size is available and the
  old bytes were not recovered, so the byte delta is inferred to be chrome, not proven.
- `.md` is vendor-generated text; `dateModified` is vendor-declared; `.md` `Last-Modified`
  is regenerated per request and was not used as a content clock.
- No JavaScript/browser rendering and no tab clicking; anchors were inspected in the static
  DOM, where both tab panels are present. Visibility behavior under a fragment was not
  exercised.
- S017/S018/S020 content was not re-audited; only the S019 row text and one `(public beta)`
  sidebar string were used for supersession context.
- No census, `SC_FETCH`, fixture or other gate was executed; all checker statements are
  specifications, not observed passes.
- No archive/Wayback query this round.

Report: `.ufo/waves/round-23/parent-build/SourceS007.md`
