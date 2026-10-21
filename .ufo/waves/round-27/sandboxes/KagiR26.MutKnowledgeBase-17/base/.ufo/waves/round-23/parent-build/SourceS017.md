# SourceS017 — S017 provenance audit (round 23 parent build, read-only)

Seat `SourceS017` (reviewer, leaf). Axes: calibration, freshness, operability.
Advisory only: this report is not an admission, and it makes no production edit. S017 stays `mined`/A as recorded.
Audit window: 2026-10-21 03:42Z–03:58Z (UTC).

## 1. Observed revision and inputs

| item | observed |
|---|---|
| HEAD / frozen base | `d218603b74099ddca0bd8f869516fc41db0979bf` (= `plans/round-23.md:3`) |
| `corpus/SOURCES.md` at base | `a5e1c13e95bafbdd7cbfdf2352fda7a6ba76b620fc2873f93031700f5f99cc30`, 118 lines, 22,843 B (= `corpus/stamps.tsv:61`) |
| S017 row | base line 23; row+LF sha256 `1127ecdbcc15508703abc97b40867ca01513385b2598c83b60e9ed6e29bdb73a`. Introduced once in `8ada17a` (round-22 landing; `git log -S` finds no other commit). Byte-identical at `d218603b` and in the live tree at 03:52Z |
| `corpus/feature-claims.json` | `a66acbfb…449b` (= `stamps.tsv:9`); S017 record at lines 99–117 |
| `corpus/knowledge/feature-bound-credential-review.md` | `53a24710…42d8`, 60 lines |
| `corpus/lessons/round-22.md` | `0bb9d105…cae8` |

**Live-tree movement.** L1's uncommitted round-23 integration ran while this audit was in progress, and HEAD stayed `d218603b`:

- `SOURCES.md` changed to `06dde644…`, 121 lines, adding S024–S026.
- `corpus/source-fetches.tsv` was added. It changed three times while I read it (`c77520f8…` → `e2f40132…` → `ccc9ae6e…`).
- `sources-census.sh` was edited (`ece39d32…` → `80966e20…`).
- `corpus/lessons/round-23.md` was added (`2adea258…` → `d5520988…`).

Citations of in-flight files name the snapshot I read; they are not committed evidence.

## 2. Opens and failures

All requests were public, unauthenticated GETs made on 2026-10-21.

| # | target | result |
|---|---|---|
| O1 | `read` tool on the registry URL | Succeeded. It served the `text/markdown` alternate. |
| O2 | `curl` on the registry URL (trailing slash) | 308 → `/brokered-access/github-actions` → 200 `text/html`. 1,215,460 B, sha256 `62953bb47db1af593c522b06c4f12c6a89853dd0a8fb718118189349213f478d`. Every variant returned identical bytes: default/Mozilla/curl UA, HTTP/1.1, `--compressed`, `Accept-Encoding: identity`, `Accept-Encoding: gzip`, `Accept-Language`. The declared profile `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)'` (03:57Z) also matched. |
| O3 | `…/github-actions.md` (`rel=alternate type=text/markdown`) | 200 `text/markdown`. 5,245 B, sha256 `092fd0ba581cbb60eaf756e853d8659c15b76e17dd616c23aff8137ef42c6d0f`. Four GETs were identical, including the declared profile. |
| O4 | `developer.1password.com/docs/` | 301 → `https://www.1password.dev/`, a first-party domain |
| O5 | Wayback CDX for the page | The first attempt **failed** (30 s timeout). The retry succeeded: six captures from 2026-08-13 to 2026-10-12, none on 10-20 or 10-21. |
| O6 | Wayback `id_` payloads 20261006075820, 20261012140443, 20261012140444 | Each payload's base32 SHA-1 equals its CDX digest. Bodies are gzip; decoded sizes are 1,204,919, 1,202,335 and 1,202,335 B. |
| O7 | Wayback CDX for the `.md` alternate | No captures (empty result). |

## 3. Row recheck: supported as written

Public text was observed at https://www.1password.dev/brokered-access/github-actions on 2026-10-21. Quotes total 25 words:

- **Page title H1:** “Use 1Password Credential Broker to access secrets in GitHub Actions at runtime (public preview)”
- **Badge under the H1:** “Public Preview”
- **Introduction:** “connected your GitHub organization to your 1Password Business account” (inside the conditional opening sentence)

