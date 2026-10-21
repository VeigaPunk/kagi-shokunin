# SourceS015: S015 source-bound provenance audit (round 23, parent build)

Axes: **calibration**, **freshness**, **operability**. Read-only and advisory. This report does not admit anything.
Leaf seat, no dispatch. Scope is the one row S015. I touch no other source row except to show supersession and same-chain context.

## 0. Observed revisions

- Frozen base: `HEAD` = `d218603b74099ddca0bd8f869516fc41db0979bf`. This is the `Base:` line in `plans/round-23.md`.
- `corpus/SOURCES.md`:
  - At my first read it had sha256 `a5e1c13e95bafbdd7cbfdf2352fda7a6ba76b620fc2873f93031700f5f99cc30` and 23 rows.
  - Later the in-flight working tree had `06dde644801bee13736fca21d9ecadec83086ea1f5de77043394a62d2d525b29` and 26 rows. L1 added S024–S026.
- **S015 row at `corpus/SOURCES.md:21` is byte-identical in both.**
  - Line+LF sha256 is `9a75576ebd0d6a8ac393dd92ac26f45f4fa5c188a8c2852e1eb64f71e6d86643`.
  - Without the LF it is `2577ade761ad505e0df8fd9bfafa3acb28bc3f0797dd56f4c551d6d5eb106c67`. That equals `.ufo/waves/round-22/registry-census-details.json:81` (`immutable_original_full_line_sha256.S015`).
- In-flight L1 files are uncommitted and changed *while this audit ran*. I cite them only at these hashes:

  | file | sha256 |
  |---|---|
  | `plans/round-23.md` | `cb1287ba303a26942b94094be26751b8d86cc967deb49dfcddb25afee6b007ac` |
  | `corpus/source-fetches.tsv` | `ccc9ae6ec1b4bfa2ea8d879762a8fca18a84673145b54a04f39530de2d65a0af` |
  | `corpus/sources-census.sh` | `24d834cc85344b762b485ef2b1c44cdbddab4e641f96acbaf2853823b02af057` |
  | `corpus/lessons/round-23.md` | `2f53cf690d81666a4b2510e6b611bd55cdf61a260020c28c6480d788183dcf53` |
- Used-by entry E3 is `corpus/knowledge/vault-openbao-token-lease-lifecycle.md`: sha256 `4932f37f6e4bc0cf312f9d844b1ab215cb66248846664715515e0fa8d7b17298`, 176 lines. I saw no round-23 edit to it.

Row fields under audit:

| field | value |
|---|---|
| source | Kubernetes JWT provider, `https://openbao.org/docs/auth/jwt/oidc-providers/kubernetes/` |
| kind / tier / status | `docs` / `A` / `mined` |
| scope | OpenBao Kubernetes JWT signature verification versus TokenReview revocation behavior |
| anchor | §Kubernetes, TokenReview note; OpenBao 2.7.x |
| teaches | OpenBao JWT verification does not consult Kubernetes TokenReview, so Kubernetes revocation is not immediate through this path |
| in-row quote | 12 words, given in §3 |
| in-row `Fetch sha256:` | `a0a2b227a7a91b7af0033a9fc665d319776d2d03aa09341620f9abee2f195fd4` |
| opened / recheck | `2026-10-19` / `on-release` |
| used-by | E3 |

## 1. Opens and failures (2026-10-21, all public, read-only)

