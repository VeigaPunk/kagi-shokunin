# SrcGithubReleasesApi — GitHub REST API releases endpoints (round-28 source opening)

**Verdict: ACCEPT, kind `docs`, tier A — as a bounded *release-field contract* source only. Do not cite it for the Atom-feed projection (S033–S035), Git tag-name grammar, or C2's derived-anchor binding; the page documents none of those.**

## Access receipt (2026-10-21, 14:06–14:11 UTC)

- URL `https://docs.github.com/en/rest/releases/releases` — HTTP **200**, final URL identical (no redirect).
- Profile `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)'`, the declared `curl-fsSL-compressed-v1` profile at BASE `corpus/source-fetches.tsv:14-15`.
- Title `REST API endpoints for releases - GitHub Docs`; H1 `REST API endpoints for releases`.
- Decoded body 469,800 B; normalized (rendered-text-v1) 43,580 B; capture of record
  `github-releases-raw-e.html`, raw sha256 `8592b6384be10f05888b31f91ed30cb40c4f266e065caff6f6f8015c72ae1881`,
  normalized sha256 `05a02388729ca82d49f093f4ee25917d9f47b3c56fe00091daaf52e2d53f928f`.
- Saved in `.ufo/waves/round-28/sandboxes/SrcGithubReleasesApi/`: `github-releases-raw-{a,b,c,d,e}.html`
  (plus `github-releases-text.txt`, a local extraction cited only as a sandbox artifact).
- Five captures produced **four** raw digests (`09ca7d6f…`, `1ed00b47…`, `6f34d382…` twice, `8592b638…`) but
  **one** normalized digest. Two same-profile captures (`d`,`e`) differ in exactly 63 bytes = the same 21-char
  Next.js buildId in three places (`_buildManifest.js`, `_ssgManifest.js`, inline `"buildId"`) — deployment-coupled
  chrome, not content. So the capture row
  MUST declare `decoded-http-body-volatile-v1` (BASE `corpus/source-fetches.tsv:19-22`), never
  `decoded-http-body-v1`; the raw digest is a point attestation, the normalized digest is the stable one.

## Findings (verbatim, located; counts from `corpus/rendered-text-v1.py locate`)

**F1 — `tag_name` has no documented version format.** The complete documented contract of the field is the
sentence **“The name of the tag.”** (`Create a release` → Body parameters → `tag_name`, required string; the
same sentence under `Update a release`; locate count=2). No pattern, regex, `must`, or semver requirement
appears for `tag_name` anywhere on the page. This grounds **by documented omission**, not by an explicit
“unconstrained” statement; the honest reading is “these endpoints document no version-format constraint”.

**F2 — tag creation is implicit and ungrammatical here.** `target_commitish`: “Specifies the commitish value
that determines where the Git tag is created from.” and “Can be any branch or commit SHA. Unused if the Git
tag already exists.” (count=2 / count=1). Git ref-name validity (`git check-ref-format`, GitHub “Git
references”) is documented elsewhere and was **not opened**, so this page cannot ground “GitHub never
constrains tag names”.

**F3 — `draft`/`prerelease` are author-set booleans, default `false`, never derived from the tag text.**
“true to create a draft (unpublished) release, false to create a published one.” (count=1) and “true to
identify the release as a prerelease, false to identify the release as a full release.” (count=1). No
cross-check between flag and tag string is documented, so these are all permitted: `tag_name=v1.0.0` with
`prerelease=true`; `tag_name=v1.0.0-rc1` with `prerelease=false`; `tag_name=release-2026-10` with no version
at all. **[INFERENCE: permitted because no constraint is documented; not observed API behaviour.]**

**F4 — release ≠ tag, and “latest” is repo-configured.** “This returns a list of releases, which does not
include regular Git tags that have not been associated with a release.” (count=1, `List releases`); “Drafts
and prereleases cannot be set as latest.” (count=2, `make_latest`); “The latest release is the most recent
non-prerelease, non-draft release, sorted by the created_at attribute.” (count=1, `Get the latest release`).
`created_at` is “the date of the commit used for the release” — configuration-dependent, not identity.

**F5 — release `name` and `tag_name` are independent free-form strings.** `name` = “The name of the release.”
(count=2), `tag_name` = “The name of the tag.”; the sample JSON carries both keys (`tag_name: v1.0.0`,
`name: v1.0.0`). Consequence for C2: an Atom entry **title** is not by itself a tag-name proof; anchor the
`/releases/tag/<tag>` link. **[INFERENCE: that the feed title is the release `name`; this page documents no feed.]**

**F6 — the only semver mention is `make_latest: legacy`:** “the latest release should be determined based on
the release creation date and higher semantic version.” (count=2). Parsing, canonicalisation and non-semver
fallback are undefined, so it cannot be borrowed as a version contract.

## Does it ground the C1/C2 purpose?

- **It grounds the “do not” half for both claims:** no vendor field canonicalises or validates version text;
  `draft`/`prerelease` are author assertions, not parsed properties of the version; a release is not a tag.
  That is exactly the boundary a clock needs before imposing its own canonicality rule (S042 §2) and its own
  derived-anchor binding.
- **It does not ground the C2 mechanism.** The page never mentions Atom feeds (`grep -i atom` on the rendered
  text: 0 matches; only a footer “Feeds” nav). C2 binds a `derived:` row to the version named by its
  `feed_source_id` row's *located anchor*; that mechanism must be carried by S033–S035 and the lesson.