| field | verdict and evidence |
|---|---|
| scope | **Supported.** Status and the Business prerequisite both come from this feature page's own H1, badge and introduction. |
| anchor | **Supported.** The H1 is `.md` line 5 and the single `<h1 id="page-title">`; the introduction is `.md` line 11. The page displays no version or date. Its machine content clock (JSON-LD `dateModified` `2026-08-04T15:42:17.097Z`) is the same on 10-06, 10-12 and 10-21. |
| teaches | **Supported.** “First” is a fair reading of the conditional prerequisite. Get help repeats the administrator connection but says “1Password account” there. |
| tier A / kind docs | **Supported.** First-party developer docs: JSON-LD Organization “1Password Developer”, and the vendor docs domain 301-redirects here. |
| status `mined` / used-by | **Supported.** Both files carry S017 on their `source:` line: `corpus/lessons/round-22.md:1` and `feature-bound-credential-review.md:1`. |
| supersession | **None.** The string `supersedes S017` appears 0 times at base and in the live tree, so S017 is active. S019 and S020 supersede only S007's and S006's readings. S017 is the per-feature status evidence QA10 requires. It does not carry S019's GitHub.com/GHES/Free restrictions or S020's EPM plan, and `feature-bound-credential-review.md:16` correctly cites S019 for those. |
| recheck `on-release` | The page has no release number; `dateModified` is the only observable change signal. |

## 4. The four distinctions

### Historical bytes
- The row bytes have not changed since `8ada17a`.
- The catalog digest `937f6828…0849` (raw HTML, 1,215,155 B; `feature-claims.json:102`, observed 2026-10-20) was reproduced the same day (`ReopenSource17.md:40,175`). It is **not reproduced on 2026-10-21**: the page now returns `62953bb4…478d`, 1,215,460 B (+305 B).
- It is now only a historical point attestation. Committed production text already treats it that way (`feature-claims.json:17`: “not live drift pins”; `SOURCES.md:101` is past tense).
- `ReopenSource17.md:175` (“byte-stable across fetches”) and `:201` (“reproducible today”) described a single time window and do not generalize.

### Current semantic support
- The H1, badge and introduction are present on 10-21.
- The article itself is unchanged since at least 10-06: the rendered text of `id="content-area"` hashes to `3e15d765…594e` (3,894 chars) on 10-06, 10-12 and 10-21.

### Transport and raw-HTML volatility
Three separate layers were observed:

- **(a) Content-Encoding.** Two Wayback records one second apart (2026-10-12) have different gzip payloads (SHA-1 `4RTTZ…` vs `M3RFU…`) but decode to identical HTML (`7983dd76…`).
- **(b) Site build.** Decoded HTML differs across dates:
  - 10-06: `5822f81d…`, buildId `6ac3e1e3…`
  - 10-12: `7983dd76…`, buildId `6ac963c7…`
  - 10-20: `937f6828…`, 1,215,155 B, buildId `6ad68a29…` (committed round-22 evidence `Source07.md:33,41`)
  - 10-21: `62953bb4…`, buildId `6ad68a29…`
- **(c) Site-wide chrome inside rendered text.** Whole-page `rendered-text-v1` is `7227ed88…33c9` on 10-06 and 10-12 but `2a39cb16…81c7` on 10-21. The only word-level difference is two new sidebar entries under Plugins (Claude Code and Cursor, each labelled beta).

Transport metadata is not a content clock either. The `.md` `last-modified` header is the response time (1 s after `date`). The HTML is served with `cache-control: no-store` and `age: 10711`.

### Deployed-product proof
None. This was a docs-only check with no account, integration, workflow or entitlement probe. “Public preview” is a vendor documentation label, not proof that the feature is available to any organization. This matches the limits in `feature-bound-credential-review.md`.

## 5. Used-by pointers, followed locally

- **`round-22.md`.** `:1` reads `source: S017, S018, S019, S020`. The `:17` Gate row quotes the H1 exactly (matches the live H1) and limits scope to Actions status plus the introduction's prerequisite.
- **`feature-bound-credential-review.md`.** `:1` cites S017 for its title and introduction. `:16` uses S017 only for status and the Business prerequisite.
- **Typed catalog (joined by id only, not a used-by target).** `feature-claims.json:99–117` holds the S017 record. `:265–273` require `S017-title` for status (alongside `S020-status-split`) and `S017-runtime` for `fact`.
- **No back-pointer.** The S017 row points to neither the catalog nor `source-fetches.tsv`, so a C1/C2 checker has to join by id.

## 6. C2 expectations for S017 (exact)