| # | what | result |
|---|---|---|
| O1 | `read` (native) of the row URL | **OK**. Canonical link equals the URL. `meta docusaurus_version 2.7.x`, displayed "Version: Version 2.7.x". H1 `kubernetes`; H2 `Kubernetes` `id=kubernetes`; first `info` admonition sits under that H2. No page date is displayed. |
| O2 | `curl` identity GET, `Date: Wed, 21 Oct 2026 03:42:45 GMT` | **200**. `last-modified: Tue, 20 Oct 2026 07:50:18 GMT`, `etag: "6ad71d3a-da10"`, `cache-control: max-age=600`, `age: 12`. Body 55,824 B, sha256 `4e3fdb7d2628f11584690f7eb856186283c688bad09ec8a77e509ab133edbf2f`. |
| O3 | cache-busted GET (`?cb=…`, `Cache-Control: no-cache`) | **200**. Body byte-identical to O2 (`age: 38`). |
| O4 | `curl --compressed` | **200**. `content-encoding: gzip`, weak `etag: W/"6ad71d3a-da10"`. Wire 10,227 B, sha `0348dfcf456f5f20330d83038c709de754770d769240e0000122411030f85e0c`. Decoded body identical to O2. |
| O5 | `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)'`, which matches profile `curl-fsSL-compressed-v1`; I built the request myself, not from ledger text | **200**. Final URL equals the registered URL (no redirect). Decoded sha `4e3fdb7d…`, 55,824 B. Calibration GET of the same-site S025 URL reproduced its `source-fetches.tsv` digest `449ef132…` (63,046 B). |
| O6 | version routes | `/docs/2.7.x/auth/jwt/oidc-providers/kubernetes/` → **404** (no version-pinned route while 2.7.x is current). `/docs/2.6.x/…` → 200 (2.6.x; TokenReview ×2). `/docs/next/…` → 200 (`current`/Development; quote located). |
| O7 | content artifact: raw `website/content/docs/auth/jwt/oidc-providers/kubernetes.mdx` at `main`, `release/2.7.x` and tag `v2.7.1` | **200 ×3**. Identical sha `ca1129c20ff8dbb7bf3ff93917a976d8f48f828c0f5ee12dd75aed27728b73e1`, 8,874 B. The served page's "Edit" link targets `blob/release/2.7.x/…/kubernetes.mdx`; the `/docs/next/` page targets `blob/main/…`. |
| O8 | GitHub API (unauthenticated) | Releases: latest `v2.7.1` 2026-10-01T14:03:19Z, not prerelease. Tags: none newer than `v2.7.1`; the tag commit is `a5db72cef75c24b920ade02065b18dd8eb666bac`. Path history: last MDX change `1b7f4b0f605e` 2026-09-02T18:44:26Z. "Deploy docs" workflow runs: 2026-10-14T11:41Z (`2baf1410d835`), then 2026-10-20T07:47Z→07:50:41Z (`edf79a4e3183`). Site headers show `server: GitHub.com` (Pages); there is no `gh-pages` branch (404). |
| O9 | shipped source at tag `v2.7.1`, static read only (never built or run) | First Contents-API guess `builtin/credential/jwt` → **404** (wrong path). The real path `internal/builtin/credential/` worked. `jwt`: 34 `.go` files, **0** `TokenReview`. `kubernetes`: 15 files, TokenReview in 7. `jwt/provider_kubernetes.go` (182 lines, sha `a394e281…`) fetches only OIDC discovery + JWKS, using the pod service-account bearer token. `hashicorp/cap` `v0.14.0` `jwt/jwt.go` (sha `3cc61ce7…`) was read too. |
| O10 | Wayback CDX, 2026-10-01..2026-10-21 | **OK, `[]`**: no archived capture. |

## 2. Scoped recheck: teaches / scope / anchor / tier / status

| item | observation | verdict |
|---|---|---|
| teaches clause 1: no TokenReview | Q1 (below) is present verbatim in words. Shipped `v2.7.1` JWT backend has 0 `TokenReview` tokens. | **SUPPORTED** (doc). Static source corroborates it. |
| teaches clause 2: "revocation is not immediate through this path" | Q2: Kubernetes-revoked tokens stay valid "until their expiry time". Static code: `cap` `jwt.go:319` rejects exp only when `now − clock_skew_leeway > exp`. `expiration_leeway` is used only when `exp` is absent (`:273-285`). OpenBao's role default is 60 s (Q3). | **SUPPORTED, under-calibrated.** "Not immediate" allows a *delayed-propagation* reading that the page does not support. The page says revocation is **never observed** on this path, and acceptance ends at the JWT's own `exp`. Code adds clock-skew leeway, default 60 s [INFERENCE, static read, not measured]. This is not a refutation. Round-22's two readings disagree (`build/Source15.md` C5 vs `falsify/ReopenSource15.md:45-46`); this sides with C5. |
| scope | The page names the JWT/OIDC auth path with Kubernetes as the OIDC provider. | **SUPPORTED**, bounded to this provider path. Not other IdPs, not Vault. |
| anchor `§Kubernetes, TokenReview note; OpenBao 2.7.x` | `h2#kubernetes`; the note is the first `info` admonition before `h3#using-service-account-issuer-discovery`; served version 2.7.x. | **SUPPORTED**, but the route moves (see §4c). |
| kind/tier `docs`/`A` | Official project docs (`meta-author: OpenBao a Series of LF Projects, LLC`). | **Consistent.** |
| status `mined`, used-by E3 | E3 `source:` (line 3) carries S015, so it is cited back. | **Consistent.** It stays `mined`; this report does not change status. |
| supersession | No `supersedes S015` exists at the base or in the in-flight registry. S025/S026 supersede S014/S016 only. | **No superseding row.** S015 is the active row for this teaching. |
| freshness `on-release` | No release or tag after `v2.7.1` (2026-10-01), which is before `opened 2026-10-19`. The MDX blob has not changed since 2026-09-02, and `main` = `release/2.7.x` = `v2.7.1`. | **Not triggered.** The content is current as of 2026-10-21. |

