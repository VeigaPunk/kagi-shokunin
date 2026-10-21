# SrcGithubAtom — C2 source curation: GitHub `releases.atom` entry window/order

**Seat:** KagiR26.SrcGithubAtom-17 (leaf; no subagents dispatched)
**Frozen BASE:** `0a47dd189356ea66ec83c3891eed54526e95b89b` (confirmed `HEAD` at observation; all lane citations below are from BASE blobs, not the live working tree)
**Access window:** 2026-10-21T15:04Z–15:26Z UTC (per-fetch timestamps in §1)
**Verdict:** **No authoritative GitHub Docs or GitHub-maintainer statement about the repository `releases.atom` feed's entry window, ordering, pagination, or completeness was found.** The nearest official statements are about *different* feeds (events/timeline Atom retention) or about the *REST* latest-release endpoint. Recommendation: **REJECT** the SOURCES row for this claim, with the flip in §5. No registry file was written.

This independently confirms the round-27 Gate rejection quoted in the working-tree lesson — “A release-ordering spec proves a vendor's feed is complete or monotonic” → REJECT, flip “a vendor statement of feed completeness, scoped to that feed” — and shows the flip is **still unmet** for GitHub.

---

## 1. Sources opened (URL, access, HTTP, located text)

| # | URL | Access (UTC) | HTTP | What it is / located text |
|---|---|---|---|---|
| 1 | `https://github.com/github/docs` at commit `cca0c9d7299f760587d6601bd96acfd2f5cb8929` (committer date 2026-10-21T14:35:37Z), tarball `https://codeload.github.com/github/docs/tar.gz/cca0c9d7299f760587d6601bd96acfd2f5cb8929` | 15:14Z | 200 | Whole docs source snapshot: 154,188,419 bytes, sha256 `3dec983daca52e05466988f90b96277dc3a53915736b80622020de76737ed732`; 14,885 tree entries, `truncated: false` |
| 2 | `https://docs.github.com/en/rest/activity/feeds` | 15:05Z | 200 | Documents only `GET /feeds` (timeline / user / org / security-advisory feeds). No repository releases feed, no entry window/order statement |
| 3 | `https://docs.github.com/en/rest/releases/releases.md` | 15:22Z | 200 | 20,934 bytes, sha256 `731dc3d1ac3156629e8ef60e23c5c59cc92bfd96925cfe0b66c6bd8870965fed`. The only definitional “latest” sentence found (§Get the latest release) |
| 4 | `https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository` | 15:06Z | 200 | Release create/edit/**delete** operations; no feed semantics |
| 5 | `https://docs.github.com/en/repositories/releasing-projects-on-github/viewing-your-repositorys-releases-and-tags` | 15:06Z | 200 | Web UI viewing only; no Atom mention |
| 6 | `https://docs.github.com/en/code-security/concepts/supply-chain-security/immutable-releases` | 15:23Z | 200 | Tag/deletion semantics for immutable releases (yank context, §3) |
| 7 | `https://github.blog/changelog/2024-11-08-upcoming-changes-to-data-retention-for-events-api-atom-feed-timeline-and-dashboard-feed-features` | 15:19Z | 200 | Official GitHub statement about an **Atom feed** window — but events/timeline, not repository releases (§4) |
| 8 | `https://github.com/orgs/community/discussions/42198`, `/128589`, `/60433`, `/35990`, `/157306` | 15:07–15:26Z | 200 | Community threads on Atom feeds; no substantive maintainer statement on window/order (§4) |
| 9 | `https://docs.github.com/en/search?query=releases.atom` (and `tags.atom`, `commits.atom`, `max_versions`, `op run`) | 15:12Z | 200 | Search corroboration only: 0 results for all three feed names; **but** also 0 for `max_versions`, which the KV page demonstrably contains, so search recall for code-like strings is unreliable and is not used as the primary absence proof |
| 10 | `https://api.github.com/repos/{getsops/sops,hashicorp/vault,openbao/openbao}/releases?per_page=100` | 15:20Z | 200 | Release-history counts used to prove the Atom feed is a cropped window (§3) |

### 1.1 The docs snapshot contains no `releases.atom` page or mention

Exact operations on the pinned snapshot (all read-only):

```
tar -xzOf docs.tar.gz | grep -a -c 'releases\.atom'   → 0     # every file in the snapshot
grep -rniE '\.atom\b' docs-src --include='*.md' -l     → (no files)  # content/ + data/reusables/ only
grep -rniE '\batom\b' docs-src/docs-<sha>/content      → 1 hit
```

The single `Atom` hit is a front-matter redirect alias for a long-deleted GitHub Pages article, not documentation of any feed:

`content/pages/setting-up-a-github-pages-site-with-jekyll/about-github-pages-and-jekyll.md:13` (docs commit `cca0c9d7`): `- /articles/atom-rss-feeds-for-github-pages`.

The only repository-release “feed” wording in the docs corpus is a **false friend** that means the web Releases page:

`data/reusables/releases/finish-release.md:10` (docs commit `cca0c9d7`): “You can then view your published or draft releases in the releases feed for your repository.” — its link target is `viewing-your-repositorys-releases-and-tags`, not an Atom URL.

**Conclusion of the absence proof:** at docs commit `cca0c9d7` (2026-10-21), GitHub Docs has no page, anchor, snippet, or sentence describing `releases.atom`, a repository release feed window, feed ordering, pagination, or completeness. Search-page results agree but are not load-bearing because of the recall weakness shown in row 9.

---

## 2. What the opened sources do and do NOT support

Target rule: *“an observed newest-stable release numerically below the anchored X.Y.Z is a regression finding, not a release event.”*

The limit this rule closes is stated at BASE in `corpus/lessons/round-26.md:230-233`: “the evaluator defines fired as observed-version unequal to anchor, not strictly newer. A stale/cropped feed could regress and un-fire an older anchor; no monotonic-history guarantee is made.” The rule's numeric typing is what the source hunt is meant to ground; the question here is whether GitHub supplies the feed-side premise (window/order/completeness).

| Element of the rule | Support found |
|---|---|
| Numeric precedence of strict `X.Y.Z` | **None from GitHub.** Only the round-27 rows S042 (SemVer 2.0.0 §11.2) and S043 (PyPA) carry this (working tree; not in BASE). GitHub never states a version-order rule for feeds |
| Observation means “newest **stable**” | **Only REST, not the feed.** GitHub defines “latest release” for `GET /repos/{owner}/{repo}/releases/latest` as non-prerelease, non-draft, sorted by `created_at` (commit date, not publish date). The Atom feed has no prerelease/draft field (§3), so “stable” there is the lane's title-suffix heuristic |
| The feed is a window that can crop | **Not documented.** Observed 10 entries on 8 repositories; official Atom-window statement is scoped to events/timeline (§4) |
| Observed < anchor ⇒ regression, not a release | **Not documented.** No GitHub statement of feed monotonicity or completeness exists in the checked sources |
| Prerelease handling | **Partial (REST only).** The feed itself carries prereleases with no marker; see §3 counterexamples |
| Backport/second-line handling | **Not documented.** GitHub says nothing about multiple maintained lines; the lane's max-over-titles is series-blind |
| Yank/deletion handling | **Not documented for feeds.** GitHub documents deleting a release and immutable-release tag locking, but not what the Atom feed does afterwards |

### 2.1 The one relevant REST sentence (scope: API, not feed)

`https://docs.github.com/en/rest/releases/releases.md:379`, §Get the latest release:

> “The latest release is the most recent non-prerelease, non-draft release, sorted by the created_at attribute.”

(15 words.) The following sentence adds that `created_at` “is the date of the commit used for the release, and not the date when the release was drafted or published.” This is authoritative for the **REST** definition of “latest”; it is **not** a statement about `releases.atom`, and it actually warns that “latest” is not “newest published” even for the API. The lane's max-version parser sidesteps that date ambiguity, but the docs sentence cannot be cited as feed behavior.

### 2.2 The only official “Atom feed window” statement is about a different feed

`https://github.blog/changelog/2024-11-08-...` (GitHub Changelog, 2024-11-08, modified 2025-04-30), §body:

> “we will be modifying the window of data retention for these features from 90 days to 30 days.”

(18 words.) The “features” are the **Events API**, the dashboard/timeline **Atom feed**, `/timeline`, and `/dashboard-feed`; the impacted-API list names the events endpoints and `/feeds`, **not** repository `releases.atom`. Citing this post for release feeds would be a scope error. It is still useful as an existence proof that GitHub *does* publish Atom-window policy when it wants to — and has not done so for releases.

### 2.3 Maintainer statements checked (none on window/order)

| Thread | What it contains | Admissible? |
|---|---|---|
| `#42198` “Pagination for `.atom` feeds” (2022-12-20) | User reports only the first page is displayed and `?page=2` fails; **only reply is the dormant GitHub Actions bot** (2024-06-08) | No substantive statement |
| `#128589` “Releases Atom feed controls/filters” (2024-06-14) | `LiteBrite82` (profile shows GitHub organization; bio “Facilitating the flow of conversations in GitHub Communities”) replies: “Not that I'm aware of.” (5 words) about filter parameters, then tags the thread `enhancement` | A GitHub-org-affiliated reply that **filters do not exist**; says nothing about window or order |
| `#60433` “RSS Feed only for stable Releases” (2023-07-09) | User feature request; community replies only, no GitHub responder | No |
| `#35990` “Exclude certain tags/releases from `releases.atom`” (2022-10-13) | User reports a tag pushed without a Release appears in `releases.atom`; a second user (2023-04-15) confirms tag-only entries appear in release feeds and calls it a bug | User-to-user observation, not authority; corroborates that tag-only entries occur in the feed |
| `#157306` “Are GitHub tags being treated like releases in the releases Atom feed?” (2025-04-21) | User pastes an actual Miniflux `releases.atom` body with 10 entries, tagged `Question`; bot reminder only | Interesting observation, **not authority** |

No GitHub Docs page, no GitHub Changelog post about release feeds (blog search API `search=releases.atom` → `[]`), and no maintainer reply states the feed's window size, sort key, or completeness.

---

## 3. Observed facts (evidence, not documentation)

### 3.1 Feed window and content, fetched 2026-10-21

| Repository | Entries | Head title | Tail entry `<updated>` | API release count / oldest |
|---|---|---|---|---|
| getsops/sops | 10 | `v3.13.3` | 2025-03-31T18:15:30Z | 38; oldest 2.0.10 (2017-08-25) |
| hashicorp/vault | 10 | `v2.2.0` | 2026-05-21T15:21:39Z | 100 (full page; older exist, e.g. v1.11.10 2023) |
| openbao/openbao | 10 | `v2.7.1` | 2026-09-09T12:02:09Z | 36; oldest v2.0.0-alpha20240329 |
| kubernetes/kubernetes | 10 | `v1.38.0-alpha.2` | — | — |
| python/cpython | 10 | `v3.15.1` | — | — |
| microsoft/vscode | 10 | `1.142.0` | — | — |
| hashicorp/terraform | 10 | `v1.17.0-rc2` | — | — |
| prometheus/prometheus | 10 | `v3.15.1` | — | — |

SOPS is the clean crop proof: the feed's oldest entry is `v3.10.1` (2025-03-31) while the repository has releases back to `2.0.10` (2017-08-25). The feed is a recent window, not a history.

Bodies of the three registered feeds are byte-identical to the BASE receipts: sops `47a224ad71435b7f5cae863bc96c01468bfed482636045fc307430983b072ff6` (253,037 bytes), vault `e41bc5793403136a07c68d7d107fe3e9d68b834f51bd4d77cad5c13a388670ba` (303,995), openbao `1f0bb338e341cfe8eb797a20bb66328513c37b677fe9ba31b21fdfe23798bc6f` (506,783). These equal `corpus/source-fetches.tsv:76-78` (BASE) body digests and sizes.

### 3.2 Ordering and timestamps

- All three registered feeds have entries in non-increasing `<updated>` order (checked pairwise).
- **No `<published>` element occurs in any entry** (`<published>` count = 0 in all three). A consumer cannot separate publish time from edit time.
- The feed-level `<updated>` is **older** than the first entry in all three: SOPS `2026-07-23T04:56:54Z` vs first entry `05:29:11Z`; Vault `2026-10-14T19:24:08Z` vs `2026-10-15T18:50:14Z`; OpenBao `2026-10-01T13:32:54Z` vs `18:32:18Z`. So feed-level `updated` is not a max-entry timestamp either.
- No `rel="next"`, no `rel="previous"`, no RFC 5005 `fh:` archive/paging links, and no `Link:` response header. `?page=2` returns the **same bytes** as page 1 for SOPS (`sha256 47a224ad…` both). No pagination is documented or advertised.
- Response headers: `content-type: application/atom+xml; charset=utf-8`, `etag: W/"47a224ad71435b7f5cae863bc96c0146"`, `cache-control: max-age=0, private, must-revalidate`. A stale body is therefore a revalidation/CDN question, not an advertised long TTL.

### 3.3 Prerelease marking in the feed

The feed entries carry title, link, `updated`, author, and `media:thumbnail`; there is **no** `prerelease` or `draft` field. GitHub's REST definition of latest excludes those states (§2.1), but the Atom feed provides no equivalent signal. Prereleases are only recognizable by the tag/title suffix convention (`v2.2.0-rc1`, `v1.38.0-alpha.2`, `v1.17.0-rc2`, `v3.16.0a1` are all present in live feeds today).

API cross-check of the three registered feeds: SOPS prerelease tags = `v3.8.0-rc.1`; Vault = 13 tags all `-rc*`; OpenBao = 7 tags all `-alpha*`/`-beta*`; **none is a bare `X.Y.Z`**. So today's S033–S035 observations are safe from the bare-version-prerelease trap — by observation, not by guarantee.

---

## 4. Counterexamples for the rule (prerelease / backport / yank / crop)

All probes are read-only. `parse_latest_version` was imported from a copy of the BASE blob (`git show 0a47dd18:corpus/release-clock.py`, BASE lines 654–699); `is_regression` was imported from the round-27 draft working tree observed at 2026-10-21T15:22:40Z, sha256 `81261ce993a686ba96bd43a64602b71a9733d1133b4cee622c837950cfaff3a9` (uncommitted; not BASE; line numbers move under integration, cite by symbol).

```
BASE parse sops 10 -> 3.13.3 ; vault 10 -> 2.2.0 ; openbao 10 -> 2.7.1
crowded window [9 × v3.0.0-rcN, v2.1.2] -> BASE parse 2.1.2
draft is_regression("2.2.0", "2.1.2") -> True          # REGRESSED with no yank
all-prerelease window [10 × v3.0.0-rcN] -> ValueError "feed has no stable X.Y.Z release entry"
backport window [v3.15.1, v3.14.9] -> BASE parse 3.15.1 ; is_regression("3.14.9", obs) -> False
is_regression("v1.21.x", "2.2.0") -> False             # non-numeric anchor keeps inequality rule
BASE feed-row scan (numeric observed < numeric anchor) -> []
```

1. **Crop/crowding false trigger (prerelease case).** A repository that publishes ten or more prereleases after the anchored stable pushes that stable out of the 10-entry window. If one older stable remains in the tail (`v2.1.2`), the lane reports `REGRESSED` even though nothing was withdrawn. If *all* ten entries are prereleases, the parser raises `feed has no stable X.Y.Z release entry` — an observation error, never CLEAN. Live near-misses exist: Kubernetes' head is `v1.38.0-alpha.2` and Terraform's is `v1.17.0-rc2`, both above older stables, so the max-over-titles parser still finds a stable today. The rule's wording (“a regression finding, not a release event”) survives this case **only if the finding is never read as “the vendor withdrew a release”**; GitHub documents no window guarantee that would let the lane tell a crop from a yank.
2. **Bare-version prerelease.** A release marked pre-release in GitHub but tagged `2.2.7` (no suffix) is indistinguishable from stable in the feed. Discussion `#157306` pastes exactly this shape for Miniflux (`Miniflux 2.2.7` and a separate `v2.2.7: Miniflux 2.2.7` tag entry). The REST `prerelease` boolean is not in the feed. [INFERENCE: the lane's title-suffix filter is an approximation, not GitHub semantics.]
3. **Backport / multi-line blindness.** CPython's feed contains `v3.15.1`, `v3.14.9`, `v3.16.0a1`, …; max is `3.15.1`. An anchor on the 3.14 line (`3.14.9`) can never regress while 3.15.1 stays in the window, even if 3.14 itself regressed. Numeric max is series-blind by construction; GitHub says nothing about maintained lines.
4. **Yank.** GitHub docs support deleting a release (§Deleting a release), and for immutable releases: “If you delete the immutable release, you can delete the tag, but you cannot reuse the same tag name.” (20 words, immutable-releases doc). The feed demonstrably includes tag-only/module entries (Vault `sdk/v0.26.0`; OpenBao `api/v2.7.1: …`; user-reported for `releases.atom` in `#35990`), so a deleted *release* may leave a tag entry and the observed max can stay unchanged; a deleted *tag* can drop the observed max below the anchor. Neither direction is documented, and no mutation was attempted to test it.
5. **Stale/cropped inference direction.** A lower observation cannot distinguish (a) feed window crowding, (b) tag deletion/yank, (c) a stale CDN body, (d) an anchor that was ahead of the vendor (the S029 `8.23.1`-DEV case, already normalized by S037 to `8.23.0`). `REGRESSED` is a typed stop for re-verification; it is not an attribution.

**Existing rows:** a scan of BASE `corpus/release-clocks.tsv` found **zero** feed rows whose numeric observation is below its numeric anchor. S029 is `8.23.0 / 8.23.0` at BASE line 26 (the derived note explains the unreleased `8.23.1` dev label). So the new rule does not retroactively REGRESS any BASE row; the working-tree table was not re-scanned after my observation time.

---

## 5. Proposed SOURCES.md row (rejected) and flip

Registry shape follows BASE `corpus/SOURCES.md` columns (`id | source | kind | tier | scope | anchor | teaches | status | opened | recheck | used-by`). BASE ends at S041 (158 lines; `grep -c S042` = 0); id is TBD by L1.

```markdown
| S0xx | GitHub Docs / maintainers on the repository releases Atom feed — https://github.com/github/docs/tree/cca0c9d7299f760587d6601bd96acfd2f5cb8929 | docs | A | Whether GitHub documents `releases.atom` entry window, ordering, pagination or completeness | github/docs commit `cca0c9d7299f760587d6601bd96acfd2f5cb8929` (2026-10-21): whole-tree grep for `releases\.atom` = 0, docs search = 0, no maintainer statement in community #42198/#128589/#60433/#35990/#157306; REST `#get-the-latest-release` and the 2024-11-08 events/timeline retention post are different scopes | REJECTED: no GitHub Docs page or maintainer statement describes `releases.atom`'s window/order/completeness; the only official Atom-window statement (90→30 days) covers events/timeline feeds, not repository releases, and the REST "latest" sentence covers the API, not the feed. Flip: GitHub Docs publishes a repository-release-feed page, or a GitHub-affiliated maintainer states the window/order/pagination in an official channel; re-open it and admit tier A scoped to that statement. | rejected | 2026-10-21 | 90d | — |
```

**Flip, made precise (all must be answered by the new statement, not inferred):**
1. the entry window (fixed count vs date vs activity, and whether it varies);
2. the ordering key (`updated`, `published`, or version) and tie behavior;
3. whether prereleases/drafts/tag-only entries are represented and how they are marked;
4. whether older entries are reachable (pagination/archive), and whether absence implies deletion.

Until all four are stated by GitHub, the claim remains unsourced and the row stays rejected.

**Do not register a substitute:** the REST `#get-the-latest-release` sentence is real and tier-A for the REST API, but it is **not** evidence about `releases.atom`. If L1 wants it for a non-C2 purpose, its scope must read “GitHub REST latest-release definition (non-prerelease, non-draft, `created_at`); not the Atom feed” and its teaches must not mention the feed. It cannot carry the C2 rule.

---

## 6. Advice to L1 (advisory; no production edits by this seat)

1. **Keep S042/S043 as the only C2 version-precedence sources.** My independent source hunt found no GitHub statement that could be added. The working-tree lesson's Gate rejection is correct, and its flip (“a vendor statement of feed completeness, scoped to that feed”) is unmet for GitHub.
2. **BASE `corpus/release-clock.py:657-658` over-claims in a docstring.** It asserts “GitHub Atom orders by update time and mixes module tags such as `sdk/v0.26.0` and prereleases such as `v2.2.0-rc1`”. That is an *observation* from S033–S035 and the sampled feeds, not a GitHub statement. This round cannot source it; word it as observation (or cite the feed observations), and do not let it become vendor documentation by implication.
3. **The lesson limit is right but should name the source gap.** “A REGRESSED finding needs human re-verification of the feed” is exactly the behavior my counterexamples require: crowding, bare-version prerelease, backport series, and yank are indistinguishable from a crop in a feed with no documented window/order. Add: “GitHub documents no window/order/completeness for `releases.atom`; an older observation is a stop, not an attribution.”
4. **No receipt churn is needed.** The live bodies match the BASE receipt digests exactly; no BASE row is numerically regressed. The `?page=2` identity and absent `Link`/RFC 5005 links are useful evidence that the feed offers no complete-history path, but that is an observation, not a vendor guarantee.

---

## 7. What I did NOT check (unrun ≠ pass)

- Non-English served docs (`/de`, `/es`, `/ja`, …) and any separate translations repository; only the English `github/docs` source at one commit was grepped.
- GitHub Enterprise Server (GHES) docs beyond the same repo snapshot; GHES-hosted feed behavior was not fetched.
- Any private repository feed, authenticated feed, or SAML/SSO behavior.
- Draft-release visibility in the feed (anonymous fetches cannot see drafts; the API cross-check reported `draft: 0` because drafts are hidden from anonymous callers).
- Yank behavior by mutation: no release, tag, or asset was deleted, and no feed was observed before/after a deletion. The yank analysis in §4 is docs + inference, not an executed test.
- CDN/edge staleness: only response headers were read; no cache-poisoning or conditional-request experiment was run.
- A universal window size: 8 feeds on 2026-10-21 plus one user-pasted feed in `#157306`; the 10-entry cap is an observation for this date, not proven stable over time or across all repositories. The empty WHATWG feed (S038) shows a zero-entry feed is possible.
- RFC 4287 / RFC 5005 were **not** opened this round (outside the assigned “GitHub docs or maintainer statements” class); their absence is noted only as “no `fh:`/`rel=next` appears in the bodies”, not as a spec claim.
- GitHub's internal code, `github/feedback` issues, GitHub Support tickets, and non-public statements.
- The lane's selftest/gate/measure scripts were **not** run (round contract forbids mid-flight checks); the probes imported pure functions from a BASE blob copy and one timestamped draft copy, nothing else.
- The live round-27 working tree changed several times during observation (`corpus/release-clock.py` observed digests `c3c2a70…` and `81261c…`, with a new `feed_floors` symbol); the draft may have moved again. My analysis is against BASE plus the timestamped draft noted in §4; re-check line numbers before integrating.

**Tooling:** no installs or upgrades (no pacman/uv/npm/cargo), no vault/account/handler/CDP contact, no subagents, no Git/jj mutation. Writes were limited to this report; scratch fetches were kept outside the lane (system temp) and no lane production file was modified.