| field | expected |
|---|---|
| url | `https://www.1password.dev/brokered-access/github-actions/` (exact registry string) |
| final_url | `https://www.1password.dev/brokered-access/github-actions` after one 308; equals `rel=canonical` and `og:url` |
| http_status | 200 |
| representation | `decoded-http-body-volatile-v1` is correct for the raw HTML |
| sha256 / bytes, raw HTML (10-21) | `62953bb47db1af593c522b06c4f12c6a89853dd0a8fb718118189349213f478d` / 1,215,460 |
| non-volatile candidate | `.md` alternate `092fd0ba581cbb60eaf756e853d8659c15b76e17dd616c23aff8137ef42c6d0f` / 5,245. Same value recorded on 2026-10-20 by `Source07.md:148`, `ReopenSource02.md:66` and `ReopenSource17.md:41`. Stability is shown only for 10-20 → 10-21. |
| quote / location | The H1 (14 words) / page title H1. Located in `rendered-text-v1` on all three dates and at `.md` line 5. |
| normalized_sha256 (`rendered-text-v1`) | `2a39cb1691b24f492dd4ad5a126538df35f865c15cd5f46a35e405a5282781c7`, reproduced independently. Reproduction depends on: a final trim (collapsing without trimming gives `7f9e0c93…`); Python `re` Unicode `\s`; case-insensitive `script`/`style` removal. Six U+200B characters remain in the text. |
| proposed stable identity | Rendered text of the `id="content-area"` subtree: `3e15d76578e0c09290272c158b824b0609c0e6a033f324ff324f34dc6b93594e`, identical on 10-06, 10-12 and 10-21 |
| row identity | `916f8afe…423f` = sha256 of `S017<TAB>mined<TAB><url><LF>` (verified) |

**In-flight row check** (`source-fetches.tsv:37`, snapshot `ccc9ae6e…`): url, final_url, status, sha256, bytes, quote, location, normalized digest and identity digest all match my observations. The only disagreement is the meaning assigned to the normalized digest (C-1).

## 7. Contradictions

### C-1 — in-flight C2: the normalized digest is not a stable identity for S017 (sent to `agent://KagiR23`)

**Claim being contradicted:**
- `source-fetches.tsv:17–21` says the normalized digest is “the stable declared identity”.
- `sources-census.sh:282` says chrome changes “the bytes, not the article”.
- `sources-census.sh:290–295` enforce same-URL normalized agreement.

**Evidence:** §4(c). The whole-page normalized digest changed between 10-12 and 10-21 because of sidebar edits, while the article (content-area digest and `dateModified`) stayed constant.

**State after my message, at 03:58Z:**
- `round-23.md:52–54` now concedes the point: “page chrome can move the normalized digest between days… so no cross-capture equality is enforced.”
- `round-23.md:61` still claims SC_FETCH enforces “same-URL agreement”.
- The census still enforces that agreement at lines 290–295.
- The TSV header still says “stable declared identity”.

The in-flight tree contradicts itself on this point.

**Risk:**
- A later recapture, or a second registry row on the same 1password.dev URL, made after a site navigation edit will produce `same-url-normalized-disagreement` or read as content drift. That is a false failure on unchanged vendor text.
- The normalized text also carries status words from the navigation (sidebar beta labels, and `.md` Related topics line 98 “(public beta)”). Status must therefore keep coming from the H1 anchor.

**Fix options:**
1. Declare a scoped normalization such as `rendered-content-area-v1` (`rendered-text-v1` applied to the `id="content-area"` subtree; S017 = `3e15d765…`).
2. Or record the `.md` alternate as `decoded-http-body-v1`.
3. Or drop same-URL normalized agreement across fetch dates.

In every case, make the TSV header, the census comment and rule, and the lesson state the same rule.

### C-2 — committed production (base `d218603b`): catalog quote and digest come from different representations

- **The mismatch:**
  - The `S017-runtime` quote at `feature-claims.json:108` uses an ASCII apostrophe (U+0027).
  - The page renders U+2019 in its raw HTML, and therefore also in `rendered-text-v1` (`html.unescape` does not fold typographic quotes). This holds in the 10-06, 10-12 and 10-21 captures.
  - The ASCII form appears only in the `.md` alternate (line 11).
  - The record's sha256 (`:102`) is the raw-HTML digest (`ReopenSource17.md:40`). The quote therefore cannot be found in the bytes that the digest identifies.
- **Scope:**
  - `ReopenSource17.md:58–59` (“verbatim substrings of the live page”) is true only for the `.md` alternate.
  - `S017-title` and `S017-business` contain no apostrophe and are found in both representations.