Public quotes (each ≤25 words):

- **Q1** (12 words): "The JWT auth engine does not use Kubernetes' TokenReview API during authentication".
  - Where: §Kubernetes (info Note), https://openbao.org/docs/auth/jwt/oidc-providers/kubernetes/, docs Version 2.7.x, no page date, opened 2026-10-21.
- **Q2** (18 words): "tokens that have been revoked by Kubernetes will still be considered valid by OpenBao until their expiry time".
  - Where: same heading, URL and date as Q1.
- **Q3** (16 words): "Defaults to 60 (1 minute) if set to 0 and can be disabled if set to -1."
  - Where: `clock_skew_leeway` field description, `internal/builtin/credential/jwt/path_role.go:127-131`, openbao/openbao tag `v2.7.1` (published 2026-10-01), https://github.com/openbao/openbao/blob/v2.7.1/internal/builtin/credential/jwt/path_role.go

## 3. Four evidence classes, kept separate

**a. Historical bytes.**
- `a0a2b227…` (2026-10-19) has no declared representation.
- I tested **520** candidate representations of today's bytes and none matched:
  - raw bytes;
  - gzip with mtime 0;
  - three tag-strip variants;
  - raw MDX, MDX with CRLF, and MDX without its final newline;
  - a 512-way text-normalization matrix: tag→`''`/`' '`, script/style removal, unescape order, whitespace collapse, strip, lowercase, trailing LF, and two script regexes.
- This adds to round-22's tested set (`falsify/ReopenSource15.md:56-61`).
- The open date, 2026-10-19, falls between deploys 2026-10-14 and 2026-10-20. So it most plausibly saw the 2026-10-14 build [INFERENCE: this assumes `docs-deploy.yml` is the only deploy path; `stable-website.yaml` was not inspected].
- That build is no longer served. Pages artifacts are not a public branch, and no archive exists.
- **Verdict: unreplayable historical point observation. It is not drift evidence.**

**b. Current semantic support.**
- Q1 and Q2 are located under the anchor.
- The version label is 2.7.x.
- The content blob `ca1129c2…` predates the open.
- The `/docs/next/` and `/docs/2.6.x/` routes carry the same note.
- **Supported as of 2026-10-21.**

**c. Transport / raw-HTML volatility.**
- The raw identity body `4e3fdb7d…` was stable across 4 GETs today and equals round-22's 2026-10-20 capture. So it is stable within a build.
- It is still deploy-coupled:
  - It embeds `/assets/js/main.aa34622e.js` and `/assets/css/styles.f040e9fc.css`.
  - `Last-Modified` equals the deploy time.
  - The ETag is `hex(epoch 0x6ad71d3a = 2026-10-20T07:50:18Z)-hex(length 0xda10 = 55,824)`. It is not a content hash, and it turns weak under gzip.
- Wire gzip bytes (`0348dfcf…`, 10,227 B) depend on `Accept-Encoding`. They must never be used as a pin.
- The unversioned `/docs/…` route is a **moving route**. It will serve the next major docs line after a release (the 2.7.x-pinned route is 404 today). The census moving-ref heuristic (`raw.githubusercontent.com` or `/main/`) does not see this.

**d. Deployed-product proof.**
- **None.** No OpenBao binary, cluster, vault or account was run or contacted.
- The `v2.7.1` source read in O9 is *static corroboration*, not runtime proof.
- E3's own scope line, "vendor documentation only; nothing was deployed or probed", stays accurate.

## 4. Used-by follow (local, one hop): E3

| E3 line | content | status vs S015 |
|---|---|---|
| 3 `source:` | cites S015 "§Kubernetes note, Version 2.7.x" | consistent |
| 4 `verified-at` | "fetched and read as tag-stripped text". This is the only reading representation E3 declares. | consistent; not a digest declaration |
| 5 `recheck:` | names "S015 TokenReview note" | consistent; not triggered |
| 17 | four-clocks row "(IdP, Kubernetes) … its own expiry" | historical defective reading. Bounded by errata 105-107 and 113-118. Code also adds clock-skew leeway (§2). |
| 42-47 | restates Q1/Q2 + mitigations | supported |
| 58-60 | `[INFERENCE]` "an operator must revoke it" | withdrawn as universal by 128-133 |
| 98-101 falsifier | "OpenBao 2.x page saying JWT auth consults TokenReview" | not triggered (2.6.x, 2.7.x and next all keep the note) |