- **REJECT condition:** if L1 wants one row to ground C2 end-to-end, this page does not and must be rejected
  for that use. It is accepted only as the release-field boundary source above.

## Duplicate check (BASE `3553d499`)

- `grep -c 'docs\.github\.com' corpus/SOURCES.md` → `0`, exit **1**; exact registered URL → `0`, exit **1**.
- `grep -rn 'docs\.github\.com' corpus/` → 0 lines, exit **1**; `grep -rn 'rest/releases' corpus/` → 0 lines, exit **1**.
- Existing GitHub URLs are `github.com/<owner>/<repo>/releases.atom` (BASE `corpus/SOURCES.md:39`, `:40`,
  `:41`, `:45`) — different host/path. **No W04 duplicate.** The lane census's own duplicate check is
  id-based (`SC_DUP`, BASE `corpus/sources-census.sh:189-191`); W04 is the fleet wrapper's normalized-URL
  warning and cannot fire on a first `docs.github.com` row.

## Proposed registry row (next free id S044; max at BASE is S043)

```
| S044 | GitHub REST API — releases endpoints, release field contract — https://docs.github.com/en/rest/releases/releases | docs | A | Release field contract only: `tag_name` is a required free-form tag string, `draft`/`prerelease` are author-set booleans, releases are distinct from plain Git tags; not the Atom feed, not tag-name grammar, not a version validator | Create a release → Body parameters (`tag_name`, `target_commitish`, `name`, `draft`, `prerelease`, `make_latest`); List releases; Get the latest release; sample JSON `tag_name`/`name`; `X-GitHub-Api-Version: 2026-03-10` in examples; title `REST API endpoints for releases`, fetched 2026-10-21 | These endpoints document no version-format constraint on `tag_name` (required; complete description “The name of the tag.”), keep `name` and `tag_name` as independent free-form fields, and make `draft`/`prerelease` author-declared booleans that only affect latest-release selection; so no vendor field canonicalises a version and a release is not a plain Git tag. Quote: “The name of the tag.” (Create/Update a release → `tag_name`; count=2). | mined | 2026-10-21 | 180d | corpus/lessons/round-28.md |
```

## Mandatory fetch provenance (16 columns; BASE `corpus/source-fetches.tsv:6-35`)

S044 is **not** in S001–S016, so an in-row `Fetch sha256:` is forbidden (`SC_INROW … inrow-pin-not-historical`,
BASE `corpus/sources-census.sh:326`) and a capture row is required (`:328`). Tab-separated:

```
S044	mined	623b3d046bf92938dfd72c91acb7175debd5baa5850a51e3d825f96aef7dd134	https://docs.github.com/en/rest/releases/releases	https://docs.github.com/en/rest/releases/releases	200	curl-fsSL-compressed-v1	2026-10-21	decoded-http-body-volatile-v1	8592b6384be10f05888b31f91ed30cb40c4f266e065caff6f6f8015c72ae1881	469800	-	The name of the tag.	rendered-text-v1	05a02388729ca82d49f093f4ee25917d9f47b3c56fe00091daaf52e2d53f928f	Create a release > Body parameters > tag_name
```

`row_identity_sha256` = `sha256("S044\tmined\thttps://docs.github.com/en/rest/releases/releases\n")`
(recomputed here; if L1 changes the status to `queued`, it becomes
`34dbb7d91e676d6950af3a7facb98a96cdd0fe9fcc62ad12ae2b1474dcb6c744`). `mined` additionally requires
`corpus/lessons/round-28.md` to carry `S044` on its `source:` line (`SC_ENTRY_CITE`, BASE `corpus/sources-census.sh:350`).

## Consequences I recommend for C1/C2 (calibration axis)

1. **Do not infer stability from any vendor flag.** Because `prerelease` is author-set (F3), an “exclude
   prereleases” feed rule keyed on the API flag and one keyed on the tag text (`-rc`) are different rules.
   S034's exclusion of `v2.2.0-rc1` is a title-text rule; keep it explicit and do not claim vendor agreement.
2. **Anchor on tag links, not titles.** `name` and `tag_name` are independent (F5), so C2's “located anchor”
   should remain the `/releases/tag/vX.Y.Z` link S033–S035 already record; the title alone is weaker.
3. **Never use `/releases/latest` as clock identity.** Latest is repo configuration (`make_latest`), excludes
   drafts/prereleases by rule, and sorts by commit date (F4) — the opposite of a feed-anchored version.

## Commands run (exit codes) and what I did NOT check

- 5 × `curl` captures (no-UA `-L`, no-UA `--compressed`, profile UA ×3): HTTP 200 each, exit 0, final URL unchanged.
- `rendered-text-v1.py digest` ×5: exit 0, normalized sha identical in all five; `locate` ×6: exit 0, counts above.
- `sha256sum` ×5 and a Python byte-diff (`d` vs `e`: 63 differing bytes, build id only): exit 0.
- Duplicate greps above: exit 1 with zero lines (no match, as required). No tools installed or upgraded.
- NOT checked: `api.github.com` (no calls, no auth; draft visibility untested); Git `check-ref-format` or
  GitHub “Git references”; the Atom feeds themselves (S033–S035 anchors read from the registry, not refetched);
  whether other locales/versions serve the same normalized text (URL is unversioned; only
  `X-GitHub-Api-Version: 2026-03-10` appears, in request examples); page history/snapshots; lane gates,
  selftests or census execution in the lane checkout — the admission controls above are read from BASE text,
  not run. No lane file written other than this report; no subagents, no host-private reads.