- **Impact today:** none, because `feature-claims.py` never fetches (`feature-claims.json:11`).
- **Risk:** any C1/C2 extension that locates catalog quotes under `rendered-text-v1` will fail `S017-runtime`, which is the required `fact` evidence (`:273`).
- **Fix options:**
  - Declare `.md` as the catalog quote representation.
  - Or add a declared typographic-quote folding step.
  - Or re-quote with U+2019 through a QM14 migration that re-pins `PINNED_SOURCES_SHA256`.

  Do not edit silently.

## 8. Synthetic minimal failing fixtures (proposals; no gate was executed)

**FX-1 (C-1).** Document A:

```
<html><body><nav><a href="/p">Plugins</a></nav><div id="content-area"><h1>Feature X (public preview)</h1><p>If an administrator has connected your organization, you can use it.</p></div></body></html>\n
```

Document B is A with `<a href="/c">Cursor (beta)</a>` appended inside `<nav>`.

My own computation gives:
- `rendered-text-v1`: A `1f8c4e25740fe1de052028d577f756460b6bb45f49cd67cb15825a266822cd83`, B `b224e3d692b50f3e51ecdf3d335aceae091f94c2867fbf2ce4b9acf8e6b64647` (they differ).
- content-area scope: A = B = `acd7ad21baf62834fa4e8617a9690b0fa432c4c6ead6e452acfc1b4590cb3d44`.

Census case: two registry rows share `https://example.invalid/page`, both `decoded-http-body-volatile-v1` + `rendered-text-v1`, with those two normalized digests and different `fetched` dates. Current code reports `same-url-normalized-disagreement`, which refutes the “stable identity” claim on a navigation-only change.

After a fix, the scoped digests should agree and the case should be CLEAN. Changing the H1 from “(public preview)” to “(public beta)” inside `content-area` must still produce a disagreement.

**FX-2 (C-2).** Document C is A with its paragraph changed to `you can use it in your organization’s workflows.` (U+2019). The ASCII quote `organization's workflows` is not found in `rendered-text-v1`(C), while the U+2019 form is. A quote locator must fail this case unless a folding rule is declared.

**FX-3 (identity scope).** In a fixture copy, flip the teaches cell of an S017-like row from “public preview” to “public beta” and leave id, status and url unchanged. The identity digest (`sources-census.sh:256–257`) is unchanged, so SC_FETCH reports nothing. Only the whole-file stamp (`stamps.tsv:61`) catches the change, and stamps are re-pinned at integration. Either bind the anchor and teaches cells as well, or document this bound.

## 9. Lower-severity notes

- **One quote per id.** The S017 provenance row attests only the status clause. The Business-prerequisite clause has no located quote in C2, and `duplicate-provenance` (`sources-census.sh:296`) forbids adding a second row. “missing=0” therefore means one clause per row, not full `teaches` coverage. Either allow (id, clause) rows or state this bound.
- **`rendered-text-v1` is under-specified** (see the reproduction notes in §6). Publish a normative snippet.
- **The S017 anchor says “unversioned”** even though the page exposes `dateModified`. That field is usable as a content clock for on-release rechecks; it is not a version.
- **Actions `runtime_constraints` is empty** (`feature-claims.json:262,272`). The catalog already declares this bound (`:18`), so no action is needed.

## 10. Limits, residual risk and checks for L1

- **Scope:** one row only. Public GETs only; no gate, selftest, census or feature-claims command was executed. In-flight files were read, never written.
- **Unresolved:** the 2026-10-20 raw bytes are not available to me, so I cannot say whether the 10-20 whole-page normalized digest equals `2a39cb16…`.
- **Same build, different bytes (observed, not inferred).** `Source07.md:33,41` records the Actions page on 10-20 as `937f6828…` with buildId `6ad68a29…` on all three Broker pages. On 10-21 the page shows the same buildId and the same `dateModified` but different bytes (`62953bb4…`, +305 B), while the `.md` alternate is unchanged. So raw HTML moves within one build, not only across builds. Which part changed between 10-20 and 10-21 is unresolved.
- **Wayback:** these are third-party archived responses. I verified them against the CDX SHA-1 digests, not against the 1Password origin at capture time.
- **Installations:** none. curl and python3 were already present, so RULES.md did not need to be consulted.
- **L1 to run after integration:**
  - `bash corpus/sources-census.sh` and `--selftest`, with FX-1 added.
  - Recompute the S017 content-area digest with the published normalization; expect `3e15d765…` if the article is unchanged.
  - `python3 corpus/feature-claims.py --selftest` and `--phase after`; expectations are unchanged unless the C-2 fix re-pins.