E3 cites no superseding row for S015, and none exists. The E3 quote at line 44 has no backticks and is therefore located under rendered text.

## 5. Planned C2: exact S015 provenance expectations

Measured 2026-10-21 against the in-flight 16-column contract (`source-fetches.tsv` header, sha `ccc9ae6e…`). Advisory values, not a committed row:

| column | expected value |
|---|---|
| id / status | `S015` / `mined` |
| row_identity_sha256 | `3ec08212407774db9fe1a08ba8fe64b49395a34183570fda413d68f68defb131`, i.e. sha256 of `S015⇥mined⇥<url>⏎` |
| url / final_url | `https://openbao.org/docs/auth/jwt/oidc-providers/kubernetes/` / same (no redirect) |
| http_status / request_profile / fetched | `200` / `curl-fsSL-compressed-v1` / `2026-10-21` |
| representation | `decoded-http-body-volatile-v1`. It is deploy-coupled, not per-response, and matches same-site S021/S025/S026. |
| sha256 / bytes / revision | `4e3fdb7d2628f11584690f7eb856186283c688bad09ec8a77e509ab133edbf2f` / `55824` / `-` (see recommendation 3) |
| quote | `The JWT auth engine does not use Kubernetes' TokenReview API during authentication` (12 words; the row's quote without the Markdown backticks) |
| normalization / normalized_sha256 | `rendered-text-v1`. The digest depends on the whitespace class: ASCII `[\t\n\f\r ]+` gives **`cb4324cd7bb718b51451d40b0e63c289efc4bcdf851347e1d5076e34c633be30`**; Unicode `\s+` gives **`2732189767e6663d9994b7d7f5d20cab6c4d5b28ede6f73c5f2cfb4707a2aab8`**. Both are 8,709 chars. |
| location | `Kubernetes (h2#kubernetes), info Note` |

Content identity:
- The blob is `ca1129c2…`, 8,874 B, at `openbao/openbao@a5db72cef75c24b920ade02065b18dd8eb666bac` (`v2.7.1`).
- On 2026-10-21 it equals `release/2.7.x`, the served "Edit" target.

Exact anchor:
- Use the fragment id `kubernetes`, the H2. Do not use heading text.
- Normalized text carries 7 U+200B characters from hash-links, e.g. `Kubernetes \u200b Kubernetes can function`.
- A heading-text literal check would therefore need ZWSP handling.

Quote locatability:
- The in-row quote as literally recorded, with backticks, is **not** a substring of any of these: raw HTML, whitespace-collapsed HTML, tag-stripped text, raw MDX or collapsed MDX.
- It is located only after a declared normalization:
  - remove the backticks and use rendered text; or
  - remove `**` from the MDX and collapse whitespace.
- The words are exact. Only the emphasis on "not" is dropped and the code span changes form.

Normalization ambiguity (S015 witness):
- The page contains exactly one U+00A0 NO-BREAK SPACE.
- It comes from the upstream content itself: MDX line 214, a YAML comment ("ensure only␣a single token"). It is served raw, not as an entity.
- S025's page has none. So both whitespace classes reproduce S025's recorded `ca496ad8…`, and calibration on existing rows cannot detect the split.
- `rendered-text-v1` is defined only in prose: "collapse whitespace" in `source-fetches.tsv:25-27`, `sources-census.sh` header and the lesson's quotation rule. No committed normalizer exists in `corpus/`.

## 6. The one real contradiction (C2), sent to agent://KagiR23

**Lesson M23-1 names the defect class, but the census still lets it through for S015.**

1. M23-1 (`corpus/lessons/round-23.md:142` at `2f53cf69…`) names the class "a digest with no declared representation was treated as provenance". Its stated fix bounds legacy pins as historical.
2. S015 is still an **active** row: `mined`, not superseded, and consumed by E3 (lines 3, 42-47, 107).
3. The census still drops `missing-provenance` for S015 only because a 64-hex in-row digest exists (`corpus/sources-census.sh:294-300` at `24d834cc…`, where `continue` precedes the `missing-provenance` check).
4. That digest reproduces under 0 of 520 tested representations (§3a). The census header itself calls it "undocumented representation -- required for coverage".
5. So for S015 the class is renamed "coverage", not fixed.
6. D7 (`:106`) and M23-1's evidence pointer list S008/S012/S013/S014/S016 and omit S015.
7. Every other URL in E3's chain has declared provenance in `source-fetches.tsv`: S022 (S012 URL), S023 (S013), S025 (S014), S021/S026 (S016). S015's URL has none; `oidc-providers` appears 0 times in the file.
8. `source-fetches.tsv:2` ("bind every mined row's quote and digest to a declared representation") is therefore false for S015. Line 1 and plan lines 22-32 correctly scope this to rows without an in-row pin.

Counterexample: S015 itself. It is active evidence whose only fetch provenance is a historical, unreplayable, undeclared digest, and the census verdict cannot tell it apart from declared provenance.

Fix options (L1's call; minimal first):
1. Add one `source-fetches.tsv` row for S015 with §5 values, after choosing the whitespace class. No registry-row rewrite is needed, because the census validates provenance rows for in-row-pinned ids too. Then widen header line 1 wording, or fix line 2.
2. Pin the whitespace class in the `rendered-text-v1` prose, e.g. ASCII `[\t\n\f\r ]+`, which matches the recipe in `SourceS014.md:146-147`. Better still, commit the normalizer with a NBSP test vector.
3. Make legacy-only coverage machine-visible: a verdict counter `legacy_only=N` or a per-id line, so `0 rows without either` is never read as "declared provenance".
4. Record the docs-route version (`2.7.x`) or the content blob/commit with the capture, because the unversioned route moves at release.

## 7. Synthetic minimal failing fixture (proposal for L1, not executed)

**F1, legacy-only active row:**
- `corpus/SOURCES.md`: the four required headings, plus one row `| S001 | Fx — https://example.invalid/doc | docs | A | fx scope | §Fx | Fx teaching. Quote: “fx words” (§Fx). Fetch sha256: \`<any 64-hex>\`. | mined | 2026-10-21 | on-release | corpus/knowledge/fx.md |`
- `corpus/knowledge/fx.md`: `source: S001 (https://example.invalid/doc, §Fx)`, `verified-at: 2026-10-21`, `recheck: on-release`.
- `corpus/source-fetches.tsv`: comments only.
- Today: a static reading of `sources-census.sh:294-300` shows no `SC_FETCH` line. The fixture is classed clean although it has no declared representation.
- Desired: a distinct, machine-visible classification, e.g. `FINDING SC_FETCH id=S001 legacy-pin-only` (fail-closed), or verdict `legacy_only=1` (bounded).
- Control: add one complete 16-column row for S001, and the classification clears.

**F2, whitespace-class pin:** this targets whatever tool computes `normalized_sha256`, since the census never recomputes it.
- Input: the HTML body `<p>a&nbsp;b\u00a0c</p>`.
- The chosen class's digest must be the only one accepted.
- Mutant: the other class's digest must fail.

## 8. Falsifiers

- **Teaching:**
  - Falsified by an OpenBao page for this provider saying JWT auth consults TokenReview, or that Kubernetes-revoked service-account tokens are rejected before expiry.
  - Withdrawn, not falsified, if the note disappears.
  - The code-leeway refinement is falsified by a `cap`/OpenBao revision whose exp check ignores clock-skew leeway.
- **Pin verdict:** falsified by any retained 2026-10-19 artifact that reproduces `a0a2b227…` under a declared method.
- **NBSP finding:** falsified by an MDX or build revision that removes the U+00A0, after which both classes agree.

## 9. Limits and conduct

- Documentation and static source only. No gate, census, selftest, handler, `op` or vault command was run. Census statements are static readings at the stated hash. Line numbers in the in-flight files may move.
- Git: I ran `rev-parse`, `log` and `status --porcelain` ×2. `git status` may opportunistically refresh the index stat cache. Disclosed; I ran no further git.
- Scratch:
  - All scratch files were in `/tmp`. I removed all 23 after verifying their content.
  - Before creating them, I ran `rm -rf /tmp/obao /tmp/obao_jwt` without checking for pre-existing content. Disclosed.
- GitHub API was unauthenticated, with 9 core calls left at the end. Pages deploy artifacts were not downloaded (they need auth).
- No installs or updates. I used the existing `curl`, `python3` stdlib and coreutils. No package transactions.
- I did not audit other rows. S025 was fetched only to calibrate the normalizer, and S014/S016/S021–S023 appear only as same-chain provenance context.

Checks for L1 after integration (not run here): `bash corpus/sources-census.sh`; `bash corpus/sources-census.sh --selftest`; `grep -c 'oidc-providers' corpus/source-fetches.tsv` (expect 1 if fix 1 is taken).

Report: .ufo/waves/round-23/parent-build/SourceS015.md
